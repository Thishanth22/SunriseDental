<%-- patients/patient-form.jsp — Register / Edit Patient --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="isEdit" value="${not empty patient && patient.patientId > 0}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Patient' : 'Register Patient'}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">${isEdit ? 'Edit Patient' : 'Register New Patient'}</div>
        <div class="topbar-subtitle">
          ${isEdit ? 'Update patient information' : 'Complete all required fields to register a patient'}
        </div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/patients" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back to Patients
        </a>
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/patients">Patients</a></li>
          <li class="breadcrumb-item active">${isEdit ? 'Edit' : 'Register'}</li>
        </ol>
      </nav>

      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/patients"
            method="POST"
            class="needs-validation form-with-loading"
            novalidate>

        <input type="hidden" name="action" value="${isEdit ? 'update' : 'save'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="patientId" value="${patient.patientId}"/>
        </c:if>

        <!-- ===== PERSONAL INFORMATION ===== -->
        <div class="card mb-3">
          <div class="card-header">
            <i class="bi bi-person-fill text-primary"></i>
            <h6>Personal Information</h6>
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label" for="firstName">First Name <span class="text-danger">*</span></label>
                <input type="text" id="firstName" name="firstName" class="form-control"
                       value="${patient.firstName}" required maxlength="100"
                       placeholder="Enter first name"/>
                <div class="invalid-feedback">First name is required.</div>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="lastName">Last Name <span class="text-danger">*</span></label>
                <input type="text" id="lastName" name="lastName" class="form-control"
                       value="${patient.lastName}" required maxlength="100"
                       placeholder="Enter last name"/>
                <div class="invalid-feedback">Last name is required.</div>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="gender">Gender <span class="text-danger">*</span></label>
                <select id="gender" name="gender" class="form-select" required>
                  <option value="">-- Select --</option>
                  <option value="MALE"   ${patient.gender == 'MALE'   ? 'selected' : ''}>Male</option>
                  <option value="FEMALE" ${patient.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                  <option value="OTHER"  ${patient.gender == 'OTHER'  ? 'selected' : ''}>Other</option>
                </select>
                <div class="invalid-feedback">Please select gender.</div>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="dateOfBirth">Date of Birth</label>
                <input type="date" id="dateOfBirth" name="dateOfBirth" class="form-control"
                       value="${not empty patient.dateOfBirth ? patient.dateOfBirth : ''}"
                       max="${today}"/>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="bloodGroup">Blood Group</label>
                <select id="bloodGroup" name="bloodGroup" class="form-select">
                  <option value="">-- Unknown --</option>
                  <c:forEach var="bg" items="${['A+','A-','B+','B-','AB+','AB-','O+','O-']}">
                    <option value="${bg}" ${patient.bloodGroup == bg ? 'selected' : ''}>${bg}</option>
                  </c:forEach>
                </select>
              </div>
            </div>
          </div>
        </div>

        <!-- ===== CONTACT DETAILS ===== -->
        <div class="card mb-3">
          <div class="card-header">
            <i class="bi bi-telephone-fill text-primary"></i>
            <h6>Contact Details</h6>
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label" for="contactNumber">Contact Number <span class="text-danger">*</span></label>
                <input type="tel" id="contactNumber" name="contactNumber" class="form-control"
                       value="${patient.contactNumber}" required maxlength="15"
                       placeholder="0771234567" data-phone/>
                <div class="invalid-feedback">Please enter a valid contact number.</div>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="altContact">Alt. Contact</label>
                <input type="tel" id="altContact" name="altContact" class="form-control"
                       value="${patient.altContact}" maxlength="15"
                       placeholder="0771234567" data-phone/>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="email">Email Address</label>
                <input type="email" id="email" name="email" class="form-control"
                       value="${patient.email}" maxlength="150"
                       placeholder="patient@example.com"/>
                <div class="invalid-feedback">Please enter a valid email address.</div>
              </div>
              <div class="col-md-8">
                <label class="form-label" for="address">Address</label>
                <input type="text" id="address" name="address" class="form-control"
                       value="${patient.address}" maxlength="255"
                       placeholder="Street address"/>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="city">City</label>
                <input type="text" id="city" name="city" class="form-control"
                       value="${patient.city}" maxlength="100"
                       placeholder="City"/>
              </div>
            </div>
          </div>
        </div>

        <!-- ===== EMERGENCY CONTACT ===== -->
        <div class="card mb-3">
          <div class="card-header">
            <i class="bi bi-exclamation-triangle-fill text-warning"></i>
            <h6>Emergency Contact</h6>
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label" for="emergencyContactName">Contact Name</label>
                <input type="text" id="emergencyContactName" name="emergencyContactName" class="form-control"
                       value="${patient.emergencyContactName}" maxlength="150"
                       placeholder="Full name"/>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="emergencyContactPhone">Contact Phone</label>
                <input type="tel" id="emergencyContactPhone" name="emergencyContactPhone" class="form-control"
                       value="${patient.emergencyContactPhone}" maxlength="15"
                       placeholder="0771234567" data-phone/>
              </div>
              <div class="col-md-4">
                <label class="form-label" for="emergencyContactRelation">Relationship</label>
                <select id="emergencyContactRelation" name="emergencyContactRelation" class="form-select">
                  <option value="">-- Select --</option>
                  <c:forEach var="rel" items="${['Spouse','Parent','Child','Sibling','Friend','Guardian','Other']}">
                    <option value="${rel}" ${patient.emergencyContactRelation == rel ? 'selected' : ''}>${rel}</option>
                  </c:forEach>
                </select>
              </div>
            </div>
          </div>
        </div>

        <!-- ===== MEDICAL INFORMATION ===== -->
        <div class="card mb-3">
          <div class="card-header">
            <i class="bi bi-clipboard2-pulse-fill text-primary"></i>
            <h6>Medical Information</h6>
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label" for="allergies">Known Allergies</label>
                <textarea id="allergies" name="allergies" class="form-control" rows="2"
                          maxlength="500"
                          placeholder="List any known allergies (e.g. Penicillin, latex...)">${patient.allergies}</textarea>
              </div>
              <div class="col-md-6">
                <label class="form-label" for="medicalNotes">Medical Notes</label>
                <textarea id="medicalNotes" name="medicalNotes" class="form-control" rows="2"
                          maxlength="1000"
                          placeholder="Any relevant medical history or conditions...">${patient.medicalNotes}</textarea>
              </div>
            </div>
          </div>
        </div>

        <!-- ===== ACTION BUTTONS ===== -->
        <div class="d-flex gap-2 justify-content-end">
          <a href="${pageContext.request.contextPath}/patients" class="btn btn-outline-secondary">
            <i class="bi bi-x-circle me-1"></i>Cancel
          </a>
          <button type="submit" class="btn btn-primary" id="submitBtn">
            <i class="bi bi-${isEdit ? 'save' : 'person-plus-fill'} me-1"></i>
            ${isEdit ? 'Update Patient' : 'Register Patient'}
          </button>
        </div>

      </form>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
