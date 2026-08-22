package com.sunrise.dental.service;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.util.DBConnection;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BillingService — Invoice generation and payment processing business logic.
 *
 * Security rules:
 *   - Treatment prices are ALWAYS fetched from DB — never trusted from browser
 *   - Grand total is ALWAYS calculated server-side
 *   - Payment amount is validated against bill balance
 *
 * Design pattern: Strategy Pattern is used for payment methods
 *   (CashPaymentStrategy, CardPaymentStrategy, BankTransferPaymentStrategy).
 */
public class BillingService {

    private static final Logger logger = Logger.getLogger(BillingService.class.getName());

    private final BillDAO        billDAO;
    private final PaymentDAO     paymentDAO;
    private final AppointmentDAO appointmentDAO;
    private final TreatmentDAO   treatmentDAO;
    private final AuditService   auditService;

    // Standard consultation fee (loaded from system_settings or default)
    private static final BigDecimal CONSULTATION_FEE = new BigDecimal("1500.00");

    public BillingService() {
        this.billDAO        = DAOFactory.getBillDAO();
        this.paymentDAO     = DAOFactory.getPaymentDAO();
        this.appointmentDAO = DAOFactory.getAppointmentDAO();
        this.treatmentDAO   = DAOFactory.getTreatmentDAO();
        this.auditService   = new AuditService();
    }

    /**
     * Generate a bill for a completed appointment.
     *
     * Price sources (all server-side, never from browser form):
     *   - consultationFee → system_settings or constant
     *   - treatmentCost   → treatments.base_cost from DB
     *   - additionalCharges → validated BigDecimal from form
     *   - discountPercent → validated percentage from form (admin only)
     *   - taxPercent      → from system_settings
     *
     * @return Generated bill_id
     */
    public int generateBill(int appointmentId, BigDecimal additionalCharges,
                            String additionalDesc, BigDecimal discountPercent,
                            BigDecimal taxPercent, String notes,
                            int createdByUserId) throws ApplicationException {

        // Check appointment exists
        Appointment appt = appointmentDAO.findById(appointmentId);
        if (appt == null) {
            throw new ApplicationException("Appointment not found.");
        }

        // Check no duplicate bill
        Bill existing = billDAO.findByAppointmentId(appointmentId);
        if (existing != null) {
            throw new ApplicationException(
                "A bill already exists for this appointment (Bill #" +
                existing.getBillNumber() + ").");
        }

        // Fetch treatment price from DB — NEVER from browser
        Treatment treatment = treatmentDAO.findById(appt.getTreatmentId());
        if (treatment == null) {
            throw new ApplicationException("Treatment details not found.");
        }
        BigDecimal treatmentCost = treatment.getBaseCost();

        // Validate and sanitize inputs
        if (additionalCharges == null || additionalCharges.compareTo(BigDecimal.ZERO) < 0) {
            additionalCharges = BigDecimal.ZERO;
        }
        if (discountPercent == null || discountPercent.compareTo(BigDecimal.ZERO) < 0
                || discountPercent.compareTo(new BigDecimal("100")) > 0) {
            discountPercent = BigDecimal.ZERO;
        }
        if (taxPercent == null || taxPercent.compareTo(BigDecimal.ZERO) < 0) {
            taxPercent = BigDecimal.ZERO;
        }

        // ---- SERVER-SIDE CALCULATION ----
        BigDecimal consultFee  = CONSULTATION_FEE;
        BigDecimal subTotal    = consultFee.add(treatmentCost).add(additionalCharges);
        BigDecimal discountAmt = subTotal.multiply(discountPercent)
                                         .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        BigDecimal afterDisc   = subTotal.subtract(discountAmt);
        BigDecimal taxAmt      = afterDisc.multiply(taxPercent)
                                          .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        BigDecimal grandTotal  = afterDisc.add(taxAmt);

        // Build bill using Builder Pattern (GoF)
        Bill bill = Bill.builder()
                .billNumber(billDAO.generateBillNumber())
                .appointmentId(appointmentId)
                .patientId(appt.getPatientId())
                .consultationFee(consultFee)
                .treatmentCost(treatmentCost)
                .additionalCharges(additionalCharges, additionalDesc)
                .discount(discountPercent, discountAmt)
                .tax(taxPercent, taxAmt)
                .totals(subTotal, grandTotal)
                .status("ISSUED")
                .notes(notes)
                .dates(LocalDate.now(), LocalDate.now())
                .createdBy(createdByUserId)
                .build();

        int billId = billDAO.save(bill);

        // Save bill items
        BillItem consultItem = new BillItem();
        consultItem.setBillId(billId);
        consultItem.setItemType("CONSULTATION");
        consultItem.setDescription("Dental Consultation Fee");
        consultItem.setUnitPrice(consultFee);
        consultItem.setQuantity(BigDecimal.ONE);
        consultItem.setTotalPrice(consultFee);
        billDAO.saveBillItem(consultItem);

        BillItem trtItem = new BillItem();
        trtItem.setBillId(billId);
        trtItem.setItemType("TREATMENT");
        trtItem.setDescription(treatment.getTreatmentName());
        trtItem.setUnitPrice(treatmentCost);
        trtItem.setQuantity(BigDecimal.ONE);
        trtItem.setTotalPrice(treatmentCost);
        billDAO.saveBillItem(trtItem);

        if (additionalCharges.compareTo(BigDecimal.ZERO) > 0) {
            BillItem addItem = new BillItem();
            addItem.setBillId(billId);
            addItem.setItemType("OTHER");
            addItem.setDescription(additionalDesc != null ? additionalDesc : "Additional Charges");
            addItem.setUnitPrice(additionalCharges);
            addItem.setQuantity(BigDecimal.ONE);
            addItem.setTotalPrice(additionalCharges);
            billDAO.saveBillItem(addItem);
        }

        // Audit
        auditService.log(createdByUserId, null, "BILL_CREATED",
            "BILL", billId, "Bill " + bill.getBillNumber() +
            " generated for appointment #" + appointmentId, null, null);

        return billId;
    }

