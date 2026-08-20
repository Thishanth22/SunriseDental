<%-- dentists/dentist-view.jsp — Dentist Profile View --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Dr. ${dentist.fullName}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Dentist Profile</div>
        <div class="topbar-subtitle">Practitioner summary details</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/dentists?action=edit&id=${dentist.dentistId}" class="btn btn-primary btn-sm">
          <i class="bi bi-pencil-fill me-1"></i> Edit Profile
        </a>
        <a href="${pageContext.request.contextPath}/dentists" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i> Back
        </a>
      </div>
    </div>

    <div class="page-content">
      <div class="row g-3">
        
        <!-- Summary card -->
        <div class="col-lg-4">
          <div class="card mb-3">
            <div class="card-body text-center py-4">
              <div class="avatar avatar-lg mx-auto mb-3" style="width:72px;height:72px;font-size:1.8rem;background:var(--accent);">D</div>
              <h5 class="fw-800 mb-1">Dr. ${dentist.fullName}</h5>
              <p class="text-secondary fw-600 mb-2">${dentist.specialization}</p>
              <p class="text-muted mb-3" style="font-size:.8rem;"><code>${dentist.dentistNumber}</code></p>
              
              <div class="mb-3">
                <c:choose>
                  <c:when test="${dentist.status == 'ACTIVE'}">
                    <span class="badge bg-success">Active</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-secondary">Inactive</span>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="border-top pt-3 text-start style-details" style="font-size:.85rem;">
                <div class="row g-2">
                  <div class="col-5 text-secondary">Council License:</div>
                  <div class="col-7 fw-700">${dentist.licenseNumber}</div>
                  
                  <div class="col-5 text-secondary">Qualifications:</div>
                  <div class="col-7 fw-700 text-primary-custom">${dentist.qualification}</div>

                  <div class="col-5 text-secondary">Shift Hours:</div>
                  <div class="col-7 font-monospace fw-700">${dentist.workStartTime} &ndash; ${dentist.workEndTime}</div>
                </div>
              </div>
            </div>
            <div class="card-footer">
              <c:if test="${dentist.status == 'ACTIVE'}">
                <form action="${pageContext.request.contextPath}/dentists" method="POST" class="w-100">
                  <input type="hidden" name="action" value="deactivate"/>
                  <input type="hidden" name="id" value="${dentist.dentistId}"/>
                  <button type="submit" class="btn btn-outline-danger btn-sm w-100" data-confirm="Deactivate Dr. ${dentist.fullName} profile?">
                    <i class="bi bi-person-dash me-1"></i>Deactivate Dentist
                  </button>
                </form>
              </c:if>
            </div>
          </div>
        </div>

        <!-- Weekly schedule -->
        <div class="col-lg-8">
          <div class="card mb-3">
            <div class="card-header">
              <i class="bi bi-calendar-week-fill text-primary"></i>
              <h6>Weekly Availability Registry</h6>
            </div>
            <div class="card-body">
              <div class="list-group">
                <div class="list-group-item d-flex justify-content-between align-items-center">
                  <span>Monday Availability</span>
                  <span class="badge ${dentist.availableMonday ? 'bg-success' : 'bg-secondary'}">${dentist.availableMonday ? 'Available' : 'Off Duty'}</span>
                </div>
                <div class="list-group-item d-flex justify-content-between align-items-center">
                  <span>Tuesday Availability</span>
                  <span class="badge ${dentist.availableTuesday ? 'bg-success' : 'bg-secondary'}">${dentist.availableTuesday ? 'Available' : 'Off Duty'}</span>
                </div>
                <div class="list-group-item d-flex justify-content-between align-items-center">
                  <span>Wednesday Availability</span>
                  <span class="badge ${dentist.availableWednesday ? 'bg-success' : 'bg-secondary'}">${dentist.availableWednesday ? 'Available' : 'Off Duty'}</span>
                </div>
                <div class="list-group-item d-flex justify-content-between align-items-center">
                  <span>Thursday Availability</span>
                  <span class="badge ${dentist.availableThursday ? 'bg-success' : 'bg-secondary'}">${dentist.availableThursday ? 'Available' : 'Off Duty'}</span>
                </div>
                <div class="list-group-item d-flex justify-content-between align-items-center">
                  <span>Friday Availability</span>
                  <span class="badge ${dentist.availableFriday ? 'bg-success' : 'bg-secondary'}">${dentist.availableFriday ? 'Available' : 'Off Duty'}</span>
                </div>
                <div class="list-group-item d-flex justify-content-between align-items-center">
                  <span>Saturday Availability</span>
                  <span class="badge ${dentist.availableSaturday ? 'bg-success' : 'bg-secondary'}">${dentist.availableSaturday ? 'Available' : 'Off Duty'}</span>
                </div>
                <div class="list-group-item d-flex justify-content-between align-items-center">
                  <span>Sunday Availability</span>
                  <span class="badge ${dentist.availableSunday ? 'bg-success' : 'bg-secondary'}">${dentist.availableSunday ? 'Available' : 'Off Duty'}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
