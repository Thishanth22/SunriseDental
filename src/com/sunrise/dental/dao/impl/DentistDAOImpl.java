package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.DentistDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Dentist;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DentistDAOImpl implements DentistDAO {

    private static final Logger logger = Logger.getLogger(DentistDAOImpl.class.getName());

    private Dentist mapRow(ResultSet rs) throws SQLException {
        Dentist d = new Dentist();
        d.setDentistId(rs.getInt("dentist_id"));
        d.setDentistNumber(rs.getString("dentist_number"));
        d.setFirstName(rs.getString("first_name"));
        d.setLastName(rs.getString("last_name"));
        d.setSpecialization(rs.getString("specialization"));
        d.setQualification(rs.getString("qualification"));
        d.setLicenseNumber(rs.getString("license_number"));
        d.setContactNumber(rs.getString("contact_number"));
        d.setEmail(rs.getString("email"));
        d.setAvailableMonday(rs.getBoolean("available_monday"));
        d.setAvailableTuesday(rs.getBoolean("available_tuesday"));
        d.setAvailableWednesday(rs.getBoolean("available_wednesday"));
        d.setAvailableThursday(rs.getBoolean("available_thursday"));
        d.setAvailableFriday(rs.getBoolean("available_friday"));
        d.setAvailableSaturday(rs.getBoolean("available_saturday"));
        d.setAvailableSunday(rs.getBoolean("available_sunday"));
        Time wst = rs.getTime("work_start_time");
        if (wst != null) d.setWorkStartTime(wst.toLocalTime());
        Time wet = rs.getTime("work_end_time");
        if (wet != null) d.setWorkEndTime(wet.toLocalTime());
        d.setStatus(rs.getString("status"));
        d.setNotes(rs.getString("notes"));
        d.setUserId(rs.getInt("user_id"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) d.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) d.setUpdatedAt(ua.toLocalDateTime());
        return d;
    }

    @Override
    public int save(Dentist den) throws ApplicationException {
        final String sql =
            "INSERT INTO dentists (dentist_number,first_name,last_name,specialization," +
            "qualification,license_number,contact_number,email," +
            "available_monday,available_tuesday,available_wednesday,available_thursday," +
            "available_friday,available_saturday,available_sunday," +
            "work_start_time,work_end_time,status,notes,user_id) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, den.getDentistNumber());
            ps.setString(2, den.getFirstName());
            ps.setString(3, den.getLastName());
            ps.setString(4, den.getSpecialization());
            ps.setString(5, den.getQualification());
            ps.setString(6, den.getLicenseNumber());
            ps.setString(7, den.getContactNumber());
            ps.setString(8, den.getEmail());
            ps.setBoolean(9, den.isAvailableMonday());
            ps.setBoolean(10, den.isAvailableTuesday());
            ps.setBoolean(11, den.isAvailableWednesday());
            ps.setBoolean(12, den.isAvailableThursday());
            ps.setBoolean(13, den.isAvailableFriday());
            ps.setBoolean(14, den.isAvailableSaturday());
            ps.setBoolean(15, den.isAvailableSunday());
            ps.setTime(16, den.getWorkStartTime() != null ? Time.valueOf(den.getWorkStartTime()) : null);
            ps.setTime(17, den.getWorkEndTime()   != null ? Time.valueOf(den.getWorkEndTime())   : null);
            ps.setString(18, den.getStatus() != null ? den.getStatus() : "ACTIVE");
            ps.setString(19, den.getNotes());
            if (den.getUserId() > 0) ps.setInt(20, den.getUserId());
            else ps.setNull(20, Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save dentist failed", e);
            throw new ApplicationException("Unable to save dentist. Please try again.", e);
        }
        return 0;
    }

    @Override
    public Dentist findById(int id) throws ApplicationException {
        final String sql = "SELECT * FROM dentists WHERE dentist_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById dentist failed", e);
            throw new ApplicationException("Unable to retrieve dentist.", e);
        }
        return null;
    }

    @Override
    public Dentist findByUserId(int userId) throws ApplicationException {
        final String sql = "SELECT * FROM dentists WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByUserId dentist failed", e);
            throw new ApplicationException("Unable to retrieve dentist by user ID.", e);
        }
        return null;
    }

    @Override
    public Dentist findByNumber(String number) throws ApplicationException {
        final String sql = "SELECT * FROM dentists WHERE dentist_number=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByNumber dentist failed", e);
            throw new ApplicationException("Unable to retrieve dentist.", e);
        }
        return null;
    }

    @Override
    public List<Dentist> findAll() throws ApplicationException {
        return executeListQuery("SELECT * FROM dentists ORDER BY last_name, first_name", null);
    }

    @Override
    public List<Dentist> findAllActive() throws ApplicationException {
        return executeListQuery(
            "SELECT * FROM dentists WHERE status='ACTIVE' ORDER BY last_name, first_name", null);
    }

    @Override
    public List<Dentist> search(String query, int offset, int limit) throws ApplicationException {
        final String sql =
            "SELECT * FROM dentists " +
            "WHERE (first_name LIKE ? OR last_name LIKE ? OR specialization LIKE ?) " +
            "ORDER BY last_name, first_name LIMIT ? OFFSET ?";
        String like = "%" + (query == null ? "" : query.trim()) + "%";
        List<Dentist> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setInt(4, limit);
            ps.setInt(5, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search dentists failed", e);
            throw new ApplicationException("Unable to search dentists.", e);
        }
        return list;
    }

    @Override
    public int countSearch(String query) throws ApplicationException {
        final String sql =
            "SELECT COUNT(*) FROM dentists " +
            "WHERE first_name LIKE ? OR last_name LIKE ? OR specialization LIKE ?";
        String like = "%" + (query == null ? "" : query.trim()) + "%";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, like); ps.setString(2, like); ps.setString(3, like);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countSearch dentists failed", e);
            throw new ApplicationException("Unable to count dentists.", e);
        }
    }

    @Override
    public void update(Dentist den) throws ApplicationException {
        final String sql =
            "UPDATE dentists SET first_name=?,last_name=?,specialization=?,qualification=?," +
            "license_number=?,contact_number=?,email=?," +
            "available_monday=?,available_tuesday=?,available_wednesday=?," +
            "available_thursday=?,available_friday=?,available_saturday=?,available_sunday=?," +
            "work_start_time=?,work_end_time=?,status=?,notes=? " +
            "WHERE dentist_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, den.getFirstName());
            ps.setString(2, den.getLastName());
            ps.setString(3, den.getSpecialization());
            ps.setString(4, den.getQualification());
            ps.setString(5, den.getLicenseNumber());
            ps.setString(6, den.getContactNumber());
            ps.setString(7, den.getEmail());
            ps.setBoolean(8, den.isAvailableMonday());
            ps.setBoolean(9, den.isAvailableTuesday());
            ps.setBoolean(10, den.isAvailableWednesday());
            ps.setBoolean(11, den.isAvailableThursday());
            ps.setBoolean(12, den.isAvailableFriday());
            ps.setBoolean(13, den.isAvailableSaturday());
            ps.setBoolean(14, den.isAvailableSunday());
            ps.setTime(15, den.getWorkStartTime() != null ? Time.valueOf(den.getWorkStartTime()) : null);
            ps.setTime(16, den.getWorkEndTime()   != null ? Time.valueOf(den.getWorkEndTime())   : null);
            ps.setString(17, den.getStatus());
            ps.setString(18, den.getNotes());
            ps.setInt(19, den.getDentistId());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "update dentist failed", e);
            throw new ApplicationException("Unable to update dentist.", e);
        }
    }

    @Override
    public void updateStatus(int dentistId, String status) throws ApplicationException {
        final String sql = "UPDATE dentists SET status=? WHERE dentist_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, dentistId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "updateStatus dentist failed", e);
            throw new ApplicationException("Unable to update dentist status.", e);
        }
    }

    @Override
    public String generateDentistNumber() throws ApplicationException {
        int year = Year.now().getValue();
        final String sql = "SELECT COUNT(*) FROM dentists WHERE YEAR(created_at)=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return String.format("DEN-%d-%06d", year, count + 1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "generateDentistNumber failed", e);
            throw new ApplicationException("Unable to generate dentist number.", e);
        }
    }

    @Override
    public int count() throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dentists WHERE status='ACTIVE'");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "count dentists failed", e);
            throw new ApplicationException("Unable to count dentists.", e);
        }
    }

    // Helper for simple list queries
    private List<Dentist> executeListQuery(String sql, Object param) throws ApplicationException {
        List<Dentist> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (param instanceof Integer) ps.setInt(1, (Integer) param);
            else if (param instanceof String) ps.setString(1, (String) param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "executeListQuery dentists failed", e);
            throw new ApplicationException("Unable to retrieve dentists.", e);
        }
        return list;
    }
}
