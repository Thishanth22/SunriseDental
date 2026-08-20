package com.sunrise.dental.filter;

import com.sunrise.dental.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * AuthenticationFilter — Ensures every protected URL has a valid session.
 *
 * Security rule: If no session or no "user" attribute, redirect to login.
 * This cannot be bypassed by manipulating JSP URLs.
 *
 * Public URLs (no authentication required):
 *   /login.jsp, /LoginServlet, /css/*, /js/*, /images/*
 */
public class AuthenticationFilter implements Filter {

    // URL patterns that do NOT require authentication
    private static final List<String> PUBLIC_PATHS = Arrays.asList(
        "/login.jsp",
        "/LoginServlet",
        "/verify-bill",
        "/css/",
        "/js/",
        "/images/",
        "/errors/"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        // Allow public paths through
        for (String pub : PUBLIC_PATHS) {
            if (path.startsWith(pub) || path.equals(pub)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Check session
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // No valid session — redirect to login
            String loginUrl = contextPath + "/login.jsp?timeout=true";
            resp.sendRedirect(loginUrl);
            return;
        }

        // Valid session — continue
        // Set no-cache headers on all authenticated responses for security
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        chain.doFilter(request, response);
    }
}
