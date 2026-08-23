package com.sunrise.dental;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.service.PaymentStrategy;
import com.sunrise.dental.service.PaymentStrategyFactory;
import org.junit.Test;
import java.math.BigDecimal;
import static org.junit.Assert.*;

/**
 * Automated Unit Tests for Strategy Pattern Payment Processing.
 * Covers: UT-12, UT-13, UT-14, UT-15.
 */
public class PaymentServiceTest {

    @Test
    public void testCashPayment_UT12() throws ApplicationException {
        // UT-12: Cash payment processing without requiring transaction reference
        PaymentStrategy strategy = PaymentStrategyFactory.getStrategy("CASH");
        assertNotNull("Cash strategy must be resolved", strategy);
        assertEquals("CASH", strategy.getMethodName());

        // Cash does not require transactionRef (null or empty is valid)
        strategy.validate(null, new BigDecimal("6000.00"));
        strategy.validate("", new BigDecimal("1500.00"));
    }

    @Test
    public void testCardPaymentWithValidRef_UT13() throws ApplicationException {
        // UT-13: Card payment processing with valid approval reference
        PaymentStrategy strategy = PaymentStrategyFactory.getStrategy("CARD");
        assertNotNull("Card strategy must be resolved", strategy);
        assertEquals("CARD", strategy.getMethodName());

        // Valid card reference
        strategy.validate("AUTH-99882", new BigDecimal("4500.00"));
    }

    @Test(expected = ApplicationException.class)
    public void testInvalidCardPaymentEmptyRef_UT14() throws ApplicationException {
        // UT-14: Card payment rejected when transaction reference is missing
        PaymentStrategy strategy = PaymentStrategyFactory.getStrategy("CARD");
        // Must throw ApplicationException
        strategy.validate("   ", new BigDecimal("4500.00"));
    }

    @Test
    public void testBankTransferPayment_UT15() throws ApplicationException {
        // UT-15: Bank transfer processing requiring transfer slip reference
        PaymentStrategy strategy = PaymentStrategyFactory.getStrategy("BANK_TRANSFER");
        assertNotNull("Bank transfer strategy must be resolved", strategy);
        assertEquals("BANK_TRANSFER", strategy.getMethodName());

        strategy.validate("SLIP-TX-88219", new BigDecimal("8000.00"));
    }
}
