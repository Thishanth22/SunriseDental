<%-- payments/payment-view.jsp — Payment View --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Payment receipt ${payment.paymentNumber}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Payment Transaction Receipt</div>
        <div class="topbar-subtitle">Transaction Number: ${payment.paymentNumber}</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/billing?action=receipt&id=${payment.billId}" class="btn btn-outline-primary btn-sm" target="_blank">
          <i class="bi bi-printer-fill me-1"></i> Print Invoice
        </a>
        <a href="${pageContext.request.contextPath}/payments" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i> Back to Payments
        </a>
      </div>
    </div>

    <div class="page-content">

      <!-- Message notifications -->
      <c:if test="${param.msg == 'paid'}">
        <div class="alert alert-success auto-dismiss mb-3">
          <i class="bi bi-check-circle-fill me-2"></i>Payment processed and recorded successfully.
        </div>
      </c:if>

      <div class="row justify-content-center">
        <div class="col-lg-6">
          <div class="card">
            <div class="card-body">
              
              <!-- Invoice Header details -->
              <div class="text-center mb-4">
                <h5 class="fw-800 text-primary-custom mb-1">SUNRISE DENTAL CLINIC</h5>
                <div class="text-muted" style="font-size:.8rem;">
                  123 Medical Center Road, Colombo 07, Sri Lanka
                </div>
                <hr class="my-3"/>
                <h5 class="fw-800 mb-1" style="letter-spacing:1px;">PAYMENT RECEIPT</h5>
                <span class="fs-6 font-monospace text-muted fw-700">${payment.paymentNumber}</span>
              </div>

              <!-- Transaction sheet -->
              <div class="border rounded p-3 mb-4 bg-light" style="font-size:.9rem;">
                <div class="row g-2">
                  <div class="col-5 text-secondary">Date &amp; Time:</div>
                  <div class="col-7 text-dark fw-600">
                    <fmt:parseDate value="${payment.paymentDate}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedPd" type="both"/>
                    <fmt:formatDate value="${parsedPd}" pattern="dd MMM yyyy, HH:mm"/>
                  </div>

                  <div class="col-5 text-secondary">Patient Name:</div>
                  <div class="col-7 text-dark fw-700">${payment.patientName}</div>

                  <div class="col-5 text-secondary">Invoice Reference:</div>
                  <div class="col-7 text-dark fw-600">
                    <a href="${pageContext.request.contextPath}/billing?action=view&id=${payment.billId}" class="text-decoration-none font-monospace">
                      ${payment.billNumber}
                    </a>
                  </div>

                  <div class="col-5 text-secondary">Payment Method:</div>
                  <div class="col-7 text-dark fw-700">${payment.paymentMethod}</div>

                  <c:if test="${not empty payment.transactionRef}">
                    <div class="col-5 text-secondary">Approval / Ref ID:</div>
                    <div class="col-7 text-dark font-monospace fw-700">${payment.transactionRef}</div>
                  </c:if>

                  <c:if test="${not empty payment.notes}">
                    <div class="col-5 text-secondary">Remarks:</div>
                    <div class="col-7 text-dark">${payment.notes}</div>
                  </c:if>
                </div>
              </div>

              <!-- Big total alert block -->
              <div class="p-3 bg-success-subtle text-success rounded text-center mb-4">
                <div style="font-size:.85rem;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;">Amount Paid</div>
                <div class="fw-800 fs-2 mt-1">LKR <fmt:formatNumber value="${payment.amount}" type="number" minFractionDigits="2"/></div>
              </div>

              <!-- Cashier metadata -->
              <div class="text-center text-muted" style="font-size:.75rem;">
                Processed By: ${not empty payment.receivedByName ? payment.receivedByName : 'System Agent'}
              </div>

            </div>
            <div class="card-footer no-print text-center">
              <button onclick="window.print();" class="btn btn-primary btn-sm">
                <i class="bi bi-printer me-1"></i> Print Receipt
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
