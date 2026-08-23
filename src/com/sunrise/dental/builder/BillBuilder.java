package com.sunrise.dental.builder;

import com.sunrise.dental.model.Bill;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

/**
 * BillBuilder — Builder Pattern implementation for financial Bill entities.
 *
 * Design Pattern: Builder Pattern (GoF)
 * Purpose: Separates the complex calculation and assembly of invoice/bill data
 *          into a readable, self-validating, fluent builder.
 * Benefits:
 *   - Encapsulates multi-step financial math (subtotal, discount, tax, balance).
 *   - Ensures scale and rounding consistency across all monetary calculations.
 *   - Guarantees non-null numeric defaults (BigDecimal.ZERO).
 */
public class BillBuilder {

    private int        billId;
    private String     billNumber;
    private int        appointmentId;
    private int        patientId;
    private BigDecimal consultationFee   = BigDecimal.ZERO;
    private BigDecimal treatmentCost     = BigDecimal.ZERO;
    private BigDecimal additionalCharges = BigDecimal.ZERO;
    private String     additionalDesc;
    private BigDecimal discountPercent   = BigDecimal.ZERO;
    private BigDecimal discountAmount    = BigDecimal.ZERO;
    private BigDecimal taxPercent        = BigDecimal.ZERO;
    private BigDecimal taxAmount         = BigDecimal.ZERO;
    private BigDecimal subTotal          = BigDecimal.ZERO;
    private BigDecimal grandTotal        = BigDecimal.ZERO;
    private BigDecimal amountPaid        = BigDecimal.ZERO;
    private BigDecimal balanceDue        = BigDecimal.ZERO;
    private String     billStatus        = "ISSUED";
    private String     notes;
    private LocalDate  issuedDate        = LocalDate.now();
    private LocalDate  dueDate           = LocalDate.now();
    private int        createdBy;

    // Display fields
    private String     patientName;
    private String     patientNumber;
    private String     patientPhone;
    private String     patientAddress;
    private String     appointmentNumber;
    private String     dentistName;
    private String     treatmentName;

    public BillBuilder() {}

    public BillBuilder billId(int id) {
        this.billId = id;
        return this;
    }

    public BillBuilder billNumber(String num) {
        this.billNumber = num;
        return this;
    }

    public BillBuilder appointmentId(int id) {
        this.appointmentId = id;
        return this;
    }

    public BillBuilder patientId(int id) {
        this.patientId = id;
        return this;
    }

    public BillBuilder consultationFee(BigDecimal fee) {
        this.consultationFee = (fee != null) ? fee : BigDecimal.ZERO;
        return this;
    }

    public BillBuilder treatmentCost(BigDecimal cost) {
        this.treatmentCost = (cost != null) ? cost : BigDecimal.ZERO;
        return this;
    }

    public BillBuilder additionalCharges(BigDecimal charges, String description) {
        this.additionalCharges = (charges != null) ? charges : BigDecimal.ZERO;
        this.additionalDesc = description;
        return this;
    }

    public BillBuilder discount(BigDecimal percent, BigDecimal amount) {
        this.discountPercent = (percent != null) ? percent : BigDecimal.ZERO;
        this.discountAmount = (amount != null) ? amount : BigDecimal.ZERO;
        return this;
    }

    public BillBuilder tax(BigDecimal percent, BigDecimal amount) {
        this.taxPercent = (percent != null) ? percent : BigDecimal.ZERO;
        this.taxAmount = (amount != null) ? amount : BigDecimal.ZERO;
        return this;
    }

    public BillBuilder totals(BigDecimal subTotal, BigDecimal grandTotal) {
        this.subTotal = (subTotal != null) ? subTotal : BigDecimal.ZERO;
        this.grandTotal = (grandTotal != null) ? grandTotal : BigDecimal.ZERO;
        this.balanceDue = this.grandTotal.subtract(this.amountPaid);
        return this;
    }

    public BillBuilder amountPaid(BigDecimal paid) {
        this.amountPaid = (paid != null) ? paid : BigDecimal.ZERO;
        if (this.grandTotal != null) {
            this.balanceDue = this.grandTotal.subtract(this.amountPaid);
        }
        return this;
    }

