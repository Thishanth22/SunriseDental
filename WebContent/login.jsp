<%-- login.jsp — Sunrise Dental Clinic Login Page --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLDecoder" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login — Sunrise Dental Clinic</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <style>
    :root {
      --primary: #2563eb;
      --primary-dark: #1d4ed8;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', sans-serif;
      background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0c4a6e 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1rem;
    }
    .login-container {
      width: 100%;
      max-width: 420px;
    }
    .login-card {
      background: #fff;
      border-radius: 20px;
      padding: 2.5rem;
      box-shadow: 0 25px 60px rgba(0,0,0,.3);
    }
    .clinic-logo {
      text-align: center;
      margin-bottom: 2rem;
    }
    .logo-icon {
      width: 70px; height: 70px;
      background: linear-gradient(135deg, var(--primary), #0891b2);
      border-radius: 20px;
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 1rem;
      font-size: 2rem;
      color: #fff;
      box-shadow: 0 8px 24px rgba(37,99,235,.35);
    }
    .clinic-name {
      font-size: 1.4rem;
      font-weight: 800;
      color: #0f172a;
      line-height: 1.2;
    }
    .clinic-sub {
      font-size: .8rem;
      color: #64748b;
      font-weight: 400;
      margin-top: .25rem;
    }
    .form-label {
      font-size: .8rem;
      font-weight: 600;
      color: #64748b;
      text-transform: uppercase;
      letter-spacing: .05em;
    }
    .form-control {
      border: 1.5px solid #e2e8f0;
      border-radius: 10px;
      padding: .7rem 1rem;
      font-size: .9rem;
      transition: all .2s;
    }
    .form-control:focus {
      border-color: var(--primary);
      box-shadow: 0 0 0 3px rgba(37,99,235,.12);
    }
    .input-group-text {
      background: #f8fafc;
      border: 1.5px solid #e2e8f0;
      border-radius: 10px 0 0 10px;
      color: #94a3b8;
    }
    .input-group .form-control { border-radius: 0 10px 10px 0; }
    .btn-login {
      width: 100%;
      padding: .8rem;
      background: linear-gradient(135deg, var(--primary), #0891b2);
      color: #fff;
      border: none;
      border-radius: 10px;
      font-weight: 700;
      font-size: 1rem;
      cursor: pointer;
      transition: all .2s;
      box-shadow: 0 4px 12px rgba(37,99,235,.3);
    }
    .btn-login:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(37,99,235,.4);
    }
    .alert {
      border-radius: 10px;
      border: none;
      font-size: .875rem;
      padding: .875rem 1rem;
    }
    .alert-danger { background: #fee2e2; color: #991b1b; }
    .alert-success { background: #d1fae5; color: #065f46; }
    .alert-warning { background: #fef3c7; color: #92400e; }
    .copyright {
      text-align: center;
      margin-top: 1.5rem;
      font-size: .75rem;
      color: rgba(255,255,255,.5);
    }
    .password-toggle { cursor: pointer; border: 1.5px solid #e2e8f0; border-left: none; }
  </style>
</head>
<body>
  <div class="login-container">
    <div class="login-card">

      <!-- Logo -->
      <div class="clinic-logo">
        <div class="logo-icon">
          <i class="bi bi-hospital-fill"></i>
        </div>
        <div class="clinic-name">Sunrise Dental</div>
        <div class="clinic-sub">Clinic Management System</div>
      </div>

      <%-- Messages --%>
      <% if ("true".equals(request.getParameter("timeout"))) { %>
        <div class="alert alert-warning mb-3">
          <i class="bi bi-clock-history me-2"></i>
          Your session has expired. Please log in again.
        </div>
      <% } else if ("true".equals(request.getParameter("logout"))) { %>
        <div class="alert alert-success mb-3">
          <i class="bi bi-check-circle me-2"></i>
          You have been logged out successfully.
        </div>
      <% } %>

      <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger mb-3">
          <i class="bi bi-exclamation-circle-fill me-2"></i>
          <%= request.getAttribute("error") %>
        </div>
      <% } %>

      <!-- Login Form -->
      <form action="${pageContext.request.contextPath}/LoginServlet"
            method="POST" class="needs-validation form-with-loading" novalidate>

        <div class="mb-3">
          <label class="form-label" for="username">Username</label>
          <div class="input-group">
            <span class="input-group-text"><i class="bi bi-person-fill"></i></span>
            <input type="text"
                   id="username"
                   name="username"
                   class="form-control"
                   placeholder="Enter your username"
                   value="${not empty param.username ? param.username : ''}"
                   autocomplete="username"
                   required
                   maxlength="50"/>
          </div>
          <div class="invalid-feedback" style="font-size:.75rem;color:#dc2626;">
            Username is required.
          </div>
        </div>

        <div class="mb-4">
          <label class="form-label" for="password">Password</label>
          <div class="input-group">
            <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
            <input type="password"
                   id="password"
                   name="password"
                   class="form-control"
                   placeholder="Enter your password"
                   autocomplete="current-password"
                   required
                   maxlength="255"/>
            <span class="input-group-text password-toggle" onclick="togglePassword()" title="Show/hide password">
              <i class="bi bi-eye" id="eyeIcon"></i>
            </span>
          </div>
          <div class="invalid-feedback" style="font-size:.75rem;color:#dc2626;">
            Password is required.
          </div>
        </div>

        <button type="submit" id="loginBtn" class="btn-login">
          <i class="bi bi-box-arrow-in-right me-1"></i>
          Sign In
        </button>

      </form>

      <p class="text-center mt-3" style="font-size:.75rem;color:#94a3b8;">
        <i class="bi bi-shield-lock-fill me-1"></i>
        Secure access — authorised personnel only
      </p>
    </div>

    <p class="copyright">
      &copy; 2026 Sunrise Dental Clinic. All rights reserved.
    </p>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    // Password visibility toggle
    function togglePassword() {
      const pwd = document.getElementById('password');
      const ico = document.getElementById('eyeIcon');
      if (pwd.type === 'password') {
        pwd.type = 'text';
        ico.className = 'bi bi-eye-slash';
      } else {
        pwd.type = 'password';
        ico.className = 'bi bi-eye';
      }
    }

    // Bootstrap validation
    (function() {
      'use strict';
      var forms = document.querySelectorAll('.needs-validation');
      Array.prototype.slice.call(forms).forEach(function(form) {
        form.addEventListener('submit', function(event) {
          if (!form.checkValidity()) {
            event.preventDefault();
            event.stopPropagation();
          } else {
            var btn = document.getElementById('loginBtn');
            if (btn) {
              btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Signing in...';
              btn.disabled = true;
            }
          }
          form.classList.add('was-validated');
        }, false);
      });
    })();
  </script>
</body>
</html>
