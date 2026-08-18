package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.PatientDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Patient;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * PatientDAOImpl — JDBC implementation of PatientDAO.
 */
public class PatientDAOImpl implements PatientDAO {

    private static final Logger logger = Logger.getLogger(PatientDAOImpl.class.getName());

    // -------------------------------------------------------
    // Reusable SELECT fragment (joins for created_by not needed here)
    // -------------------------------------------------------
    private static final String SELECT_COLS =
        "patient_id, patient_number, first_name, last_name, " +
        "date_of_birth, gender, address, city, contact_number, alt_contact, email, " +
        "emergency_contact_name, emergency_contact_phone, emergency_contact_relation, " +
        "blood_group, allergies, medical_notes, registration_date, status, " +
        "created_by, created_at, updated_at";

    private Patient mapRow(ResultSet rs) throws SQLException {
        Patient p = new Patient();
        p.setPatientId(rs.getInt("patient_id"));
        p.setPatientNumber(rs.getString("patient_number"));
        p.setFirstName(rs.getString("first_name"));
        p.setLastName(rs.getString("last_name"));

        Date dob = rs.getDate("date_of_birth");
        if (dob != null) p.setDateOfBirth(dob.toLocalDate());

        p.setGender(rs.getString("gender"));
        p.setAddress(rs.getString("address"));
        p.setCity(rs.getString("city"));
        p.setContactNumber(rs.getString("contact_number"));
        p.setAltContact(rs.getString("alt_contact"));
        p.setEmail(rs.getString("email"));
        p.setEmergencyContactName(rs.getString("emergency_contact_name"));
        p.setEmergencyContactPhone(rs.getString("emergency_contact_phone"));
        p.setEmergencyContactRelation(rs.getString("emergency_contact_relation"));
        p.setBloodGroup(rs.getString("blood_group"));
        p.setAllergies(rs.getString("allergies"));
        p.setMedicalNotes(rs.getString("medical_notes"));

        Date regDate = rs.getDate("registration_date");
        if (regDate != null) p.setRegistrationDate(regDate.toLocalDate());

        p.setStatus(rs.getString("status"));
        p.setCreatedBy(rs.getInt("created_by"));

        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) p.setCreatedAt(ca.toLocalDateTime());

        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) p.setUpdatedAt(ua.toLocalDateTime());

        return p;
    }

    @Override
    public int save(Patient patient) throws ApplicationException {
        final String sql =
            "INSERT INTO patients (" +
            "  patient_number, first_name, last_name, date_of_birth, gender, " +
            "  address, city, contact_number, alt_contact, email, " +
            "  emergency_contact_name, emergency_contact_phone, emergency_contact_relation, " +
            "  blood_group, allergies, medical_notes, registration_date, status, created_by" +
            ") VALUES (?,?,?,?,?, ?,?,?,?,?, ?,?,?, ?,?,?,?,?,?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, patient.getPatientNumber());
            ps.setString(2, patient.getFirstName());
            ps.setString(3, patient.getLastName());
            ps.setDate(4, patient.getDateOfBirth() != null
                    ? Date.valueOf(patient.getDateOfBirth()) : null);
            ps.setString(5, patient.getGender());
            ps.setString(6, patient.getAddress());
            ps.setString(7, patient.getCity());
            ps.setString(8, patient.getContactNumber());
            ps.setString(9, patient.getAltContact());
            ps.setString(10, patient.getEmail());
            ps.setString(11, patient.getEmergencyContactName());
            ps.setString(12, patient.getEmergencyContactPhone());
            ps.setString(13, patient.getEmergencyContactRelation());
            ps.setString(14, patient.getBloodGroup());
            ps.setString(15, patient.getAllergies());
            ps.setString(16, patient.getMedicalNotes());
            ps.setDate(17, patient.getRegistrationDate() != null
                    ? Date.valueOf(patient.getRegistrationDate()) : Date.valueOf(LocalDate.now()));
            ps.setString(18, patient.getStatus() != null ? patient.getStatus() : "ACTIVE");
            if (patient.getCreatedBy() > 0) ps.setInt(19, patient.getCreatedBy());
            else ps.setNull(19, Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save patient failed: " + e.getMessage(), e);
            throw new ApplicationException("Unable to register patient. Please verify the information and try again.", e);
        }
        return 0;
    }

    @Override
    public Patient findById(int patientId) throws ApplicationException {
        final String sql = "SELECT " + SELECT_COLS + " FROM patients WHERE patient_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById patient failed", e);
            throw new ApplicationException("Unable to retrieve patient.", e);
        }
        return null;
    }

    @Override
    public Patient findByPatientNumber(String patientNumber) throws ApplicationException {
        final String sql = "SELECT " + SELECT_COLS + " FROM patients WHERE patient_number=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByPatientNumber failed", e);
            throw new ApplicationException("Unable to retrieve patient.", e);
        }
        return null;
    }

    @Override
    public List<Patient> findByContactNumber(String contactNumber) throws ApplicationException {
        final String sql =
            "SELECT " + SELECT_COLS + " FROM patients WHERE contact_number=? OR alt_contact=? " +
            "ORDER BY last_name, first_name";
        List<Patient> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, contactNumber);
            ps.setString(2, contactNumber);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByContactNumber failed", e);
            throw new ApplicationException("Unable to search patients.", e);
        }
        return list;
    }

    @Override
    public List<Patient> search(String query, int offset, int limit) throws ApplicationException {
        // Safe LIKE search — uses PreparedStatement parameter
        final String sql =
            "SELECT " + SELECT_COLS + " FROM patients " +
            "WHERE (first_name LIKE ? OR last_name LIKE ? OR " +
            "       CONCAT(first_name,' ',last_name) LIKE ? OR " +
            "       contact_number LIKE ? OR email LIKE ? OR patient_number LIKE ?) " +
            "ORDER BY last_name, first_name LIMIT ? OFFSET ?";
        List<Patient> list = new ArrayList<>();
        String like = "%" + query.trim() + "%";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 6; i++) ps.setString(i, like);
            ps.setInt(7, limit);
            ps.setInt(8, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search patients failed", e);
            throw new ApplicationException("Unable to search patients.", e);
        }
        return list;
    }

    @Override
    public int countSearch(String query) throws ApplicationException {
        final String sql =
            "SELECT COUNT(*) FROM patients " +
            "WHERE (first_name LIKE ? OR last_name LIKE ? OR " +
            "       CONCAT(first_name,' ',last_name) LIKE ? OR " +
            "       contact_number LIKE ? OR email LIKE ? OR patient_number LIKE ?)";
        String like = "%" + query.trim() + "%";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 6; i++) ps.setString(i, like);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countSearch patients failed", e);
            throw new ApplicationException("Unable to count patients.", e);
        }
        return 0;
    }

    @Override
    public List<Patient> findAll(int offset, int limit) throws ApplicationException {
        final String sql =
            "SELECT " + SELECT_COLS + " FROM patients " +
            "ORDER BY created_at DESC LIMIT ? OFFSET ?";
        List<Patient> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findAll patients failed", e);
            throw new ApplicationException("Unable to retrieve patients.", e);
        }
        return list;
    }

    @Override
    public int count() throws ApplicationException {
        final String sql = "SELECT COUNT(*) FROM patients";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "count patients failed", e);
            throw new ApplicationException("Unable to count patients.", e);
        }
        return 0;
    }

    @Override
    public void update(Patient patient) throws ApplicationException {
        final String sql =
            "UPDATE patients SET first_name=?, last_name=?, date_of_birth=?, gender=?, " +
            "address=?, city=?, contact_number=?, alt_contact=?, email=?, " +
            "emergency_contact_name=?, emergency_contact_phone=?, emergency_contact_relation=?, " +
            "blood_group=?, allergies=?, medical_notes=?, status=? " +
            "WHERE patient_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patient.getFirstName());
            ps.setString(2, patient.getLastName());
            ps.setDate(3, patient.getDateOfBirth() != null
                    ? Date.valueOf(patient.getDateOfBirth()) : null);
            ps.setString(4, patient.getGender());
            ps.setString(5, patient.getAddress());
            ps.setString(6, patient.getCity());
            ps.setString(7, patient.getContactNumber());
            ps.setString(8, patient.getAltContact());
            ps.setString(9, patient.getEmail());
            ps.setString(10, patient.getEmergencyContactName());
            ps.setString(11, patient.getEmergencyContactPhone());
            ps.setString(12, patient.getEmergencyContactRelation());
            ps.setString(13, patient.getBloodGroup());
            ps.setString(14, patient.getAllergies());
            ps.setString(15, patient.getMedicalNotes());
            ps.setString(16, patient.getStatus());
            ps.setInt(17, patient.getPatientId());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "update patient failed", e);
            throw new ApplicationException("Unable to update patient.", e);
        }
    }

    @Override
    public void updateStatus(int patientId, String status) throws ApplicationException {
        final String sql = "UPDATE patients SET status=? WHERE patient_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, patientId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "updateStatus patient failed", e);
            throw new ApplicationException("Unable to update patient status.", e);
        }
    }

    @Override
    public String generatePatientNumber() throws ApplicationException {
        int year = Year.now().getValue();
        final String sql = "SELECT COUNT(*) FROM patients WHERE YEAR(created_at)=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return String.format("PAT-%d-%06d", year, count + 1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "generatePatientNumber failed", e);
            throw new ApplicationException("Unable to generate patient number.", e);
        }
    }
}
