<%-- reports/report-outstanding.jsp — Outstanding Invoices --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Outstanding Payments Report"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar no-print">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Outstanding Payments Report</div>
        <div class="topbar-subtitle">Invoices with outstanding balances</div>
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
        <h4>Outstanding Payments Report</h4>
        <p class="text-muted">As of: <%= java.time.LocalDate.now().toString() %></p>
        <hr/>
      </div>

      <!-- Outstanding Invoices Table -->
      <div class="card">
        <div class="card-header no-print">
          <h6>Outstanding Invoices Registry</h6>
        </div>
        <div class="card-body p-0">
          <c:choose>
            <c:when test="${empty bills}">
              <div class="empty-state">
                <i class="bi bi-shield-check text-success"></i>
                <p>Great! There are no outstanding payments currently.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-responsive">
                <table class="table table-bordered mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>Invoice #</th>
                      <th>Issued Date</th>
                      <th>Patient</th>
                      <th>Phone</th>
                      <th>Grand Total</th>
                      <th>Amount Paid</th>
                      <th>Balance Due</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="b" items="${bills}">
                      <tr>
                        <td><code>${b.billNumber}</code></td>
                        <td><fmt:formatDate value="${b.issuedDateSql}" pattern="dd MMM yyyy"/></td>
                        <td>${b.patientName} (${b.patientNumber})</td>
                        <td>${b.contactNumber}</td>
                        <td>LKR <fmt:formatNumber value="${b.grandTotal}" type="number"/></td>
                        <td class="text-success">LKR <fmt:formatNumber value="${b.amountPaid}" type="number"/></td>
                        <td class="text-danger fw-600">LKR <fmt:formatNumber value="${b.balanceDue}" type="number"/></td>
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
