<%-- reports/report-daily-appointments.jsp — Daily Appointment Report --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="${reportType}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar no-print">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">${reportType}</div>
        <div class="topbar-subtitle">Appointments schedule for <fmt:formatDate value="${reportDateSql}" pattern="dd MMM yyyy"/></div>
      </div>
      <div class="topbar-right">
        <button onclick="window.print();" class="btn btn-primary btn-sm">
          <i class="bi bi-printer me-1"></i> Print Report
        </button>
        <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i> Back to Reports
        </a>
      </div>
    </div>

    <div class="page-content">
      
      <!-- Printable Header -->
      <div class="d-none d-print-block text-center mb-4">
        <h2>SUNRISE DENTAL CLINIC</h2>
        <h4 class="mb-1">${reportType}</h4>
        <p class="text-muted">Generated Date: <fmt:formatDate value="${reportDateSql}" pattern="dd MMMM yyyy"/></p>
        <hr/>
      </div>

      <div class="card">
        <div class="card-header justify-content-between no-print">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-calendar-check text-primary"></i>
            <h6>Schedule Registry</h6>
          </div>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty appointments}">
              <div class="empty-state">
                <i class="bi bi-calendar-x"></i>
                <p>No appointments scheduled for this date.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-bordered mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>Time</th>
                      <th>Appt #</th>
                      <th>Patient Name</th>
                      <th>Dentist</th>
                      <th>Treatment Code</th>
                      <th>Priority</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="appt" items="${appointments}">
                      <tr>
                        <td>
                          <strong><fmt:formatDate value="${appt.appointmentTimeSql}" pattern="HH:mm"/></strong>
                        </td>
                        <td><code>${appt.appointmentNumber}</code></td>
                        <td>${appt.patientName} (${appt.patientNumber})</td>
                        <td>Dr. ${appt.dentistName}</td>
                        <td>${appt.treatmentName}</td>
                        <td>${appt.priority}</td>
                        <td>${appt.status}</td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