    public BillBuilder status(String status) {
        if (status != null && !status.trim().isEmpty()) {
            this.billStatus = status.trim().toUpperCase();
        }
        return this;
    }

    public BillBuilder notes(String notes) {
        this.notes = notes;
        return this;
    }

    public BillBuilder dates(LocalDate issued, LocalDate due) {
        if (issued != null) this.issuedDate = issued;
        if (due != null)    this.dueDate = due;
        return this;
    }

    public BillBuilder createdBy(int userId) {
        this.createdBy = userId;
        return this;
    }

    public BillBuilder patientInfo(String name, String number) {
        this.patientName = name;
        this.patientNumber = number;
        return this;
    }

    public BillBuilder patientPhone(String phone) {
        this.patientPhone = phone;
        return this;
    }

    public BillBuilder patientAddress(String address) {
        this.patientAddress = address;
        return this;
    }

    public BillBuilder patientInfo(String name, String number, String phone, String address) {
        this.patientName = name;
        this.patientNumber = number;
        this.patientPhone = phone;
        this.patientAddress = address;
        return this;
    }

    public BillBuilder appointmentInfo(String number, String dentist, String treatment) {
        this.appointmentNumber = number;
        this.dentistName = dentist;
        this.treatmentName = treatment;
        return this;
    }

    /**
     * Automatically computes subtotal, discount, tax, grand total, and balance due
     * according to the clinic's standard pricing policy.
     *
     * Formula:
     *   subTotal   = consultationFee + treatmentCost + additionalCharges
     *   discountAmt= subTotal * (discountPercent / 100)
     *   afterDisc  = subTotal - discountAmt
     *   taxAmt     = afterDisc * (taxPercent / 100)
     *   grandTotal = afterDisc + taxAmt
     *   balanceDue = grandTotal - amountPaid
     */
    public BillBuilder calculateTotals() {
        this.subTotal = this.consultationFee.add(this.treatmentCost).add(this.additionalCharges);
        
        if (this.discountPercent.compareTo(BigDecimal.ZERO) > 0) {
            this.discountAmount = this.subTotal.multiply(this.discountPercent)
                    .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        } else {
            this.discountAmount = BigDecimal.ZERO;
        }

        BigDecimal afterDiscount = this.subTotal.subtract(this.discountAmount);

        if (this.taxPercent.compareTo(BigDecimal.ZERO) > 0) {
            this.taxAmount = afterDiscount.multiply(this.taxPercent)
                    .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        } else {
            this.taxAmount = BigDecimal.ZERO;
        }

        this.grandTotal = afterDiscount.add(this.taxAmount);
        this.balanceDue = this.grandTotal.subtract(this.amountPaid);
        return this;
    }

    /**
     * Builds and returns the configured Bill instance.
     * @return Fully assembled Bill entity
     */
    public Bill build() {
        Bill b = new Bill();
        b.setBillId(this.billId);
        b.setBillNumber(this.billNumber);
        b.setAppointmentId(this.appointmentId);
        b.setPatientId(this.patientId);
        b.setConsultationFee(this.consultationFee);
        b.setTreatmentCost(this.treatmentCost);
        b.setAdditionalCharges(this.additionalCharges);
        b.setAdditionalDesc(this.additionalDesc);
        b.setDiscountPercent(this.discountPercent);
        b.setDiscountAmount(this.discountAmount);
        b.setTaxPercent(this.taxPercent);
        b.setTaxAmount(this.taxAmount);
        b.setSubTotal(this.subTotal);
        b.setGrandTotal(this.grandTotal);
        b.setAmountPaid(this.amountPaid);
        b.setBalanceDue(this.balanceDue);
        b.setBillStatus(this.billStatus);
        b.setNotes(this.notes);
        b.setIssuedDate(this.issuedDate);
        b.setDueDate(this.dueDate);
        b.setCreatedBy(this.createdBy);

        b.setPatientName(this.patientName);
        b.setPatientNumber(this.patientNumber);
        b.setPatientPhone(this.patientPhone);
        b.setPatientAddress(this.patientAddress);
        b.setAppointmentNumber(this.appointmentNumber);
        b.setDentistName(this.dentistName);
        b.setTreatmentName(this.treatmentName);

        return b;
    }
}
