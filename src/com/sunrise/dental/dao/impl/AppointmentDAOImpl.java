package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.AppointmentDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Appointment;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AppointmentDAOImpl — JDBC implementation of AppointmentDAO.
 *
 * Critical method: hasConflict() — prevents double-booking.
 * It checks for time overlaps for a given dentist on a given date.
 */
public class AppointmentDAOImpl implements AppointmentDAO {

    private static final Logger logger = Logger.getLogger(AppointmentDAOImpl.class.getName());

    // Full SELECT with JOINs for display fields
    private static final String SELECT_FULL =
        "SELECT a.*, " +
        "       CONCAT(p.first_name,' ',p.last_name) AS patient_name, " +
        "       p.patient_number, p.contact_number AS patient_phone, " +
        "       CONCAT_WS(', ', p.address, p.city) AS patient_address, " +
        "       p.allergies AS patient_allergies, " +
        "       CONCAT('Dr. ',d.first_name,' ',d.last_name) AS dentist_name, " +
        "       d.specialization AS dentist_specialization, " +
        "       t.treatment_name, t.duration_mins AS treatment_duration_mins " +
        "FROM appointments a " +
        "JOIN patients   p ON a.patient_id   = p.patient_id " +
        "JOIN dentists   d ON a.dentist_id   = d.dentist_id " +
        "JOIN treatments t ON a.treatment_id = t.treatment_id ";

    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setAppointmentId(rs.getInt("appointment_id"));
        a.setAppointmentNumber(rs.getString("appointment_number"));
        a.setPatientId(rs.getInt("patient_id"));
        a.setDentistId(rs.getInt("dentist_id"));
        a.setTreatmentId(rs.getInt("treatment_id"));

        Date d = rs.getDate("appointment_date");
        if (d != null) a.setAppointmentDate(d.toLocalDate());

        Time st = rs.getTime("appointment_time");
        if (st != null) a.setAppointmentTime(st.toLocalTime());

        Time et = rs.getTime("end_time");
        if (et != null) a.setEndTime(et.toLocalTime());

        a.setStatus(rs.getString("status"));
        a.setPriority(rs.getString("priority"));
        a.setNotes(rs.getString("notes"));
        a.setCancellationReason(rs.getString("cancellation_reason"));

        int rsf = rs.getInt("rescheduled_from");
        if (!rs.wasNull()) a.setRescheduledFrom(rsf);

