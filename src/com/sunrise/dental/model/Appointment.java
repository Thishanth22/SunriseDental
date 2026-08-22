package com.sunrise.dental.model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

/**
 * Appointment — Core scheduling entity.
 * Status lifecycle: SCHEDULED → CONFIRMED → COMPLETED
 *                                        → CANCELLED
 *                                        → NO_SHOW
 *                  SCHEDULED → RESCHEDULED (old) + new SCHEDULED
 */
public class Appointment {

    private int           appointmentId;
    private String        appointmentNumber;
    private int           patientId;
    private int           dentistId;
    private int           treatmentId;
    private LocalDate     appointmentDate;
    private LocalTime     appointmentTime;
    private LocalTime     endTime;
    private String        status;         // SCHEDULED|CONFIRMED|COMPLETED|CANCELLED|NO_SHOW|RESCHEDULED
    private String        priority;       // NORMAL|URGENT|EMERGENCY
    private String        notes;
    private String        cancellationReason;
    private Integer       rescheduledFrom;  // previous appointment_id
    private int           createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // -------------------------------------------------------
    // Denormalised display fields (populated via JOIN)
    // -------------------------------------------------------
    private String        patientName;
    private String        patientNumber;
    private String        patientPhone;
    private String        patientAddress;
    private String        patientAllergies;
    private String        dentistName;
    private String        dentistSpecialization;
    private String        treatmentName;
    private int           treatmentDurationMins;

    public String getPatientAllergies() { return patientAllergies; }
    public void setPatientAllergies(String v) { this.patientAllergies = v; }

    // -------------------------------------------------------
    // Status helpers
    // -------------------------------------------------------
    public boolean isScheduled()   { return "SCHEDULED".equalsIgnoreCase(status); }
    public boolean isConfirmed()   { return "CONFIRMED".equalsIgnoreCase(status); }
    public boolean isCompleted()   { return "COMPLETED".equalsIgnoreCase(status); }
    public boolean isCancelled()   { return "CANCELLED".equalsIgnoreCase(status); }
    public boolean isNoShow()      { return "NO_SHOW".equalsIgnoreCase(status); }
    public boolean isRescheduled() { return "RESCHEDULED".equalsIgnoreCase(status); }

    public boolean isEditable() {
        return isScheduled() || isConfirmed();
    }

    public static com.sunrise.dental.builder.AppointmentBuilder builder() {
        return new com.sunrise.dental.builder.AppointmentBuilder();
    }

    public String getStatusBadgeClass() {
        if (status == null) return "secondary";
        return switch (status.toUpperCase()) {
            case "SCHEDULED"   -> "primary";
            case "CONFIRMED"   -> "info";
            case "COMPLETED"   -> "success";
            case "CANCELLED"   -> "danger";
            case "NO_SHOW"     -> "warning";
            case "RESCHEDULED" -> "secondary";
            default            -> "light";
        };
    }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int        getAppointmentId()              { return appointmentId; }
    public void       setAppointmentId(int v)         { this.appointmentId = v; }

    public String     getAppointmentNumber()          { return appointmentNumber; }
    public void       setAppointmentNumber(String v)  { this.appointmentNumber = v; }

    public int        getPatientId()                  { return patientId; }
    public void       setPatientId(int v)             { this.patientId = v; }

    public int        getDentistId()                  { return dentistId; }
    public void       setDentistId(int v)             { this.dentistId = v; }

    public int        getTreatmentId()                { return treatmentId; }
    public void       setTreatmentId(int v)           { this.treatmentId = v; }

    public LocalDate  getAppointmentDate()            { return appointmentDate; }
    public void       setAppointmentDate(LocalDate v) { this.appointmentDate = v; }

    public LocalTime  getAppointmentTime()            { return appointmentTime; }
    public void       setAppointmentTime(LocalTime v) { this.appointmentTime = v; }

    public LocalTime  getEndTime()                    { return endTime; }
    public void       setEndTime(LocalTime v)         { this.endTime = v; }

    public String     getStatus()                     { return status; }
    public void       setStatus(String v)             { this.status = v; }

    public String     getPriority()                   { return priority; }
    public void       setPriority(String v)           { this.priority = v; }

    public String     getNotes()                      { return notes; }
    public void       setNotes(String v)              { this.notes = v; }

    public String     getCancellationReason()             { return cancellationReason; }
    public void       setCancellationReason(String v)     { this.cancellationReason = v; }

    public Integer    getRescheduledFrom()             { return rescheduledFrom; }
    public void       setRescheduledFrom(Integer v)    { this.rescheduledFrom = v; }

    public int        getCreatedBy()                  { return createdBy; }
    public void       setCreatedBy(int v)             { this.createdBy = v; }

    public LocalDateTime getCreatedAt()               { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()               { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    // Denormalised display fields
    public String     getPatientName()               { return patientName; }
    public void       setPatientName(String v)       { this.patientName = v; }

    public String     getPatientNumber()             { return patientNumber; }
    public void       setPatientNumber(String v)     { this.patientNumber = v; }

    public String     getPatientPhone()              { return patientPhone; }
    public void       setPatientPhone(String v)      { this.patientPhone = v; }

    public String     getPatientAddress()            { return patientAddress; }
    public void       setPatientAddress(String v)    { this.patientAddress = v; }

    public String     getDentistName()               { return dentistName; }
    public void       setDentistName(String v)       { this.dentistName = v; }

    public String     getDentistSpecialization()         { return dentistSpecialization; }
    public void       setDentistSpecialization(String v) { this.dentistSpecialization = v; }

    public String     getTreatmentName()             { return treatmentName; }
    public void       setTreatmentName(String v)     { this.treatmentName = v; }

    public int        getTreatmentDurationMins()          { return treatmentDurationMins; }
    public void       setTreatmentDurationMins(int v)     { this.treatmentDurationMins = v; }

    // JSTL Formatting Helpers for Java 8 Date/Time
    public java.sql.Date getAppointmentDateSql() {
        return appointmentDate != null ? java.sql.Date.valueOf(appointmentDate) : null;
    }
    public java.sql.Time getAppointmentTimeSql() {
        return appointmentTime != null ? java.sql.Time.valueOf(appointmentTime) : null;
    }
    public java.sql.Time getEndTimeSql() {
        return endTime != null ? java.sql.Time.valueOf(endTime) : null;
    }

    @Override
    public String toString() {
        return "Appointment{id=" + appointmentId
                + ", number='" + appointmentNumber
                + "', date=" + appointmentDate
                + ", status='" + status + "'}";
    }
}
