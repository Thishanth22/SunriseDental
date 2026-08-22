<%-- appointments/appointment-list.jsp — Appointment list --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Appointments"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <!-- Topbar -->
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Appointment Management</div>
        <div class="topbar-subtitle">Manage clinic appointments schedule</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/appointments?action=new" class="btn btn-primary btn-sm">
          <i class="bi bi-calendar-plus-fill me-1"></i> Book Appointment
        </a>
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Appointments</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>
      <c:if test="${param.msg == 'booked'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Appointment booked successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Appointment details rescheduled.</div>
      </c:if>
      <c:if test="${param.msg == 'cancelled'}">
        <div class="alert alert-warning auto-dismiss mb-3"><i class="bi bi-calendar-x-fill me-2"></i>Appointment cancelled.</div>
      </c:if>

      <!-- Search & Filters -->
      <div class="card mb-3">
        <div class="card-body py-3">
          <form method="GET" action="${pageContext.request.contextPath}/appointments" class="row g-2 align-items-end">
            <div class="col-md-3">
              <label class="form-label" style="font-size:.7rem;" for="qInput">Search Patient</label>
              <div class="search-wrapper">
                <i class="bi bi-search"></i>
                <input type="text" name="q" id="qInput" class="form-control" placeholder="Name or number..." value="${q}"/>
              </div>
            </div>
            
            <div class="col-md-2">
              <label class="form-label" style="font-size:.7rem;" for="statusInput">Status</label>
              <select name="status" id="statusInput" class="form-select">
                <option value="">All Statuses</option>
                <option value="SCHEDULED"   ${statusFilter == 'SCHEDULED'   ? 'selected' : ''}>Scheduled</option>
                <option value="CONFIRMED"   ${statusFilter == 'CONFIRMED'   ? 'selected' : ''}>Confirmed</option>
                <option value="COMPLETED"   ${statusFilter == 'COMPLETED'   ? 'selected' : ''}>Completed</option>
                <option value="CANCELLED"   ${statusFilter == 'CANCELLED'   ? 'selected' : ''}>Cancelled</option>
                <option value="NO_SHOW"     ${statusFilter == 'NO_SHOW'     ? 'selected' : ''}>No Show</option>
              </select>
            </div>

            <div class="col-md-2">
              <label class="form-label" style="font-size:.7rem;" for="dateFromInput">From Date</label>
              <input type="date" name="dateFrom" id="dateFromInput" class="form-control" value="${dateFrom}"/>
            </div>
            <div class="col-md-2">
              <label class="form-label" style="font-size:.7rem;" for="dateToInput">To Date</label>
              <input type="date" name="dateTo" id="dateToInput" class="form-control" value="${dateTo}"/>
            </div>

            <div class="col-md-2">
              <button type="submit" class="btn btn-primary w-100"><i class="bi bi-funnel me-1"></i>Filter</button>
            </div>
            <div class="col-md-1">
              <a href="${pageContext.request.contextPath}/appointments" class="btn btn-outline-secondary w-100" title="Reset Filters"><i class="bi bi-arrow-counterclockwise"></i></a>
            </div>
          </form>
        </div>
      </div>

      <!-- Schedule table -->
      <div class="card">
        <div class="card-header justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-calendar2-week-fill text-primary"></i>
            <h6>Appointments Checklist</h6>
            <span class="badge bg-primary">${total}</span>
          </div>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty appointments}">
              <div class="empty-state">
                <i class="bi bi-calendar-x"></i>
                <p>No appointments found matching constraints.</p>
                <a href="${pageContext.request.contextPath}/appointments?action=new" class="btn btn-primary btn-sm mt-2">
                  <i class="bi bi-calendar-plus-fill me-1"></i>Book New Appointment
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Appointment #</th>
                      <th>Date &amp; Time</th>
                      <th>Patient</th>
                      <th>Dentist</th>
                      <th>Treatment</th>
                      <th>Priority</th>
                      <th>Status</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="appt" items="${appointments}">
                      <tr>
                        <td><code style="font-size:.8rem;">${appt.appointmentNumber}</code></td>
                        <td>
                          <strong>
                            <fmt:formatDate value="${appt.appointmentDateSql}" pattern="dd MMM yyyy"/>
                          </strong>
                          <div style="font-size:.75rem;color:var(--text-muted);">
                            <fmt:formatDate value="${appt.appointmentTimeSql}" pattern="HH:mm"/> &ndash; 
                            <fmt:formatDate value="${appt.endTimeSql}" pattern="HH:mm"/>
                          </div>
                        </td>
                        <td>
                          <div class="fw-600">
                            ${appt.patientName}
                            <c:if test="${not empty appt.patientAllergies}">
                              <span class="badge bg-danger ms-1" style="font-size:.65rem;" title="Allergies: <c:out value="${appt.patientAllergies}"/>">
                                <i class="bi bi-exclamation-octagon-fill"></i> Allergy!
                              </span>
                            </c:if>
                          </div>
                          <div style="font-size:.75rem;color:var(--text-muted);">${appt.patientNumber}</div>
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
                              <span class="badge bg-success">Completed</span>
                            </c:when>
                            <c:when test="${appt.status == 'CANCELLED'}">
                              <span class="badge bg-danger">Cancelled</span>
                            </c:when>
                            <c:when test="${appt.status == 'CONFIRMED'}">
                              <span class="badge bg-info">Confirmed</span>
                            </c:when>
                            <c:when test="${appt.status == 'NO_SHOW'}">
                              <span class="badge bg-secondary">No Show</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-primary">Scheduled</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <div class="btn-group btn-group-sm">
                            <a href="${pageContext.request.contextPath}/appointments?action=view&id=${appt.appointmentId}"
                               class="btn btn-outline-primary" title="Details" data-bs-toggle="tooltip">
                              <i class="bi bi-eye-fill"></i>
                            </a>
                            <c:if test="${appt.editable}">
                              <a href="${pageContext.request.contextPath}/appointments?action=edit&id=${appt.appointmentId}"
                                 class="btn btn-outline-secondary" title="Reschedule" data-bs-toggle="tooltip">
                                <i class="bi bi-calendar-event"></i>
                              </a>
                            </c:if>
                          </div>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>

              <!-- Pagination -->
              <c:if test="${totalPages > 1}">
                <div class="d-flex justify-content-between align-items-center p-3">
                  <div style="font-size:.8rem;color:var(--text-muted);">
                    Showing ${(page-1)*pageSize + 1} &ndash; ${[(page)*pageSize < total ? (page)*pageSize : total]} of ${total} appointments
                  </div>
                  <nav>
                    <ul class="pagination pagination-sm mb-0">
                      <li class="page-item ${page == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page-1}&q=${q}&status=${statusFilter}&dateFrom=${dateFrom}&dateTo=${dateTo}">
                          <i class="bi bi-chevron-left"></i>
                        </a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="pg">
                        <li class="page-item ${pg == page ? 'active' : ''}">
                          <a class="page-link" href="?page=${pg}&q=${q}&status=${statusFilter}&dateFrom=${dateFrom}&dateTo=${dateTo}">${pg}</a>
                        </li>
                      </c:forEach>
                      <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page+1}&q=${q}&status=${statusFilter}&dateFrom=${dateFrom}&dateTo=${dateTo}">
                          <i class="bi bi-chevron-right"></i>
                        </a>
                      </li>
                    </ul>
                  </nav>
                </div>
              </c:if>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
