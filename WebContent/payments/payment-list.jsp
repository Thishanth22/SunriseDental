<%-- payments/payment-list.jsp — Payment Transaction Registry --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Payments"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Payment Transaction Registry</div>
        <div class="topbar-subtitle">Audit history of dental treatment payments</div>
      </div>
      <div class="topbar-right">
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Payments</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${not empty error}">
        <div class="alert alert-danger auto-dismiss mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <!-- Filters -->
      <div class="card mb-3">
        <div class="card-body py-3">
          <form method="GET" action="${pageContext.request.contextPath}/payments" class="row g-2 align-items-end">
            <div class="col-md-3">
              <label class="form-label" style="font-size:.7rem;" for="qInput">Search Transaction</label>
              <div class="search-wrapper">
                <i class="bi bi-search"></i>
                <input type="text" name="q" id="qInput" class="form-control" placeholder="Receipt #, Invoice #..." value="${param.q}"/>
              </div>
            </div>

            <div class="col-md-2">
              <label class="form-label" style="font-size:.7rem;" for="methodInput">Method</label>
              <select name="method" id="methodInput" class="form-select">
                <option value="">All Methods</option>
                <option value="CASH"           ${param.method == 'CASH'           ? 'selected' : ''}>Cash</option>
                <option value="CARD"           ${param.method == 'CARD'           ? 'selected' : ''}>Debit/Credit Card</option>
                <option value="BANK_TRANSFER"  ${param.method == 'BANK_TRANSFER'  ? 'selected' : ''}>Bank Transfer</option>
                <option value="ONLINE"         ${param.method == 'ONLINE'         ? 'selected' : ''}>Online Portal</option>
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
              <a href="${pageContext.request.contextPath}/payments" class="btn btn-outline-secondary w-100"><i class="bi bi-arrow-counterclockwise"></i></a>
            </div>
          </form>
        </div>
      </div>

      <!-- Payment list -->
      <div class="card">
        <div class="card-header justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-cash-coin text-primary"></i>
            <h6>Payments Registry</h6>
            <span class="badge bg-primary">${total}</span>
          </div>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty payments}">
              <div class="empty-state">
                <i class="bi bi-cash-stack"></i>
                <p>No payments recorded yet.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead>
                    <tr>
                      <th>Receipt #</th>
                      <th>Payment Date</th>
                      <th>Patient</th>
                      <th>Invoice #</th>
                      <th>Amount Paid</th>
                      <th>Payment Method</th>
                      <th>Transaction Ref</th>
                      <th class="text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="pay" items="${payments}">
                      <tr>
                        <td><strong><code style="font-size:.85rem;">${pay.paymentNumber}</code></strong></td>
                        <td>
                          <fmt:parseDate value="${pay.paymentDate}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedPd" type="both"/>
                          <fmt:formatDate value="${parsedPd}" pattern="dd MMM yyyy, HH:mm"/>
                        </td>
                        <td>
                          <div class="fw-600">${pay.patientName}</div>
                        </td>
                        <td><code style="font-size:.8rem;">${pay.billNumber}</code></td>
                        <td><strong class="text-success">LKR <fmt:formatNumber value="${pay.amount}" type="number" minFractionDigits="2"/></strong></td>
                        <td>
                          <span class="badge bg-secondary">${pay.paymentMethod}</span>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${not empty pay.transactionRef}">
                              <span class="font-monospace text-muted" style="font-size:.8rem;">${pay.transactionRef}</span>
                            </c:when>
                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                          </c:choose>
                        </td>
                        <td class="text-center">
                          <a href="${pageContext.request.contextPath}/payments?action=view&id=${pay.paymentId}"
                             class="btn btn-sm btn-outline-primary" title="Receipt Details" data-bs-toggle="tooltip">
                            <i class="bi bi-eye-fill"></i>
                          </a>
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
                    Showing ${(page-1)*pageSize + 1} &ndash; ${[(page)*pageSize < total ? (page)*pageSize : total]} of ${total} transactions
                  </div>
                  <nav>
                    <ul class="pagination pagination-sm mb-0">
                      <li class="page-item ${page == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page-1}&q=${param.q}&method=${param.method}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}">
                          <i class="bi bi-chevron-left"></i>
                        </a>
                      </li>
                      <c:forEach begin="1" end="${totalPages}" var="pg">
                        <li class="page-item ${pg == page ? 'active' : ''}">
                          <a class="page-link" href="?page=${pg}&q=${param.q}&method=${param.method}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}">${pg}</a>
                        </li>
                      </c:forEach>
                      <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${page+1}&q=${param.q}&method=${param.method}&dateFrom=${param.dateFrom}&dateTo=${param.dateTo}">
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
