<%-- payments/payment-form.jsp — Record Payment --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Record Payment"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Record Payment Transaction</div>
        <div class="topbar-subtitle">Process payments against clinic invoices</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/billing?action=view&id=${bill.billId}" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back to Invoice
        </a>
      </div>
    </div>

    <div class="page-content">

      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <div class="row g-3">
        <div class="col-lg-8">
          <div class="card mb-3">
            <div class="card-header">
              <i class="bi bi-credit-card-fill text-primary"></i>
              <h6>Payment details</h6>
            </div>
            <div class="card-body">
              <form action="${pageContext.request.contextPath}/payments"
                    method="POST"
                    class="needs-validation form-with-loading"
                    novalidate>
                
                <input type="hidden" name="action" value="pay"/>
                <input type="hidden" name="billId" value="${bill.billId}"/>

                <div class="row g-3">
                  <!-- Payment Amount -->
                  <div class="col-md-6">
                    <label class="form-label" for="amount">Payment Amount (LKR) <span class="text-danger">*</span></label>
                    <input type="number" id="amount" name="amount" class="form-control"
                           min="0.01" max="${bill.balanceDue}" step="0.01"
                           value="${bill.balanceDue}" required/>
                    <div class="invalid-feedback">Please enter a valid payment amount not exceeding LKR <fmt:formatNumber value="${bill.balanceDue}" type="number"/>.</div>
                    <div class="form-text">Cannot exceed the balance due of LKR <fmt:formatNumber value="${bill.balanceDue}" type="number"/>.</div>
                  </div>

                  <!-- Payment Method -->
                  <div class="col-md-6">
                    <label class="form-label" for="paymentMethod">Payment Method <span class="text-danger">*</span></label>
                    <select id="paymentMethod" name="paymentMethod" class="form-select" required>
                      <option value="">-- Select Method --</option>
                      <option value="CASH">Cash</option>
                      <option value="CARD">Debit/Credit Card</option>
                      <option value="BANK_TRANSFER">Bank Transfer</option>
                      <option value="ONLINE">Online Portal</option>
                      <option value="CHEQUE">Cheque</option>
                    </select>
                    <div class="invalid-feedback">Please select a payment method.</div>
                  </div>

                  <!-- Transaction reference (required for non-cash) -->
                  <div class="col-md-6" id="txRefGroup">
                    <label class="form-label" for="transactionRef">Transaction / Approval Ref. <span class="text-danger" id="txRefRequiredIndicator">*</span></label>
                    <input type="text" id="transactionRef" name="transactionRef" class="form-control" maxlength="100" placeholder="e.g. TxN1000293992"/>
                    <div class="invalid-feedback" id="txFeedback">Reference is required for selected payment method.</div>
                    <div class="form-text">Card authorization codes, bank transfer reference ID.</div>
                  </div>

                  <!-- Notes -->
                  <div class="col-md-6">
                    <label class="form-label" for="notes">Comments &amp; Remarks</label>
                    <input type="text" id="notes" name="notes" class="form-control" maxlength="250" placeholder="e.g. Paid in full by patient spouse"/>
                  </div>
                </div>

                <div class="d-flex gap-2 justify-content-end mt-4">
                  <a href="${pageContext.request.contextPath}/billing?action=view&id=${bill.billId}" class="btn btn-outline-secondary">
                    <i class="bi bi-x-circle"></i> Cancel
                  </a>
                  <button type="submit" class="btn btn-success">
                    <i class="bi bi-check-circle-fill"></i> Process Payment
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- Bill quick summary card -->
        <div class="col-lg-4">
          <div class="card mb-3">
            <div class="card-header bg-light">
              <i class="bi bi-file-earmark-text-fill text-primary"></i>
              <h6>Invoice Summary</h6>
            </div>
            <div class="card-body" style="font-size:.85rem;">
              <div class="mb-2"><strong>Invoice #:</strong> ${bill.billNumber}</div>
              <div class="mb-2"><strong>Patient Name:</strong> ${bill.patientName}</div>
              <div class="mb-2"><strong>Appointment #:</strong> ${bill.appointmentNumber}</div>
              <hr class="my-2"/>
              <div class="mb-2"><strong>Grand Total:</strong> LKR <fmt:formatNumber value="${bill.grandTotal}" type="number" minFractionDigits="2"/></div>
              <div class="mb-2 text-success"><strong>Amount Paid:</strong> LKR <fmt:formatNumber value="${bill.amountPaid}" type="number" minFractionDigits="2"/></div>
              <div class="mb-0 text-danger fs-6 fw-700"><strong>Balance Due:</strong> LKR <fmt:formatNumber value="${bill.balanceDue}" type="number" minFractionDigits="2"/></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>

<script>
  // Simple validation dynamic adjustments
  document.addEventListener('DOMContentLoaded', function () {
    const methodSelect   = document.getElementById('paymentMethod');
    const txRefGroup     = document.getElementById('txRefGroup');
    const txRefInput     = document.getElementById('transactionRef');
    const refIndicator   = document.getElementById('txRefRequiredIndicator');

    function toggleTxRef() {
      const val = methodSelect.value;
      if (val === 'CASH' || val === '') {
        txRefInput.required = false;
        refIndicator.style.display = 'none';
      } else {
        txRefInput.required = true;
        refIndicator.style.display = 'inline';
      }
    }

    if (methodSelect) {
      methodSelect.addEventListener('change', toggleTxRef);
      toggleTxRef(); // Initial call
    }
  });
</script>
