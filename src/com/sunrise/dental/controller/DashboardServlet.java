package com.sunrise.dental.controller;

import com.sunrise.dental.dao.AppointmentDAO;
import com.sunrise.dental.dao.PatientDAO;
import com.sunrise.dental.dao.DentistDAO;
import com.sunrise.dental.dao.BillDAO;
import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.*;
import com.sunrise.dental.util.DateUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DashboardServlet — Aggregates KPI data for the dashboard.
 *
 * Fetches all dashboard metrics from the database and passes
 * them to dashboard.jsp as request attributes.
 *
 * KPI Cards: Today's Appointments, Completed, Registered Patients,
 *            Active Dentists, Today's Revenue, Pending Payments,
 *            Cancelled Appointments
 *
 * Charts: Appointments per day (last 7), Revenue per month,
 *         Today's appointment list
 */
public class DashboardServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(DashboardServlet.class.getName());

    private final AppointmentDAO appointmentDAO = DAOFactory.getAppointmentDAO();
    private final PatientDAO     patientDAO     = DAOFactory.getPatientDAO();
    private final DentistDAO     dentistDAO     = DAOFactory.getDentistDAO();
    private final BillDAO        billDAO        = DAOFactory.getBillDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            User user = (User) req.getSession().getAttribute("user");
            boolean isDentist = user != null && "DENTIST".equalsIgnoreCase(user.getRoleName());
            List<Appointment> todayList = null;

            if (isDentist) {
                Dentist dentist = dentistDAO.findByUserId(user.getUserId());
                int dentistId = dentist != null ? dentist.getDentistId() : 0;
                
                // Get all appointments for this dentist today
                todayList = appointmentDAO.search(null, null, LocalDate.now(), LocalDate.now(), dentistId, 0, 1000);
                
                int todayAppts = todayList.size();
                int todayCompleted = 0;
                int todayCancelled = 0;
                int todayPending = 0;
                for (Appointment appt : todayList) {
                    if ("COMPLETED".equalsIgnoreCase(appt.getStatus())) {
                        todayCompleted++;
                    } else if ("CANCELLED".equalsIgnoreCase(appt.getStatus())) {
                        todayCancelled++;
                    } else if ("SCHEDULED".equalsIgnoreCase(appt.getStatus()) || "CONFIRMED".equalsIgnoreCase(appt.getStatus())) {
                        todayPending++;
                    }
                }
                
                req.setAttribute("todayAppts",     todayAppts);
                req.setAttribute("todayCompleted", todayCompleted);
                req.setAttribute("todayCancelled", todayCancelled);
                req.setAttribute("todayPending",   todayPending);
                req.setAttribute("todayList",      todayList);
            } else {
                // ---- KPI Cards (Admin / Receptionist) ----
                int todayAppts      = appointmentDAO.countToday();
                int todayCompleted  = appointmentDAO.countTodayCompleted();
                int todayCancelled  = appointmentDAO.countTodayCancelled();
                int totalPatients   = patientDAO.count();
                int activeDentists  = dentistDAO.count();
                BigDecimal todayRevenue   = billDAO.getTodayRevenue();
                int pendingPayments = billDAO.countOutstandingBills();

                req.setAttribute("todayAppts",     todayAppts);
                req.setAttribute("todayCompleted", todayCompleted);
                req.setAttribute("todayCancelled", todayCancelled);
                req.setAttribute("totalPatients",  totalPatients);
                req.setAttribute("activeDentists", activeDentists);
                req.setAttribute("todayRevenue",   todayRevenue);
                req.setAttribute("pendingPayments",pendingPayments);

                todayList = appointmentDAO.findToday();
                req.setAttribute("todayList", todayList);
            }

            // ---- Monthly revenue chart data (current year) ----
            int year = DateUtil.currentYear();
            List<Map<String, Object>> monthlyRevenue = billDAO.getMonthlyRevenue(year);
            req.setAttribute("monthlyRevenue", monthlyRevenue);
            req.setAttribute("currentYear",    year);

            // ---- Today's date for display ----
            req.setAttribute("today", LocalDate.now().format(
                java.time.format.DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy")));

            req.getRequestDispatcher("/dashboard/dashboard.jsp").forward(req, resp);

        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "Dashboard data load failed", e);
            req.setAttribute("error", "Dashboard data could not be loaded. Please try again.");
            req.getRequestDispatcher("/dashboard/dashboard.jsp").forward(req, resp);
        }
    }
}
