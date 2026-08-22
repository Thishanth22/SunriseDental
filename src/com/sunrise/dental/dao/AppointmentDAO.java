package com.sunrise.dental.dao;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Appointment;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * AppointmentDAO — Data access interface for Appointment entities.
 */
public interface AppointmentDAO {

    /** Save new appointment. Returns generated appointment_id. */
    int save(Appointment appointment) throws ApplicationException;

    /** Find by PK. Returns null if not found. */
    Appointment findById(int appointmentId) throws ApplicationException;

    /** Find by appointment_number. */
    Appointment findByNumber(String appointmentNumber) throws ApplicationException;

    /** Search by multiple criteria with pagination. */
    List<Appointment> search(String query, String status, LocalDate dateFrom,
                             LocalDate dateTo, Integer dentistId,
                             int offset, int limit) throws ApplicationException;

    /** Count search results (for pagination). */
    int countSearch(String query, String status, LocalDate dateFrom,
                    LocalDate dateTo, Integer dentistId) throws ApplicationException;

    /** All appointments for a patient. */
    List<Appointment> findByPatient(int patientId) throws ApplicationException;

    /** All appointments for a dentist on a given date. */
    List<Appointment> findByDentistAndDate(int dentistId, LocalDate date) throws ApplicationException;

    /** All appointments on a given date (for dashboard). */
    List<Appointment> findByDate(LocalDate date) throws ApplicationException;

    /** All appointments today. */
    List<Appointment> findToday() throws ApplicationException;

    /** Update appointment (status, time, etc.). */
    void update(Appointment appointment) throws ApplicationException;

    /** Update status only (most frequent operation). */
    void updateStatus(int appointmentId, String newStatus,
                      String cancellationReason) throws ApplicationException;

    /**
     * Check for conflicting appointments (double-booking check).
     * Returns true if the dentist already has a booking that overlaps
     * with [startTime, endTime] on the given date.
     * excludeId = 0 for new bookings, or the current appointmentId for edits.
     */
    boolean hasConflict(int dentistId, LocalDate date,
                        LocalTime startTime, LocalTime endTime,
                        int excludeId) throws ApplicationException;

    /**
     * Check if patient has a conflicting appointment at the same time.
     */
    boolean hasPatientConflict(int patientId, LocalDate date,
                               LocalTime startTime, LocalTime endTime,
                               int excludeId) throws ApplicationException;

    /** Count today's appointments. */
    int countToday() throws ApplicationException;

    /** Count today's completed appointments. */
    int countTodayCompleted() throws ApplicationException;

    /** Count today's cancelled appointments. */
    int countTodayCancelled() throws ApplicationException;

    /** Generate next appointment number. */
    String generateAppointmentNumber() throws ApplicationException;
}
