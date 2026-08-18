package com.sunrise.dental.dao;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Payment;
import java.time.LocalDate;
import java.util.List;

/**
 * PaymentDAO — Data access interface for Payment entities.
 */
public interface PaymentDAO {

    int save(Payment payment) throws ApplicationException;

    Payment findById(int paymentId) throws ApplicationException;

    Payment findByNumber(String paymentNumber) throws ApplicationException;

    List<Payment> findByBillId(int billId) throws ApplicationException;

    List<Payment> findByPatient(int patientId) throws ApplicationException;

    List<Payment> search(String query, String status, String method,
                         LocalDate dateFrom, LocalDate dateTo,
                         int offset, int limit) throws ApplicationException;

    int countSearch(String query, String status, String method,
                    LocalDate dateFrom, LocalDate dateTo) throws ApplicationException;

    void updateStatus(int paymentId, String status) throws ApplicationException;

    String generatePaymentNumber() throws ApplicationException;

    int count() throws ApplicationException;
}
