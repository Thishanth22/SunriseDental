<%-- users/user-list.jsp — Users List (ADMIN only) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Users"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Clinic Staff Users Registry</div>
        <div class="topbar-subtitle">Manage login accounts &amp; RBAC access roles</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/users?action=new" class="btn btn-primary btn-sm">
          <i class="bi bi-person-plus-fill me-1"></i> Create User Account
        </a>
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Users</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>
      <c:if test="${param.msg == 'saved'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>User account created successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>User account details updated.</div>
      </c:if>
      <c:if test="${param.msg == 'deactivated'}">
        <div class="alert alert-warning auto-dismiss mb-3"><i class="bi bi-person-dash-fill me-2"></i>Account deactivated. Login blocked.</div>
      </c:if>
      <c:if test="${param.msg == 'activated'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-person-check-fill me-2"></i>Account activated successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'password-reset'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-shield-check me-2"></i>Password reset successfully.</div>
      </c:if>

      <div class="card">
        <div class="card-header justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-people-fill text-primary"></i>
            <h6>System User Registry</h6>
            <span class="badge bg-primary">${total}</span>
          </div>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty users}">
              <div class="empty-state">
                <i class="bi bi-person-gear"></i>
                <p>No user accounts found.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Name &amp; Contacts</th>
                      <th>Username</th>
                      <th>System Role</th>
                      <th>Status</th>
                      <th>Last Login Session</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="u" items="${users}">
                      <tr>
                        <td>
                          <div class="d-flex align-items-center gap-2">
                            <div class="avatar avatar-sm">${u.fullName.substring(0,1).toUpperCase()}</div>
                            <div>
                              <div class="fw-600">${u.fullName}</div>
                              <div style="font-size:.75rem;color:var(--text-muted);">${u.email} | ${u.phone}</div>
                            </div>
                          </div>
                        </td>
                        <td><code>${u.username}</code></td>
                        <td>
                          <span class="badge bg-primary">${u.roleName}</span>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${u.active}">
                              <span class="badge bg-success">Active</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-secondary">Inactive</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td style="font-size:.8rem;">
                          <c:choose>
                            <c:when test="${not empty u.lastLogin}">
                              <fmt:parseDate value="${u.lastLogin}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedLl" type="both"/>
                              <fmt:formatDate value="${parsedLl}" pattern="dd MMM yyyy, HH:mm"/>
                            </c:when>
                            <c:otherwise><span class="text-muted">Never logged in</span></c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <div class="btn-group btn-group-sm">
                            <a href="${pageContext.request.contextPath}/users?action=edit&id=${u.userId}"
                               class="btn btn-outline-secondary" title="Edit Profile Details" data-bs-toggle="tooltip">
                              <i class="bi bi-pencil-fill"></i>
                            </a>
                            <c:choose>
                              <c:when test="${u.active}">
                                <form action="${pageContext.request.contextPath}/users" method="POST" style="display:inline-block;">
                                  <input type="hidden" name="action" value="deactivate"/>
                                  <input type="hidden" name="id" value="${u.userId}"/>
                                  <button type="submit" class="btn btn-outline-danger btn-sm rounded-0"
                                          title="Deactivate Account" data-bs-toggle="tooltip" data-confirm="Deactivate account ${u.username}?">
                                    <i class="bi bi-person-dash-fill"></i>
                                  </button>
                                </form>
                              </c:when>
                              <c:otherwise>
                                <form action="${pageContext.request.contextPath}/users" method="POST" style="display:inline-block;">
                                  <input type="hidden" name="action" value="activate"/>
                                  <input type="hidden" name="id" value="${u.userId}"/>
                                  <button type="submit" class="btn btn-outline-success btn-sm rounded-0"
                                          title="Activate Account" data-bs-toggle="tooltip">
                                    <i class="bi bi-person-check-fill"></i>
                                  </button>
                                </form>
                              </c:otherwise>
                            </c:choose>
                            <button type="button" class="btn btn-outline-warning"
                                    title="Reset Password" data-bs-toggle="modal" data-bs-target="#resetModal"
                                    onclick="document.getElementById('resetUserId').value = '${u.userId}';">
                              <i class="bi bi-key-fill"></i>
                            </button>
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

<!-- Password Reset Modal -->
<div class="modal fade" id="resetModal" tabindex="-1" aria-labelledby="resetModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <form action="${pageContext.request.contextPath}/users" method="POST" class="needs-validation" novalidate>
      <input type="hidden" name="action" value="reset-password"/>
      <input type="hidden" name="id" id="resetUserId"/>
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="resetModalLabel">Reset Account Password</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label" for="newPassword">New Password <span class="text-danger">*</span></label>
            <input type="password" id="newPassword" name="newPassword" class="form-control" required minlength="8" placeholder="Enter new strong password"/>
            <div class="invalid-feedback">Password is required (min 8 chars).</div>
            <div class="form-text">Must be at least 8 characters and include uppercase, lowercase, and numeric characters.</div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Reset Password</button>
        </div>
      </div>
    </form>
  </div>
</div>
