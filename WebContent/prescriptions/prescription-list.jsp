<%-- prescriptions/prescription-list.jsp — List Prescriptions --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="E-Prescriptions Ledger"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">E-Prescriptions Index</div>
        <div class="topbar-subtitle">Browse and print patient prescription records</div>
      </div>
    </div>

    <div class="page-content">

      <!-- Action Toolbar -->
      <div class="card mb-3 p-3">
        <form method="GET" action="${pageContext.request.contextPath}/prescriptions" class="row g-2 align-items-center">
          <input type="hidden" name="action" value="list"/>
          <div class="col-md-6">
            <div class="input-group">
              <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
              <input type="text" name="q" class="form-control" placeholder="Search by Rx Number or Patient Name..." value="${param.q}"/>
              <c:if test="${not empty param.q}">
                <a href="${pageContext.request.contextPath}/prescriptions?action=list" class="btn btn-outline-secondary"><i class="bi bi-x"></i></a>
              </c:if>
              <button class="btn btn-primary" type="submit">Search</button>
            </div>
          </div>
        </form>
      </div>

      <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <!-- Prescriptions Table Card -->
      <div class="card">
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty prescriptions}">
              <div class="empty-state">
                <i class="bi bi-capsule"></i>
                <p>No e-prescription records found.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Prescription #</th>
                      <th>Date Written</th>
                      <th>Patient</th>
                      <th>Prescribed By</th>
                      <th>Notes / Remarks</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="rx" items="${prescriptions}">
                      <tr>
                        <td><code style="font-size:.85rem;font-weight:700;">${rx.prescriptionNumber}</code></td>
                        <td>
                          <strong>
                            <fmt:formatDate value="${rx.createdAtSql}" pattern="dd MMM yyyy"/>
                          </strong>
                          <div class="text-muted" style="font-size:.7rem;">
                            <fmt:formatDate value="${rx.createdAtSql}" pattern="HH:mm a"/>
                          </div>
                        </td>
                        <td>
                          <div class="fw-600">${rx.patientName}</div>
                          <div class="text-muted" style="font-size:.75rem;">${rx.patientNumber}</div>
                        </td>
                        <td>${rx.dentistName}</td>
                        <td style="font-size:.8rem;max-width:250px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                          ${empty rx.notes ? '—' : rx.notes}
                        </td>
                        <td class="text-center">
                          <a href="${pageContext.request.contextPath}/prescriptions?action=view&id=${rx.prescriptionId}"
                             class="btn btn-sm btn-outline-primary"
                             data-bs-toggle="tooltip" title="View &amp; Print Slip">
                            <i class="bi bi-printer-fill me-1"></i> Print Rx
                          </a>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>

              <!-- Pagination Footer -->
              <c:if test="${totalPages > 1}">
                <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3 border-top">
                  <div class="text-muted small">Showing Page ${page} of ${totalPages} (Total: ${total})</div>
                  <nav>
                    <ul class="pagination pagination-sm mb-0">
                      <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/prescriptions?action=list&page=${page - 1}&q=${param.q}"><i class="bi bi-chevron-left"></i></a>
                      </li>
                      <c:forEach var="i" begin="1" end="${totalPages}">
                        <li class="page-item ${page == i ? 'active' : ''}">
                          <a class="page-link" href="${pageContext.request.contextPath}/prescriptions?action=list&page=${i}&q=${param.q}">${i}</a>
                        </li>
                      </c:forEach>
                      <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/prescriptions?action=list&page=${page + 1}&q=${param.q}"><i class="bi bi-chevron-right"></i></a>
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