        a.setCreatedBy(rs.getInt("created_by"));

        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) a.setCreatedAt(ca.toLocalDateTime());

        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) a.setUpdatedAt(ua.toLocalDateTime());

        // Denormalised display fields (available in SELECT_FULL queries)
        try {
            a.setPatientName(rs.getString("patient_name"));
            a.setPatientNumber(rs.getString("patient_number"));
            a.setPatientPhone(rs.getString("patient_phone"));
            a.setPatientAddress(rs.getString("patient_address"));
            a.setPatientAllergies(rs.getString("patient_allergies"));
            a.setDentistName(rs.getString("dentist_name"));
            a.setDentistSpecialization(rs.getString("dentist_specialization"));
            a.setTreatmentName(rs.getString("treatment_name"));
            a.setTreatmentDurationMins(rs.getInt("treatment_duration_mins"));
        } catch (SQLException ignore) {
            // Column may not exist in simple queries — ignore
        }
        return a;
    }

    @Override
    public int save(Appointment appt) throws ApplicationException {
        final String sql =
            "INSERT INTO appointments (" +
            "  appointment_number, patient_id, dentist_id, treatment_id, " +
            "  appointment_date, appointment_time, status, priority, notes, " +
            "  rescheduled_from, created_by" +
            ") VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, appt.getAppointmentNumber());
            ps.setInt(2, appt.getPatientId());
            ps.setInt(3, appt.getDentistId());
            ps.setInt(4, appt.getTreatmentId());
            ps.setDate(5, Date.valueOf(appt.getAppointmentDate()));
            ps.setTime(6, Time.valueOf(appt.getAppointmentTime()));
            ps.setString(7, appt.getStatus() != null ? appt.getStatus() : "SCHEDULED");
            String prio = appt.getPriority();
            if (prio == null || prio.trim().isEmpty() || (!"URGENT".equalsIgnoreCase(prio.trim()) && !"EMERGENCY".equalsIgnoreCase(prio.trim()))) {
                prio = "NORMAL";
            } else {
                prio = prio.trim().toUpperCase();
            }
            ps.setString(8, prio);
            ps.setString(9, appt.getNotes());
            if (appt.getRescheduledFrom() != null) ps.setInt(10, appt.getRescheduledFrom());
            else ps.setNull(10, Types.INTEGER);
            if (appt.getCreatedBy() > 0) ps.setInt(11, appt.getCreatedBy());
            else ps.setNull(11, Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save appointment failed: " + e.getMessage(), e);
            throw new ApplicationException(
                "Unable to save appointment. Please verify the information and try again.", e);
        }
        return 0;
    }

    @Override
    public Appointment findById(int id) throws ApplicationException {
        final String sql = SELECT_FULL + "WHERE a.appointment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById appointment failed", e);
            throw new ApplicationException("Unable to retrieve appointment.", e);
        }
        return null;
    }

    @Override
    public Appointment findByNumber(String number) throws ApplicationException {
        final String sql = SELECT_FULL + "WHERE a.appointment_number=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByNumber appointment failed", e);
            throw new ApplicationException("Unable to retrieve appointment.", e);
        }
        return null;
    }

    @Override
    public List<Appointment> search(String query, String status,
                                    LocalDate dateFrom, LocalDate dateTo,
                                    Integer dentistId, int offset, int limit)
            throws ApplicationException {

        StringBuilder sql = new StringBuilder(SELECT_FULL).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (a.appointment_number LIKE ? " +
                       "OR CONCAT(p.first_name,' ',p.last_name) LIKE ? " +
                       "OR p.contact_number LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND a.status=? ");
            params.add(status);
        }
        if (dateFrom != null) {
            sql.append("AND a.appointment_date >= ? ");
            params.add(Date.valueOf(dateFrom));
        }
        if (dateTo != null) {
            sql.append("AND a.appointment_date <= ? ");
            params.add(Date.valueOf(dateTo));
        }
        if (dentistId != null) {
            sql.append("AND a.dentist_id=? ");
            params.add(dentistId);
        }
        sql.append("ORDER BY a.appointment_date DESC, a.appointment_time DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof String) ps.setString(i+1, (String) v);
                else if (v instanceof Integer) ps.setInt(i+1, (Integer) v);
                else if (v instanceof Date) ps.setDate(i+1, (Date) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search appointments failed", e);
            throw new ApplicationException("Unable to search appointments.", e);
        }
        return list;
    }

    @Override
    public int countSearch(String query, String status, LocalDate dateFrom,
                           LocalDate dateTo, Integer dentistId) throws ApplicationException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM appointments a " +
            "JOIN patients p ON a.patient_id=p.patient_id " +
            "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (a.appointment_number LIKE ? " +
                       "OR CONCAT(p.first_name,' ',p.last_name) LIKE ? " +
                       "OR p.contact_number LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (status != null && !status.isEmpty()) { sql.append("AND a.status=? "); params.add(status); }
        if (dateFrom != null) { sql.append("AND a.appointment_date >= ? "); params.add(Date.valueOf(dateFrom)); }
        if (dateTo   != null) { sql.append("AND a.appointment_date <= ? "); params.add(Date.valueOf(dateTo)); }
        if (dentistId!= null) { sql.append("AND a.dentist_id=? "); params.add(dentistId); }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof String) ps.setString(i+1, (String) v);
                else if (v instanceof Integer) ps.setInt(i+1, (Integer) v);
                else if (v instanceof Date) ps.setDate(i+1, (Date) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countSearch appointments failed", e);
            throw new ApplicationException("Unable to count appointments.", e);
        }
        return 0;
    }

    @Override
    public List<Appointment> findByPatient(int patientId) throws ApplicationException {
        final String sql = SELECT_FULL +
            "WHERE a.patient_id=? ORDER BY a.appointment_date DESC, a.appointment_time DESC";
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByPatient failed", e);
            throw new ApplicationException("Unable to retrieve patient appointments.", e);
        }
        return list;
    }

    @Override
    public List<Appointment> findByDentistAndDate(int dentistId, LocalDate date)
            throws ApplicationException {
        final String sql = SELECT_FULL +
            "WHERE a.dentist_id=? AND a.appointment_date=? " +
            "AND a.status NOT IN ('CANCELLED','NO_SHOW','RESCHEDULED') " +
            "ORDER BY a.appointment_time";
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dentistId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByDentistAndDate failed", e);
            throw new ApplicationException("Unable to retrieve dentist schedule.", e);
        }
        return list;
    }

    @Override
    public List<Appointment> findByDate(LocalDate date) throws ApplicationException {
        final String sql = SELECT_FULL +
            "WHERE a.appointment_date=? " +
            "ORDER BY a.appointment_time, d.last_name";
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByDate failed", e);
            throw new ApplicationException("Unable to retrieve appointments.", e);
        }
        return list;
    }

    @Override
    public List<Appointment> findToday() throws ApplicationException {
        return findByDate(LocalDate.now());
    }

    @Override
    public void update(Appointment appt) throws ApplicationException {
        final String sql =
            "UPDATE appointments SET patient_id=?, dentist_id=?, treatment_id=?, " +
            "appointment_date=?, appointment_time=?, status=?, priority=?, " +
            "notes=?, cancellation_reason=? WHERE appointment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appt.getPatientId());
            ps.setInt(2, appt.getDentistId());
            ps.setInt(3, appt.getTreatmentId());
            ps.setDate(4, Date.valueOf(appt.getAppointmentDate()));
            ps.setTime(5, Time.valueOf(appt.getAppointmentTime()));
            ps.setString(6, appt.getStatus());
            String prioUpdate = appt.getPriority();
            if (prioUpdate == null || prioUpdate.trim().isEmpty() || (!"URGENT".equalsIgnoreCase(prioUpdate.trim()) && !"EMERGENCY".equalsIgnoreCase(prioUpdate.trim()))) {
                prioUpdate = "NORMAL";
            } else {
                prioUpdate = prioUpdate.trim().toUpperCase();
            }
            ps.setString(7, prioUpdate);
            ps.setString(8, appt.getNotes());
            ps.setString(9, appt.getCancellationReason());
            ps.setInt(10, appt.getAppointmentId());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "update appointment failed", e);
            throw new ApplicationException("Unable to update appointment.", e);
        }
    }

    @Override
    public void updateStatus(int appointmentId, String newStatus,
                             String cancellationReason) throws ApplicationException {
        final String sql =
            "UPDATE appointments SET status=?, cancellation_reason=? WHERE appointment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, cancellationReason);
            ps.setInt(3, appointmentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "updateStatus appointment failed", e);
            throw new ApplicationException("Unable to update appointment status.", e);
        }
    }

    /**
     * DOUBLE-BOOKING PREVENTION — Core conflict check.
     *
     * An overlap exists when:
     *   newStart < existingEnd  AND  newEnd > existingStart
     *
     * Excluded statuses (CANCELLED/NO_SHOW/RESCHEDULED) don't block slots.
     * excludeId=0 means a new booking (no exclusion needed).
     */
    @Override
    public boolean hasConflict(int dentistId, LocalDate date,
                               LocalTime startTime, LocalTime endTime,
                               int excludeId) throws ApplicationException {
        final String sql =
            "SELECT COUNT(*) FROM appointments " +
            "WHERE dentist_id=? " +
            "  AND appointment_date=? " +
            "  AND appointment_id <> ? " +
            "  AND status NOT IN ('CANCELLED','NO_SHOW','RESCHEDULED') " +
            "  AND (? < end_time AND ? > appointment_time)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dentistId);
            ps.setDate(2, Date.valueOf(date));
            ps.setInt(3, excludeId);
            ps.setTime(4, Time.valueOf(startTime));
            ps.setTime(5, Time.valueOf(endTime));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "hasConflict failed", e);
            throw new ApplicationException(
                "Unable to check appointment availability. Please try again.", e);
        }
    }

    @Override
    public boolean hasPatientConflict(int patientId, LocalDate date,
                                      LocalTime startTime, LocalTime endTime,
                                      int excludeId) throws ApplicationException {
        final String sql =
            "SELECT COUNT(*) FROM appointments " +
            "WHERE patient_id=? " +
            "  AND appointment_date=? " +
            "  AND appointment_id <> ? " +
            "  AND status NOT IN ('CANCELLED','NO_SHOW','RESCHEDULED') " +
            "  AND (? < end_time AND ? > appointment_time)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ps.setDate(2, Date.valueOf(date));
            ps.setInt(3, excludeId);
            ps.setTime(4, Time.valueOf(startTime));
            ps.setTime(5, Time.valueOf(endTime));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "hasPatientConflict failed", e);
            throw new ApplicationException(
                "Unable to check patient availability. Please try again.", e);
        }
    }

    @Override
    public int countToday() throws ApplicationException {
        final String sql =
            "SELECT COUNT(*) FROM appointments WHERE appointment_date=CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countToday failed", e);
            throw new ApplicationException("Unable to count appointments.", e);
        }
    }

    @Override
    public int countTodayCompleted() throws ApplicationException {
        final String sql =
            "SELECT COUNT(*) FROM appointments " +
            "WHERE appointment_date=CURDATE() AND status='COMPLETED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countTodayCompleted failed", e);
            throw new ApplicationException("Unable to count appointments.", e);
        }
    }

    @Override
    public int countTodayCancelled() throws ApplicationException {
        final String sql =
            "SELECT COUNT(*) FROM appointments " +
            "WHERE appointment_date=CURDATE() AND status='CANCELLED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countTodayCancelled failed", e);
            throw new ApplicationException("Unable to count appointments.", e);
        }
    }

    @Override
    public String generateAppointmentNumber() throws ApplicationException {
        int year = Year.now().getValue();
        final String sql = "SELECT COUNT(*) FROM appointments WHERE YEAR(created_at)=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return String.format("APT-%d-%06d", year, count + 1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "generateAppointmentNumber failed", e);
            throw new ApplicationException("Unable to generate appointment number.", e);
        }
    }
}
