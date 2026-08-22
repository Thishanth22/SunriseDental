package com.sunrise.dental.service;

import com.sunrise.dental.exception.ApplicationException;
import java.math.BigDecimal;

/**
 * PaymentStrategy — Strategy Pattern interface for payment methods.
 *
 * Design Pattern: Strategy
 * Purpose: Allows payment method logic to vary independently.
 *          New payment methods can be added without modifying BillingService.
 *
 * Implementations:
 *   CashPaymentStrategy       — Cash payment (no transaction ref needed)
 *   CardPaymentStrategy       — Card payment (transaction ref required)
 *   BankTransferPaymentStrategy — Bank transfer (transaction ref required)
 */
public interface PaymentStrategy {
    /**
     * Validate the payment before saving.
     * @param transactionRef Reference number (may be null for cash)
     * @param amount Payment amount
     * @throws ApplicationException if validation fails
     */
    void validate(String transactionRef, BigDecimal amount) throws ApplicationException;

    /** Display name for this payment method. */
    String getMethodName();
}