    /**
     * Process a payment against a bill.
     * Uses Strategy Pattern for payment method handling.
     *
     * @return Generated payment_id
     */
    public int processPayment(int billId, BigDecimal amount, String paymentMethod,
                              String transactionRef, String notes,
                              int receivedByUserId) throws ApplicationException {

        Bill bill = billDAO.findById(billId);
        if (bill == null) throw new ApplicationException("Bill not found.");
        if (bill.isCancelled()) throw new ApplicationException("Cannot process payment for a cancelled bill.");
        if (bill.isPaid()) throw new ApplicationException("This bill is already fully paid.");

        // Validate amount
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApplicationException("Payment amount must be greater than zero.");
        }
        if (amount.compareTo(bill.getBalanceDue()) > 0) {
            throw new ApplicationException(
                "Payment amount (LKR " + amount + ") exceeds balance due (LKR " +
                bill.getBalanceDue() + ").");
        }

        // Select payment strategy
        PaymentStrategy strategy = PaymentStrategyFactory.getStrategy(paymentMethod);
        strategy.validate(transactionRef, amount);

        // Build payment
        Payment payment = new Payment();
        payment.setPaymentNumber(paymentDAO.generatePaymentNumber());
        payment.setBillId(billId);
        payment.setPatientId(bill.getPatientId());
        payment.setAmount(amount);
        payment.setPaymentMethod(paymentMethod);
        payment.setPaymentStatus("COMPLETED");
        payment.setTransactionRef(transactionRef);
        payment.setNotes(notes);
        payment.setReceivedBy(receivedByUserId);

        int paymentId = paymentDAO.save(payment);
        // NOTE: The trg_payment_update_bill MySQL trigger automatically
        // updates bills.amount_paid, balance_due, and bill_status

        auditService.log(receivedByUserId, null, "PAYMENT_CREATED",
            "PAYMENT", paymentId,
            "Payment " + payment.getPaymentNumber() + " of LKR " + amount +
            " received for Bill #" + bill.getBillNumber(), null, null);

        return paymentId;
    }

    public Bill getBill(int billId) throws ApplicationException {
        return billDAO.findById(billId);
    }

    public List<BillItem> getBillItems(int billId) throws ApplicationException {
        return billDAO.findItemsByBillId(billId);
    }

    /**
     * Demonstrates the Decorator Pattern (GoF) in clinical billing calculations.
     * Dynamically attaches clinical enhancements (sterilization barrier packs, painless sedation,
     * specialist oversight, emergency surcharges) to a base dental treatment.
     */
    public com.sunrise.dental.decorator.DentalProcedure calculateCustomProcedureQuote(
            int treatmentId, boolean addSterilizationPack, boolean addSedation,
            boolean addSpecialistReview, boolean isEmergency) throws ApplicationException {

        Treatment treatment = treatmentDAO.findById(treatmentId);
        if (treatment == null) {
            throw new ApplicationException("Treatment not found for quote calculation.");
        }

        // 1. Concrete Component
        com.sunrise.dental.decorator.DentalProcedure procedure =
                new com.sunrise.dental.decorator.StandardDentalTreatment(treatment);

        // 2. Dynamically wrap with Decorators
        if (addSterilizationPack) {
            procedure = new com.sunrise.dental.decorator.SterilizationSafetyPackDecorator(procedure);
        }
        if (addSedation) {
            procedure = new com.sunrise.dental.decorator.SedationAnesthesiaDecorator(procedure);
        }
        if (addSpecialistReview) {
            procedure = new com.sunrise.dental.decorator.SpecialistConsultantDecorator(procedure);
        }
        if (isEmergency) {
            procedure = new com.sunrise.dental.decorator.EmergencySurchargeDecorator(procedure, 20.0);
        }

        return procedure;
    }
}
