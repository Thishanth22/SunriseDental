<%-- patients/patient-list.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Patients"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Patient Management</div>
        <div class="topbar-subtitle">Manage clinic patient records</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/patients?action=new" class="btn btn-primary btn-sm">
          <i class="bi bi-person-plus-fill"></i> Register Patient
        </a>
      </div>
    </div>

    <div class="page-content">

      <nav aria-label="breadcrumb" class="breadcrumb-nav mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Patients</li>
        </ol>
      </nav>

      <!-- Messages -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>
      <c:if test="${param.msg == 'saved'}">
        <div class="alert alert-success auto-dismiss"><i class="bi bi-check-circle-fill me-2"></i>Patient registered successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success auto-dismiss"><i class="bi bi-check-circle-fill me-2"></i>Patient details updated successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'deactivated'}">
        <div class="alert alert-warning auto-dismiss"><i class="bi bi-person-dash-fill me-2"></i>Patient deactivated.</div>
      </c:if>

      <!-- Search & Filter Bar -->
      <div class="card mb-3">
        <div class="card-body py-3">
          <form method="GET" action="${pageContext.request.contextPath}/patients" class="row g-2 align-items-end">
            <div class="col-md-8">
              <div class="search-wrapper">
                <i class="bi bi-search"></i>
                <input type="text" name="q" id="searchInput" class="form-control search-auto-submit"
                       placeholder="Search by name, contact, email, or patient number..."
                       value="${not empty query ? query : ''}"
                       maxlength="100"/>
              </div>
            </div>
            <div class="col-md-2">
              <button type="submit" class="btn btn-primary w-100">
                <i class="bi bi-search me-1"></i>Search
              </button>
            </div>
            <div class="col-md-2">
              <a href="${pageContext.request.contextPath}/patients" class="btn btn-outline-secondary w-100">
                <i class="bi bi-x-circle me-1"></i>Clear
              </a>
            </div>
          </form>
        </div>
      </div>

      <!-- Patient Table -->
      <div class="card">
        <div class="card-header justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-people-fill text-primary"></i>
            <h6>Patient Records</h6>
            <span class="badge bg-primary">${total}</span>
          </div>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty patients}">
              <div class="empty-state">
                <i class="bi bi-person-slash"></i>
                <p>No patients found.</p>
                <a href="${pageContext.request.contextPath}/patients?action=new" class="btn btn-primary btn-sm mt-2">
                  <i class="bi bi-person-plus-fill me-1"></i>Register First Patient
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Patient #</th>
                      <th>Name</th>
                      <th>Gender</th>
                      <th>Contact</th>
                      <th>Email</th>
                      <th>Blood Group</th>
                      <th>Status</th>
                      <th>Registered</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="p" items="${patients}" varStatus="s">
                      <tr>
                        <td class="text-muted" style="font-size:.8rem;">${(page-1)*pageSize + s.index + 1}</td>
                        <td><code style="font-size:.8rem;">${p.patientNumber}</code></td>
                        <td>
                          <div class="d-flex align-items-center gap-2">
                            <div class="avatar avatar-sm">
                              ${not empty p.firstName ? p.firstName.substring(0,1) : 'P'}
                            </div>
                            <div>
                              <div class="fw-600">${p.fullName}</div>
                              <div style="font-size:.75rem;color:var(--text-muted);">
                                <c:if test="${p.age > 0}">${p.age} yrs</c:if>
                              </div>
                            </div>
                          </div>
                        </td>
                        <td>${p.gender}</td>
                        <td>${p.contactNumber}</td>
                        <td style="font-size:.8rem;">${p.email}</td>
                        <td>
                          <c:if test="${not empty p.bloodGroup}">
                            <span class="badge bg-danger">${p.bloodGroup}</span>
                          </c:if>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${p.status == 'ACTIVE'}">
                              <span class="badge bg-success">Active</span>
                            </c:when>
                            <c:when test="${p.status == 'INACTIVE'}">
                              <span class="badge bg-secondary">Inactive</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-warning">${p.status}</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td style="font-size:.8rem;">
                          <fmt:formatDate value="${p.registrationDateSql}" pattern="dd MMM yyyy"/>
                        </td>
                        <td class="text-center">
                          <div class="btn-group btn-group-sm">
                            <a href="${pageContext.request.contextPath}/patients?action=view&id=${p.patientId}"
                               class="btn btn-outline-primary" title="View" data-bs-toggle="tooltip">
                              <i class="bi bi-eye-fill"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/patients?action=edit&id=${p.patientId}"
                               class="btn btn-outline-secondary" title="Edit" data-bs-toggle="tooltip">
                              <i class="bi bi-pencil-fill"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/appointments?action=new&patientId=${p.patientId}"
                               class="btn btn-outline-success" title="Book Appointment" data-bs-toggle="tooltip">
                              <i class="bi bi-calendar-plus-fill"></i>
                            </a>
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
                    Showing ${(page-1)*pageSize + 1} – ${[(page)*pageSize < total ? (page)*pageSize : total]} of ${total} patients
                  </div>
                  <nav>
                    <ul class="pagination pagination-sm mb-0">
                      <li class="page-item ${page == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page-1}&q=${query}">
                          <i class="bi bi-chevron-left"></i>
                        </a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="pg">
                        <li class="page-item ${pg == page ? 'active' : ''}">
                          <a class="page-link" href="?page=${pg}&q=${query}">${pg}</a>
                        </li>
                      </c:forEach>
                      <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page+1}&q=${query}">
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
