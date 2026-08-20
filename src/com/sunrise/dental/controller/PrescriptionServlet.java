package com.sunrise.dental.controller;

import com.sunrise.dental.dao.DentistDAO;
import com.sunrise.dental.dao.PatientDAO;
import com.sunrise.dental.dao.impl.DentistDAOImpl;
import com.sunrise.dental.dao.impl.PatientDAOImpl;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.service.PrescriptionService;
import com.sunrise.dental.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * PrescriptionServlet — E-Prescriptions controller.
 */
public class PrescriptionServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(PrescriptionServlet.class.getName());
    private static final int PAGE_SIZE = 15;

    private final PrescriptionService rxService  = new PrescriptionService();
    private final PatientDAO          patientDAO = new PatientDAOImpl();
    private final DentistDAO          dentistDAO = new DentistDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "list" -> listPrescriptions(req, resp);
                case "new"  -> showNewPrescriptionForm(req, resp);
                case "view" -> viewPrescription(req, resp);
                default     -> listPrescriptions(req, resp);
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "PrescriptionServlet GET error", e);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/errors/500.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try {
            if ("save".equals(action)) {
                savePrescription(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/prescriptions");
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "PrescriptionServlet POST error", e);
            req.setAttribute("error", e.getMessage());
            // Recover form data
            try {
                int patientId = parseInt(req.getParameter("patientId"), 0);
                req.setAttribute("patient", patientDAO.findById(patientId));
                req.setAttribute("dentists", dentistDAO.findAllActive());
                req.getRequestDispatcher("/prescriptions/prescription-form.jsp").forward(req, resp);
            } catch (Exception ex) {
                resp.sendRedirect(req.getContextPath() + "/prescriptions");
            }
        }
    }

    private void listPrescriptions(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int page = parsePage(req.getParameter("page"));
        int offset = (page - 1) * PAGE_SIZE;
        String query = req.getParameter("q");

        List<Prescription> list = rxService.searchPrescriptions(query, offset, PAGE_SIZE);
        int total = rxService.countSearch(query);

        req.setAttribute("prescriptions", list);
        req.setAttribute("total", total);
        req.setAttribute("page", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.getRequestDispatcher("/prescriptions/prescription-list.jsp").forward(req, resp);
    }

    private void showNewPrescriptionForm(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int patientId = parseInt(req.getParameter("patientId"), 0);
        Patient patient = patientDAO.findById(patientId);
        if (patient == null) {
            throw new ApplicationException("Patient is required to write a prescription.");
        }

        User user = (User) req.getSession().getAttribute("user");
        if (user != null && "DENTIST".equalsIgnoreCase(user.getRoleName())) {
            Dentist dentist = dentistDAO.findByUserId(user.getUserId());
            req.setAttribute("selectedDentist", dentist);
        }

        req.setAttribute("patient", patient);
        req.setAttribute("dentists", dentistDAO.findAllActive());
        req.setAttribute("appointmentId", req.getParameter("appointmentId"));
        req.getRequestDispatcher("/prescriptions/prescription-form.jsp").forward(req, resp);
    }

    private void viewPrescription(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Prescription rx = rxService.getPrescription(id);
        if (rx == null) {
            resp.sendRedirect(req.getContextPath() + "/prescriptions");
            return;
        }
        req.setAttribute("prescription", rx);
        req.getRequestDispatcher("/prescriptions/prescription-view.jsp").forward(req, resp);
    }

    private void savePrescription(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int patientId = parseInt(req.getParameter("patientId"), 0);
        int dentistId = parseInt(req.getParameter("dentistId"), 0);
        int apptId    = parseInt(req.getParameter("appointmentId"), 0);
        String notes  = ValidationUtil.sanitize(req.getParameter("notes"));

        // Extract list of items dynamically
        String[] drugNames   = req.getParameterValues("drugName[]");
        String[] dosages     = req.getParameterValues("dosage[]");
        String[] frequencies = req.getParameterValues("frequency[]");
        String[] durations   = req.getParameterValues("duration[]");
        String[] instructions= req.getParameterValues("instructions[]");

        List<PrescriptionItem> items = new ArrayList<>();
        if (drugNames != null) {
            for (int i = 0; i < drugNames.length; i++) {
                if (drugNames[i] == null || drugNames[i].trim().isEmpty()) continue;
                PrescriptionItem item = new PrescriptionItem();
                item.setDrugName(ValidationUtil.sanitize(drugNames[i]));
                item.setDosage(ValidationUtil.sanitize(dosages[i]));
                item.setFrequency(ValidationUtil.sanitize(frequencies[i]));
                item.setDuration(ValidationUtil.sanitize(durations[i]));
                item.setInstructions(instructions != null && i < instructions.length ? ValidationUtil.sanitize(instructions[i]) : "");
                items.add(item);
            }
        }

        Prescription rx = new Prescription();
        rx.setPatientId(patientId);
        rx.setDentistId(dentistId);
        if (apptId > 0) rx.setAppointmentId(apptId);
        rx.setNotes(notes);

        User user = (User) req.getSession().getAttribute("user");
        int rxId = rxService.createPrescription(rx, items, user != null ? user.getUserId() : 0);

        resp.sendRedirect(req.getContextPath() + "/prescriptions?action=view&id=" + rxId + "&msg=created");
    }

    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; } catch (NumberFormatException e) { return def; }
    }
    private int parsePage(String s) { int p = parseInt(s, 1); return p < 1 ? 1 : p; }
}
