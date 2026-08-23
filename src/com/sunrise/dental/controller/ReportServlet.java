package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.dao.impl.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReportServlet — Generates various clinic management reports.
 *
 * Report types:
 *   daily-appointments, monthly-appointments, dentist-performance,
 *   treatment-revenue, daily-revenue, monthly-revenue,
 *   patient-registration, cancellation, outstanding-payments
 */
public class ReportServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(ReportServlet.class.getName());
    private final AppointmentDAO apptDAO    = new AppointmentDAOImpl();
    private final BillDAO        billDAO    = new BillDAOImpl();
    private final DentistDAO     dentistDAO = new DentistDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String type = req.getParameter("type");
        if (type == null || type.isEmpty()) {
            req.getRequestDispatcher("/reports/report-menu.jsp").forward(req, resp);
            return;
        }
        try {
            switch (type) {
                case "daily-appointments" -> {
                    String dateS = req.getParameter("date");
                    LocalDate date = dateS != null ? DateUtil.parseDate(dateS) : LocalDate.now();
                    req.setAttribute("reportDate", date);
                    req.setAttribute("appointments", apptDAO.findByDate(date));
                    req.setAttribute("reportType", "Daily Appointment Report");
                    req.getRequestDispatcher("/reports/report-daily-appointments.jsp").forward(req, resp);
                }
                case "daily-revenue" -> {
                    req.setAttribute("bills", billDAO.search(null, null,
                        LocalDate.now(), LocalDate.now(), 0, 9999));
                    req.setAttribute("todayRevenue", billDAO.getTodayRevenue());
                    req.setAttribute("reportDate", LocalDate.now());
                    req.getRequestDispatcher("/reports/report-daily-revenue.jsp").forward(req, resp);
                }
                case "monthly-revenue" -> {
                    int year  = parseInt(req.getParameter("year"),  DateUtil.currentYear());
                    int month = parseInt(req.getParameter("month"), LocalDate.now().getMonthValue());
                    req.setAttribute("monthlyData", billDAO.getMonthlyRevenue(year));
                    req.setAttribute("year", year);
                    req.setAttribute("month", month);
                    req.getRequestDispatcher("/reports/report-monthly-revenue.jsp").forward(req, resp);
                }
                case "outstanding" -> {
                    req.setAttribute("bills", billDAO.findOutstanding(200));
                    req.getRequestDispatcher("/reports/report-outstanding.jsp").forward(req, resp);
                }
                default -> req.getRequestDispatcher("/reports/report-menu.jsp").forward(req, resp);
            }
        } catch (ApplicationException e) {
            logger.log(Level.SEVERE, "ReportServlet error", e);
            req.setAttribute("error", "Report could not be generated: " + e.getMessage());
            req.getRequestDispatcher("/reports/report-menu.jsp").forward(req, resp);
        }
    }

    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; } catch (NumberFormatException e) { return def; }
    }
}
