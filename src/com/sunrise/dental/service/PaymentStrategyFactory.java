package com.sunrise.dental.service;

import com.sunrise.dental.exception.ApplicationException;
import java.math.BigDecimal;

// ============================================================
// Strategy Pattern Implementations — one class per method
// ============================================================

/**
 * CashPaymentStrategy
 * Cash payments do not require a transaction reference.
 */
class CashPaymentStrategy implements PaymentStrategy {
    @Override
    public void validate(String transactionRef, BigDecimal amount) throws ApplicationException {
        // Cash: no transaction reference required
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApplicationException("Cash payment amount must be greater than zero.");
        }
    }
    @Override
    public String getMethodName() { return "CASH"; }
}

/**
 * CardPaymentStrategy
 * Card payments require a valid transaction reference number.
 */
class CardPaymentStrategy implements PaymentStrategy {
    @Override
    public void validate(String transactionRef, BigDecimal amount) throws ApplicationException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApplicationException("Card payment amount must be greater than zero.");
        }
        if (transactionRef == null || transactionRef.trim().length() < 4) {
            throw new ApplicationException(
                "Card payment requires a valid transaction/approval reference number.");
        }
    }
    @Override
    public String getMethodName() { return "CARD"; }
}

/**
 * BankTransferPaymentStrategy
 * Bank transfers require a transaction/reference number.
 */
class BankTransferPaymentStrategy implements PaymentStrategy {
    @Override
    public void validate(String transactionRef, BigDecimal amount) throws ApplicationException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApplicationException("Bank transfer amount must be greater than zero.");
        }
        if (transactionRef == null || transactionRef.trim().isEmpty()) {
            throw new ApplicationException(
                "Bank transfer requires a transaction reference number.");
        }
    }
    @Override
    public String getMethodName() { return "BANK_TRANSFER"; }
}

/**
 * OnlinePaymentStrategy
 * Online payments require a transaction reference.
 */
class OnlinePaymentStrategy implements PaymentStrategy {
    @Override
    public void validate(String transactionRef, BigDecimal amount) throws ApplicationException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ApplicationException("Online payment amount must be greater than zero.");
        }
        if (transactionRef == null || transactionRef.trim().isEmpty()) {
            throw new ApplicationException("Online payment requires a transaction reference.");
        }
    }
    @Override
    public String getMethodName() { return "ONLINE"; }
}

/**
 * PaymentStrategyFactory — Factory Pattern for creating payment strategies.
 *
 * Design Pattern: Factory Method
 * Purpose: Decouples BillingService from concrete strategy implementations.
 *          Adding a new payment method = add a new strategy + register here.
 */
public class PaymentStrategyFactory {

    private PaymentStrategyFactory() {}

    /**
     * Return the appropriate PaymentStrategy for the given method name.
     * @param method  Payment method string (CASH, CARD, BANK_TRANSFER, ONLINE, CHEQUE)
     * @return Corresponding PaymentStrategy implementation
     * @throws ApplicationException if method is not recognised
     */
    public static PaymentStrategy getStrategy(String method) throws ApplicationException {
        if (method == null) throw new ApplicationException("Payment method is required.");
        return switch (method.toUpperCase()) {
            case "CASH"          -> new CashPaymentStrategy();
            case "CARD"          -> new CardPaymentStrategy();
            case "BANK_TRANSFER" -> new BankTransferPaymentStrategy();
            case "ONLINE"        -> new OnlinePaymentStrategy();
            case "CHEQUE"        -> new BankTransferPaymentStrategy(); // same validation
            default -> throw new ApplicationException(
                "Unsupported payment method: " + method + ". " +
                "Accepted: CASH, CARD, BANK_TRANSFER, ONLINE, CHEQUE.");
        };
    }
}
