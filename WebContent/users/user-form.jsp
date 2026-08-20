<%-- users/user-form.jsp — Add / Edit User --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty editUser && editUser.userId > 0}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit User' : 'Create User'}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">${isEdit ? 'Edit User Account' : 'Create Staff User Account'}</div>
        <div class="topbar-subtitle">Configure staff system details &amp; roles</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/users" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back
        </a>
      </div>
    </div>

    <div class="page-content">
      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/users"
            method="POST"
            class="needs-validation form-with-loading"
            novalidate>
        
        <input type="hidden" name="action" value="${isEdit ? 'update' : 'save'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="userId" value="${editUser.userId}"/>
        </c:if>

        <div class="row g-3">
          <div class="col-lg-8">
            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-person-fill text-primary"></i>
                <h6>Profile Details</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label class="form-label" for="fullName">Full Name <span class="text-danger">*</span></label>
                    <input type="text" id="fullName" name="fullName" class="form-control" value="${isEdit ? editUser.fullName : ''}" required maxlength="100"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="email">Email Address <span class="text-danger">*</span></label>
                    <input type="email" id="email" name="email" class="form-control" value="${isEdit ? editUser.email : ''}" required maxlength="150"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="phone">Phone Number <span class="text-danger">*</span></label>
                    <input type="tel" id="phone" name="phone" class="form-control" value="${isEdit ? editUser.phone : ''}" required maxlength="15" data-phone/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="roleId">Access Role <span class="text-danger">*</span></label>
                    <select id="roleId" name="roleId" class="form-select" required>
                      <option value="">-- Select Role --</option>
                      <option value="1" ${(isEdit ? editUser.roleId : 0) == 1 ? 'selected' : ''}>Administrator</option>
                      <option value="2" ${(isEdit ? editUser.roleId : 0) == 2 ? 'selected' : ''}>Dentist</option>
                      <option value="3" ${(isEdit ? editUser.roleId : 0) == 3 ? 'selected' : ''}>Receptionist</option>
                    </select>
                  </div>

                  <c:if test="${not isEdit}">
                    <hr class="my-2"/>
                    <div class="col-md-6">
                      <label class="form-label" for="username">Username <span class="text-danger">*</span></label>
                      <input type="text" id="username" name="username" class="form-control" required minlength="4" maxlength="50" placeholder="e.g. janesmith"/>
                      <div class="form-text">Unique system login username (lowercase, no spaces).</div>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label" for="password">Password <span class="text-danger">*</span></label>
                      <input type="password" id="password" name="password" class="form-control" required minlength="8" placeholder="Enter initial password"/>
                      <div class="form-text">Must contain at least 8 characters (uppercase, lowercase, numbers).</div>
                    </div>
                  </c:if>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="d-flex gap-2 justify-content-end mt-2">
          <a href="${pageContext.request.contextPath}/users" class="btn btn-outline-secondary">Cancel</a>
          <button type="submit" class="btn btn-primary">${isEdit ? 'Update Details' : 'Create User'}</button>
        </div>

      </form>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
