<%-- reports/report-menu.jsp — Report Dashboard --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Reports"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Clinic Report Analytics Center</div>
        <div class="topbar-subtitle">Generate business and operational clinic reports</div>
      </div>
      <div class="topbar-right">
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Reports</li>
        </ol>
      </nav>

      <!-- Grid of reports -->
      <div class="row g-3">
        
        <!-- Daily appointment list -->
        <div class="col-md-6 col-lg-4">
          <div class="card h-100">
            <div class="card-body">
              <div class="d-flex align-items-center gap-2 mb-3">
                <div class="avatar bg-primary-light text-primary"><i class="bi bi-calendar-check-fill"></i></div>
                <h6 class="fw-700 mb-0">Daily Appointments</h6>
              </div>
              <p class="text-muted mb-4" style="font-size:.8rem;min-height:40px;">
                Detailed schedule listings of patient sessions booked for a specific date.
              </p>
              <form method="GET" action="${pageContext.request.contextPath}/reports">
                <input type="hidden" name="type" value="daily-appointments"/>
                <div class="row g-2">
                  <div class="col-8">
                    <input type="date" name="date" class="form-control form-control-sm" required value="<%= java.time.LocalDate.now().toString() %>"/>
                  </div>
                  <div class="col-4">
                    <button type="submit" class="btn btn-primary btn-sm w-100">View</button>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- Daily revenue report -->
        <div class="col-md-6 col-lg-4">
          <div class="card h-100">
            <div class="card-body">
              <div class="d-flex align-items-center gap-2 mb-3">
                <div class="avatar bg-success-light text-success"><i class="bi bi-cash-coin"></i></div>
                <h6 class="fw-700 mb-0">Daily Revenue Ledger</h6>
              </div>
              <p class="text-muted mb-4" style="font-size:.8rem;min-height:40px;">
                Complete record of patient treatments invoiced and payments received today.
              </p>
              <a href="${pageContext.request.contextPath}/reports?type=daily-revenue" class="btn btn-success btn-sm w-100">
                <i class="bi bi-eye-fill me-1"></i> View Today's Ledger
              </a>
            </div>
          </div>
        </div>

        <!-- Outstanding invoices list -->
        <div class="col-md-6 col-lg-4">
          <div class="card h-100">
            <div class="card-body">
              <div class="d-flex align-items-center gap-2 mb-3">
                <div class="avatar bg-danger-light text-danger"><i class="bi bi-file-earmark-exclamation-fill"></i></div>
                <h6 class="fw-700 mb-0">Outstanding Invoices</h6>
              </div>
              <p class="text-muted mb-4" style="font-size:.8rem;min-height:40px;">
                List of patients with pending balances, unpaid invoices, or overdue payments.
              </p>
              <a href="${pageContext.request.contextPath}/reports?type=outstanding" class="btn btn-danger btn-sm w-100">
                <i class="bi bi-eye-fill me-1"></i> View Aging Accounts
              </a>
            </div>
          </div>
        </div>

      </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
