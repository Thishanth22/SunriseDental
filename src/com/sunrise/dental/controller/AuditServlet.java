package com.sunrise.dental.controller;

import com.sunrise.dental.service.AuditService;
import com.sunrise.dental.model.AuditLog;
import com.sunrise.dental.exception.ApplicationException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/** AuditServlet — View audit logs (Admin only). */
public class AuditServlet extends HttpServlet {
    private final AuditService auditService = new AuditService();
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int page   = parsePage(req.getParameter("page"));
        int offset = (page - 1) * PAGE_SIZE;
        String q   = req.getParameter("q");
        String act = req.getParameter("action_filter");
        try {
            List<AuditLog> logs;
            int total;
            if ((q != null && !q.isEmpty()) || (act != null && !act.isEmpty())) {
                logs  = auditService.search(q, act, offset, PAGE_SIZE);
                total = auditService.count();
            } else {
                logs  = auditService.findAll(offset, PAGE_SIZE);
                total = auditService.count();
            }
            req.setAttribute("logs",       logs);
            req.setAttribute("total",      total);
            req.setAttribute("page",       page);
            req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
            req.getRequestDispatcher("/audit/audit-list.jsp").forward(req, resp);
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/audit/audit-list.jsp").forward(req, resp);
        }
    }
    private int parsePage(String s) {
        try { int p = s != null ? Integer.parseInt(s.trim()) : 1; return p < 1 ? 1 : p; }
        catch (NumberFormatException e) { return 1; }
    }
}
