package com.sunrise.dental.controller;

import com.sunrise.dental.model.User;
import com.sunrise.dental.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

/** LogoutServlet — Invalidates session and redirects to login. */
public class LogoutServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            String ip = req.getRemoteAddr();
            authService.logout(user, ip);
            session.invalidate();
        }

        // Remove remember-username cookie on explicit logout
        // (keep it — it's non-sensitive; user preference only)

        resp.sendRedirect(req.getContextPath() + "/login.jsp?logout=true");
    }
}
