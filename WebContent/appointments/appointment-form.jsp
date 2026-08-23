<%-- appointments/appointment-form.jsp — Book / Edit Appointment --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="isEdit" value="${not empty appointment && appointment.appointmentId > 0}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Appointment' : 'Book Appointment'}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">${isEdit ? 'Reschedule Appointment' : 'Book New Appointment'}</div>
        <div class="topbar-subtitle">Schedule a dental consultation</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/appointments" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back
        </a>
      </div>
    </div>

    <div class="page-content">

      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3">
          <i class="bi bi-exclamation-circle-fill me-2"></i>${error}
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/appointments"
            method="POST"
            class="needs-validation form-with-loading"
            novalidate>

        <input type="hidden" name="action" value="${isEdit ? 'update' : 'save'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="appointmentId" value="${appointment.appointmentId}"/>
          <input type="hidden" name="appointmentNumber" value="${appointment.appointmentNumber}"/>
          <input type="hidden" id="excludeId" value="${appointment.appointmentId}"/>
        </c:if>
        <c:if test="${not isEdit}">
          <input type="hidden" id="excludeId" value="0"/>
        </c:if>

        <div class="row g-3">
          <!-- LEFT COLUMN -->
          <div class="col-lg-8">

            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-person-fill text-primary"></i>
                <h6>Patient &amp; Treatment</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label class="form-label" for="patientId">Patient <span class="text-danger">*</span></label>
                    <select id="patientId" name="patientId" class="form-select" required>
                      <option value="" data-phone="" data-address="">-- Select Patient --</option>
                      <c:forEach var="p" items="${patients}">
                        <option value="${p.patientId}"
                                data-phone="${p.contactNumber}"
                                data-address="${p.address}${not empty p.city ? ', ' : ''}${p.city}"
                                ${appointment.patientId == p.patientId || param.patientId == p.patientId ? 'selected' : ''}>
                          ${p.fullName} (${p.patientNumber})
                        </option>
                      </c:forEach>
                    </select>
                    <div class="invalid-feedback">Please select a patient.</div>
                  </div>

                  <div class="col-md-6">
                    <label class="form-label" for="treatmentId">Treatment <span class="text-danger">*</span></label>
                    <select id="treatmentId" name="treatmentId" class="form-select" required>
                      <option value="">-- Select Treatment --</option>
                      <c:forEach var="t" items="${treatments}">
                        <option value="${t.treatmentId}"
                                data-duration="${t.durationMins}"
                                data-cost="${t.baseCost}"
                                ${appointment.treatmentId == t.treatmentId ? 'selected' : ''}>
                          ${t.treatmentName} (${t.category}) — LKR <fmt:formatNumber value="${t.baseCost}" type="number"/>
                        </option>
                      </c:forEach>
                    </select>
                    <div class="invalid-feedback">Please select a treatment.</div>
                    <div id="treatmentDuration" class="mt-1" style="font-size:.75rem;color:var(--text-muted);"></div>
                  </div>

                  <!-- Patient Contact & Address Fields -->
                  <div class="col-md-6">
                    <label class="form-label" for="patientPhone">Phone Number</label>
                    <div class="input-group">
                      <span class="input-group-text"><i class="bi bi-telephone-fill text-muted"></i></span>
                      <input type="tel" id="patientPhone" name="patientPhone"
                             class="form-control"
                             placeholder="e.g. 0771234567"
                             value="${not empty appointment.patientPhone ? appointment.patientPhone : ''}"/>
                    </div>
                    <div class="form-text text-muted" style="font-size:.75rem;">
                      Auto-populated from patient record; editable for this booking.
                    </div>
                  </div>

                  <div class="col-md-6">
                    <label class="form-label" for="patientAddress">Patient Address</label>
                    <div class="input-group">
                      <span class="input-group-text"><i class="bi bi-geo-alt-fill text-muted"></i></span>
                      <input type="text" id="patientAddress" name="patientAddress"
                             class="form-control"
                             placeholder="e.g. 45 Galle Road, Colombo"
                             value="${not empty appointment.patientAddress ? appointment.patientAddress : ''}"/>
                    </div>
                    <div class="form-text text-muted" style="font-size:.75rem;">
                      Residential / contact address of the patient.
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-calendar2-week-fill text-primary"></i>
                <h6>Schedule</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label class="form-label" for="dentistId">Dentist <span class="text-danger">*</span></label>
                    <select id="dentistId" name="dentistId" class="form-select" required>
                      <option value="" data-start="" data-end="" data-days="" data-mon="false" data-tue="false" data-wed="false" data-thu="false" data-fri="false" data-sat="false" data-sun="false">-- Select Dentist --</option>
                      <c:forEach var="d" items="${dentists}">
                        <option value="${d.dentistId}"
                                data-start="${d.workStartTime}"
                                data-end="${d.workEndTime}"
                                data-days="${d.availableDaysSummary}"
                                data-mon="${d.availableMonday}"
                                data-tue="${d.availableTuesday}"
                                data-wed="${d.availableWednesday}"
                                data-thu="${d.availableThursday}"
                                data-fri="${d.availableFriday}"
                                data-sat="${d.availableSaturday}"
                                data-sun="${d.availableSunday}"
                                ${appointment.dentistId == d.dentistId ? 'selected' : ''}>
                          ${d.fullName.startsWith('Dr.') ? d.fullName : 'Dr. '.concat(d.fullName)} — ${d.specialization}
                        </option>
                      </c:forEach>
                    </select>
                    <div class="invalid-feedback">Please select a dentist.</div>
                    <div id="dentistScheduleBadge" class="mt-1" style="font-size:.78rem;font-weight:500;"></div>
                  </div>

                  <div class="col-md-3">
                    <label class="form-label" for="appointmentDate">Date <span class="text-danger">*</span></label>
                    <input type="date" id="appointmentDate" name="appointmentDate"
                           class="form-control"
                           value="${not empty appointment.appointmentDate ? appointment.appointmentDate : ''}"
                           min="${today}" required/>
                    <div class="invalid-feedback">Please select a date.</div>
                    <div id="dateAvailabilityBadge" class="mt-1" style="font-size:.78rem;"></div>
                  </div>

                  <div class="col-md-3">
                    <label class="form-label" for="appointmentTime">Time <span class="text-danger">*</span></label>
                    <input type="time" id="appointmentTime" name="appointmentTime"
                           class="form-control"
                           value="${not empty appointment.appointmentTime ? appointment.appointmentTime : ''}"
                           step="60" required/>
                    <div class="invalid-feedback">Please select a valid appointment time.</div>
                    <div id="timeGuidance" class="mt-1 text-muted" style="font-size:.75rem;"></div>
                  </div>

                  <!-- Availability Status (AJAX result) -->
                  <div class="col-12">
                    <div id="availabilityStatus" class="mt-1" style="font-size:.85rem;min-height:1.5rem;"></div>
                  </div>
                </div>
              </div>
            </div>

            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-card-text text-primary"></i>
                <h6>Additional Details</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-4">
                    <label class="form-label" for="priority">Priority</label>
                    <select id="priority" name="priority" class="form-select">
                      <option value="NORMAL"    ${appointment.priority == 'NORMAL'    ? 'selected' : ''}>Normal</option>
                      <option value="URGENT"    ${appointment.priority == 'URGENT'    ? 'selected' : ''}>Urgent</option>
                      <option value="EMERGENCY" ${appointment.priority == 'EMERGENCY' ? 'selected' : ''}>Emergency</option>
                    </select>
                  </div>
                  <div class="col-md-8">
                    <label class="form-label" for="notes">Notes</label>
                    <textarea id="notes" name="notes" class="form-control" rows="2"
                              maxlength="500"
                              placeholder="Special instructions, patient concerns...">${appointment.notes}</textarea>
                  </div>
                </div>
              </div>
            </div>

          </div>

          <!-- RIGHT COLUMN — Info Panel -->
          <div class="col-lg-4">
            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-info-circle-fill text-primary"></i>
                <h6>Booking Guidelines</h6>
              </div>
              <div class="card-body">
                <ul class="list-unstyled" style="font-size:.85rem;color:var(--text-secondary);">
                  <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Select the patient and treatment first.</li>
                  <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Choose a dentist trained for the treatment.</li>
                  <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>The availability checker confirms no conflicts.</li>
                  <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Appointments can only be booked during working hours.</li>
                  <li class="mb-2"><i class="bi bi-exclamation-triangle-fill text-warning me-2"></i>Emergency bookings may override standard rules.</li>
                </ul>
              </div>
            </div>

            <div class="card">
              <div class="card-header">
                <i class="bi bi-shield-check-fill text-success"></i>
                <h6>Double-Booking Protection</h6>
              </div>
              <div class="card-body" style="font-size:.85rem;color:var(--text-secondary);">
                <p>The system automatically checks for scheduling conflicts when you select dentist, date and time.</p>
                <div id="availabilityStatus2" class="mt-2"></div>
              </div>
            </div>
          </div>
        </div>

        <div class="d-flex gap-2 justify-content-end mt-2">
          <a href="${pageContext.request.contextPath}/appointments" class="btn btn-outline-secondary">
            <i class="bi bi-x-circle me-1"></i>Cancel
          </a>
          <button type="submit" id="apptSubmitBtn" class="btn btn-primary">
            <i class="bi bi-calendar-check-fill me-1"></i>
            ${isEdit ? 'Update Appointment' : 'Book Appointment'}
          </button>
        </div>

      </form>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
