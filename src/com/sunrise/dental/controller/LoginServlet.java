package com.sunrise.dental.controller;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.User;
import com.sunrise.dental.service.AuthService;
import com.sunrise.dental.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * LoginServlet — Handles POST /LoginServlet (login form submission).
 *
 * GET  → redirect to login.jsp
 * POST → authenticate → set session → redirect to dashboard
 *
 * Security:
 *   - Credentials validated server-side via AuthService
 *   - Session regenerated after login (session fixation prevention)
 *   - Input sanitised before use
 */
public class LoginServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(LoginServlet.class.getName());
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, redirect to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String username = ValidationUtil.sanitize(req.getParameter("username"));
        String password = req.getParameter("password");   // Do NOT sanitize password (may have special chars)
        String ipAddress = getClientIp(req);

        // Basic validation
        if (ValidationUtil.isNullOrEmpty(username) || ValidationUtil.isNullOrEmpty(password)) {
            req.setAttribute("error", "Username and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = authService.login(username, password, ipAddress);

            // Session fixation protection — invalidate old session, create new
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession session = req.getSession(true);
            session.setAttribute("user",     user);
            session.setAttribute("userId",   user.getUserId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("role",     user.getRoleName());
            session.setMaxInactiveInterval(30 * 60);  // 30 minutes

            // Optional: remember username cookie (non-sensitive preference only)
            Cookie usernameCookie = new Cookie("dental_last_user", username);
            usernameCookie.setMaxAge(30 * 24 * 3600);  // 30 days
            usernameCookie.setPath(req.getContextPath());
            usernameCookie.setHttpOnly(true);
            resp.addCookie(usernameCookie);

            logger.info("User logged in: " + username + " from " + ipAddress);
            resp.sendRedirect(req.getContextPath() + "/dashboard");

        } catch (ApplicationException e) {
            logger.log(Level.WARNING, "Login failed for: " + username, e);
            req.setAttribute("error", e.getMessage());
            req.setAttribute("username", username);
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    private String getClientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) ip = req.getRemoteAddr();
        return ip;
    }
}
