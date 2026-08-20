package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.service.BillingService;
import com.sunrise.dental.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/** PaymentServlet — payment processing and history. */
public class PaymentServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(PaymentServlet.class.getName());
    private static final int PAGE_SIZE = 15;
    private final PaymentDAO     paymentDAO    = DAOFactory.getPaymentDAO();
    private final BillDAO        billDAO       = DAOFactory.getBillDAO();
    private final BillingService billingService= new BillingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            switch (action) {
                case "list" -> listPayments(req, resp);
                case "new"  -> showPaymentForm(req, resp);
                case "view" -> viewPayment(req, resp);
                default     -> listPayments(req, resp);
            }
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/payments/payment-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            if ("pay".equals(action)) processPayment(req, resp);
            else resp.sendRedirect(req.getContextPath() + "/payments");
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/payments/payment-form.jsp").forward(req, resp);
        }
    }

    private void listPayments(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int page = parsePage(req.getParameter("page"));
        int offset = (page - 1) * PAGE_SIZE;
        List<Payment> list = paymentDAO.search(req.getParameter("q"), req.getParameter("status"),
            req.getParameter("method"),
            DateUtil.parseDate(req.getParameter("dateFrom")),
            DateUtil.parseDate(req.getParameter("dateTo")),
            offset, PAGE_SIZE);
        int total = paymentDAO.countSearch(req.getParameter("q"), req.getParameter("status"),
            req.getParameter("method"),
            DateUtil.parseDate(req.getParameter("dateFrom")),
            DateUtil.parseDate(req.getParameter("dateTo")));
        req.setAttribute("payments", list);
        req.setAttribute("total",    total);
        req.setAttribute("page",     page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.getRequestDispatcher("/payments/payment-list.jsp").forward(req, resp);
    }

    private void showPaymentForm(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int billId = parseInt(req.getParameter("billId"), 0);
        Bill bill = billId > 0 ? billDAO.findById(billId) : null;
        req.setAttribute("bill", bill);
        req.getRequestDispatcher("/payments/payment-form.jsp").forward(req, resp);
    }

    private void viewPayment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Payment p = paymentDAO.findById(id);
        req.setAttribute("payment", p);
        req.getRequestDispatcher("/payments/payment-view.jsp").forward(req, resp);
    }

    private void processPayment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int billId = parseInt(req.getParameter("billId"), 0);
        BigDecimal amount = parseBD(req.getParameter("amount"), BigDecimal.ZERO);
        String method     = req.getParameter("paymentMethod");
        String ref        = ValidationUtil.sanitize(req.getParameter("transactionRef"));
        String notes      = ValidationUtil.sanitize(req.getParameter("notes"));
        User user = (User) req.getSession().getAttribute("user");
        try {
            int payId = billingService.processPayment(billId, amount, method, ref, notes,
                user != null ? user.getUserId() : 0);
            resp.sendRedirect(req.getContextPath() + "/payments?action=view&id=" + payId + "&msg=paid");
        } catch (ApplicationException e) {
            Bill bill = billDAO.findById(billId);
            req.setAttribute("bill", bill);
            throw e;
        }
    }

    private BigDecimal parseBD(String s, BigDecimal def) {
        try { return s != null && !s.isEmpty() ? new BigDecimal(s.trim()) : def; }
        catch (NumberFormatException e) { return def; }
    }
    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; } catch (NumberFormatException e) { return def; }
    }
    private int parsePage(String s) { int p = parseInt(s, 1); return p < 1 ? 1 : p; }
}
