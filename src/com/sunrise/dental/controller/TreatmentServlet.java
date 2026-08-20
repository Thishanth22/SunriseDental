package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.service.AuditService;
import com.sunrise.dental.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.logging.Logger;

/** TreatmentServlet — CRUD for treatment catalog. */
public class TreatmentServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(TreatmentServlet.class.getName());
    private final TreatmentDAO treatDAO    = DAOFactory.getTreatmentDAO();
    private final AuditService auditService= new AuditService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            switch (action) {
                case "list" -> {
                    String q = req.getParameter("q");
                    List<Treatment> list = (q != null && !q.isEmpty())
                        ? treatDAO.search(q, 0, 100) : treatDAO.findAll();
                    req.setAttribute("treatments", list);
                    req.getRequestDispatcher("/treatments/treatment-list.jsp").forward(req, resp);
                }
                case "new" -> {
                    req.setAttribute("treatment", null);
                    req.getRequestDispatcher("/treatments/treatment-form.jsp").forward(req, resp);
                }
                case "edit" -> {
                    int id = parseInt(req.getParameter("id"), 0);
                    req.setAttribute("treatment", treatDAO.findById(id));
                    req.getRequestDispatcher("/treatments/treatment-form.jsp").forward(req, resp);
                }
                default -> resp.sendRedirect(req.getContextPath() + "/treatments");
            }
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/treatments/treatment-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            switch (action != null ? action : "") {
                case "save" -> {
                    Treatment t = buildFromForm(req);
                    int id = treatDAO.save(t);
                    User u = (User) req.getSession().getAttribute("user");
                    auditService.log(u != null ? u.getUserId() : null, u != null ? u.getUsername() : null,
                        "TREATMENT_CREATED", "TREATMENT", id, "Treatment: " + t.getTreatmentName(), req.getRemoteAddr(), null);
                    resp.sendRedirect(req.getContextPath() + "/treatments?msg=saved");
                }
                case "update" -> {
                    Treatment t = buildFromForm(req);
                    t.setTreatmentId(parseInt(req.getParameter("treatmentId"), 0));
                    treatDAO.update(t);
                    resp.sendRedirect(req.getContextPath() + "/treatments?msg=updated");
                }
                case "discontinue" -> {
                    treatDAO.updateStatus(parseInt(req.getParameter("id"), 0), "DISCONTINUED");
                    resp.sendRedirect(req.getContextPath() + "/treatments?msg=discontinued");
                }
                default -> resp.sendRedirect(req.getContextPath() + "/treatments");
            }
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/treatments/treatment-form.jsp").forward(req, resp);
        }
    }

    private Treatment buildFromForm(HttpServletRequest req) {
        Treatment t = new Treatment();
        t.setTreatmentCode(ValidationUtil.sanitize(req.getParameter("treatmentCode")));
        t.setTreatmentName(ValidationUtil.sanitize(req.getParameter("treatmentName")));
        t.setCategory(ValidationUtil.sanitize(req.getParameter("category")));
        t.setDescription(ValidationUtil.sanitize(req.getParameter("description")));
        try { t.setBaseCost(new BigDecimal(req.getParameter("baseCost").trim())); }
        catch (Exception e) { t.setBaseCost(BigDecimal.ZERO); }
        try { t.setDurationMins(Integer.parseInt(req.getParameter("durationMins").trim())); }
        catch (Exception e) { t.setDurationMins(30); }
        t.setRequiresFollowup("on".equals(req.getParameter("requiresFollowup")));
        t.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "ACTIVE");
        return t;
    }
    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; } catch (NumberFormatException e) { return def; }
    }
}
