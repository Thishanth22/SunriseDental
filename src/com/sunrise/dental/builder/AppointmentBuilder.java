package com.sunrise.dental.builder;

import com.sunrise.dental.model.Appointment;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * AppointmentBuilder — Builder Pattern implementation for Appointment entities.
 *
 * Design Pattern: Builder Pattern (GoF)
 * Purpose: Provides a fluent, step-by-step assembly mechanism for constructing
 *          complex Appointment objects containing mandatory and optional fields.
 * Benefits:
 *   - Avoids telescoping constructor anti-pattern.
 *   - Enforces default values (status="SCHEDULED", priority="NORMAL").
 *   - Validates and sanitizes priority and dates during construction.
 *   - Improves code readability and maintainability.
 */
public class AppointmentBuilder {

    private int           appointmentId;
    private String        appointmentNumber;
    private int           patientId;
    private int           dentistId;
    private int           treatmentId;
    private LocalDate     appointmentDate;
    private LocalTime     appointmentTime;
    private LocalTime     endTime;
    private String        status   = "SCHEDULED";
    private String        priority = "NORMAL";
    private String        notes;
    private String        cancellationReason;
    private Integer       rescheduledFrom;
    private int           createdBy;

    // Display fields
    private String        patientName;
    private String        patientNumber;
    private String        patientPhone;
    private String        patientAddress;
    private String        patientAllergies;
    private String        dentistName;
    private String        dentistSpecialization;
    private String        treatmentName;
    private int           treatmentDurationMins;

    public AppointmentBuilder() {}

    public AppointmentBuilder appointmentId(int id) {
        this.appointmentId = id;
        return this;
    }

    public AppointmentBuilder appointmentNumber(String num) {
        this.appointmentNumber = num;
        return this;
    }

    public AppointmentBuilder patientId(int id) {
        this.patientId = id;
        return this;
    }

    public AppointmentBuilder dentistId(int id) {
        this.dentistId = id;
        return this;
    }

    public AppointmentBuilder treatmentId(int id) {
        this.treatmentId = id;
        return this;
    }

    public AppointmentBuilder appointmentDate(LocalDate date) {
        this.appointmentDate = date;
        return this;
    }

    public AppointmentBuilder appointmentTime(LocalTime time) {
        this.appointmentTime = time;
        return this;
    }

    public AppointmentBuilder endTime(LocalTime time) {
        this.endTime = time;
        return this;
    }

    public AppointmentBuilder status(String status) {
        if (status != null && !status.trim().isEmpty()) {
            this.status = status.trim().toUpperCase();
        }
        return this;
    }

    public AppointmentBuilder priority(String priority) {
        if (priority != null && !priority.trim().isEmpty()) {
            String pUpper = priority.trim().toUpperCase();
            this.priority = ("URGENT".equals(pUpper) || "EMERGENCY".equals(pUpper)) ? pUpper : "NORMAL";
        } else {
            this.priority = "NORMAL";
        }
        return this;
    }

    public AppointmentBuilder notes(String notes) {
        this.notes = notes;
        return this;
    }

    public AppointmentBuilder cancellationReason(String reason) {
        this.cancellationReason = reason;
        return this;
    }

    public AppointmentBuilder rescheduledFrom(Integer fromId) {
        this.rescheduledFrom = fromId;
        return this;
    }

    public AppointmentBuilder createdBy(int userId) {
        this.createdBy = userId;
        return this;
    }

    public AppointmentBuilder patientName(String name) {
        this.patientName = name;
        return this;
    }

    public AppointmentBuilder patientNumber(String num) {
        this.patientNumber = num;
        return this;
    }

    public AppointmentBuilder patientPhone(String phone) {
        this.patientPhone = phone;
        return this;
    }

    public AppointmentBuilder patientAddress(String address) {
        this.patientAddress = address;
        return this;
    }

    public AppointmentBuilder patientAllergies(String allergies) {
        this.patientAllergies = allergies;
        return this;
    }

    public AppointmentBuilder dentistName(String name) {
        this.dentistName = name;
        return this;
    }

    public AppointmentBuilder dentistSpecialization(String spec) {
        this.dentistSpecialization = spec;
        return this;
    }

    public AppointmentBuilder treatmentName(String name) {
        this.treatmentName = name;
        return this;
    }

    public AppointmentBuilder treatmentDurationMins(int mins) {
        this.treatmentDurationMins = mins;
        return this;
    }

    /**
     * Builds and returns the configured Appointment entity.
     * @return Fully assembled Appointment instance
     */
    public Appointment build() {
        Appointment a = new Appointment();
        a.setAppointmentId(this.appointmentId);
        a.setAppointmentNumber(this.appointmentNumber);
        a.setPatientId(this.patientId);
        a.setDentistId(this.dentistId);
        a.setTreatmentId(this.treatmentId);
        a.setAppointmentDate(this.appointmentDate);
        a.setAppointmentTime(this.appointmentTime);
        a.setEndTime(this.endTime);
        a.setStatus(this.status);
        a.setPriority(this.priority);
        a.setNotes(this.notes);
        a.setCancellationReason(this.cancellationReason);
        a.setRescheduledFrom(this.rescheduledFrom);
        a.setCreatedBy(this.createdBy);

        // Display properties
        a.setPatientName(this.patientName);
        a.setPatientNumber(this.patientNumber);
        a.setPatientPhone(this.patientPhone);
        a.setPatientAddress(this.patientAddress);
        a.setPatientAllergies(this.patientAllergies);
        a.setDentistName(this.dentistName);
        a.setDentistSpecialization(this.dentistSpecialization);
        a.setTreatmentName(this.treatmentName);
        a.setTreatmentDurationMins(this.treatmentDurationMins);

        return a;
    }
}
