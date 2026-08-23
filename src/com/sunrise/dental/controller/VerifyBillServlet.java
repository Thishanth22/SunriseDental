package com.sunrise.dental.controller;

import com.sunrise.dental.dao.BillDAO;
import com.sunrise.dental.dao.DAOFactory;
import com.sunrise.dental.dao.PatientDAO;
import com.sunrise.dental.dao.PaymentDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Bill;
import com.sunrise.dental.model.BillItem;
import com.sunrise.dental.model.Patient;
import com.sunrise.dental.model.Payment;
import com.sunrise.dental.service.BillingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * VerifyBillServlet — Public Digital Verification Portal for Invoices & QR Codes.
 *
 * Mapped to: /verify-bill
 * Accessible publicly (without staff authentication) when scanning invoice QR codes.
 * Shows verified customer details, clinical info, and billing breakdown.
 */
@WebServlet(name = "VerifyBillServlet", urlPatterns = {"/verify-bill"})
public class VerifyBillServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(VerifyBillServlet.class.getName());

    private final BillDAO        billDAO;
    private final PaymentDAO     paymentDAO;
    private final PatientDAO     patientDAO;
    private final BillingService billingService;

    public VerifyBillServlet() {
        this.billDAO        = DAOFactory.getBillDAO();
        this.paymentDAO     = DAOFactory.getPaymentDAO();
        this.patientDAO     = DAOFactory.getPatientDAO();
        this.billingService = new BillingService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String billNum = req.getParameter("num");
        if (billNum == null || billNum.trim().isEmpty()) {
            billNum = req.getParameter("billNumber");
        }
        String idStr = req.getParameter("id");

        try {
            Bill bill = null;
            if (billNum != null && !billNum.trim().isEmpty()) {
                bill = billDAO.findByNumber(billNum.trim());
            } else if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr.trim());
                    bill = billDAO.findById(id);
                } catch (NumberFormatException ignored) {}
            }

            if (bill != null) {
                List<BillItem> items    = billingService.getBillItems(bill.getBillId());
                List<Payment>  payments = paymentDAO.findByBillId(bill.getBillId());
                Patient        patient  = patientDAO.findById(bill.getPatientId());

                req.setAttribute("bill",     bill);
                req.setAttribute("items",    items);
                req.setAttribute("payments", payments);
                req.setAttribute("patient",  patient);
                req.setAttribute("verified", true);
            } else {
                req.setAttribute("verified", false);
                req.setAttribute("searchedQuery", billNum != null ? billNum : idStr);
            }

            req.getRequestDispatcher("/billing/verify-bill.jsp").forward(req, resp);

        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "VerifyBillServlet error", e);
            req.setAttribute("error", "Unable to verify invoice at this time.");
            req.setAttribute("verified", false);
            req.getRequestDispatcher("/billing/verify-bill.jsp").forward(req, resp);
        }
    }
}
