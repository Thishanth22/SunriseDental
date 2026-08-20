package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.service.AuditService;
import com.sunrise.dental.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/** DentistServlet — CRUD for dentists. */
public class DentistServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DentistServlet.class.getName());
    private final DentistDAO   dentistDAO  = DAOFactory.getDentistDAO();
    private final AuditService auditService= new AuditService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            switch (action) {
                case "list" -> listDentists(req, resp);
                case "new"  -> showForm(req, resp, null);
                case "view" -> viewDentist(req, resp);
                case "edit" -> editDentist(req, resp);
                default     -> listDentists(req, resp);
            }
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/dentists/dentist-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            switch (action != null ? action : "") {
                case "save"       -> saveDentist(req, resp);
                case "update"     -> updateDentist(req, resp);
                case "deactivate" -> deactivate(req, resp);
                default -> resp.sendRedirect(req.getContextPath() + "/dentists");
            }
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/dentists/dentist-form.jsp").forward(req, resp);
        }
    }

    private void listDentists(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        String q = req.getParameter("q");
        List<Dentist> list = (q != null && !q.isEmpty())
            ? dentistDAO.search(q, 0, 100) : dentistDAO.findAll();
        req.setAttribute("dentists", list);
        req.setAttribute("q", q);
        req.getRequestDispatcher("/dentists/dentist-list.jsp").forward(req, resp);
    }

    private void viewDentist(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Dentist d = dentistDAO.findById(id);
        if (d == null) { resp.sendRedirect(req.getContextPath() + "/dentists"); return; }
        req.setAttribute("dentist", d);
        req.getRequestDispatcher("/dentists/dentist-view.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Dentist d)
            throws ServletException, IOException {
        req.setAttribute("dentist", d);
        req.getRequestDispatcher("/dentists/dentist-form.jsp").forward(req, resp);
    }

    private void editDentist(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Dentist d = dentistDAO.findById(id);
        if (d == null) { resp.sendRedirect(req.getContextPath() + "/dentists"); return; }
        showForm(req, resp, d);
    }

    private void saveDentist(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        Dentist d = buildFromForm(req);
        d.setDentistNumber(dentistDAO.generateDentistNumber());
        int id = dentistDAO.save(d);
        User u = (User) req.getSession().getAttribute("user");
        auditService.log(u != null ? u.getUserId() : null, u != null ? u.getUsername() : null,
            "DENTIST_CREATED", "DENTIST", id, "Dentist " + d.getFullName() + " added", req.getRemoteAddr(), null);
        resp.sendRedirect(req.getContextPath() + "/dentists?action=view&id=" + id + "&msg=saved");
    }

    private void updateDentist(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        Dentist d = buildFromForm(req);
        d.setDentistId(parseInt(req.getParameter("dentistId"), 0));
        dentistDAO.update(d);
        User u = (User) req.getSession().getAttribute("user");
        auditService.log(u != null ? u.getUserId() : null, u != null ? u.getUsername() : null,
            "DENTIST_UPDATED", "DENTIST", d.getDentistId(), "Dentist #" + d.getDentistId() + " updated", req.getRemoteAddr(), null);
        resp.sendRedirect(req.getContextPath() + "/dentists?action=view&id=" + d.getDentistId() + "&msg=updated");
    }

    private void deactivate(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        dentistDAO.updateStatus(id, "INACTIVE");
        resp.sendRedirect(req.getContextPath() + "/dentists?msg=deactivated");
    }

    private Dentist buildFromForm(HttpServletRequest req) {
        Dentist d = new Dentist();
        d.setFirstName(sanitize(req.getParameter("firstName")));
        d.setLastName(sanitize(req.getParameter("lastName")));
        d.setSpecialization(sanitize(req.getParameter("specialization")));
        d.setQualification(sanitize(req.getParameter("qualification")));
        d.setLicenseNumber(sanitize(req.getParameter("licenseNumber")));
        d.setContactNumber(sanitize(req.getParameter("contactNumber")));
        d.setEmail(sanitize(req.getParameter("email")));
        d.setAvailableMonday("on".equals(req.getParameter("monday")));
        d.setAvailableTuesday("on".equals(req.getParameter("tuesday")));
        d.setAvailableWednesday("on".equals(req.getParameter("wednesday")));
        d.setAvailableThursday("on".equals(req.getParameter("thursday")));
        d.setAvailableFriday("on".equals(req.getParameter("friday")));
        d.setAvailableSaturday("on".equals(req.getParameter("saturday")));
        d.setAvailableSunday("on".equals(req.getParameter("sunday")));
        d.setWorkStartTime(DateUtil.parseTime(req.getParameter("workStart")));
        d.setWorkEndTime(DateUtil.parseTime(req.getParameter("workEnd")));
        d.setStatus(req.getParameter("status") != null ? req.getParameter("status") : "ACTIVE");
        d.setNotes(sanitize(req.getParameter("notes")));
        return d;
    }

    private String sanitize(String s) { return s != null ? ValidationUtil.sanitize(s.trim()) : null; }
    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; } catch (NumberFormatException e) { return def; }
    }
}
