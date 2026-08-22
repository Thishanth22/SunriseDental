package com.sunrise.dental.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Payment — Individual payment transaction linked to a Bill.
 * Methods: CASH, CARD, BANK_TRANSFER, ONLINE, CHEQUE
 * Statuses: PENDING, COMPLETED, FAILED, REFUNDED
 */
public class Payment {

    private int           paymentId;
    private String        paymentNumber;
    private int           billId;
    private int           patientId;
    private BigDecimal    amount;
    private String        paymentMethod;   // CASH|CARD|BANK_TRANSFER|ONLINE|CHEQUE
    private String        paymentStatus;   // PENDING|COMPLETED|FAILED|REFUNDED
    private String        transactionRef;
    private LocalDateTime paymentDate;
    private String        notes;
    private int           receivedBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Denormalised display fields
    private String        billNumber;
    private String        patientName;
    private String        receivedByName;

    // -------------------------------------------------------
    // Status helpers
    // -------------------------------------------------------
    public boolean isCompleted() { return "COMPLETED".equalsIgnoreCase(paymentStatus); }
    public boolean isPending()   { return "PENDING".equalsIgnoreCase(paymentStatus); }
    public boolean isRefunded()  { return "REFUNDED".equalsIgnoreCase(paymentStatus); }

    public String getStatusBadgeClass() {
        if (paymentStatus == null) return "secondary";
        return switch (paymentStatus.toUpperCase()) {
            case "COMPLETED" -> "success";
            case "PENDING"   -> "warning";
            case "FAILED"    -> "danger";
            case "REFUNDED"  -> "info";
            default          -> "secondary";
        };
    }

    public String getMethodIcon() {
        if (paymentMethod == null) return "bi-cash";
        return switch (paymentMethod.toUpperCase()) {
            case "CASH"          -> "bi-cash-coin";
            case "CARD"          -> "bi-credit-card";
            case "BANK_TRANSFER" -> "bi-bank";
            case "ONLINE"        -> "bi-globe";
            case "CHEQUE"        -> "bi-file-text";
            default              -> "bi-currency-exchange";
        };
    }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int        getPaymentId()               { return paymentId; }
    public void       setPaymentId(int v)          { this.paymentId = v; }

    public String     getPaymentNumber()           { return paymentNumber; }
    public void       setPaymentNumber(String v)   { this.paymentNumber = v; }

    public int        getBillId()                  { return billId; }
    public void       setBillId(int v)             { this.billId = v; }

    public int        getPatientId()               { return patientId; }
    public void       setPatientId(int v)          { this.patientId = v; }

    public BigDecimal getAmount()                  { return amount; }
    public void       setAmount(BigDecimal v)      { this.amount = v; }

    public String     getPaymentMethod()           { return paymentMethod; }
    public void       setPaymentMethod(String v)   { this.paymentMethod = v; }

    public String     getPaymentStatus()           { return paymentStatus; }
    public void       setPaymentStatus(String v)   { this.paymentStatus = v; }

    public String     getTransactionRef()          { return transactionRef; }
    public void       setTransactionRef(String v)  { this.transactionRef = v; }

    public LocalDateTime getPaymentDate()           { return paymentDate; }
    public void          setPaymentDate(LocalDateTime v){ this.paymentDate = v; }

    public String     getNotes()                   { return notes; }
    public void       setNotes(String v)           { this.notes = v; }

    public int        getReceivedBy()              { return receivedBy; }
    public void       setReceivedBy(int v)         { this.receivedBy = v; }

    public LocalDateTime getCreatedAt()               { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()               { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    public String     getBillNumber()              { return billNumber; }
    public void       setBillNumber(String v)      { this.billNumber = v; }

    public String     getPatientName()             { return patientName; }
    public void       setPatientName(String v)     { this.patientName = v; }

    public String     getReceivedByName()          { return receivedByName; }
    public void       setReceivedByName(String v)  { this.receivedByName = v; }

    @Override
    public String toString() {
        return "Payment{id=" + paymentId + ", number='" + paymentNumber
                + "', amount=" + amount + ", method='" + paymentMethod
                + "', status='" + paymentStatus + "'}";
    }
}
