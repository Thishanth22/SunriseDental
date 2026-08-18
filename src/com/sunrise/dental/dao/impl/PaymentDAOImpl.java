package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.PaymentDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Payment;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PaymentDAOImpl implements PaymentDAO {

    private static final Logger logger = Logger.getLogger(PaymentDAOImpl.class.getName());

    private static final String SELECT_FULL =
        "SELECT py.*, b.bill_number, " +
        "  CONCAT(p.first_name,' ',p.last_name) AS patient_name, " +
        "  u.full_name AS received_by_name " +
        "FROM payments py " +
        "JOIN bills    b ON py.bill_id    = b.bill_id " +
        "JOIN patients p ON py.patient_id = p.patient_id " +
        "LEFT JOIN users u ON py.received_by = u.user_id ";

    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getInt("payment_id"));
        p.setPaymentNumber(rs.getString("payment_number"));
        p.setBillId(rs.getInt("bill_id"));
        p.setPatientId(rs.getInt("patient_id"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setPaymentStatus(rs.getString("payment_status"));
        p.setTransactionRef(rs.getString("transaction_ref"));
        Timestamp pd = rs.getTimestamp("payment_date");
        if (pd != null) p.setPaymentDate(pd.toLocalDateTime());
        p.setNotes(rs.getString("notes"));
        p.setReceivedBy(rs.getInt("received_by"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) p.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) p.setUpdatedAt(ua.toLocalDateTime());
        try {
            p.setBillNumber(rs.getString("bill_number"));
            p.setPatientName(rs.getString("patient_name"));
            p.setReceivedByName(rs.getString("received_by_name"));
        } catch (SQLException ignore) {}
        return p;
    }

    @Override
    public int save(Payment payment) throws ApplicationException {
        final String sql =
            "INSERT INTO payments (payment_number,bill_id,patient_id,amount," +
            "payment_method,payment_status,transaction_ref,payment_date,notes,received_by) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, payment.getPaymentNumber());
            ps.setInt(2, payment.getBillId());
            ps.setInt(3, payment.getPatientId());
            ps.setBigDecimal(4, payment.getAmount());
            ps.setString(5, payment.getPaymentMethod());
            ps.setString(6, payment.getPaymentStatus() != null ? payment.getPaymentStatus() : "COMPLETED");
            ps.setString(7, payment.getTransactionRef());
            ps.setTimestamp(8, payment.getPaymentDate() != null
                    ? Timestamp.valueOf(payment.getPaymentDate()) : new Timestamp(System.currentTimeMillis()));
            ps.setString(9, payment.getNotes());
            if (payment.getReceivedBy() > 0) ps.setInt(10, payment.getReceivedBy());
            else ps.setNull(10, Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save payment failed", e);
            throw new ApplicationException("Unable to process payment. Please try again.", e);
        }
        return 0;
    }

    @Override
    public Payment findById(int id) throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE py.payment_id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById payment failed", e);
            throw new ApplicationException("Unable to retrieve payment.", e);
        }
        return null;
    }

    @Override
    public Payment findByNumber(String number) throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE py.payment_number=?")) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByNumber payment failed", e);
            throw new ApplicationException("Unable to retrieve payment.", e);
        }
        return null;
    }

    @Override
    public List<Payment> findByBillId(int billId) throws ApplicationException {
        List<Payment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE py.bill_id=? ORDER BY py.payment_date")) {
            ps.setInt(1, billId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByBillId payment failed", e);
            throw new ApplicationException("Unable to retrieve payments.", e);
        }
        return list;
    }

    @Override
    public List<Payment> findByPatient(int patientId) throws ApplicationException {
        List<Payment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE py.patient_id=? ORDER BY py.payment_date DESC")) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByPatient payment failed", e);
            throw new ApplicationException("Unable to retrieve payments.", e);
        }
        return list;
    }

    @Override
    public List<Payment> search(String query, String status, String method,
                                LocalDate dateFrom, LocalDate dateTo,
                                int offset, int limit) throws ApplicationException {
        StringBuilder sql = new StringBuilder(SELECT_FULL).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (py.payment_number LIKE ? OR b.bill_number LIKE ? OR CONCAT(p.first_name,' ',p.last_name) LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (status   != null && !status.isEmpty())  { sql.append("AND py.payment_status=? ");  params.add(status); }
        if (method   != null && !method.isEmpty())   { sql.append("AND py.payment_method=? ");  params.add(method); }
        if (dateFrom != null) { sql.append("AND DATE(py.payment_date) >= ? "); params.add(Date.valueOf(dateFrom)); }
        if (dateTo   != null) { sql.append("AND DATE(py.payment_date) <= ? "); params.add(Date.valueOf(dateTo)); }
        sql.append("ORDER BY py.payment_date DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);

        List<Payment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search payments failed", e);
            throw new ApplicationException("Unable to search payments.", e);
        }
        return list;
    }

    @Override
    public int countSearch(String query, String status, String method,
                           LocalDate dateFrom, LocalDate dateTo) throws ApplicationException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM payments py " +
            "JOIN bills b ON py.bill_id=b.bill_id " +
            "JOIN patients p ON py.patient_id=p.patient_id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (py.payment_number LIKE ? OR b.bill_number LIKE ? OR CONCAT(p.first_name,' ',p.last_name) LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (status   != null && !status.isEmpty())   { sql.append("AND py.payment_status=? ");  params.add(status); }
        if (method   != null && !method.isEmpty())    { sql.append("AND py.payment_method=? ");  params.add(method); }
        if (dateFrom != null) { sql.append("AND DATE(py.payment_date) >= ? "); params.add(Date.valueOf(dateFrom)); }
        if (dateTo   != null) { sql.append("AND DATE(py.payment_date) <= ? "); params.add(Date.valueOf(dateTo)); }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countSearch payments failed", e);
            throw new ApplicationException("Unable to count payments.", e);
        }
    }

    @Override
    public void updateStatus(int paymentId, String status) throws ApplicationException {
        final String sql = "UPDATE payments SET payment_status=? WHERE payment_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status); ps.setInt(2, paymentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "updateStatus payment failed", e);
            throw new ApplicationException("Unable to update payment status.", e);
        }
    }

    @Override
    public String generatePaymentNumber() throws ApplicationException {
        int year = Year.now().getValue();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM payments WHERE YEAR(created_at)=?")) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return String.format("PAY-%d-%06d", year, count + 1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "generatePaymentNumber failed", e);
            throw new ApplicationException("Unable to generate payment number.", e);
        }
    }

    @Override
    public int count() throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM payments");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "count payments failed", e);
            throw new ApplicationException("Unable to count payments.", e);
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object v = params.get(i);
            if (v instanceof String)  ps.setString(i+1, (String) v);
            else if (v instanceof Integer) ps.setInt(i+1, (Integer) v);
            else if (v instanceof Date)    ps.setDate(i+1, (Date) v);
        }
    }
}
