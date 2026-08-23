package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.service.AppointmentService;
import com.sunrise.dental.service.AuditService;
import com.sunrise.dental.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AppointmentServlet — All appointment operations.
 *
 * Actions:
 *   list, new, view, edit, save, update,
 *   cancel, confirm, complete, check-availability (AJAX)
 */
public class AppointmentServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(AppointmentServlet.class.getName());
    private static final int PAGE_SIZE = 15;

    private final AppointmentDAO     apptDAO     = DAOFactory.getAppointmentDAO();
    private final PatientDAO         patientDAO  = DAOFactory.getPatientDAO();
    private final DentistDAO         dentistDAO  = DAOFactory.getDentistDAO();
    private final TreatmentDAO       treatDAO    = DAOFactory.getTreatmentDAO();
    private final AppointmentService apptService = new AppointmentService();
    private final AuditService       auditService= new AuditService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            switch (action) {
                case "list"               -> listAppointments(req, resp);
                case "new"                -> showForm(req, resp, null);
                case "view"               -> viewAppointment(req, resp);
                case "edit"               -> editAppointment(req, resp);
                case "check-availability" -> checkAvailability(req, resp);
                default                   -> listAppointments(req, resp);
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "AppointmentServlet GET error", e);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/appointments/appointment-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            switch (action != null ? action : "") {
                case "save"     -> saveAppointment(req, resp);
                case "update"   -> updateAppointment(req, resp);
                case "cancel"   -> cancelAppointment(req, resp);
                case "confirm"  -> updateStatus(req, resp, "CONFIRMED");
                case "complete" -> completeAppointment(req, resp);
                case "noshow"   -> updateStatus(req, resp, "NO_SHOW");
                default -> resp.sendRedirect(req.getContextPath() + "/appointments");
            }
        } catch (ApplicationException e) {
            logger.log(Level.WARNING, "AppointmentServlet POST error: " + e.getMessage());
            req.setAttribute("error", e.getMessage());
            Appointment appt = buildFromForm(req);
            if ("update".equalsIgnoreCase(action)) {
                appt.setAppointmentId(parseInt(req.getParameter("appointmentId"), 0));
                appt.setAppointmentNumber(req.getParameter("appointmentNumber"));
            }
            req.setAttribute("appointment", appt);
            loadFormDropdowns(req);
            req.getRequestDispatcher("/appointments/appointment-form.jsp").forward(req, resp);
        }
    }

    // -------------------------------------------------------
    private void listAppointments(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        String query    = req.getParameter("q");
        String status   = req.getParameter("status");
        String dateFromS= req.getParameter("dateFrom");
        String dateToS  = req.getParameter("dateTo");
        String dentistS = req.getParameter("dentistId");
        int page        = parsePage(req.getParameter("page"));
        int offset      = (page - 1) * PAGE_SIZE;

        LocalDate dateFrom = DateUtil.parseDate(dateFromS);
        LocalDate dateTo   = DateUtil.parseDate(dateToS);
        Integer dentistId  = dentistS != null && !dentistS.isEmpty() ? parseInt(dentistS, 0) : null;

        List<Appointment> list = apptDAO.search(query, status, dateFrom, dateTo, dentistId, offset, PAGE_SIZE);
        int total = apptDAO.countSearch(query, status, dateFrom, dateTo, dentistId);

        req.setAttribute("appointments", list);
        req.setAttribute("total",        total);
        req.setAttribute("page",         page);
        req.setAttribute("pageSize",     PAGE_SIZE);
        req.setAttribute("totalPages",   (int) Math.ceil((double) total / PAGE_SIZE));
        req.setAttribute("dentists",     dentistDAO.findAllActive());
        req.setAttribute("q",            query);
        req.setAttribute("statusFilter", status);
        req.setAttribute("dateFrom",     dateFromS);
        req.setAttribute("dateTo",       dateToS);
        req.getRequestDispatcher("/appointments/appointment-list.jsp").forward(req, resp);
    }

    private void viewAppointment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Appointment appt = apptDAO.findById(id);
        if (appt == null) { resp.sendRedirect(req.getContextPath() + "/appointments"); return; }
        req.setAttribute("appointment", appt);
        req.getRequestDispatcher("/appointments/appointment-view.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Appointment appt)
            throws ApplicationException, ServletException, IOException {
        loadFormDropdowns(req);
        req.setAttribute("appointment", appt);
        req.setAttribute("today", DateUtil.todayString());
        req.getRequestDispatcher("/appointments/appointment-form.jsp").forward(req, resp);
    }

    private void editAppointment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Appointment appt = apptDAO.findById(id);
        if (appt == null) { resp.sendRedirect(req.getContextPath() + "/appointments"); return; }
        showForm(req, resp, appt);
    }

    private void saveAppointment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        Appointment appt = buildFromForm(req);
        syncPatientContactInfo(appt);
        User user = (User) req.getSession().getAttribute("user");
        boolean isAdmin = user != null && user.isAdmin();
        int id = apptService.bookAppointment(appt, user != null ? user.getUserId() : 0, isAdmin);
        resp.sendRedirect(req.getContextPath() + "/appointments?action=view&id=" + id + "&msg=booked");
    }

    private void updateAppointment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        Appointment appt = buildFromForm(req);
        syncPatientContactInfo(appt);
        appt.setAppointmentId(parseInt(req.getParameter("appointmentId"), 0));
        appt.setAppointmentNumber(req.getParameter("appointmentNumber"));
        User user = (User) req.getSession().getAttribute("user");
        boolean isAdmin = user != null && user.isAdmin();
        apptService.updateAppointment(appt, user != null ? user.getUserId() : 0, isAdmin);
        resp.sendRedirect(req.getContextPath() + "/appointments?action=view&id=" + appt.getAppointmentId() + "&msg=updated");
    }

    private void cancelAppointment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        String reason = ValidationUtil.sanitize(req.getParameter("reason"));
        User user = (User) req.getSession().getAttribute("user");
        apptService.cancelAppointment(id, reason, user != null ? user.getUserId() : 0);
        resp.sendRedirect(req.getContextPath() + "/appointments?msg=cancelled");
    }

    private void completeAppointment(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        User user = (User) req.getSession().getAttribute("user");
        apptService.completeAppointment(id, user != null ? user.getUserId() : 0);
        resp.sendRedirect(req.getContextPath() + "/appointments?action=view&id=" + id + "&msg=completed");
    }

    private void updateStatus(HttpServletRequest req, HttpServletResponse resp, String newStatus)
            throws ApplicationException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        apptDAO.updateStatus(id, newStatus, null);
        resp.sendRedirect(req.getContextPath() + "/appointments?action=view&id=" + id);
    }

    /** AJAX endpoint for double-booking check from the booking form. */
    private void checkAvailability(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        int dentistId  = parseInt(req.getParameter("dentistId"), 0);
        int patientId  = parseInt(req.getParameter("patientId"), 0);
        String dateS   = req.getParameter("date");
        String timeS   = req.getParameter("time");
        String treatS  = req.getParameter("treatmentId");
        int excludeId  = parseInt(req.getParameter("excludeId"), 0);

        if (dentistId == 0 || dateS == null || dateS.trim().isEmpty() || timeS == null || timeS.trim().isEmpty()) {
            resp.getWriter().write("{\"available\":false,\"message\":\"Please select a dentist, date, and time.\"}");
            return;
        }

        LocalDate date = DateUtil.parseDate(dateS);
        java.time.LocalTime startTime = DateUtil.parseTime(timeS);
        if (date == null || startTime == null) {
            resp.getWriter().write("{\"available\":false,\"message\":\"Invalid date or time format.\"}");
            return;
        }

        Dentist dentist = dentistDAO.findById(dentistId);
        if (dentist == null || !dentist.isActive()) {
            resp.getWriter().write("{\"available\":false,\"message\":\"The selected dentist is currently unavailable.\"}");
            return;
        }

        java.time.DayOfWeek dow = date.getDayOfWeek();
        if (!dentist.isAvailableOn(dow)) {
            String days = dentist.getAvailableDaysSummary();
            resp.getWriter().write("{\"available\":false,\"message\":\"" + dentist.getFullName() + 
                " is not in clinic on " + dow + "s. Available clinic days: " + days + ".\"}");
            return;
        }

        if (startTime.isBefore(dentist.getWorkStartTime()) || startTime.isAfter(dentist.getWorkEndTime())) {
            resp.getWriter().write("{\"available\":false,\"message\":\"Selected time (" + 
                DateUtil.formatTime(startTime) + ") is outside working hours (" + 
                DateUtil.formatTime(dentist.getWorkStartTime()) + " - " + 
                DateUtil.formatTime(dentist.getWorkEndTime()) + ").\"}");
            return;
        }

        int durationMins = 30;
        if (treatS != null && !treatS.trim().isEmpty()) {
            Treatment t = treatDAO.findById(parseInt(treatS, 0));
            if (t != null && t.getDurationMins() > 0) durationMins = t.getDurationMins();
        }
        java.time.LocalTime endTime = startTime.plusMinutes(durationMins);

        if (endTime.isAfter(dentist.getWorkEndTime())) {
            resp.getWriter().write("{\"available\":false,\"message\":\"Treatment duration (" + 
                durationMins + " mins) exceeds shift end (" + DateUtil.formatTime(dentist.getWorkEndTime()) + "). Choose an earlier slot.\"}");
            return;
        }

        boolean conflict = apptDAO.hasConflict(dentistId, date, startTime, endTime, excludeId);
        if (conflict) {
            resp.getWriter().write("{\"available\":false,\"message\":\"" + dentist.getFullName() + 
                " already has an appointment booked overlapping this slot (" + DateUtil.formatTime(startTime) + " - " + DateUtil.formatTime(endTime) + ").\"}");
            return;
        }

        if (patientId > 0 && apptDAO.hasPatientConflict(patientId, date, startTime, endTime, excludeId)) {
            resp.getWriter().write("{\"available\":false,\"message\":\"This patient already has an appointment overlapping this slot.\"}");
            return;
        }

        resp.getWriter().write("{\"available\":true,\"message\":\"Slot available: " + 
            DateUtil.formatTime(startTime) + " - " + DateUtil.formatTime(endTime) + 
            " (" + durationMins + " mins with " + dentist.getFullName() + ")\"}");
    }

    private void loadFormDropdowns(HttpServletRequest req) {
        try {
            req.setAttribute("patients",   patientDAO.findAll(0, 9999));
            req.setAttribute("dentists",   dentistDAO.findAllActive());
            req.setAttribute("treatments", treatDAO.findAllActive());
        } catch (ApplicationException e) {
            logger.log(Level.WARNING, "Could not load form dropdowns", e);
        }
    }

    private Appointment buildFromForm(HttpServletRequest req) {
        return Appointment.builder()
                .patientId(parseInt(req.getParameter("patientId"), 0))
                .dentistId(parseInt(req.getParameter("dentistId"), 0))
                .treatmentId(parseInt(req.getParameter("treatmentId"), 0))
                .appointmentDate(DateUtil.parseDate(req.getParameter("appointmentDate")))
                .appointmentTime(DateUtil.parseTime(req.getParameter("appointmentTime")))
                .priority(req.getParameter("priority"))
                .notes(ValidationUtil.sanitize(req.getParameter("notes")))
                .patientPhone(ValidationUtil.sanitize(req.getParameter("patientPhone")))
                .patientAddress(ValidationUtil.sanitize(req.getParameter("patientAddress")))
                .build();
    }

    private void syncPatientContactInfo(Appointment appt) {
        if (appt.getPatientId() > 0 && (appt.getPatientPhone() != null || appt.getPatientAddress() != null)) {
            try {
                Patient p = patientDAO.findById(appt.getPatientId());
                if (p != null) {
                    boolean changed = false;
                    if (appt.getPatientPhone() != null && !appt.getPatientPhone().trim().isEmpty()
                            && !appt.getPatientPhone().trim().equalsIgnoreCase(p.getContactNumber())) {
                        p.setContactNumber(appt.getPatientPhone().trim());
                        changed = true;
                    }
                    if (appt.getPatientAddress() != null && !appt.getPatientAddress().trim().isEmpty()
                            && !appt.getPatientAddress().trim().equalsIgnoreCase(p.getAddress())) {
                        p.setAddress(appt.getPatientAddress().trim());
                        changed = true;
                    }
                    if (changed) {
                        patientDAO.update(p);
                    }
                }
            } catch (Exception e) {
                logger.log(Level.WARNING, "Could not synchronize patient contact details during appointment save", e);
            }
        }
    }

    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; }
        catch (NumberFormatException e) { return def; }
    }

    private int parsePage(String s) { int p = parseInt(s, 1); return p < 1 ? 1 : p; }
}
