<%-- dentists/dentist-form.jsp — Add / Edit Dentist --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty dentist && dentist.dentistId > 0}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Dentist' : 'Add Dentist'}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">${isEdit ? 'Edit Dentist' : 'Register New Dentist'}</div>
        <div class="topbar-subtitle">Manage practitioner profile &amp; working schedule</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/dentists" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back
        </a>
      </div>
    </div>

    <div class="page-content">
      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/dentists"
            method="POST"
            class="needs-validation form-with-loading"
            novalidate>
        
        <input type="hidden" name="action" value="${isEdit ? 'update' : 'save'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="dentistId" value="${dentist.dentistId}"/>
        </c:if>

        <div class="row g-3">
          <div class="col-lg-8">
            <!-- Details Card -->
            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-person-fill text-primary"></i>
                <h6>Profile Details</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label class="form-label" for="firstName">First Name <span class="text-danger">*</span></label>
                    <input type="text" id="firstName" name="firstName" class="form-control" value="${dentist.firstName}" required maxlength="100"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="lastName">Last Name <span class="text-danger">*</span></label>
                    <input type="text" id="lastName" name="lastName" class="form-control" value="${dentist.lastName}" required maxlength="100"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="specialization">Specialization <span class="text-danger">*</span></label>
                    <select id="specialization" name="specialization" class="form-select" required>
                      <option value="">-- Select Specialist --</option>
                      <option value="General Dentistry" ${dentist.specialization == 'General Dentistry' ? 'selected' : ''}>General Dentistry</option>
                      <option value="Orthodontics"      ${dentist.specialization == 'Orthodontics'      ? 'selected' : ''}>Orthodontics</option>
                      <option value="Periodontics"      ${dentist.specialization == 'Periodontics'      ? 'selected' : ''}>Periodontics</option>
                      <option value="Endodontics"       ${dentist.specialization == 'Endodontics'       ? 'selected' : ''}>Endodontics</option>
                      <option value="Prosthodontics"    ${dentist.specialization == 'Prosthodontics'    ? 'selected' : ''}>Prosthodontics</option>
                      <option value="Oral Surgery"      ${dentist.specialization == 'Oral Surgery'      ? 'selected' : ''}>Oral Surgery</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="qualification">Qualifications <span class="text-danger">*</span></label>
                    <input type="text" id="qualification" name="qualification" class="form-control" value="${dentist.qualification}" required maxlength="150" placeholder="e.g. BDS (Pera), DDS (USA)"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="licenseNumber">Dental Council License # <span class="text-danger">*</span></label>
                    <input type="text" id="licenseNumber" name="licenseNumber" class="form-control" value="${dentist.licenseNumber}" required maxlength="50"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="contactNumber">Contact Number <span class="text-danger">*</span></label>
                    <input type="tel" id="contactNumber" name="contactNumber" class="form-control" value="${dentist.contactNumber}" required maxlength="15" data-phone/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="email">Email Address <span class="text-danger">*</span></label>
                    <input type="email" id="email" name="email" class="form-control" value="${dentist.email}" required maxlength="150"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="status">Status</label>
                    <select id="status" name="status" class="form-select">
                      <option value="ACTIVE"   ${dentist.status == 'ACTIVE'   ? 'selected' : ''}>Active</option>
                      <option value="INACTIVE" ${dentist.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>

            <!-- Schedule Card -->
            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-calendar2-week-fill text-primary"></i>
                <h6>Working Schedule &amp; Hours</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label class="form-label" for="workStart">Shift Start Time <span class="text-danger">*</span></label>
                    <input type="time" id="workStart" name="workStart" class="form-control" value="${dentist.workStartTime}" required/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="workEnd">Shift End Time <span class="text-danger">*</span></label>
                    <input type="time" id="workEnd" name="workEnd" class="form-control" value="${dentist.workEndTime}" required/>
                  </div>

                  <div class="col-12">
                    <label class="form-label d-block mb-2">Weekly Availability Checkboxes</label>
                    <div class="d-flex flex-wrap gap-3">
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="monday" name="monday" ${dentist.availableMonday || not isEdit ? 'checked' : ''}/>
                        <label class="form-check-label" for="monday">Monday</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="tuesday" name="tuesday" ${dentist.availableTuesday || not isEdit ? 'checked' : ''}/>
                        <label class="form-check-label" for="tuesday">Tuesday</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="wednesday" name="wednesday" ${dentist.availableWednesday || not isEdit ? 'checked' : ''}/>
                        <label class="form-check-label" for="wednesday">Wednesday</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="thursday" name="thursday" ${dentist.availableThursday || not isEdit ? 'checked' : ''}/>
                        <label class="form-check-label" for="thursday">Thursday</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="friday" name="friday" ${dentist.availableFriday || not isEdit ? 'checked' : ''}/>
                        <label class="form-check-label" for="friday">Friday</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="saturday" name="saturday" ${dentist.availableSaturday ? 'checked' : ''}/>
                        <label class="form-check-label" for="saturday">Saturday</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="sunday" name="sunday" ${dentist.availableSunday ? 'checked' : ''}/>
                        <label class="form-check-label" for="sunday">Sunday</label>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="d-flex gap-2 justify-content-end mt-2">
          <a href="${pageContext.request.contextPath}/dentists" class="btn btn-outline-secondary">Cancel</a>
          <button type="submit" class="btn btn-primary">${isEdit ? 'Update Details' : 'Add Dentist'}</button>
        </div>

      </form>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
