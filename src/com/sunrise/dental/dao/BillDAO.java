package com.sunrise.dental.dao;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Bill;
import com.sunrise.dental.model.BillItem;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * BillDAO — Data access interface for Bill and BillItem entities.
 */
public interface BillDAO {

    int save(Bill bill) throws ApplicationException;

    Bill findById(int billId) throws ApplicationException;

    Bill findByNumber(String billNumber) throws ApplicationException;

    Bill findByAppointmentId(int appointmentId) throws ApplicationException;

    List<Bill> findByPatient(int patientId) throws ApplicationException;

    List<Bill> search(String query, String status, LocalDate dateFrom,
                      LocalDate dateTo, int offset, int limit) throws ApplicationException;

    int countSearch(String query, String status, LocalDate dateFrom, LocalDate dateTo)
            throws ApplicationException;

    void update(Bill bill) throws ApplicationException;

    void updateStatus(int billId, String status) throws ApplicationException;

    String generateBillNumber() throws ApplicationException;

    // BillItems
    void saveBillItem(BillItem item) throws ApplicationException;

    List<BillItem> findItemsByBillId(int billId) throws ApplicationException;

    void deleteItemsByBillId(int billId) throws ApplicationException;

    // Dashboard / reporting
    /** Today's total revenue (amount_paid from completed bills). */
    java.math.BigDecimal getTodayRevenue() throws ApplicationException;

    /** Count of bills with balance_due > 0. */
    int countOutstandingBills() throws ApplicationException;

    /** Retrieve all bills with an outstanding balance (ISSUED or PARTIALLY_PAID). */
    List<Bill> findOutstanding(int limit) throws ApplicationException;

    /** Monthly revenue data for chart (12 months). */
    List<Map<String, Object>> getMonthlyRevenue(int year) throws ApplicationException;

    int count() throws ApplicationException;
}
