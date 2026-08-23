package com.sunrise.dental.service;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Appointment;
import com.sunrise.dental.model.Dentist;
import com.sunrise.dental.model.Treatment;
import com.sunrise.dental.util.DateUtil;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.logging.Logger;

/**
 * AppointmentService — All appointment booking business rules.
 *
 * Business rules enforced:
 *   1. Appointment date must not be in the past (non-admin)
 *   2. Dentist must be active
 *   3. Dentist must be available on the day of week
 *   4. Appointment time must be within dentist's working hours
 *   5. No double-booking (overlap check via DAO)
 *   6. Appointment number auto-generated
 *
 * Design pattern: Service Layer — keeps Servlets thin and business rules testable.
 */
public class AppointmentService {

    private static final Logger logger = Logger.getLogger(AppointmentService.class.getName());

    private final AppointmentDAO appointmentDAO;
    private final DentistDAO     dentistDAO;
    private final PatientDAO     patientDAO;
    private final TreatmentDAO   treatmentDAO;
    private final AuditService   auditService;

    public AppointmentService() {
        this.appointmentDAO = DAOFactory.getAppointmentDAO();
        this.dentistDAO     = DAOFactory.getDentistDAO();
        this.patientDAO     = DAOFactory.getPatientDAO();
        this.treatmentDAO   = DAOFactory.getTreatmentDAO();
        this.auditService   = new AuditService();
    }

    // Testability constructor
    public AppointmentService(AppointmentDAO aDao, DentistDAO dDao,
                              PatientDAO pDao, TreatmentDAO tDao, AuditService audit) {
        this.appointmentDAO = aDao;
        this.dentistDAO     = dDao;
        this.patientDAO     = pDao;
        this.treatmentDAO   = tDao;
        this.auditService   = audit;
    }

    /**
     * Book a new appointment.
     *
     * @param appointment  Appointment object populated from form data
     * @param createdByUserId  User performing the booking
     * @param isAdmin      Admins may book past dates
     * @return Generated appointment_id
     */
    public int bookAppointment(Appointment appointment, int createdByUserId,
                               boolean isAdmin) throws ApplicationException {

        // ----- Validate basic fields -----
        if (appointment.getPatientId() <= 0)  throw new ApplicationException("Patient is required.");
        if (appointment.getDentistId() <= 0)  throw new ApplicationException("Dentist is required.");
        if (appointment.getTreatmentId() <= 0) throw new ApplicationException("Treatment is required.");
        if (appointment.getAppointmentDate() == null) throw new ApplicationException("Appointment date is required.");
        if (appointment.getAppointmentTime() == null) throw new ApplicationException("Appointment time is required.");

        // ----- Business Rule 1: Date must not be in the past -----
        if (!isAdmin && appointment.getAppointmentDate().isBefore(LocalDate.now())) {
            throw new ApplicationException(
                "Appointment date cannot be in the past. Please select a valid future date.");
        }

        // ----- Business Rule 2: Dentist must be active -----
        Dentist dentist = dentistDAO.findById(appointment.getDentistId());
        if (dentist == null || !dentist.isActive()) {
            throw new ApplicationException(
                "The selected dentist is not currently available.");
        }

        // ----- Business Rule 3: Dentist must be available on that day -----
        validateDentistDayAvailability(dentist, appointment.getAppointmentDate());

        // ----- Business Rule 4: Time within working hours -----
        LocalTime apptTime = appointment.getAppointmentTime();
        if (apptTime.isBefore(dentist.getWorkStartTime()) ||
            apptTime.isAfter(dentist.getWorkEndTime())) {
            throw new ApplicationException(
                "The selected time is outside the dentist's working hours (" +
                dentist.getWorkStartTime() + " - " + dentist.getWorkEndTime() + ").");
        }

        // ----- Compute end time from treatment duration -----
        Treatment treatment = treatmentDAO.findById(appointment.getTreatmentId());
        if (treatment == null) throw new ApplicationException("Selected treatment not found.");

        LocalTime endTime = apptTime.plusMinutes(treatment.getDurationMins());
        appointment.setEndTime(endTime);

        if (endTime.isAfter(dentist.getWorkEndTime())) {
            throw new ApplicationException(
                "Treatment duration (" + treatment.getDurationMins() +
                " mins) exceeds the dentist's working hours (shift ends at " +
                dentist.getWorkEndTime() + "). Please select an earlier appointment time.");
        }

        // ----- Business Rule 5: Double-booking check -----
        boolean conflict = appointmentDAO.hasConflict(
            appointment.getDentistId(),
            appointment.getAppointmentDate(),
            apptTime,
            endTime,
            0   // 0 = new booking, no exclusion
        );
        if (conflict) {
            throw new ApplicationException(
                "The selected dentist is unavailable at this time. " +
                "Please select another appointment time or a different dentist.");
        }

        boolean patientConflict = appointmentDAO.hasPatientConflict(
            appointment.getPatientId(),
            appointment.getAppointmentDate(),
            apptTime,
            endTime,
            0
        );
        if (patientConflict) {
            throw new ApplicationException(
                "The patient already has another appointment scheduled that overlaps with this slot.");
        }

        // ----- Business Rule 6: Generate appointment number -----
        String apptNumber = appointmentDAO.generateAppointmentNumber();
        appointment.setAppointmentNumber(apptNumber);
        appointment.setCreatedBy(createdByUserId);
        appointment.setStatus("SCHEDULED");

        int id = appointmentDAO.save(appointment);

        // Audit
        auditService.log(createdByUserId, null, "APPOINTMENT_CREATED",
            "APPOINTMENT", id, "Appointment " + apptNumber + " created for patient #" +
            appointment.getPatientId(), null, null);

        return id;
    }

