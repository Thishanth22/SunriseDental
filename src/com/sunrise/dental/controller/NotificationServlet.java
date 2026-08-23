package com.sunrise.dental.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

/** NotificationServlet — Basic notification listing. */
public class NotificationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/notifications/notifications.jsp").forward(req, resp);
    }
}
