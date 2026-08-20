package com.sunrise.dental.service;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.AuditLog;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AuditService — Records all system audit events.
 *
 * Called by: AuthService, PatientService, AppointmentService,
 *            BillingService, and directly from Servlets for CRUD actions.
 *
 * Audit data stored: who, what, which entity, when, from where.
 */
public class AuditService {

    private static final Logger logger = Logger.getLogger(AuditService.class.getName());

    /**
     * Log an audit event.
     *
     * @param userId      User ID performing the action (null if pre-login)
     * @param username    Username snapshot at time of action
     * @param action      Action code e.g. LOGIN, PATIENT_CREATED
     * @param entityType  Entity type e.g. PATIENT, APPOINTMENT
     * @param entityId    Entity primary key (0 if not applicable)
     * @param description Human-readable description
     * @param ipAddress   Client IP address
     * @param userAgent   Browser user-agent string
     */
    public void log(Integer userId, String username, String action,
                    String entityType, Integer entityId, String description,
                    String ipAddress, String userAgent) {
        // Non-critical — never let audit failure propagate to caller
        try {
            final String sql =
                "INSERT INTO audit_logs (user_id,username,action,entity_type,entity_id," +
                "description,ip_address,user_agent) VALUES (?,?,?,?,?,?,?,?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                if (userId != null) ps.setInt(1, userId);
                else ps.setNull(1, Types.INTEGER);
                ps.setString(2, username);
                ps.setString(3, action);
                ps.setString(4, entityType);
                if (entityId != null) ps.setInt(5, entityId);
                else ps.setNull(5, Types.INTEGER);
                ps.setString(6, description);
                ps.setString(7, ipAddress);
                ps.setString(8, userAgent);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            // Log to server log but don't crash the application
            logger.log(Level.WARNING, "Audit log insert failed (non-critical): " + e.getMessage(), e);
        }
    }

    /**
     * Retrieve recent audit logs with pagination.
     */
    public List<AuditLog> findAll(int offset, int limit) throws ApplicationException {
        final String sql =
            "SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT ? OFFSET ?";
        List<AuditLog> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findAll audit logs failed", e);
            throw new ApplicationException("Unable to retrieve audit logs.", e);
        }
        return list;
    }

    /**
     * Search audit logs.
     */
    public List<AuditLog> search(String query, String action, int offset, int limit)
            throws ApplicationException {
        StringBuilder sql = new StringBuilder("SELECT * FROM audit_logs WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (username LIKE ? OR description LIKE ? OR entity_type LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (action != null && !action.isEmpty()) {
            sql.append("AND action=? ");
            params.add(action);
        }
        sql.append("ORDER BY created_at DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);

        List<AuditLog> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof String)  ps.setString(i+1, (String) v);
                else if (v instanceof Integer) ps.setInt(i+1, (Integer) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search audit logs failed", e);
            throw new ApplicationException("Unable to search audit logs.", e);
        }
        return list;
    }

    public int count() throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM audit_logs");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "count audit logs failed", e);
            throw new ApplicationException("Unable to count audit logs.", e);
        }
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog a = new AuditLog();
        a.setLogId(rs.getLong("log_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setUsername(rs.getString("username"));
        a.setAction(rs.getString("action"));
        a.setEntityType(rs.getString("entity_type"));
        a.setEntityId(rs.getInt("entity_id"));
        a.setDescription(rs.getString("description"));
        a.setIpAddress(rs.getString("ip_address"));
        a.setUserAgent(rs.getString("user_agent"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        return a;
    }
}
