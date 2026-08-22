<%-- appointments/appointment-view.jsp — Detailed Appointment View --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Appointment details"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Appointment Summary</div>
        <div class="topbar-subtitle">Appointment: ${appointment.appointmentNumber}</div>
      </div>
      <div class="topbar-right">
        <c:if test="${appointment.editable}">
          <a href="${pageContext.request.contextPath}/appointments?action=edit&id=${appointment.appointmentId}" class="btn btn-primary btn-sm">
            <i class="bi bi-pencil-fill me-1"></i> Reschedule
          </a>
        </c:if>
        <a href="${pageContext.request.contextPath}/appointments" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i> Back to Schedule
        </a>
      </div>
    </div>

    <div class="page-content">

      <!-- Alert notifications -->
      <c:if test="${param.msg == 'booked'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Appointment booked successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Appointment details rescheduled.</div>
      </c:if>
      <c:if test="${param.msg == 'completed'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Appointment completed. Ready to generate invoice/bill.</div>
      </c:if>

      <div class="row g-3">
        <div class="col-lg-8">
          <!-- Main Details Card -->
          <div class="card mb-3">
            <div class="card-header justify-content-between">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-calendar2-event-fill text-primary"></i>
                <h6>Summary Details</h6>
              </div>
              <div>
                <c:choose>
                  <c:when test="${appointment.status == 'COMPLETED'}">
                    <span class="badge bg-success">Completed</span>
                  </c:when>
                  <c:when test="${appointment.status == 'CANCELLED'}">
                    <span class="badge bg-danger">Cancelled</span>
                  </c:when>
                  <c:when test="${appointment.status == 'CONFIRMED'}">
                    <span class="badge bg-info">Confirmed</span>
                  </c:when>
                  <c:when test="${appointment.status == 'NO_SHOW'}">
                    <span class="badge bg-secondary">No Show</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-primary">Scheduled</span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <span class="text-secondary" style="font-size:.8rem;text-transform:uppercase;">Scheduled Date</span>
                  <div class="fw-700 fs-5">
                    <fmt:formatDate value="${appointment.appointmentDateSql}" pattern="EEEE, dd MMMM yyyy"/>
                  </div>
                </div>
                <div class="col-md-6">
                  <span class="text-secondary" style="font-size:.8rem;text-transform:uppercase;">Session Time</span>
                  <div class="fw-700 fs-5 text-primary-custom">
                    <fmt:formatDate value="${appointment.appointmentTimeSql}" pattern="HH:mm"/> &ndash; 
                    <fmt:formatDate value="${appointment.endTimeSql}" pattern="HH:mm"/>
                    <span class="fs-6 text-muted font-monospace">(${appointment.treatmentDurationMins} mins)</span>
                  </div>
                </div>
                <hr class="my-2"/>
                <div class="col-md-6">
                  <span class="text-secondary" style="font-size:.8rem;text-transform:uppercase;">Patient Name</span>
                  <div class="fw-700">
                    <a href="${pageContext.request.contextPath}/patients?action=view&id=${appointment.patientId}" class="text-decoration-none text-dark">
                      ${appointment.patientName} <code style="font-size:.8rem;">(${appointment.patientNumber})</code>
                    </a>
                  </div>
                </div>
                <div class="col-md-6">
                  <span class="text-secondary" style="font-size:.8rem;text-transform:uppercase;">Assigned Dentist</span>
                  <div class="fw-700 text-dark">
                    Dr. ${appointment.dentistName}
                    <div style="font-size:.75rem;color:var(--text-muted);font-weight:500;">
                      ${appointment.dentistSpecialization}
                    </div>
                  </div>
                </div>
                <hr class="my-2"/>
                <div class="col-md-6">
                  <span class="text-secondary" style="font-size:.8rem;text-transform:uppercase;">Treatment Catalog</span>
                  <div class="fw-700 text-dark">${appointment.treatmentName}</div>
                </div>
                <div class="col-md-6">
                  <span class="text-secondary" style="font-size:.8rem;text-transform:uppercase;">Priority Level</span>
                  <div>
                    <c:choose>
                      <c:when test="${appointment.priority == 'EMERGENCY'}">
                        <span class="badge bg-danger">${appointment.priority}</span>
                      </c:when>
                      <c:when test="${appointment.priority == 'URGENT'}">
                        <span class="badge bg-warning">${appointment.priority}</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-secondary">${appointment.priority}</span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
                
                <c:if test="${not empty appointment.notes}">
                  <hr class="my-2"/>
                  <div class="col-12">
                    <span class="text-secondary" style="font-size:.8rem;text-transform:uppercase;">Special Instructions &amp; Notes</span>
                    <p class="mb-0 bg-light p-2 rounded text-dark" style="font-size:.9rem;">${appointment.notes}</p>
                  </div>
                </c:if>

                <c:if test="${not empty appointment.cancellationReason}">
                  <hr class="my-2"/>
                  <div class="col-12">
                    <span class="text-danger fw-600" style="font-size:.8rem;text-transform:uppercase;">Cancellation Reason</span>
                    <p class="mb-0 bg-danger-subtle p-2 rounded text-danger" style="font-size:.9rem;">${appointment.cancellationReason}</p>
                  </div>
                </c:if>
              </div>
            </div>
          </div>

          <!-- Actions panel -->
          <div class="card">
            <div class="card-header">
              <i class="bi bi-gear-fill text-secondary"></i>
              <h6>Operations / Workflow</h6>
            </div>
            <div class="card-body">
              <div class="d-flex flex-wrap gap-2">
                <c:if test="${appointment.status == 'SCHEDULED'}">
                  <form action="${pageContext.request.contextPath}/appointments" method="POST">
                    <input type="hidden" name="action" value="confirm"/>
                    <input type="hidden" name="id" value="${appointment.appointmentId}"/>
                    <button type="submit" class="btn btn-info"><i class="bi bi-calendar-check"></i> Confirm Appointment</button>
                  </form>
                </c:if>
                
                <c:if test="${appointment.status == 'SCHEDULED' || appointment.status == 'CONFIRMED'}">
                  <form action="${pageContext.request.contextPath}/appointments" method="POST">
                    <input type="hidden" name="action" value="complete"/>
                    <input type="hidden" name="id" value="${appointment.appointmentId}"/>
                    <button type="submit" class="btn btn-success" data-confirm="Mark this appointment session as completed?">
                      <i class="bi bi-clipboard-check"></i> Complete Treatment Session
                    </button>
                  </form>
                </c:if>

                <c:if test="${appointment.status == 'COMPLETED'}">
                  <a href="${pageContext.request.contextPath}/billing?action=new&appointmentId=${appointment.appointmentId}" class="btn btn-primary">
                    <i class="bi bi-receipt"></i> Generate Invoice/Bill
                  </a>
                </c:if>

                <c:if test="${appointment.editable}">
                  <button type="button" class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#cancelModal">
                    <i class="bi bi-calendar-x"></i> Cancel Appointment
                  </button>
                  <form action="${pageContext.request.contextPath}/appointments" method="POST">
                    <input type="hidden" name="action" value="noshow"/>
                    <input type="hidden" name="id" value="${appointment.appointmentId}"/>
                    <button type="submit" class="btn btn-outline-secondary" data-confirm="Mark patient as No Show?">
                      <i class="bi bi-person-x"></i> Mark No Show
                    </button>
                  </form>
                </c:if>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-4">
          <!-- Patient Summary Card -->
          <div class="card mb-3">
            <div class="card-header">
              <i class="bi bi-person-badge-fill text-primary"></i>
              <h6>Patient Info</h6>
            </div>
            <div class="card-body">
              <div class="d-flex align-items-center gap-2 mb-3">
                <div class="avatar avatar-sm">${appointment.patientName.substring(0,1).toUpperCase()}</div>
                <div>
                  <h6 class="fw-700 mb-0">${appointment.patientName}</h6>
                  <span class="text-muted" style="font-size:.75rem;">${appointment.patientNumber}</span>
                </div>
              </div>
              <div style="font-size:.85rem;">
                <div class="mb-2"><strong>Phone:</strong> ${appointment.patientPhone}</div>
                <div class="mb-2"><strong>Address:</strong> <c:out value="${empty appointment.patientAddress ? 'Not specified' : appointment.patientAddress}"/></div>
                <div class="mb-2"><strong>Quick View:</strong> <a href="${pageContext.request.contextPath}/patients?action=view&id=${appointment.patientId}" class="text-decoration-none">Full Profile</a></div>
              </div>
            </div>
          </div>

          <!-- Metadata info -->
          <div class="card">
            <div class="card-header">
              <i class="bi bi-info-circle text-secondary"></i>
              <h6>System Logs</h6>
            </div>
            <div class="card-body" style="font-size:.8rem;color:var(--text-secondary);">
              <div class="mb-2"><strong>Booked By ID:</strong> ${appointment.createdBy}</div>
              <div class="mb-2"><strong>Created:</strong> 
                <fmt:parseDate value="${appointment.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedCa" type="both"/>
                <fmt:formatDate value="${parsedCa}" pattern="dd MMM yyyy, HH:mm"/>
              </div>
              <c:if test="${not empty appointment.updatedAt}">
                <div><strong>Updated:</strong> 
                  <fmt:parseDate value="${appointment.updatedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedUa" type="both"/>
                  <fmt:formatDate value="${parsedUa}" pattern="dd MMM yyyy, HH:mm"/>
                </div>
              </c:if>
            </div>
          </div>
        </div>
      </div>

    </div>

    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>

<!-- Cancel Modal -->
<div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="${pageContext.request.contextPath}/appointments" method="POST" class="needs-validation" novalidate>
      <input type="hidden" name="action" value="cancel"/>
      <input type="hidden" name="id" value="${appointment.appointmentId}"/>
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="cancelModalLabel">Cancel Appointment</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label" for="cancelReason">Reason for Cancellation <span class="text-danger">*</span></label>
            <textarea name="reason" id="cancelReason" class="form-control" rows="3" required placeholder="State reason (e.g. Patient rescheduled, Dentist unavailable...)"></textarea>
            <div class="invalid-feedback">Cancellation reason is required.</div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
          <button type="submit" class="btn btn-danger">Confirm Cancellation</button>
        </div>
      </div>
    </form>
  </div>
</div>
