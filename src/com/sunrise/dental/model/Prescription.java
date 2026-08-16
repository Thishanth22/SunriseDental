package com.sunrise.dental.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Prescription — Patient e-prescription record.
 */
public class Prescription {

    private int              prescriptionId;
    private String           prescriptionNumber; // RX-YYYY-000000
    private int              patientId;
    private int              dentistId;
    private Integer          appointmentId;
    private String           notes;
    private int              createdBy;
    private LocalDateTime    createdAt;

    // Denormalised display fields
    private String           patientName;
    private String           patientNumber;
    private String           dentistName;
    private String           createdByName;

    // Items list
    private List<PrescriptionItem> items = new ArrayList<>();

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int getPrescriptionId() { return prescriptionId; }
    public void setPrescriptionId(int v) { this.prescriptionId = v; }

    public String getPrescriptionNumber() { return prescriptionNumber; }
    public void setPrescriptionNumber(String v) { this.prescriptionNumber = v; }

    public int getPatientId() { return patientId; }
    public void setPatientId(int v) { this.patientId = v; }

    public int getDentistId() { return dentistId; }
    public void setDentistId(int v) { this.dentistId = v; }

    public Integer getAppointmentId() { return appointmentId; }
    public void setAppointmentId(Integer v) { this.appointmentId = v; }

    public String getNotes() { return notes; }
    public void setNotes(String v) { this.notes = v; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int v) { this.createdBy = v; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }

    // Denormalised display fields
    public String getPatientName() { return patientName; }
    public void setPatientName(String v) { this.patientName = v; }

    public String getPatientNumber() { return patientNumber; }
    public void setPatientNumber(String v) { this.patientNumber = v; }

    public String getDentistName() { return dentistName; }
    public void setDentistName(String v) { this.dentistName = v; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String v) { this.createdByName = v; }

    // Items list
    public List<PrescriptionItem> getItems() { return items; }
    public void setItems(List<PrescriptionItem> v) { this.items = v; }
    public void addItem(PrescriptionItem item) { this.items.add(item); }

    // SQL Helper for JSTL Formatting
    public java.sql.Timestamp getCreatedAtSql() {
        return createdAt != null ? java.sql.Timestamp.valueOf(createdAt) : null;
    }
}
