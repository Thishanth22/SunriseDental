package com.sunrise.dental.controller;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.User;
import com.sunrise.dental.service.AuditService;
import com.sunrise.dental.service.AuthService;
import com.sunrise.dental.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

/** UserServlet — User management (ADMIN only). */
public class UserServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(UserServlet.class.getName());
    private final UserDAO      userDAO    = DAOFactory.getUserDAO();
    private final AuthService  authService= new AuthService();
    private final AuditService auditService=new AuditService();
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            switch (action) {
                case "list" -> {
                    int page   = parsePage(req.getParameter("page"));
                    int offset = (page - 1) * PAGE_SIZE;
                    List<User> users = userDAO.findAll(offset, PAGE_SIZE);
                    int total = userDAO.count();
                    req.setAttribute("users", users);
                    req.setAttribute("total", total);
                    req.setAttribute("page",  page);
                    req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
                    req.getRequestDispatcher("/users/user-list.jsp").forward(req, resp);
                }
                case "new" -> {
                    req.setAttribute("user", null);
                    req.getRequestDispatcher("/users/user-form.jsp").forward(req, resp);
                }
                case "edit" -> {
                    int id = parseInt(req.getParameter("id"), 0);
                    req.setAttribute("editUser", userDAO.findById(id));
                    req.getRequestDispatcher("/users/user-form.jsp").forward(req, resp);
                }
                default -> resp.sendRedirect(req.getContextPath() + "/users");
            }
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/users/user-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            switch (action != null ? action : "") {
                case "save" -> {
                    String username  = ValidationUtil.sanitize(req.getParameter("username"));
                    String password  = req.getParameter("password");
                    String fullName  = ValidationUtil.sanitize(req.getParameter("fullName"));
                    String email     = ValidationUtil.sanitize(req.getParameter("email"));
                    String phone     = ValidationUtil.sanitize(req.getParameter("phone"));
                    int roleId       = parseInt(req.getParameter("roleId"), 0);
                    if (userDAO.usernameExists(username))
                        throw new ApplicationException("Username '" + username + "' already exists.");
                    if (!PasswordUtil.meetsPolicy(password))
                        throw new ApplicationException("Password must be at least 8 chars with uppercase, lowercase and digits.");
                    User u = new User();
                    u.setUsername(username);
                    u.setPasswordHash(PasswordUtil.hash(password));
                    u.setFullName(fullName);
                    u.setEmail(email);
                    u.setPhone(phone);
                    u.setRoleId(roleId);
                    int id = userDAO.save(u);
                    User cu = (User) req.getSession().getAttribute("user");
                    auditService.log(cu != null ? cu.getUserId() : null, cu != null ? cu.getUsername() : null,
                        "USER_CREATED", "USER", id, "User '" + username + "' created", req.getRemoteAddr(), null);
                    resp.sendRedirect(req.getContextPath() + "/users?msg=saved");
                }
                case "update" -> {
                    int id = parseInt(req.getParameter("userId"), 0);
                    User u = userDAO.findById(id);
                    if (u != null) {
                        u.setFullName(ValidationUtil.sanitize(req.getParameter("fullName")));
                        u.setEmail(ValidationUtil.sanitize(req.getParameter("email")));
                        u.setPhone(ValidationUtil.sanitize(req.getParameter("phone")));
                        u.setRoleId(parseInt(req.getParameter("roleId"), u.getRoleId()));
                        userDAO.update(u);
                    }
                    resp.sendRedirect(req.getContextPath() + "/users?msg=updated");
                }
                case "deactivate" -> {
                    userDAO.deactivate(parseInt(req.getParameter("id"), 0));
                    resp.sendRedirect(req.getContextPath() + "/users?msg=deactivated");
                }
                case "activate" -> {
                    userDAO.activate(parseInt(req.getParameter("id"), 0));
                    resp.sendRedirect(req.getContextPath() + "/users?msg=activated");
                }
                case "reset-password" -> {
                    int id = parseInt(req.getParameter("id"), 0);
                    String newPass = req.getParameter("newPassword");
                    authService.adminResetPassword(id, newPass);
                    resp.sendRedirect(req.getContextPath() + "/users?msg=password-reset");
                }
                default -> resp.sendRedirect(req.getContextPath() + "/users");
            }
        } catch (ApplicationException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/users/user-form.jsp").forward(req, resp);
        }
    }
    private int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s.trim()) : def; } catch (NumberFormatException e) { return def; }
    }
    private int parsePage(String s) { int p = parseInt(s, 1); return p < 1 ? 1 : p; }
}
