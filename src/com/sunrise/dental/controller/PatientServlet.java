package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Patient;
import com.sunrise.dental.model.User;
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
 * PatientServlet — Handles all patient CRUD operations.
 *
 * Actions (request parameter "action"):
 *   list     → GET  → patient-list.jsp
 *   new      → GET  → patient-form.jsp (empty form)
 *   view     → GET  → patient-view.jsp
 *   edit     → GET  → patient-form.jsp (pre-filled)
 *   save     → POST → validate → save → redirect
 *   update   → POST → validate → update → redirect
 *   deactivate → POST → change status → redirect
 */
public class PatientServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(PatientServlet.class.getName());

    private final PatientDAO   patientDAO   = DAOFactory.getPatientDAO();
    private final AuditService auditService = new AuditService();

    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {
                case "list"   -> listPatients(req, resp);
                case "new"    -> showForm(req, resp, null);
                case "view"   -> viewPatient(req, resp);
                case "edit"   -> editPatient(req, resp);
                default       -> listPatients(req, resp);
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "PatientServlet GET error: " + e.getMessage(), e);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/patients/patient-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "save"       -> savePatient(req, resp);
                case "update"     -> updatePatient(req, resp);
                case "deactivate" -> deactivatePatient(req, resp);
                case "activate"   -> activatePatient(req, resp);
                case "updateNotes"-> updateClinicalNotes(req, resp);
                default -> resp.sendRedirect(req.getContextPath() + "/patients");
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "PatientServlet POST error: " + e.getMessage(), e);
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/patients/patient-form.jsp").forward(req, resp);
        }
    }

    private void updateClinicalNotes(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException, ServletException {
        int id = parseInt(req.getParameter("id"), 0);
        Patient patient = patientDAO.findById(id);
        if (patient == null) {
            resp.sendRedirect(req.getContextPath() + "/patients?error=Patient+not+found");
            return;
        }

        String allergies = ValidationUtil.sanitize(req.getParameter("allergies"));
        String medicalNotes = ValidationUtil.sanitize(req.getParameter("medicalNotes"));

        patient.setAllergies(allergies);
        patient.setMedicalNotes(medicalNotes);
        patientDAO.update(patient);

        User user = (User) req.getSession().getAttribute("user");
        int userId = user != null ? user.getUserId() : 0;
        auditService.log(userId, null, "PATIENT_CLINICAL_NOTES_UPDATED",
            "PATIENT", id, "Clinical notes/allergies updated for Patient #" + id,
            req.getRemoteAddr(), null);

        resp.sendRedirect(req.getContextPath() + "/patients?action=view&id=" + id + "&msg=notes_updated");
    }

    // -------------------------------------------------------
    private void listPatients(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {

        String query = req.getParameter("q");
        int page     = parsePage(req.getParameter("page"));
        int offset   = (page - 1) * PAGE_SIZE;

        List<Patient> patients;
        int total;

        if (query != null && !query.trim().isEmpty()) {
            patients = patientDAO.search(query, offset, PAGE_SIZE);
            total    = patientDAO.countSearch(query);
            req.setAttribute("query", ValidationUtil.escapeHtml(query));
        } else {
            patients = patientDAO.findAll(offset, PAGE_SIZE);
            total    = patientDAO.count();
        }

        req.setAttribute("patients",   patients);
        req.setAttribute("total",      total);
        req.setAttribute("page",       page);
        req.setAttribute("pageSize",   PAGE_SIZE);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
        req.getRequestDispatcher("/patients/patient-list.jsp").forward(req, resp);
    }

    private void viewPatient(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Patient patient = patientDAO.findById(id);
        if (patient == null) {
            resp.sendRedirect(req.getContextPath() + "/patients?error=Patient+not+found");
            return;
        }
        
        // Load patient's prescriptions history
        com.sunrise.dental.dao.PrescriptionDAO rxDAO = new com.sunrise.dental.dao.impl.PrescriptionDAOImpl();
        List<com.sunrise.dental.model.Prescription> prescriptions = rxDAO.findByPatientId(id);
        req.setAttribute("prescriptions", prescriptions);
        
        req.setAttribute("patient", patient);
        req.getRequestDispatcher("/patients/patient-view.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Patient patient)
            throws ServletException, IOException {
        req.setAttribute("patient", patient);
        req.setAttribute("today", DateUtil.todayString());
        req.getRequestDispatcher("/patients/patient-form.jsp").forward(req, resp);
    }

    private void editPatient(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        Patient patient = patientDAO.findById(id);
        if (patient == null) {
            resp.sendRedirect(req.getContextPath() + "/patients?error=Patient+not+found");
            return;
        }
        showForm(req, resp, patient);
    }

    private void savePatient(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {

        Patient patient = buildPatientFromForm(req);

        // Server-side validation
        validatePatient(patient, req, resp);

        User user = (User) req.getSession().getAttribute("user");
        patient.setCreatedBy(user != null ? user.getUserId() : 0);
        patient.setPatientNumber(patientDAO.generatePatientNumber());
        patient.setStatus("ACTIVE");
        patient.setRegistrationDate(LocalDate.now());

        int id = patientDAO.save(patient);

        auditService.log(user != null ? user.getUserId() : null,
            user != null ? user.getUsername() : null,
            "PATIENT_CREATED", "PATIENT", id,
            "Patient " + patient.getPatientNumber() + " registered",
            req.getRemoteAddr(), null);

        resp.sendRedirect(req.getContextPath() + "/patients?action=view&id=" + id + "&msg=saved");
    }

    private void updatePatient(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {

        int id = parseInt(req.getParameter("patientId"), 0);
        Patient patient = buildPatientFromForm(req);
        patient.setPatientId(id);

        validatePatient(patient, req, resp);

        patientDAO.update(patient);

        User user = (User) req.getSession().getAttribute("user");
        auditService.log(user != null ? user.getUserId() : null,
            user != null ? user.getUsername() : null,
            "PATIENT_UPDATED", "PATIENT", id,
            "Patient #" + id + " details updated",
            req.getRemoteAddr(), null);

        resp.sendRedirect(req.getContextPath() + "/patients?action=view&id=" + id + "&msg=updated");
    }

    private void deactivatePatient(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        patientDAO.updateStatus(id, "INACTIVE");
        User user = (User) req.getSession().getAttribute("user");
        auditService.log(user != null ? user.getUserId() : null,
            user != null ? user.getUsername() : null,
            "PATIENT_DEACTIVATED", "PATIENT", id,
            "Patient #" + id + " deactivated", req.getRemoteAddr(), null);
        resp.sendRedirect(req.getContextPath() + "/patients?msg=deactivated");
    }

    private void activatePatient(HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, IOException {
        int id = parseInt(req.getParameter("id"), 0);
        patientDAO.updateStatus(id, "ACTIVE");
        resp.sendRedirect(req.getContextPath() + "/patients?action=view&id=" + id + "&msg=activated");
    }

    // -------------------------------------------------------
    // Build Patient from form parameters (server-side, never trust hidden price fields)
    // -------------------------------------------------------
    private Patient buildPatientFromForm(HttpServletRequest req) {
        Patient p = new Patient();
        p.setFirstName(sanitize(req.getParameter("firstName")));
        p.setLastName(sanitize(req.getParameter("lastName")));
        p.setDateOfBirth(DateUtil.parseDate(req.getParameter("dateOfBirth")));
        p.setGender(sanitize(req.getParameter("gender")));
        p.setAddress(sanitize(req.getParameter("address")));
        p.setCity(sanitize(req.getParameter("city")));
        p.setContactNumber(sanitize(req.getParameter("contactNumber")));
        p.setAltContact(sanitize(req.getParameter("altContact")));
        p.setEmail(sanitize(req.getParameter("email")));
        p.setEmergencyContactName(sanitize(req.getParameter("emergencyContactName")));
        p.setEmergencyContactPhone(sanitize(req.getParameter("emergencyContactPhone")));
        p.setEmergencyContactRelation(sanitize(req.getParameter("emergencyContactRelation")));
        p.setBloodGroup(sanitize(req.getParameter("bloodGroup")));
        p.setAllergies(sanitize(req.getParameter("allergies")));
        p.setMedicalNotes(sanitize(req.getParameter("medicalNotes")));
        String status = sanitize(req.getParameter("status"));
        p.setStatus(status != null && !status.isEmpty() ? status : "ACTIVE");
        return p;
    }

    private void validatePatient(Patient p, HttpServletRequest req, HttpServletResponse resp)
            throws ApplicationException, ServletException, IOException {
        if (!ValidationUtil.isValidName(p.getFirstName())) {
            throw new ApplicationException("First name is required and must contain valid characters.");
        }
        if (!ValidationUtil.isValidName(p.getLastName())) {
            throw new ApplicationException("Last name is required and must contain valid characters.");
        }
        if (!ValidationUtil.isValidPhoneLK(p.getContactNumber())) {
            throw new ApplicationException(
                "Contact number is invalid. Please enter a valid Sri Lankan phone number (e.g. 0771234567).");
        }
        if (p.getEmail() != null && !p.getEmail().isEmpty()
                && !ValidationUtil.isValidEmail(p.getEmail())) {
            throw new ApplicationException("Please enter a valid email address.");
        }
    }

    // -------------------------------------------------------
    private String sanitize(String s) {
        return s != null ? ValidationUtil.sanitize(s.trim()) : null;
    }

    private int parseInt(String s, int defaultVal) {
        try { return s != null ? Integer.parseInt(s.trim()) : defaultVal; }
        catch (NumberFormatException e) { return defaultVal; }
    }

    private int parsePage(String s) {
        int p = parseInt(s, 1);
        return p < 1 ? 1 : p;
    }
}
