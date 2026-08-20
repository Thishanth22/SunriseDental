<%-- audit/audit-list.jsp — Audit Log (ADMIN only) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Audit Log"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">System Audit Log Trail</div>
        <div class="topbar-subtitle">Monitor clinical operations &amp; login activities</div>
      </div>
      <div class="topbar-right">
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Audit Logs</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <div class="card">
        <div class="card-header justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-shield-lock-fill text-primary"></i>
            <h6>System Action History Trail</h6>
            <span class="badge bg-primary">${total}</span>
          </div>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty logs}">
              <div class="empty-state">
                <i class="bi bi-file-earmark-lock"></i>
                <p>No audit trail records found.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0" style="font-size:.8rem;">
                  <thead class="table-light">
                    <tr>
                      <th>Timestamp</th>
                      <th>Operator User</th>
                      <th>Action Code</th>
                      <th>Entity Type</th>
                      <th>Entity ID</th>
                      <th>Description Summary</th>
                      <th>IP Address</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="log" items="${logs}">
                      <tr>
                        <td>
                          <fmt:parseDate value="${log.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedCa" type="both"/>
                          <strong><fmt:formatDate value="${parsedCa}" pattern="dd MMM yyyy, HH:mm:ss"/></strong>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${not empty log.username}">
                              <strong><code>${log.username}</code></strong>
                            </c:when>
                            <c:otherwise><span class="text-muted">Unauthenticated</span></c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${log.action == 'LOGIN'}"><span class="badge bg-success">${log.action}</span></c:when>
                            <c:when test="${log.action == 'LOGIN_FAILED' || log.action == 'APPOINTMENT_CANCELLED'}"><span class="badge bg-danger">${log.action}</span></c:when>
                            <c:otherwise><span class="badge bg-secondary">${log.action}</span></c:otherwise>
                          </c:choose>
                        </td>
                        <td><code>${log.entityType}</code></td>
                        <td><code>${log.entityId > 0 ? log.entityId : '—'}</code></td>
                        <td><span class="text-dark fw-600">${log.description}</span></td>
                        <td><code style="font-size:.7rem;">${log.ipAddress}</code></td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>

              <!-- Pagination -->
              <c:if test="${totalPages > 1}">
                <div class="d-flex justify-content-between align-items-center p-3">
                  <div style="font-size:.8rem;color:var(--text-muted);">
                    Showing ${(page-1)*20 + 1} &ndash; ${[(page)*20 < total ? (page)*20 : total]} of ${total} logs
                  </div>
                  <nav>
                    <ul class="pagination pagination-sm mb-0">
                      <li class="page-item ${page == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page-1}">
                          <i class="bi bi-chevron-left"></i>
                        </a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="pg">
                        <li class="page-item ${pg == page ? 'active' : ''}">
                          <a class="page-link" href="?page=${pg}">${pg}</a>
                        </li>
                      </c:forEach>
                      <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page+1}">
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
