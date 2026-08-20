package com.sunrise.dental.filter;

import com.sunrise.dental.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthorizationFilter — Role-Based Access Control (RBAC).
 *
 * Enforces that only users with the correct role can access
 * specific URL prefixes. This is server-side enforcement —
 * hiding menu items in JSP is NOT sufficient for security.
 *
 * Role → URL mapping:
 *   /admin/*          → ADMIN only
 *   /users/*          → ADMIN only
 *   /audit/*          → ADMIN only
 *   /reports/*        → ADMIN, RECEPTIONIST
 *   /patients/*       → ADMIN, RECEPTIONIST
 *   /appointments/*   → ADMIN, RECEPTIONIST, DENTIST
 *   /billing/*        → ADMIN, RECEPTIONIST
 *   /payments/*       → ADMIN, RECEPTIONIST
 *   /dentists/*       → ADMIN
 *   /treatments/*     → ADMIN
 *   /dashboard/*      → ALL authenticated
 *   /notifications/*  → ALL authenticated
 */
public class AuthorizationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        if (session == null) {
            chain.doFilter(request, response);
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            chain.doFilter(request, response);
            return;
        }

        String path = req.getRequestURI().substring(req.getContextPath().length());
        String role = user.getRoleName();

        // ---- Admin-only paths ----
        if ((path.startsWith("/admin")    ||
             path.startsWith("/users")    ||
             path.startsWith("/audit")    ||
             path.startsWith("/dentists") ||
             path.startsWith("/treatments"))
            && !"ADMIN".equalsIgnoreCase(role)) {

            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                "You do not have permission to access this page.");
            return;
        }

        // ---- Admin + Receptionist paths ----
        if ((path.startsWith("/patients")  ||
             path.startsWith("/billing")   ||
             path.startsWith("/payments")  ||
             path.startsWith("/reports"))
            && !"ADMIN".equalsIgnoreCase(role)
            && !"RECEPTIONIST".equalsIgnoreCase(role)) {

            // Special exception: Dentists are allowed to view specific patient profiles & update clinical notes
            if (path.startsWith("/patients") && "DENTIST".equalsIgnoreCase(role)) {
                String action = req.getParameter("action");
                if ("view".equals(action) || "updateNotes".equals(action)) {
                    chain.doFilter(request, response);
                    return;
                }
            }

            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                "You do not have permission to access this page.");
            return;
        }

        // All other authenticated paths — allow
        chain.doFilter(request, response);
    }
}
