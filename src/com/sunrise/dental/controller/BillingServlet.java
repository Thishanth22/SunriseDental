package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.service.BillingService;
import com.sunrise.dental.service.AuditService;
import com.sunrise.dental.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * BillingServlet — Bill generation and management.
 *
 * Actions:
 *   list, new (select appointment), view, generate (POST), receipt
 */
public class BillingServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(BillingServlet.class.getName());
    private static final int PAGE_SIZE = 15;

    private final BillDAO        billDAO       = DAOFactory.getBillDAO();
    private final AppointmentDAO apptDAO       = DAOFactory.getAppointmentDAO();
    private final BillingService billingService= new BillingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            switch (action) {
                case "list"    -> listBills(req, resp);
                case "new"     -> showNewBillForm(req, resp);
                case "view"    -> viewBill(req, resp);
                case "receipt" -> showReceipt(req, resp);
                default        -> listBills(req, resp);
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "BillingServlet GET error", e);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/billing/bill-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            switch (action != null ? action : "") {
                case "generate" -> generateBill(req, resp);
                case "cancel"   -> cancelBill(req, resp);
                default -> resp.sendRedirect(req.getContextPath() + "/billing");
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "BillingServlet POST error", e);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/billing/bill-form.jsp").forward(req, resp);
        }
    }

    private void listBills(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        String query   = req.getParameter("q");
        String status  = req.getParameter("status");
        String fromS   = req.getParameter("dateFrom");
        String toS     = req.getParameter("dateTo");
        int page       = parsePage(req.getParameter("page"));
        int offset     = (page - 1) * PAGE_SIZE;

        LocalDate from = DateUtil.parseDate(fromS);
        LocalDate to   = DateUtil.parseDate(toS);

        List<Bill> bills = billDAO.search(query, status, from, to, offset, PAGE_SIZE);
        int total        = billDAO.countSearch(query, status, from, to);

        req.setAttribute("bills",       bills);
        req.setAttribute("total",       total);
        req.setAttribute("page",        page);
        req.setAttribute("totalPages",  (int) Math.ceil((double) total / PAGE_SIZE));
        req.getRequestDispatcher("/billing/bill-list.jsp").forward(req, resp);
    }

    private void showNewBillForm(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int apptId = parseInt(req.getParameter("appointmentId"), 0);
        Appointment appt = apptId > 0 ? apptDAO.findById(apptId) : null;
        if (appt != null) {
            // Check if bill already exists
            Bill existing = billDAO.findByAppointmentId(apptId);
            if (existing != null) {
                resp.sendRedirect(req.getContextPath() + "/billing?action=view&id=" + existing.getBillId());
                return;
            }
        }
        // Load completed appointments without bills for dropdown
        req.setAttribute("appointment", appt);
        req.getRequestDispatcher("/billing/bill-form.jsp").forward(req, resp);
    }

    private void viewBill(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Bill bill = billDAO.findById(id);
        if (bill == null) { resp.sendRedirect(req.getContextPath() + "/billing"); return; }
        List<BillItem> items = billingService.getBillItems(id);
        req.setAttribute("bill",  bill);
        req.setAttribute("items", items);
        req.getRequestDispatcher("/billing/bill-view.jsp").forward(req, resp);
    }

    private void showReceipt(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Bill bill = billDAO.findById(id);
        if (bill == null) { resp.sendRedirect(req.getContextPath() + "/billing"); return; }
        List<BillItem> items = billingService.getBillItems(id);
        req.setAttribute("bill",  bill);
        req.setAttribute("items", items);
        req.getRequestDispatcher("/billing/receipt.jsp").forward(req, resp);
    }

    private void generateBill(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int apptId = parseInt(req.getParameter("appointmentId"), 0);
        // Server-side: prices fetched from DB in BillingService — not from form
        BigDecimal additionalCharges = parseBigDecimal(req.getParameter("additionalCharges"), BigDecimal.ZERO);
        String     additionalDesc    = ValidationUtil.sanitize(req.getParameter("additionalDesc"));
        BigDecimal discountPct       = parseBigDecimal(req.getParameter("discountPercent"), BigDecimal.ZERO);
        BigDecimal taxPct            = parseBigDecimal(req.getParameter("taxPercent"), BigDecimal.ZERO);
        String     notes             = ValidationUtil.sanitize(req.getParameter("notes"));

        User user = (User) req.getSession().getAttribute("user");
        try {
            int billId = billingService.generateBill(apptId, additionalCharges, additionalDesc,
                discountPct, taxPct, notes, user != null ? user.getUserId() : 0);

            resp.sendRedirect(req.getContextPath() + "/billing?action=view&id=" + billId + "&msg=generated");
        } catch (ApplicationException e) {
            Appointment appt = apptDAO.findById(apptId);
            req.setAttribute("appointment", appt);
            throw e;
        }
    }

    private void cancelBill(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        billDAO.updateStatus(id, "CANCELLED");
        resp.sendRedirect(req.getContextPath() + "/billing?msg=cancelled");
    }

    private BigDecimal parseBigDecimal(String s, BigDecimal def) {
        try { return s != null && !s.isEmpty() ? new BigDecimal(s.trim()) : def; }
        catch (NumberFormatException e) { return def; }
    }

    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; }
        catch (NumberFormatException e) { return def; }
    }

    private int parsePage(String s) { int p = parseInt(s, 1); return p < 1 ? 1 : p; }
}
