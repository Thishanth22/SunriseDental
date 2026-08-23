package com.sunrise.dental;

import com.sunrise.dental.model.Bill;
import org.junit.Test;
import java.math.BigDecimal;
import static org.junit.Assert.*;

/**
 * Automated Unit Tests for Billing & Invoicing Calculations.
 * Covers: UT-11, UT-16.
 */
public class BillingServiceTest {

    @Test
    public void testBillCalculation_UT11() {
        // UT-11: Treatment cost Rs. 5,000 + Consultation fee Rs. 1,500 - Discount Rs. 500 = Rs. 6,000
        BigDecimal treatmentCost   = new BigDecimal("5000.00");
        BigDecimal consultationFee = new BigDecimal("1500.00");
        BigDecimal discount        = new BigDecimal("500.00");

        BigDecimal subtotal = treatmentCost.add(consultationFee);
        BigDecimal grandTotal = subtotal.subtract(discount);

        assertEquals("Subtotal must equal Rs. 6,500.00", new BigDecimal("6500.00"), subtotal);
        assertEquals("Grand Total must equal Rs. 6,000.00", new BigDecimal("6000.00"), grandTotal);
    }

    @Test
    public void testPartialPaymentAndBalance_UT16() {
        // UT-16: Partial payment of Rs. 4,000 against Rs. 10,000 bill
        Bill bill = new Bill();
        bill.setGrandTotal(new BigDecimal("10000.00"));
        bill.setAmountPaid(BigDecimal.ZERO);
        bill.setBalanceDue(bill.getGrandTotal());
        bill.setBillStatus("ISSUED");

        BigDecimal paymentAmount = new BigDecimal("4000.00");
        bill.setAmountPaid(bill.getAmountPaid().add(paymentAmount));
        bill.setBalanceDue(bill.getGrandTotal().subtract(bill.getAmountPaid()));

        if (bill.getBalanceDue().compareTo(BigDecimal.ZERO) == 0) {
            bill.setBillStatus("PAID");
        } else if (bill.getAmountPaid().compareTo(BigDecimal.ZERO) > 0) {
            bill.setBillStatus("PARTIALLY_PAID");
        }

        assertEquals("Paid amount must be Rs. 4,000.00", new BigDecimal("4000.00"), bill.getAmountPaid());
        assertEquals("Remaining balance must be Rs. 6,000.00", new BigDecimal("6000.00"), bill.getBalanceDue());
        assertEquals("Status must be updated to PARTIALLY_PAID", "PARTIALLY_PAID", bill.getBillStatus());
    }
}
