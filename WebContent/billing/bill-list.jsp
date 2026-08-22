<%-- billing/bill-list.jsp — Bill List --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Billing"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Invoice &amp; Billing Management</div>
        <div class="topbar-subtitle">Manage dental treatment billing operations</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/billing?action=new" class="btn btn-primary btn-sm">
          <i class="bi bi-file-earmark-plus-fill me-1"></i> Generate New Invoice
        </a>
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Billing</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>
      <c:if test="${param.msg == 'cancelled'}">
        <div class="alert alert-warning auto-dismiss mb-3"><i class="bi bi-file-earmark-x-fill me-2"></i>Invoice marked as Cancelled.</div>
      </c:if>

      <!-- Search & Filters -->
      <div class="card mb-3">
        <div class="card-body py-3">
          <form method="GET" action="${pageContext.request.contextPath}/billing" class="row g-2 align-items-end">
            <div class="col-md-3">
              <label class="form-label" style="font-size:.7rem;" for="qInput">Search Invoice</label>
              <div class="search-wrapper">
                <i class="bi bi-search"></i>
                <input type="text" name="q" id="qInput" class="form-control" placeholder="Invoice # or patient..." value="${param.q}"/>
              </div>
            </div>
            
            <div class="col-md-2">
              <label class="form-label" style="font-size:.7rem;" for="statusInput">Bill Status</label>
              <select name="status" id="statusInput" class="form-select">
                <option value="">All Statuses</option>
                <option value="ISSUED"          ${param.status == 'ISSUED'          ? 'selected' : ''}>Issued</option>
                <option value="PARTIALLY_PAID"  ${param.status == 'PARTIALLY_PAID'  ? 'selected' : ''}>Partially Paid</option>
                <option value="PAID"            ${param.status == 'PAID'            ? 'selected' : ''}>Paid</option>
                <option value="OVERDUE"         ${param.status == 'OVERDUE'         ? 'selected' : ''}>Overdue</option>
                <option value="CANCELLED"       ${param.status == 'CANCELLED'       ? 'selected' : ''}>Cancelled</option>
              </select>
            </div>

            <div class="col-md-2">
              <label class="form-label" style="font-size:.7rem;" for="dateFromInput">From Date</label>
              <input type="date" name="dateFrom" id="dateFromInput" class="form-control" value="${param.dateFrom}"/>
            </div>
            <div class="col-md-2">
              <label class="form-label" style="font-size:.7rem;" for="dateToInput">To Date</label>
              <input type="date" name="dateTo" id="dateToInput" class="form-control" value="${param.dateTo}"/>
            </div>

            <div class="col-md-2">
              <button type="submit" class="btn btn-primary w-100"><i class="bi bi-funnel me-1"></i>Filter</button>
            </div>
            <div class="col-md-1">
              <a href="${pageContext.request.contextPath}/billing" class="btn btn-outline-secondary w-100" title="Reset Filters"><i class="bi bi-arrow-counterclockwise"></i></a>
            </div>
          </form>
        </div>
      </div>

      <!-- Invoices Checklist -->
      <div class="card">
        <div class="card-header justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-receipt-cutoff text-primary"></i>
            <h6>Invoices Registry</h6>
            <span class="badge bg-primary">${total}</span>
          </div>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty bills}">
              <div class="empty-state">
                <i class="bi bi-file-earmark-x"></i>
                <p>No invoices found matching criteria.</p>
                <a href="${pageContext.request.contextPath}/billing?action=new" class="btn btn-primary btn-sm mt-2">
                  <i class="bi bi-file-earmark-plus me-1"></i>Generate First Invoice
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Invoice #</th>
                      <th>Issued Date</th>
                      <th>Patient</th>
                      <th>Appointment #</th>
                      <th>Grand Total</th>
                      <th>Amount Paid</th>
                      <th>Balance Due</th>
                      <th>Status</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="bill" items="${bills}">
                      <tr>
                        <td><strong><code style="font-size:.85rem;">${bill.billNumber}</code></strong></td>
                        <td>
                          <fmt:formatDate value="${bill.issuedDateSql}" pattern="dd MMM yyyy"/>
                        </td>
                        <td>
                          <div class="fw-600">${bill.patientName}</div>
                          <div style="font-size:.75rem;color:var(--text-muted);">${bill.patientNumber}</div>
                        </td>
                        <td><code style="font-size:.8rem;">${bill.appointmentNumber}</code></td>
                        <td><strong>LKR <fmt:formatNumber value="${bill.grandTotal}" type="number" minFractionDigits="2"/></strong></td>
                        <td class="text-success">LKR <fmt:formatNumber value="${bill.amountPaid}" type="number" minFractionDigits="2"/></td>
                        <td class="${bill.balanceDue > 0 ? 'text-danger fw-600' : 'text-muted'}">
                          LKR <fmt:formatNumber value="${bill.balanceDue}" type="number" minFractionDigits="2"/>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${bill.billStatus == 'PAID'}">
                              <span class="badge bg-success">Paid</span>
                            </c:when>
                            <c:when test="${bill.billStatus == 'PARTIALLY_PAID'}">
                              <span class="badge bg-warning">Partially Paid</span>
                            </c:when>
                            <c:when test="${bill.billStatus == 'CANCELLED'}">
                              <span class="badge bg-secondary">Cancelled</span>
                            </c:when>
                            <c:when test="${bill.billStatus == 'OVERDUE'}">
                              <span class="badge bg-danger">Overdue</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge bg-primary">Issued</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <div class="btn-group btn-group-sm">
                            <a href="${pageContext.request.contextPath}/billing?action=view&id=${bill.billId}"
                               class="btn btn-outline-primary" title="Details" data-bs-toggle="tooltip">
                              <i class="bi bi-eye-fill"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/billing?action=receipt&id=${bill.billId}"
                               class="btn btn-outline-secondary" title="Print Invoice" target="_blank" data-bs-toggle="tooltip">
                              <i class="bi bi-printer-fill"></i>
                            </a>
                            <c:if test="${bill.balanceDue > 0 && bill.billStatus != 'CANCELLED'}">
                              <a href="${pageContext.request.contextPath}/payments?action=new&billId=${bill.billId}"
                                 class="btn btn-outline-success" title="Record Payment" data-bs-toggle="tooltip">
                                <i class="bi bi-cash-coin"></i>
                              </a>
                            </c:if>
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
                    Showing ${(page-1)*pageSize + 1} &ndash; ${[(page)*pageSize < total ? (page)*pageSize : total]} of ${total} invoices
                  </div>
                  <nav>
                    <ul class="pagination pagination-sm mb-0">
                      <li class="page-item ${page == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page-1}&q=${param.q}&status=${param.status}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}">
                          <i class="bi bi-chevron-left"></i>
                        </a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="pg">
                        <li class="page-item ${pg == page ? 'active' : ''}">
                          <a class="page-link" href="?page=${pg}&q=${param.q}&status=${param.status}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}">${pg}</a>
                        </li>
                      </c:forEach>
                      <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page+1}&q=${param.q}&status=${param.status}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}">
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
