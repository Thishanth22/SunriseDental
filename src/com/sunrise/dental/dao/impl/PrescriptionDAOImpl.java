package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.PrescriptionDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Prescription;
import com.sunrise.dental.model.PrescriptionItem;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * PrescriptionDAOImpl — JDBC Implementation of PrescriptionDAO.
 */
public class PrescriptionDAOImpl implements PrescriptionDAO {

    private static final Logger logger = Logger.getLogger(PrescriptionDAOImpl.class.getName());

    private static final String SELECT_FULL =
        "SELECT r.*, " +
        "       CONCAT(p.first_name, ' ', p.last_name) AS patient_name, " +
        "       p.patient_number, " +
        "       CONCAT('Dr. ', d.first_name, ' ', d.last_name) AS dentist_name, " +
        "       u.full_name AS created_by_name " +
        "FROM prescriptions r " +
        "JOIN patients p ON r.patient_id = p.patient_id " +
        "JOIN dentists d ON r.dentist_id = d.dentist_id " +
        "JOIN users u ON r.created_by = u.user_id ";

    private Prescription mapRow(ResultSet rs) throws SQLException {
        Prescription p = new Prescription();
        p.setPrescriptionId(rs.getInt("prescription_id"));
        p.setPrescriptionNumber(rs.getString("prescription_number"));
        p.setPatientId(rs.getInt("patient_id"));
        p.setDentistId(rs.getInt("dentist_id"));
        
        int apptId = rs.getInt("appointment_id");
        p.setAppointmentId(rs.wasNull() ? null : apptId);
        
        p.setNotes(rs.getString("notes"));
        p.setCreatedBy(rs.getInt("created_by"));
        
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) p.setCreatedAt(ts.toLocalDateTime());

        // Denormalized fields
        try {
            p.setPatientName(rs.getString("patient_name"));
            p.setPatientNumber(rs.getString("patient_number"));
            p.setDentistName(rs.getString("dentist_name"));
            p.setCreatedByName(rs.getString("created_by_name"));
        } catch (SQLException ignore) {}

        return p;
    }

    private PrescriptionItem mapItemRow(ResultSet rs) throws SQLException {
        PrescriptionItem item = new PrescriptionItem();
        item.setItemId(rs.getInt("item_id"));
        item.setPrescriptionId(rs.getInt("prescription_id"));
        item.setDrugName(rs.getString("drug_name"));
        item.setDosage(rs.getString("dosage"));
        item.setFrequency(rs.getString("frequency"));
        item.setDuration(rs.getString("duration"));
        item.setInstructions(rs.getString("instructions"));
        return item;
    }

    @Override
    public int save(Prescription p) throws ApplicationException {
        final String sql =
            "INSERT INTO prescriptions (prescription_number, patient_id, dentist_id, appointment_id, notes, created_by) " +
            "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getPrescriptionNumber());
            ps.setInt(2, p.getPatientId());
            ps.setInt(3, p.getDentistId());
            if (p.getAppointmentId() != null) ps.setInt(4, p.getAppointmentId());
            else ps.setNull(4, Types.INTEGER);
            ps.setString(5, p.getNotes());
            ps.setInt(6, p.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save prescription failed", e);
            throw new ApplicationException("Unable to save prescription record.", e);
        }
        return 0;
    }

    @Override
    public void saveItem(PrescriptionItem item) throws ApplicationException {
        final String sql =
            "INSERT INTO prescription_items (prescription_id, drug_name, dosage, frequency, duration, instructions) " +
            "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getPrescriptionId());
            ps.setString(2, item.getDrugName());
            ps.setString(3, item.getDosage());
            ps.setString(4, item.getFrequency());
            ps.setString(5, item.getDuration());
            ps.setString(6, item.getInstructions());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save prescription item failed", e);
            throw new ApplicationException("Unable to save prescription drug item.", e);
        }
    }

    @Override
    public Prescription findById(int id) throws ApplicationException {
        final String sql = SELECT_FULL + "WHERE r.prescription_id = ?";
        Prescription p = null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) p = mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById prescription failed", e);
            throw new ApplicationException("Unable to retrieve prescription details.", e);
        }

        if (p != null) {
            p.setItems(findItemsByPrescriptionId(id));
        }
        return p;
    }

    private List<PrescriptionItem> findItemsByPrescriptionId(int rxId) throws ApplicationException {
        final String sql = "SELECT * FROM prescription_items WHERE prescription_id = ? ORDER BY item_id";
        List<PrescriptionItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rxId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapItemRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findItemsByPrescriptionId failed", e);
            throw new ApplicationException("Unable to retrieve prescription items.", e);
        }
        return list;
    }

    @Override
    public List<Prescription> findByPatientId(int patientId) throws ApplicationException {
        final String sql = SELECT_FULL + "WHERE r.patient_id = ? ORDER BY r.created_at DESC";
        List<Prescription> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByPatientId failed", e);
            throw new ApplicationException("Unable to retrieve patient prescriptions.", e);
        }
        return list;
    }

    @Override
    public List<Prescription> findByDentistId(int dentistId) throws ApplicationException {
        final String sql = SELECT_FULL + "WHERE r.dentist_id = ? ORDER BY r.created_at DESC";
        List<Prescription> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dentistId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByDentistId failed", e);
            throw new ApplicationException("Unable to retrieve dentist prescriptions.", e);
        }
        return list;
    }

    @Override
    public List<Prescription> search(String query, int offset, int limit) throws ApplicationException {
        StringBuilder sql = new StringBuilder(SELECT_FULL).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (r.prescription_number LIKE ? OR CONCAT(p.first_name,' ',p.last_name) LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like);
            params.add(like);
        }

        sql.append("ORDER BY r.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Prescription> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof String) ps.setString(i+1, (String) v);
                else if (v instanceof Integer) ps.setInt(i+1, (Integer) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search prescriptions failed", e);
            throw new ApplicationException("Unable to search prescriptions.", e);
        }
        return list;
    }

    @Override
    public int countSearch(String query) throws ApplicationException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM prescriptions r " +
            "JOIN patients p ON r.patient_id = p.patient_id " +
            "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (r.prescription_number LIKE ? OR CONCAT(p.first_name,' ',p.last_name) LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like);
            params.add(like);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i+1, (String) params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countSearch prescriptions failed", e);
            throw new ApplicationException("Unable to count prescriptions.", e);
        }
    }

    @Override
    public String generatePrescriptionNumber() throws ApplicationException {
        int year = Year.now().getValue();
        final String sql = "SELECT COUNT(*) FROM prescriptions WHERE YEAR(created_at) = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return String.format("RX-%d-%06d", year, count + 1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "generatePrescriptionNumber failed", e);
            throw new ApplicationException("Unable to generate prescription reference number.", e);
        }
    }
}
