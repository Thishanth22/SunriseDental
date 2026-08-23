<%-- notifications/notifications.jsp — Notifications panel --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Notifications"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Notification alerts</div>
        <div class="topbar-subtitle">Real-time alerts and system logs</div>
      </div>
      <div class="topbar-right">
      </div>
    </div>

    <div class="page-content">
      <div class="card">
        <div class="card-header">
          <i class="bi bi-bell-fill text-primary"></i>
          <h6>Recent Notifications</h6>
        </div>
        <div class="card-body">
          <div class="empty-state">
            <i class="bi bi-bell-slash"></i>
            <p>You have no new notifications.</p>
          </div>
        </div>
      </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
