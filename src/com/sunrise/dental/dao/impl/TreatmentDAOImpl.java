package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.TreatmentDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Treatment;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TreatmentDAOImpl implements TreatmentDAO {

    private static final Logger logger = Logger.getLogger(TreatmentDAOImpl.class.getName());

    private Treatment mapRow(ResultSet rs) throws SQLException {
        Treatment t = new Treatment();
        t.setTreatmentId(rs.getInt("treatment_id"));
        t.setTreatmentCode(rs.getString("treatment_code"));
        t.setTreatmentName(rs.getString("treatment_name"));
        t.setCategory(rs.getString("category"));
        t.setDescription(rs.getString("description"));
        t.setBaseCost(rs.getBigDecimal("base_cost"));
        t.setDurationMins(rs.getInt("duration_mins"));
        t.setRequiresFollowup(rs.getBoolean("requires_followup"));
        t.setStatus(rs.getString("status"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) t.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) t.setUpdatedAt(ua.toLocalDateTime());
        return t;
    }

    @Override
    public int save(Treatment t) throws ApplicationException {
        final String sql =
            "INSERT INTO treatments (treatment_code,treatment_name,category,description," +
            "base_cost,duration_mins,requires_followup,status) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, t.getTreatmentCode());
            ps.setString(2, t.getTreatmentName());
            ps.setString(3, t.getCategory());
            ps.setString(4, t.getDescription());
            ps.setBigDecimal(5, t.getBaseCost());
            ps.setInt(6, t.getDurationMins());
            ps.setBoolean(7, t.isRequiresFollowup());
            ps.setString(8, t.getStatus() != null ? t.getStatus() : "ACTIVE");
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save treatment failed", e);
            throw new ApplicationException("Unable to save treatment.", e);
        }
        return 0;
    }

    @Override
    public Treatment findById(int id) throws ApplicationException {
        final String sql = "SELECT * FROM treatments WHERE treatment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById treatment failed", e);
            throw new ApplicationException("Unable to retrieve treatment.", e);
        }
        return null;
    }

    @Override
    public Treatment findByCode(String code) throws ApplicationException {
        final String sql = "SELECT * FROM treatments WHERE treatment_code=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByCode treatment failed", e);
            throw new ApplicationException("Unable to retrieve treatment.", e);
        }
        return null;
    }

    @Override
    public List<Treatment> findAll() throws ApplicationException {
        return runList("SELECT * FROM treatments ORDER BY category, treatment_name");
    }

    @Override
    public List<Treatment> findAllActive() throws ApplicationException {
        return runList("SELECT * FROM treatments WHERE status='ACTIVE' ORDER BY category, treatment_name");
    }

    @Override
    public List<Treatment> findByCategory(String category) throws ApplicationException {
        final String sql = "SELECT * FROM treatments WHERE category=? AND status='ACTIVE' ORDER BY treatment_name";
        List<Treatment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByCategory failed", e);
            throw new ApplicationException("Unable to retrieve treatments.", e);
        }
        return list;
    }

    @Override
    public List<Treatment> search(String query, int offset, int limit) throws ApplicationException {
        final String sql =
            "SELECT * FROM treatments WHERE treatment_name LIKE ? OR category LIKE ? OR treatment_code LIKE ? " +
            "ORDER BY category, treatment_name LIMIT ? OFFSET ?";
        String like = "%" + (query == null ? "" : query.trim()) + "%";
        List<Treatment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, like); ps.setString(2, like); ps.setString(3, like);
            ps.setInt(4, limit); ps.setInt(5, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search treatments failed", e);
            throw new ApplicationException("Unable to search treatments.", e);
        }
        return list;
    }

    @Override
    public int countSearch(String query) throws ApplicationException {
        final String sql = "SELECT COUNT(*) FROM treatments WHERE treatment_name LIKE ? OR category LIKE ? OR treatment_code LIKE ?";
        String like = "%" + (query == null ? "" : query.trim()) + "%";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, like); ps.setString(2, like); ps.setString(3, like);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countSearch treatments failed", e);
            throw new ApplicationException("Unable to count treatments.", e);
        }
    }

    @Override
    public void update(Treatment t) throws ApplicationException {
        final String sql =
            "UPDATE treatments SET treatment_name=?,category=?,description=?," +
            "base_cost=?,duration_mins=?,requires_followup=?,status=? WHERE treatment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTreatmentName());
            ps.setString(2, t.getCategory());
            ps.setString(3, t.getDescription());
            ps.setBigDecimal(4, t.getBaseCost());
            ps.setInt(5, t.getDurationMins());
            ps.setBoolean(6, t.isRequiresFollowup());
            ps.setString(7, t.getStatus());
            ps.setInt(8, t.getTreatmentId());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "update treatment failed", e);
            throw new ApplicationException("Unable to update treatment.", e);
        }
    }

    @Override
    public void updateStatus(int id, String status) throws ApplicationException {
        final String sql = "UPDATE treatments SET status=? WHERE treatment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status); ps.setInt(2, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "updateStatus treatment failed", e);
            throw new ApplicationException("Unable to update treatment status.", e);
        }
    }

    @Override
    public int count() throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM treatments WHERE status='ACTIVE'");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "count treatments failed", e);
            throw new ApplicationException("Unable to count treatments.", e);
        }
    }

    private List<Treatment> runList(String sql) throws ApplicationException {
        List<Treatment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "runList treatments failed", e);
            throw new ApplicationException("Unable to retrieve treatments.", e);
        }
        return list;
    }
}
