<%-- dashboard/dashboard.jsp — Main Dashboard --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Dashboard"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>

  <div class="main-content">
    <!-- Topbar -->
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle">
        <i class="bi bi-list fs-5"></i>
      </button>
      <div>
        <div class="topbar-title">Dashboard</div>
        <div class="topbar-subtitle">${today}</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/appointments?action=new"
           class="btn btn-primary btn-sm">
          <i class="bi bi-calendar-plus-fill"></i> Book Appointment
        </a>
        <div class="topbar-user">
          <div class="user-avatar">
            ${not empty sessionScope.fullName ? sessionScope.fullName.substring(0,1).toUpperCase() : 'U'}
          </div>
          ${sessionScope.fullName}
        </div>
      </div>
    </div>

    <div class="page-content">

      <!-- Alert Messages -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3">
          <i class="bi bi-exclamation-circle-fill me-2"></i>${error}
        </div>
      </c:if>

      <!-- ===== KPI CARDS (ADMIN / RECEPTIONIST) ===== -->
      <c:if test="${sessionScope.role != 'DENTIST'}">
        <div class="row g-3 mb-4">
          <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card" style="--kpi-color:#2563eb;--kpi-bg:#dbeafe;">
              <div class="kpi-icon"><i class="bi bi-calendar2-check-fill"></i></div>
              <div class="kpi-value">${todayAppts}</div>
              <div class="kpi-label">Today's Appts</div>
            </div>
          </div>

          <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card" style="--kpi-color:#059669;--kpi-bg:#d1fae5;">
              <div class="kpi-icon"><i class="bi bi-check2-circle"></i></div>
              <div class="kpi-value">${todayCompleted}</div>
              <div class="kpi-label">Completed</div>
            </div>
          </div>

          <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card" style="--kpi-color:#0891b2;--kpi-bg:#cffafe;">
              <div class="kpi-icon"><i class="bi bi-people-fill"></i></div>
              <div class="kpi-value">${totalPatients}</div>
              <div class="kpi-label">Patients</div>
            </div>
          </div>

          <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card" style="--kpi-color:#7c3aed;--kpi-bg:#ede9fe;">
              <div class="kpi-icon"><i class="bi bi-person-badge-fill"></i></div>
              <div class="kpi-value">${activeDentists}</div>
              <div class="kpi-label">Dentists</div>
            </div>
          </div>

          <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card" style="--kpi-color:#059669;--kpi-bg:#d1fae5;">
              <div class="kpi-icon"><i class="bi bi-cash-coin"></i></div>
              <div class="kpi-value" style="font-size:1.3rem;">
                LKR <fmt:formatNumber value="${todayRevenue}" type="number" minFractionDigits="2"/>
              </div>
              <div class="kpi-label">Today Revenue</div>
            </div>
          </div>

          <div class="col-6 col-md-4 col-xl-2">
            <div class="kpi-card" style="--kpi-color:#d97706;--kpi-bg:#fef3c7;">
              <div class="kpi-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
              <div class="kpi-value">${pendingPayments}</div>
              <div class="kpi-label">Outstanding</div>
            </div>
          </div>
        </div>
      </c:if>

      <!-- ===== KPI CARDS (DENTIST) ===== -->
      <c:if test="${sessionScope.role == 'DENTIST'}">
        <div class="row g-3 mb-4">
          <div class="col-12 col-sm-6 col-md-3">
            <div class="kpi-card" style="--kpi-color:#2563eb;--kpi-bg:#dbeafe;">
              <div class="kpi-icon"><i class="bi bi-calendar2-check-fill"></i></div>
              <div class="kpi-value">${todayAppts}</div>
              <div class="kpi-label">My Schedule Today</div>
            </div>
          </div>
          <div class="col-12 col-sm-6 col-md-3">
            <div class="kpi-card" style="--kpi-color:#059669;--kpi-bg:#d1fae5;">
              <div class="kpi-icon"><i class="bi bi-check2-circle"></i></div>
              <div class="kpi-value">${todayCompleted}</div>
              <div class="kpi-label">Completed Sessions</div>
            </div>
          </div>
          <div class="col-12 col-sm-6 col-md-3">
            <div class="kpi-card" style="--kpi-color:#eab308;--kpi-bg:#fef9c3;">
              <div class="kpi-icon"><i class="bi bi-hourglass-split"></i></div>
              <div class="kpi-value">${todayPending}</div>
              <div class="kpi-label">Pending Sessions</div>
            </div>
          </div>
          <div class="col-12 col-sm-6 col-md-3">
            <div class="kpi-card" style="--kpi-color:#dc2626;--kpi-bg:#fee2e2;">
              <div class="kpi-icon"><i class="bi bi-x-circle-fill"></i></div>
              <div class="kpi-value">${todayCancelled}</div>
              <div class="kpi-label">Cancelled Sessions</div>
            </div>
          </div>
        </div>
      </c:if>

      <!-- ===== CHARTS (ADMIN / RECEPTIONIST ONLY) ===== -->
      <c:if test="${sessionScope.role != 'DENTIST'}">
        <div class="row g-3 mb-4">
          <div class="col-lg-8">
            <div class="card h-100">
              <div class="card-header">
                <i class="bi bi-bar-chart-fill text-primary"></i>
                <h6>Monthly Revenue — ${currentYear}</h6>
              </div>
              <div class="card-body" style="height:260px;">
                <canvas id="revenueChart"></canvas>
              </div>
            </div>
          </div>

          <div class="col-lg-4">
            <div class="card h-100">
              <div class="card-header">
                <i class="bi bi-pie-chart-fill text-primary"></i>
                <h6>Today's Status</h6>
              </div>
              <div class="card-body d-flex flex-column align-items-center justify-content-center"
                   style="height:260px;">
                <canvas id="statusChart"></canvas>
              </div>
            </div>
          </div>
        </div>
      </c:if>

      <!-- ===== TODAY'S APPOINTMENTS TABLE ===== -->
      <div class="card">
        <div class="card-header justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-calendar2-week-fill text-primary"></i>
            <h6>Today's Appointments</h6>
            <span class="badge bg-primary">${todayAppts}</span>
          </div>
          <a href="${pageContext.request.contextPath}/appointments"
             class="btn btn-outline-primary btn-sm ms-auto">
            View All
          </a>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty todayList}">
              <div class="empty-state">
                <i class="bi bi-calendar-x-fill"></i>
                <p>No appointments scheduled for today.</p>
                <a href="${pageContext.request.contextPath}/appointments?action=new"
                   class="btn btn-primary btn-sm mt-2">
                  <i class="bi bi-calendar-plus-fill me-1"></i>Book Appointment
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Time</th>
                      <th>Appointment #</th>
                      <th>Patient</th>
                      <th>Dentist</th>
                      <th>Treatment</th>
                      <th>Priority</th>
                      <th>Status</th>
                      <th class="text-center">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="appt" items="${todayList}">
                      <tr>
                        <td>
                          <strong>
                            <fmt:formatDate value="${appt.appointmentTimeSql}" pattern="HH:mm"/>
                          </strong>
                        </td>
                        <td>
                          <code style="font-size:.8rem;">${appt.appointmentNumber}</code>
                        </td>
                        <td>
                          <div class="d-flex align-items-center gap-2">
                            <div class="avatar avatar-sm">
                              ${not empty appt.patientName ? appt.patientName.substring(0,1) : 'P'}
                            </div>
                            <div>
                              <div class="fw-600">
                                ${appt.patientName}
                                <c:if test="${not empty appt.patientAllergies}">
                                  <span class="badge bg-danger ms-1" style="font-size:.65rem;" title="Allergies: <c:out value="${appt.patientAllergies}"/>">
                                    <i class="bi bi-exclamation-octagon-fill"></i> Allergy!
                                  </span>
                                </c:if>
                              </div>
                              <div style="font-size:.75rem;color:var(--text-muted);">${appt.patientPhone}</div>
                            </div>
                          </div>
                        </td>
                        <td>${appt.dentistName}</td>
                        <td>${appt.treatmentName}</td>
                        <td>
                          <c:choose>
                            <c:when test="${appt.priority == 'EMERGENCY'}">
                              <span class="badge bg-danger">${appt.priority}</span>
                            </c:when>
                            <c:when test="${appt.priority == 'URGENT'}">
                              <span class="badge bg-warning">${appt.priority}</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-secondary">${appt.priority}</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${appt.status == 'COMPLETED'}">
                              <span class="badge bg-success">${appt.status}</span>
                            </c:when>
                            <c:when test="${appt.status == 'CANCELLED'}">
                              <span class="badge bg-danger">${appt.status}</span>
                            </c:when>
                            <c:when test="${appt.status == 'CONFIRMED'}">
                              <span class="badge bg-info">${appt.status}</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-primary">${appt.status}</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <a href="${pageContext.request.contextPath}/appointments?action=view&id=${appt.appointmentId}"
                             class="btn btn-sm btn-outline-primary"
                             data-bs-toggle="tooltip" title="View Details">
                            <i class="bi bi-eye-fill"></i>
                          </a>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

    </div><!-- /page-content -->

    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>

<!-- Chart data passed to JS -->
<script>
  window.dashboardData = {
    revenue: {
      labels: [
        <c:forEach var="r" items="${monthlyRevenue}" varStatus="s">
          '<c:out value="${r.month}"/>'<c:if test="${!s.last}">,</c:if>
        </c:forEach>
      ],
      values: [
        <c:forEach var="r" items="${monthlyRevenue}" varStatus="s">
          <c:out value="${r.revenue}"/><c:if test="${!s.last}">,</c:if>
        </c:forEach>
      ]
    },
    statusData: {
      labels: ['Scheduled','Completed','Cancelled','No Show','Other'],
      values: [
        ${todayAppts - todayCompleted - todayCancelled},
        ${todayCompleted},
        ${todayCancelled},
        0, 0
      ]
    }
  };
</script>
