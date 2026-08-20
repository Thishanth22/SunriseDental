<%-- reports/report-daily-revenue.jsp — Daily Revenue Report --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Daily Revenue Report"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar no-print">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Daily Revenue Ledger</div>
        <div class="topbar-subtitle">Invoiced transactions on <fmt:formatDate value="${reportDateSql}" pattern="dd MMM yyyy"/></div>
      </div>
      <div class="topbar-right">
        <button onclick="window.print();" class="btn btn-primary btn-sm">
          <i class="bi bi-printer me-1"></i> Print Report
        </button>
        <a href="${pageContext.request.contextPath}/reports" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i> Back
        </a>
      </div>
    </div>

    <div class="page-content">
      
      <!-- Printable Header -->
      <div class="d-none d-print-block text-center mb-4">
        <h2>SUNRISE DENTAL CLINIC</h2>
        <h4>Daily Revenue Report</h4>
        <p class="text-muted">Ledger Date: <fmt:formatDate value="${reportDateSql}" pattern="dd MMMM yyyy"/></p>
        <hr/>
      </div>

      <!-- KPI Summary -->
      <div class="row g-3 mb-4">
        <div class="col-md-6 mx-auto text-center">
          <div class="p-3 bg-success-subtle text-success rounded">
            <h5 class="fw-700 mb-1">Today's Collected Revenue</h5>
            <h2 class="fw-800">LKR <fmt:formatNumber value="${todayRevenue}" type="number" minFractionDigits="2"/></h2>
          </div>
        </div>
      </div>

      <!-- Invoice Ledger List -->
      <div class="card">
        <div class="card-header no-print">
          <h6>Invoiced Billing Entries</h6>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty bills}">
              <div class="empty-state">
                <i class="bi bi-receipt"></i>
                <p>No billing invoices generated today.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-bordered mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>Invoice #</th>
                      <th>Patient</th>
                      <th>Sub Total</th>
                      <th>Discount</th>
                      <th>Tax</th>
                      <th>Grand Total</th>
                      <th>Amount Paid</th>
                      <th>Balance Due</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="b" items="${bills}">
                      <tr>
                        <td><code>${b.billNumber}</code></td>
                        <td>${b.patientName} (${b.patientNumber})</td>
                        <td>LKR <fmt:formatNumber value="${b.subTotal}" type="number"/></td>
                        <td>LKR <fmt:formatNumber value="${b.discountAmount}" type="number"/></td>
                        <td>LKR <fmt:formatNumber value="${b.taxAmount}" type="number"/></td>
                        <td><strong>LKR <fmt:formatNumber value="${b.grandTotal}" type="number"/></strong></td>
                        <td class="text-success">LKR <fmt:formatNumber value="${b.amountPaid}" type="number"/></td>
                        <td class="${b.balanceDue > 0 ? 'text-danger fw-600' : 'text-muted'}">
                          LKR <fmt:formatNumber value="${b.balanceDue}" type="number"/>
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
