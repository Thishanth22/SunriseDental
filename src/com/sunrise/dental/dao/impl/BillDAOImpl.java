package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.BillDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Bill;
import com.sunrise.dental.model.BillItem;
import com.sunrise.dental.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.Year;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BillDAOImpl implements BillDAO {

    private static final Logger logger = Logger.getLogger(BillDAOImpl.class.getName());

    private static final String SELECT_FULL =
        "SELECT b.*, " +
        "  CONCAT(p.first_name,' ',p.last_name) AS patient_name, p.patient_number, " +
        "  p.contact_number AS patient_phone, p.address AS patient_address, " +
        "  a.appointment_number, " +
        "  CONCAT('Dr. ',d.first_name,' ',d.last_name) AS dentist_name, " +
        "  t.treatment_name " +
        "FROM bills b " +
        "JOIN patients     p ON b.patient_id      = p.patient_id " +
        "JOIN appointments a ON b.appointment_id  = a.appointment_id " +
        "JOIN dentists     d ON a.dentist_id       = d.dentist_id " +
        "JOIN treatments   t ON a.treatment_id     = t.treatment_id ";

    private Bill mapRow(ResultSet rs) throws SQLException {
        Bill b = new Bill();
        b.setBillId(rs.getInt("bill_id"));
        b.setBillNumber(rs.getString("bill_number"));
        b.setAppointmentId(rs.getInt("appointment_id"));
        b.setPatientId(rs.getInt("patient_id"));
        b.setConsultationFee(rs.getBigDecimal("consultation_fee"));
        b.setTreatmentCost(rs.getBigDecimal("treatment_cost"));
        b.setAdditionalCharges(rs.getBigDecimal("additional_charges"));
        b.setAdditionalDesc(rs.getString("additional_desc"));
        b.setDiscountPercent(rs.getBigDecimal("discount_percent"));
        b.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        b.setTaxPercent(rs.getBigDecimal("tax_percent"));
        b.setTaxAmount(rs.getBigDecimal("tax_amount"));
        b.setSubTotal(rs.getBigDecimal("sub_total"));
        b.setGrandTotal(rs.getBigDecimal("grand_total"));
        b.setAmountPaid(rs.getBigDecimal("amount_paid"));
        b.setBalanceDue(rs.getBigDecimal("balance_due"));
        b.setBillStatus(rs.getString("bill_status"));
        b.setNotes(rs.getString("notes"));
        java.sql.Date id2 = rs.getDate("issued_date");
        if (id2 != null) b.setIssuedDate(id2.toLocalDate());
        java.sql.Date dd = rs.getDate("due_date");
        if (dd != null) b.setDueDate(dd.toLocalDate());
        b.setCreatedBy(rs.getInt("created_by"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) b.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) b.setUpdatedAt(ua.toLocalDateTime());
        // Display fields
        try {
            b.setPatientName(rs.getString("patient_name"));
            b.setPatientNumber(rs.getString("patient_number"));
            b.setPatientPhone(rs.getString("patient_phone"));
            b.setPatientAddress(rs.getString("patient_address"));
            b.setAppointmentNumber(rs.getString("appointment_number"));
            b.setDentistName(rs.getString("dentist_name"));
            b.setTreatmentName(rs.getString("treatment_name"));
        } catch (SQLException ignore) {}
        return b;
    }

    @Override
    public int save(Bill bill) throws ApplicationException {
        final String sql =
            "INSERT INTO bills (bill_number,appointment_id,patient_id," +
            "consultation_fee,treatment_cost,additional_charges,additional_desc," +
            "discount_percent,discount_amount,tax_percent,tax_amount," +
            "sub_total,grand_total,amount_paid,balance_due," +
            "bill_status,notes,issued_date,due_date,created_by) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, bill.getBillNumber());
            ps.setInt(2, bill.getAppointmentId());
            ps.setInt(3, bill.getPatientId());
            ps.setBigDecimal(4, bill.getConsultationFee());
            ps.setBigDecimal(5, bill.getTreatmentCost());
            ps.setBigDecimal(6, bill.getAdditionalCharges());
            ps.setString(7, bill.getAdditionalDesc());
            ps.setBigDecimal(8, bill.getDiscountPercent());
            ps.setBigDecimal(9, bill.getDiscountAmount());
            ps.setBigDecimal(10, bill.getTaxPercent());
            ps.setBigDecimal(11, bill.getTaxAmount());
            ps.setBigDecimal(12, bill.getSubTotal());
            ps.setBigDecimal(13, bill.getGrandTotal());
            ps.setBigDecimal(14, bill.getAmountPaid() != null ? bill.getAmountPaid() : BigDecimal.ZERO);
            ps.setBigDecimal(15, bill.getBalanceDue() != null ? bill.getBalanceDue() : bill.getGrandTotal());
            ps.setString(16, bill.getBillStatus() != null ? bill.getBillStatus() : "ISSUED");
            ps.setString(17, bill.getNotes());
            ps.setDate(18, bill.getIssuedDate() != null ? java.sql.Date.valueOf(bill.getIssuedDate()) : java.sql.Date.valueOf(LocalDate.now()));
            ps.setDate(19, bill.getDueDate() != null ? java.sql.Date.valueOf(bill.getDueDate()) : java.sql.Date.valueOf(LocalDate.now()));
            if (bill.getCreatedBy() > 0) ps.setInt(20, bill.getCreatedBy());
            else ps.setNull(20, Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save bill failed", e);
            throw new ApplicationException("Unable to generate bill. Please try again.", e);
        }
        return 0;
    }

    @Override
    public Bill findById(int id) throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE b.bill_id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById bill failed", e);
            throw new ApplicationException("Unable to retrieve bill.", e);
        }
        return null;
    }

    @Override
    public Bill findByNumber(String number) throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE b.bill_number=?")) {
            ps.setString(1, number);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByNumber bill failed", e);
            throw new ApplicationException("Unable to retrieve bill.", e);
        }
        return null;
    }

    @Override
    public Bill findByAppointmentId(int appointmentId) throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE b.appointment_id=?")) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByAppointmentId bill failed", e);
            throw new ApplicationException("Unable to retrieve bill.", e);
        }
        return null;
    }

    @Override
    public List<Bill> findByPatient(int patientId) throws ApplicationException {
        List<Bill> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_FULL + "WHERE b.patient_id=? ORDER BY b.issued_date DESC")) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByPatient bill failed", e);
            throw new ApplicationException("Unable to retrieve bills.", e);
        }
        return list;
    }

    @Override
    public List<Bill> search(String query, String status, LocalDate dateFrom,
                             LocalDate dateTo, int offset, int limit) throws ApplicationException {
        StringBuilder sql = new StringBuilder(SELECT_FULL).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (b.bill_number LIKE ? OR p.patient_number LIKE ? OR CONCAT(p.first_name,' ',p.last_name) LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (status != null && !status.isEmpty()) { sql.append("AND b.bill_status=? "); params.add(status); }
        if (dateFrom != null) { sql.append("AND b.issued_date >= ? "); params.add(java.sql.Date.valueOf(dateFrom)); }
        if (dateTo   != null) { sql.append("AND b.issued_date <= ? "); params.add(java.sql.Date.valueOf(dateTo)); }
        sql.append("ORDER BY b.issued_date DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);

        List<Bill> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "search bills failed", e);
            throw new ApplicationException("Unable to search bills.", e);
        }
        return list;
    }

    @Override
    public int countSearch(String query, String status, LocalDate dateFrom, LocalDate dateTo) throws ApplicationException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM bills b JOIN patients p ON b.patient_id=p.patient_id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (b.bill_number LIKE ? OR p.patient_number LIKE ? OR CONCAT(p.first_name,' ',p.last_name) LIKE ?) ");
            String like = "%" + query.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (status   != null && !status.isEmpty())   { sql.append("AND b.bill_status=? ");      params.add(status); }
        if (dateFrom != null)  { sql.append("AND b.issued_date >= ? "); params.add(java.sql.Date.valueOf(dateFrom)); }
        if (dateTo   != null)  { sql.append("AND b.issued_date <= ? "); params.add(java.sql.Date.valueOf(dateTo)); }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countSearch bills failed", e);
            throw new ApplicationException("Unable to count bills.", e);
        }
    }

    @Override
    public void update(Bill bill) throws ApplicationException {
        final String sql =
            "UPDATE bills SET consultation_fee=?,treatment_cost=?,additional_charges=?,additional_desc=?," +
            "discount_percent=?,discount_amount=?,tax_percent=?,tax_amount=?," +
            "sub_total=?,grand_total=?,amount_paid=?,balance_due=?,bill_status=?,notes=? WHERE bill_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, bill.getConsultationFee());
            ps.setBigDecimal(2, bill.getTreatmentCost());
            ps.setBigDecimal(3, bill.getAdditionalCharges());
            ps.setString(4, bill.getAdditionalDesc());
            ps.setBigDecimal(5, bill.getDiscountPercent());
            ps.setBigDecimal(6, bill.getDiscountAmount());
            ps.setBigDecimal(7, bill.getTaxPercent());
            ps.setBigDecimal(8, bill.getTaxAmount());
            ps.setBigDecimal(9, bill.getSubTotal());
            ps.setBigDecimal(10, bill.getGrandTotal());
            ps.setBigDecimal(11, bill.getAmountPaid());
            ps.setBigDecimal(12, bill.getBalanceDue());
            ps.setString(13, bill.getBillStatus());
            ps.setString(14, bill.getNotes());
            ps.setInt(15, bill.getBillId());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "update bill failed", e);
            throw new ApplicationException("Unable to update bill.", e);
        }
    }

    @Override
    public void updateStatus(int billId, String status) throws ApplicationException {
        final String sql = "UPDATE bills SET bill_status=? WHERE bill_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status); ps.setInt(2, billId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "updateStatus bill failed", e);
            throw new ApplicationException("Unable to update bill status.", e);
        }
    }

    @Override
    public String generateBillNumber() throws ApplicationException {
        int year = Year.now().getValue();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM bills WHERE YEAR(created_at)=?")) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                int count = rs.next() ? rs.getInt(1) : 0;
                return String.format("BIL-%d-%06d", year, count + 1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "generateBillNumber failed", e);
            throw new ApplicationException("Unable to generate bill number.", e);
        }
    }

    @Override
    public void saveBillItem(BillItem item) throws ApplicationException {
        final String sql =
            "INSERT INTO bill_items (bill_id,item_type,description,unit_price,quantity,total_price) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getBillId());
            ps.setString(2, item.getItemType());
            ps.setString(3, item.getDescription());
            ps.setBigDecimal(4, item.getUnitPrice());
            ps.setBigDecimal(5, item.getQuantity());
            ps.setBigDecimal(6, item.getTotalPrice());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "saveBillItem failed", e);
            throw new ApplicationException("Unable to save bill item.", e);
        }
    }

    @Override
    public List<BillItem> findItemsByBillId(int billId) throws ApplicationException {
        final String sql = "SELECT * FROM bill_items WHERE bill_id=? ORDER BY item_id";
        List<BillItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, billId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BillItem i = new BillItem();
                    i.setItemId(rs.getInt("item_id"));
                    i.setBillId(rs.getInt("bill_id"));
                    i.setItemType(rs.getString("item_type"));
                    i.setDescription(rs.getString("description"));
                    i.setUnitPrice(rs.getBigDecimal("unit_price"));
                    i.setQuantity(rs.getBigDecimal("quantity"));
                    i.setTotalPrice(rs.getBigDecimal("total_price"));
                    list.add(i);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findItemsByBillId failed", e);
            throw new ApplicationException("Unable to retrieve bill items.", e);
        }
        return list;
    }

    @Override
    public void deleteItemsByBillId(int billId) throws ApplicationException {
        final String sql = "DELETE FROM bill_items WHERE bill_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, billId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "deleteItemsByBillId failed", e);
            throw new ApplicationException("Unable to delete bill items.", e);
        }
    }

    @Override
    public BigDecimal getTodayRevenue() throws ApplicationException {
        final String sql =
            "SELECT COALESCE(SUM(amount),0) FROM payments " +
            "WHERE DATE(payment_date)=CURDATE() AND payment_status='COMPLETED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "getTodayRevenue failed", e);
            throw new ApplicationException("Unable to calculate revenue.", e);
        }
    }

    @Override
    public int countOutstandingBills() throws ApplicationException {
        final String sql = "SELECT COUNT(*) FROM bills WHERE balance_due>0 AND bill_status NOT IN ('CANCELLED','REFUNDED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "countOutstandingBills failed", e);
            throw new ApplicationException("Unable to count outstanding bills.", e);
        }
    }

    @Override
    public List<Map<String, Object>> getMonthlyRevenue(int year) throws ApplicationException {
        final String sql =
            "SELECT MONTH(payment_date) AS month, COALESCE(SUM(amount),0) AS revenue " +
            "FROM payments WHERE YEAR(payment_date)=? AND payment_status='COMPLETED' " +
            "GROUP BY MONTH(payment_date) ORDER BY month";
        List<Map<String, Object>> result = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("month", rs.getInt("month"));
                    row.put("revenue", rs.getBigDecimal("revenue"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "getMonthlyRevenue failed", e);
            throw new ApplicationException("Unable to retrieve revenue data.", e);
        }
        return result;
    }

    @Override
    public int count() throws ApplicationException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM bills");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "count bills failed", e);
            throw new ApplicationException("Unable to count bills.", e);
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object v = params.get(i);
            if (v instanceof String)  ps.setString(i+1, (String) v);
            else if (v instanceof Integer) ps.setInt(i+1, (Integer) v);
            else if (v instanceof java.sql.Date)    ps.setDate(i+1, (java.sql.Date) v);
        }
    }
}
