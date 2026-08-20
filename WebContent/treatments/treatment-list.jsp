<%-- treatments/treatment-list.jsp — Treatment Catalog --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Treatments"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Treatment Service Catalog</div>
        <div class="topbar-subtitle">Manage dental treatments &amp; pricing index</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/treatments?action=new" class="btn btn-primary btn-sm">
          <i class="bi bi-plus-circle-fill"></i> Add Treatment
        </a>
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Treatments</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>
      <c:if test="${param.msg == 'saved'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Treatment service added.</div>
      </c:if>
      <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Treatment catalog entry updated.</div>
      </c:if>
      <c:if test="${param.msg == 'discontinued'}">
        <div class="alert alert-warning auto-dismiss mb-3"><i class="bi bi-slash-circle-fill me-2"></i>Treatment marked as Discontinued.</div>
      </c:if>

      <div class="card">
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty treatments}">
              <div class="empty-state">
                <i class="bi bi-capsule-pill"></i>
                <p>No treatments registered in the catalog.</p>
                <a href="${pageContext.request.contextPath}/treatments?action=new" class="btn btn-primary btn-sm mt-2">
                  <i class="bi bi-plus-circle-fill me-1"></i>Add First Treatment
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Code</th>
                      <th>Treatment Name</th>
                      <th>Category</th>
                      <th>Base Cost</th>
                      <th>Est. Duration</th>
                      <th>Follow-Up</th>
                      <th>Status</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="t" items="${treatments}">
                      <tr>
                        <td><strong><code style="font-size:.85rem;">${t.treatmentCode}</code></strong></td>
                        <td>
                          <div class="fw-600 text-dark">${t.treatmentName}</div>
                          <div class="text-muted" style="font-size:.75rem;">${t.description}</div>
                        </td>
                        <td><span class="badge bg-secondary">${t.category}</span></td>
                        <td><strong>LKR <fmt:formatNumber value="${t.baseCost}" type="number" minFractionDigits="2"/></strong></td>
                        <td><span class="badge bg-light text-dark">${t.durationMins} mins</span></td>
                        <td>
                          <c:choose>
                            <c:when test="${t.requiresFollowup}">
                              <span class="badge bg-warning">Requires Follow-up</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-light text-muted">Single Session</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${t.status == 'ACTIVE'}">
                              <span class="badge bg-success">Active</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-secondary">Discontinued</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <div class="btn-group btn-group-sm">
                            <a href="${pageContext.request.contextPath}/treatments?action=edit&id=${t.treatmentId}"
                               class="btn btn-outline-secondary" title="Edit Catalog Entry" data-bs-toggle="tooltip">
                              <i class="bi bi-pencil-fill"></i>
                            </a>
                            <c:if test="${t.status == 'ACTIVE'}">
                              <form action="${pageContext.request.contextPath}/treatments" method="POST" style="display:inline-block;">
                                <input type="hidden" name="action" value="discontinue"/>
                                <input type="hidden" name="id" value="${t.treatmentId}"/>
                                <button type="submit" class="btn btn-outline-danger btn-sm rounded-0 rounded-end"
                                        title="Discontinue Treatment" data-bs-toggle="tooltip" data-confirm="Discontinue treatment code ${t.treatmentCode}?">
                                  <i class="bi bi-slash-circle"></i>
                                </button>
                              </form>
                            </c:if>
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