    /**
     * Update (reschedule) an existing appointment.
     */
    public void updateAppointment(Appointment appointment, int updatedByUserId,
                                  boolean isAdmin) throws ApplicationException {

        Appointment existing = appointmentDAO.findById(appointment.getAppointmentId());
        if (existing == null) throw new ApplicationException("Appointment not found.");
        if (!existing.isEditable()) {
            throw new ApplicationException(
                "Only SCHEDULED or CONFIRMED appointments can be modified.");
        }

        // Validate new date/time
        if (!isAdmin && appointment.getAppointmentDate().isBefore(LocalDate.now())) {
            throw new ApplicationException("Cannot reschedule to a past date.");
        }

        Dentist dentist = dentistDAO.findById(appointment.getDentistId());
        if (dentist == null || !dentist.isActive()) {
            throw new ApplicationException("Selected dentist is not available.");
        }
        validateDentistDayAvailability(dentist, appointment.getAppointmentDate());

        Treatment treatment = treatmentDAO.findById(appointment.getTreatmentId());
        if (treatment == null) throw new ApplicationException("Treatment not found.");

        LocalTime apptTime = appointment.getAppointmentTime();
        if (apptTime.isBefore(dentist.getWorkStartTime()) ||
            apptTime.isAfter(dentist.getWorkEndTime())) {
            throw new ApplicationException(
                "The selected time is outside the dentist's working hours (" +
                dentist.getWorkStartTime() + " - " + dentist.getWorkEndTime() + ").");
        }

        LocalTime endTime = apptTime.plusMinutes(treatment.getDurationMins());
        appointment.setEndTime(endTime);

        if (endTime.isAfter(dentist.getWorkEndTime())) {
            throw new ApplicationException(
                "Treatment duration (" + treatment.getDurationMins() +
                " mins) exceeds the dentist's working hours (shift ends at " +
                dentist.getWorkEndTime() + "). Please select an earlier appointment time.");
        }

        boolean conflict = appointmentDAO.hasConflict(
            appointment.getDentistId(),
            appointment.getAppointmentDate(),
            appointment.getAppointmentTime(),
            endTime,
            appointment.getAppointmentId()   // exclude self
        );
        if (conflict) {
            throw new ApplicationException(
                "The selected dentist is unavailable at this time. " +
                "Please choose a different slot.");
        }

        boolean patientConflict = appointmentDAO.hasPatientConflict(
            appointment.getPatientId(),
            appointment.getAppointmentDate(),
            appointment.getAppointmentTime(),
            endTime,
            appointment.getAppointmentId()   // exclude self
        );
        if (patientConflict) {
            throw new ApplicationException(
                "The patient already has another appointment scheduled that overlaps with this slot.");
        }

        appointmentDAO.update(appointment);

        auditService.log(updatedByUserId, null, "APPOINTMENT_UPDATED",
            "APPOINTMENT", appointment.getAppointmentId(),
            "Appointment " + appointment.getAppointmentNumber() + " updated", null, null);
    }

    /**
     * Cancel an appointment.
     */
    public void cancelAppointment(int appointmentId, String reason,
                                  int cancelledByUserId) throws ApplicationException {
        Appointment appt = appointmentDAO.findById(appointmentId);
        if (appt == null) throw new ApplicationException("Appointment not found.");
        if (appt.isCancelled()) {
            throw new ApplicationException("Appointment is already cancelled.");
        }
        if (appt.isCompleted()) {
            throw new ApplicationException("Cannot cancel a completed appointment.");
        }

        appointmentDAO.updateStatus(appointmentId, "CANCELLED", reason);

        auditService.log(cancelledByUserId, null, "APPOINTMENT_CANCELLED",
            "APPOINTMENT", appointmentId,
            "Appointment " + appt.getAppointmentNumber() + " cancelled. Reason: " + reason,
            null, null);
    }

    /**
     * Mark appointment as complete.
     */
    public void completeAppointment(int appointmentId, int completedByUserId)
            throws ApplicationException {
        Appointment appt = appointmentDAO.findById(appointmentId);
        if (appt == null) throw new ApplicationException("Appointment not found.");
        if (appt.isCompleted()) throw new ApplicationException("Appointment already completed.");
        if (appt.isCancelled())  throw new ApplicationException("Cannot complete a cancelled appointment.");

        appointmentDAO.updateStatus(appointmentId, "COMPLETED", null);

        auditService.log(completedByUserId, null, "APPOINTMENT_COMPLETED",
            "APPOINTMENT", appointmentId,
            "Appointment " + appt.getAppointmentNumber() + " marked as completed", null, null);
    }

    // -------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------

    private void validateDentistDayAvailability(Dentist dentist, LocalDate date)
            throws ApplicationException {
        DayOfWeek day = date.getDayOfWeek();
        if (!dentist.isAvailableOn(day)) {
            throw new ApplicationException(
                dentist.getFullName() + " is not available on " + day.toString() +
                "s. Available clinic days: " + dentist.getAvailableDaysSummary() + ". Please select a different date.");
        }
    }
}
