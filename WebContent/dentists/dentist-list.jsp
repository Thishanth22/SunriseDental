<%-- dentists/dentist-list.jsp — Dentist Catalog --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Dentists"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Dentist Catalog</div>
        <div class="topbar-subtitle">Manage clinic dentist directory &amp; availability</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/dentists?action=new" class="btn btn-primary btn-sm">
          <i class="bi bi-person-plus-fill"></i> Add Dentist
        </a>
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Dentists</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>
      <c:if test="${param.msg == 'saved'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Dentist profile registered.</div>
      </c:if>
      <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Dentist profile updated.</div>
      </c:if>
      <c:if test="${param.msg == 'deactivated'}">
        <div class="alert alert-warning auto-dismiss mb-3"><i class="bi bi-person-dash-fill me-2"></i>Dentist status updated.</div>
      </c:if>

      <div class="card">
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty dentists}">
              <div class="empty-state">
                <i class="bi bi-person-badge-fill"></i>
                <p>No dentists registered in the catalog.</p>
                <a href="${pageContext.request.contextPath}/dentists?action=new" class="btn btn-primary btn-sm mt-2">
                  <i class="bi bi-person-plus-fill me-1"></i>Add First Dentist
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Dentist #</th>
                      <th>Dentist Name</th>
                      <th>Specialization</th>
                      <th>License Number</th>
                      <th>Contact Number</th>
                      <th>Work Hours</th>
                      <th>Status</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="d" items="${dentists}">
                      <tr>
                        <td><code>${d.dentistNumber}</code></td>
                        <td>
                          <div class="d-flex align-items-center gap-2">
                            <div class="avatar avatar-sm">D</div>
                            <div class="fw-600">${d.fullName.startsWith('Dr.') ? d.fullName : 'Dr. '.concat(d.fullName)}</div>
                          </div>
                        </td>
                        <td>${d.specialization}</td>
                        <td>${d.licenseNumber}</td>
                        <td>${d.contactNumber}</td>
                        <td>
                          <span class="badge bg-secondary">
                            ${d.workStartTime} &ndash; ${d.workEndTime}
                          </span>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${d.status == 'ACTIVE'}">
                              <span class="badge bg-success">Active</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-secondary">Inactive</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <div class="btn-group btn-group-sm">
                            <a href="${pageContext.request.contextPath}/dentists?action=view&id=${d.dentistId}"
                               class="btn btn-outline-primary" title="Details" data-bs-toggle="tooltip">
                              <i class="bi bi-eye-fill"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/dentists?action=edit&id=${d.dentistId}"
                               class="btn btn-outline-secondary" title="Edit" data-bs-toggle="tooltip">
                              <i class="bi bi-pencil-fill"></i>
                            </a>
                          </div>
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
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
