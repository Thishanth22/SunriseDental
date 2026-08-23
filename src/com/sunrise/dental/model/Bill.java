package com.sunrise.dental.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Bill — Invoice header for a completed/in-progress appointment.
 *
 * Security note: grand_total is ALWAYS computed server-side using
 * the server's formula. Price values are NEVER accepted from the browser.
 *
 * Formula:
 *   subTotal     = consultationFee + treatmentCost + additionalCharges
 *   discountAmt  = subTotal * (discountPercent / 100)
 *   afterDisc    = subTotal - discountAmt
 *   taxAmt       = afterDisc * (taxPercent / 100)
 *   grandTotal   = afterDisc + taxAmt
 */
public class Bill {

    private int           billId;
    private String        billNumber;
    private int           appointmentId;
    private int           patientId;
    private BigDecimal    consultationFee;
    private BigDecimal    treatmentCost;
    private BigDecimal    additionalCharges;
    private String        additionalDesc;
    private BigDecimal    discountPercent;
    private BigDecimal    discountAmount;
    private BigDecimal    taxPercent;
    private BigDecimal    taxAmount;
    private BigDecimal    subTotal;
    private BigDecimal    grandTotal;
    private BigDecimal    amountPaid;
    private BigDecimal    balanceDue;
    private String        billStatus;   // DRAFT|ISSUED|PAID|PARTIALLY_PAID|CANCELLED|REFUNDED
    private String        notes;
    private LocalDate     issuedDate;
    private LocalDate     dueDate;
    private int           createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Denormalised display fields
    private String        patientName;
    private String        patientNumber;
    private String        patientPhone;
    private String        patientAddress;
    private String        appointmentNumber;
    private String        dentistName;
    private String        treatmentName;

    // -------------------------------------------------------
    // Status helpers
    // -------------------------------------------------------
    public boolean isPaid()          { return "PAID".equalsIgnoreCase(billStatus); }
    public boolean isPartiallyPaid() { return "PARTIALLY_PAID".equalsIgnoreCase(billStatus); }
    public boolean isCancelled()     { return "CANCELLED".equalsIgnoreCase(billStatus); }
    public boolean isDraft()         { return "DRAFT".equalsIgnoreCase(billStatus); }

    public boolean hasBalance() {
        return balanceDue != null && balanceDue.compareTo(BigDecimal.ZERO) > 0;
    }

    public static com.sunrise.dental.builder.BillBuilder builder() {
        return new com.sunrise.dental.builder.BillBuilder();
    }

    public String getStatusBadgeClass() {
        if (billStatus == null) return "secondary";
        return switch (billStatus.toUpperCase()) {
            case "DRAFT"           -> "secondary";
            case "ISSUED"          -> "primary";
            case "PAID"            -> "success";
            case "PARTIALLY_PAID"  -> "warning";
            case "CANCELLED"       -> "danger";
            case "REFUNDED"        -> "info";
            default                -> "light";
        };
    }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int        getBillId()                  { return billId; }
    public void       setBillId(int v)             { this.billId = v; }

    public String     getBillNumber()              { return billNumber; }
    public void       setBillNumber(String v)      { this.billNumber = v; }

    public int        getAppointmentId()           { return appointmentId; }
    public void       setAppointmentId(int v)      { this.appointmentId = v; }

    public int        getPatientId()               { return patientId; }
    public void       setPatientId(int v)          { this.patientId = v; }

    public BigDecimal getConsultationFee()             { return consultationFee; }
    public void       setConsultationFee(BigDecimal v) { this.consultationFee = v; }

    public BigDecimal getTreatmentCost()               { return treatmentCost; }
    public void       setTreatmentCost(BigDecimal v)   { this.treatmentCost = v; }

    public BigDecimal getAdditionalCharges()               { return additionalCharges; }
    public void       setAdditionalCharges(BigDecimal v)   { this.additionalCharges = v; }

    public String     getAdditionalDesc()              { return additionalDesc; }
    public void       setAdditionalDesc(String v)      { this.additionalDesc = v; }

    public BigDecimal getDiscountPercent()             { return discountPercent; }
    public void       setDiscountPercent(BigDecimal v) { this.discountPercent = v; }

    public BigDecimal getDiscountAmount()              { return discountAmount; }
    public void       setDiscountAmount(BigDecimal v)  { this.discountAmount = v; }

    public BigDecimal getTaxPercent()                  { return taxPercent; }
    public void       setTaxPercent(BigDecimal v)      { this.taxPercent = v; }

    public BigDecimal getTaxAmount()                   { return taxAmount; }
    public void       setTaxAmount(BigDecimal v)       { this.taxAmount = v; }

    public BigDecimal getSubTotal()                    { return subTotal; }
    public void       setSubTotal(BigDecimal v)        { this.subTotal = v; }

    public BigDecimal getGrandTotal()                  { return grandTotal; }
    public void       setGrandTotal(BigDecimal v)      { this.grandTotal = v; }

    public BigDecimal getAmountPaid()                  { return amountPaid; }
    public void       setAmountPaid(BigDecimal v)      { this.amountPaid = v; }

    public BigDecimal getBalanceDue()                  { return balanceDue; }
    public void       setBalanceDue(BigDecimal v)      { this.balanceDue = v; }

    public String     getBillStatus()                  { return billStatus; }
    public void       setBillStatus(String v)          { this.billStatus = v; }

    public String     getNotes()                       { return notes; }
    public void       setNotes(String v)               { this.notes = v; }

    public LocalDate  getIssuedDate()                  { return issuedDate; }
    public void       setIssuedDate(LocalDate v)       { this.issuedDate = v; }

    public java.sql.Date getIssuedDateSql() {
        return issuedDate != null ? java.sql.Date.valueOf(issuedDate) : null;
    }

    public LocalDate  getDueDate()                     { return dueDate; }
    public void       setDueDate(LocalDate v)          { this.dueDate = v; }

    public java.sql.Date getDueDateSql() {
        return dueDate != null ? java.sql.Date.valueOf(dueDate) : null;
    }

    public int        getCreatedBy()                   { return createdBy; }
    public void       setCreatedBy(int v)              { this.createdBy = v; }

    public LocalDateTime getCreatedAt()               { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()               { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    public String     getPatientName()                 { return patientName; }
    public void       setPatientName(String v)         { this.patientName = v; }

    public String     getPatientNumber()               { return patientNumber; }
    public void       setPatientNumber(String v)       { this.patientNumber = v; }

    public String     getPatientPhone()                { return patientPhone; }
    public void       setPatientPhone(String v)        { this.patientPhone = v; }

    public String     getContactNumber()               { return patientPhone; }
    public void       setContactNumber(String v)       { this.patientPhone = v; }

    public String     getPatientAddress()              { return patientAddress; }
    public void       setPatientAddress(String v)      { this.patientAddress = v; }

    public String     getAppointmentNumber()           { return appointmentNumber; }
    public void       setAppointmentNumber(String v)   { this.appointmentNumber = v; }

    public String     getDentistName()                 { return dentistName; }
    public void       setDentistName(String v)         { this.dentistName = v; }

    public String     getTreatmentName()               { return treatmentName; }
    public void       setTreatmentName(String v)       { this.treatmentName = v; }

    @Override
    public String toString() {
        return "Bill{id=" + billId + ", number='" + billNumber
                + "', total=" + grandTotal + ", status='" + billStatus + "'}";
    }
}
