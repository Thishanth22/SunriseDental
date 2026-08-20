<%-- sidebar.jsp — Navigation sidebar --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="sidebar" id="sidebar">

  <!-- Brand -->
  <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-brand text-decoration-none">
    <div class="brand-logo">
      <div class="brand-icon">
        <i class="bi bi-hospital-fill text-white"></i>
      </div>
      <div>
        <div class="brand-name">Sunrise Dental</div>
        <div class="brand-sub">Clinic Management</div>
      </div>
    </div>
  </a>

  <!-- Navigation -->
  <nav class="sidebar-nav">

    <!-- MAIN -->
    <div class="nav-label">Main</div>

    <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-link">
      <i class="bi bi-grid-1x2-fill"></i>
      <span>Dashboard</span>
    </a>

    <!-- PATIENTS -->
    <c:if test="${sessionScope.role == 'ADMIN' || sessionScope.role == 'RECEPTIONIST'}">
      <div class="nav-label mt-2">Patients</div>
      <a href="${pageContext.request.contextPath}/patients" class="sidebar-link">
        <i class="bi bi-person-lines-fill"></i>
        <span>All Patients</span>
      </a>
      <a href="${pageContext.request.contextPath}/patients?action=new" class="sidebar-link">
        <i class="bi bi-person-plus-fill"></i>
        <span>Register Patient</span>
      </a>
    </c:if>

    <!-- APPOINTMENTS -->
    <div class="nav-label mt-2">Appointments</div>
    <a href="${pageContext.request.contextPath}/appointments" class="sidebar-link">
      <i class="bi bi-calendar2-week-fill"></i>
      <span>All Appointments</span>
    </a>
    <a href="${pageContext.request.contextPath}/prescriptions" class="sidebar-link">
      <i class="bi bi-capsule-pill"></i>
      <span>E-Prescriptions</span>
    </a>
    <c:if test="${sessionScope.role == 'ADMIN' || sessionScope.role == 'RECEPTIONIST'}">
      <a href="${pageContext.request.contextPath}/appointments?action=new" class="sidebar-link">
        <i class="bi bi-calendar-plus-fill"></i>
        <span>Book Appointment</span>
      </a>
    </c:if>

    <!-- BILLING & PAYMENTS -->
    <c:if test="${sessionScope.role == 'ADMIN' || sessionScope.role == 'RECEPTIONIST'}">
      <div class="nav-label mt-2">Finance</div>
      <a href="${pageContext.request.contextPath}/billing" class="sidebar-link">
        <i class="bi bi-receipt-cutoff"></i>
        <span>Billing</span>
      </a>
      <a href="${pageContext.request.contextPath}/payments" class="sidebar-link">
        <i class="bi bi-cash-coin"></i>
        <span>Payments</span>
      </a>
      <a href="${pageContext.request.contextPath}/reports" class="sidebar-link">
        <i class="bi bi-bar-chart-fill"></i>
        <span>Reports</span>
      </a>
    </c:if>

    <!-- ADMIN -->
    <c:if test="${sessionScope.role == 'ADMIN'}">
      <div class="nav-label mt-2">Administration</div>

      <a href="${pageContext.request.contextPath}/dentists" class="sidebar-link">
        <i class="bi bi-person-badge-fill"></i>
        <span>Dentists</span>
      </a>
      <a href="${pageContext.request.contextPath}/treatments" class="sidebar-link">
        <i class="bi bi-capsule-pill"></i>
        <span>Treatments</span>
      </a>
      <a href="${pageContext.request.contextPath}/users" class="sidebar-link">
        <i class="bi bi-people-fill"></i>
        <span>Users</span>
      </a>
      <a href="${pageContext.request.contextPath}/audit" class="sidebar-link">
        <i class="bi bi-shield-lock-fill"></i>
        <span>Audit Logs</span>
      </a>
    </c:if>

    <!-- SUPPORT -->
    <div class="nav-label mt-2">Support</div>
    <a href="${pageContext.request.contextPath}/help" class="sidebar-link">
      <i class="bi bi-question-circle-fill"></i>
      <span>Help &amp; Guide</span>
    </a>

  </nav>

  <!-- User Footer -->
  <div class="sidebar-footer">
    <div class="d-flex align-items-center gap-2 mb-2">
      <div class="user-avatar">
        ${not empty sessionScope.fullName ? sessionScope.fullName.substring(0,1).toUpperCase() : 'U'}
      </div>
      <div>
        <div style="font-size:.8rem;font-weight:600;color:#fff;">
          ${sessionScope.fullName}
        </div>
        <div style="font-size:.7rem;color:#94a3b8;">
          ${sessionScope.role}
        </div>
      </div>
      <a href="${pageContext.request.contextPath}/LogoutServlet"
         class="ms-auto"
         style="color:#94a3b8;font-size:1.1rem;"
         title="Logout"
         data-bs-toggle="tooltip">
        <i class="bi bi-box-arrow-right"></i>
      </a>
    </div>
  </div>

</nav>
