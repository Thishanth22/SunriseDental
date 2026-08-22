<%-- billing/bill-view.jsp — Invoice Details --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Invoice ${bill.billNumber}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Invoice details</div>
        <div class="topbar-subtitle">Invoice: ${bill.billNumber}</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/billing?action=receipt&id=${bill.billId}" class="btn btn-outline-primary btn-sm" target="_blank">
          <i class="bi bi-printer-fill me-1"></i> Print Invoice
        </a>
        <a href="${pageContext.request.contextPath}/billing" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i> Back to Invoices
        </a>
      </div>
    </div>

    <div class="page-content">
      <!-- Message notifications -->
      <c:if test="${param.msg == 'generated'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-check-circle-fill me-2"></i>Invoice generated successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'paid'}">
        <div class="alert alert-success auto-dismiss mb-3"><i class="bi bi-cash-coin me-2"></i>Payment processed. Invoice balance updated.</div>
      </c:if>

      <div class="row g-3">
        <!-- Main details card -->
        <div class="col-lg-8">
          <div class="card mb-3">
            <div class="card-body">
              <!-- Invoice Header -->
              <div class="d-flex justify-content-between mb-4 flex-wrap gap-2">
                <div>
                  <h4 class="fw-800 text-primary-custom mb-1">SUNRISE DENTAL CLINIC</h4>
                  <p class="text-muted mb-0" style="font-size:.8rem;line-height:1.4;">
                    123 Medical Center Road, Colombo 07, Sri Lanka<br/>
                    Tel: +94 11 234 5678 | Email: info@sunrisedental.lk
                  </p>
                </div>
                <div class="text-lg-end">
                  <h5 class="fw-800 mb-1">INVOICE</h5>
                  <span class="fs-6 font-monospace fw-700">${bill.billNumber}</span>
                  <div class="mt-2">
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
                  </div>
                </div>
              </div>

              <!-- Bill details -->
              <div class="row g-3 mb-4" style="font-size:.85rem;">
                <div class="col-md-6 border-end">
                  <div class="text-secondary fw-700 mb-1" style="text-transform:uppercase;font-size:.75rem;">Bill To:</div>
                  <div class="fw-700 text-dark fs-6">${bill.patientName}</div>
                  <div class="text-muted small mb-1">Patient Number: <code>${bill.patientNumber}</code></div>
                  <c:if test="${not empty bill.patientPhone}">
                    <div class="small text-muted"><i class="bi bi-telephone-fill text-primary me-1"></i>${bill.patientPhone}</div>
                  </c:if>
                  <c:if test="${not empty bill.patientAddress}">
                    <div class="small text-muted"><i class="bi bi-geo-alt-fill text-danger me-1"></i>${bill.patientAddress}</div>
                  </c:if>
                </div>
                <div class="col-md-6 px-md-4">
                  <div class="text-secondary fw-700 mb-1" style="text-transform:uppercase;font-size:.75rem;">Invoice Metadata:</div>
                  <div><strong>Issued Date:</strong> <fmt:formatDate value="${bill.issuedDateSql}" pattern="dd MMM yyyy"/></div>
                  <div><strong>Due Date:</strong> <fmt:formatDate value="${bill.dueDateSql}" pattern="dd MMM yyyy"/></div>
                  <div><strong>Appointment #:</strong> <code style="font-size:.75rem;">${bill.appointmentNumber}</code></div>
                  <div><strong>Dentist:</strong> ${bill.dentistName}</div>
                  <div><strong>Treatment:</strong> ${bill.treatmentName}</div>
                </div>
              </div>

              <!-- Bill Items Table -->
              <div class="table-responsive mb-4">
                <table class="table table-bordered mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>#</th>
                      <th>Item Description</th>
                      <th>Category</th>
                      <th class="text-end">Unit Price</th>
                      <th class="text-center">Qty</th>
                      <th class="text-end">Total Price</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="item" items="${items}" varStatus="s">
                      <tr>
                        <td>${s.index + 1}</td>
                        <td>${item.description}</td>
                        <td><span class="badge bg-secondary">${item.itemType}</span></td>
                        <td class="text-end">LKR <fmt:formatNumber value="${item.unitPrice}" type="number" minFractionDigits="2"/></td>
                        <td class="text-center">${item.quantity}</td>
                        <td class="text-end">LKR <fmt:formatNumber value="${item.totalPrice}" type="number" minFractionDigits="2"/></td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>

              <!-- Calculations Sheet -->
              <div class="row justify-content-end" style="font-size:.9rem;">
                <div class="col-md-5">
                  <div class="d-flex justify-content-between mb-2">
                    <span class="text-secondary">Sub Total:</span>
                    <span class="fw-700">LKR <fmt:formatNumber value="${bill.subTotal}" type="number" minFractionDigits="2"/></span>
                  </div>
                  <c:if test="${bill.discountAmount > 0}">
                    <div class="d-flex justify-content-between mb-2 text-danger">
                      <span>Discount (${bill.discountPercent}%):</span>
                      <span>- LKR <fmt:formatNumber value="${bill.discountAmount}" type="number" minFractionDigits="2"/></span>
                    </div>
                  </c:if>
                  <c:if test="${bill.taxAmount > 0}">
                    <div class="d-flex justify-content-between mb-2 text-success">
                      <span>VAT / Service Tax (${bill.taxPercent}%):</span>
                      <span>+ LKR <fmt:formatNumber value="${bill.taxAmount}" type="number" minFractionDigits="2"/></span>
                    </div>
                  </c:if>
                  <hr class="my-2"/>
                  <div class="d-flex justify-content-between mb-2 align-items-center">
                    <span class="text-dark fw-800">Grand Total:</span>
                    <span class="fw-800 text-primary-custom fs-5">LKR <fmt:formatNumber value="${bill.grandTotal}" type="number" minFractionDigits="2"/></span>
                  </div>
                  <div class="d-flex justify-content-between mb-2 text-success">
                    <span>Total Paid:</span>
                    <span>LKR <fmt:formatNumber value="${bill.amountPaid}" type="number" minFractionDigits="2"/></span>
                  </div>
                  <div class="d-flex justify-content-between mb-2 align-items-center">
                    <span class="text-dark fw-700">Balance Due:</span>
                    <span class="${bill.balanceDue > 0 ? 'text-danger fw-800 fs-5' : 'text-muted fw-700'}">
                      LKR <fmt:formatNumber value="${bill.balanceDue}" type="number" minFractionDigits="2"/>
                    </span>
                  </div>
                </div>
              </div>

              <!-- Notes -->
              <c:if test="${not empty bill.notes}">
                <hr class="my-3"/>
                <div style="font-size:.85rem;color:var(--text-secondary);">
                  <strong>Notes:</strong> ${bill.notes}
                </div>
              </c:if>

            </div>
          </div>
        </div>

        <!-- Payments Panel -->
        <div class="col-lg-4">
          <!-- Record payment card -->
          <c:if test="${bill.balanceDue > 0 && bill.billStatus != 'CANCELLED'}">
            <div class="card mb-3 p-3 bg-light text-center border-dashed">
              <p class="mb-2 text-secondary fw-600">Pending balance: LKR <fmt:formatNumber value="${bill.balanceDue}" type="number" minFractionDigits="2"/></p>
              <div>
                <a href="${pageContext.request.contextPath}/payments?action=new&billId=${bill.billId}" class="btn btn-success btn-sm w-100 py-2">
                  <i class="bi bi-cash-coin me-1"></i> Record Payment
                </a>
              </div>
            </div>
          </c:if>

          <!-- Audit info -->
          <div class="card mb-3">
            <div class="card-header">
              <i class="bi bi-info-circle-fill text-secondary"></i>
              <h6>Invoice Audit</h6>
            </div>
            <div class="card-body" style="font-size:.8rem;color:var(--text-secondary);">
              <div class="mb-2"><strong>Issuer User ID:</strong> ${bill.createdBy}</div>
              <div class="mb-2"><strong>Generated:</strong> 
                <fmt:parseDate value="${bill.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedCa" type="both"/>
                <fmt:formatDate value="${parsedCa}" pattern="dd MMM yyyy, HH:mm"/>
              </div>
            </div>
          </div>

          <!-- QR Code Verification Card -->
          <div class="card mb-3 shadow-sm border-primary-subtle">
            <div class="card-header bg-primary text-white d-flex align-items-center justify-content-between py-2">
              <span class="fw-700" style="font-size:.85rem;"><i class="bi bi-qr-code-scan me-1"></i> Invoice QR Verification</span>
              <span class="badge bg-white text-primary" style="font-size:.7rem;">Scan Ready</span>
            </div>
            <div class="card-body text-center p-3">
              <div id="invoiceQrCode" class="d-inline-flex justify-content-center p-2 bg-white rounded border shadow-xs mb-2"></div>
              
              <div class="small fw-700 text-dark mt-1">Scan for Customer & Bill Details</div>
              <p class="text-muted mb-2" style="font-size:.75rem;line-height:1.3;">
                Point any mobile camera or scanner to view verified patient and invoice details.
              </p>

              <!-- Mode switch -->
              <div class="btn-group btn-group-sm w-100 mb-2" role="group">
                <button type="button" class="btn btn-outline-primary active" id="btnQrText" onclick="renderQr('text')">
                  <i class="bi bi-card-text me-1"></i> Direct Info
                </button>
                <button type="button" class="btn btn-outline-primary" id="btnQrUrl" onclick="renderQr('url')">
                  <i class="bi bi-link-45deg me-1"></i> Web Portal
                </button>
              </div>

              <a href="${pageContext.request.contextPath}/verify-bill?num=${bill.billNumber}" target="_blank" class="btn btn-light btn-sm text-primary w-100 border" style="font-size:.78rem;">
                <i class="bi bi-box-arrow-up-right me-1"></i> Open Verification Portal
              </a>
            </div>
          </div>

          <!-- Cancel Invoice Operational button -->
          <c:if test="${bill.billStatus != 'CANCELLED' && bill.amountPaid == 0}">
            <div class="card p-3 border-dashed">
              <form action="${pageContext.request.contextPath}/billing" method="POST">
                <input type="hidden" name="action" value="cancel"/>
                <input type="hidden" name="id" value="${bill.billId}"/>
                <button type="submit" class="btn btn-outline-danger btn-sm w-100" data-confirm="Are you sure you want to cancel this invoice? This cannot be undone.">
                  <i class="bi bi-file-earmark-x-fill me-1"></i> Cancel Invoice
                </button>
              </form>
            </div>
          </c:if>
        </div>
      </div>
    </div>

    <!-- Standalone Offline QRCode Script -->
    <script src="${pageContext.request.contextPath}/js/qrcode.min.js"></script>
    <script>
      (function() {
        var qrContainer = document.getElementById("invoiceQrCode");
        if (!qrContainer) return;

        // Structured customer and billing text for instant camera scanner display
        var directText = 
          "=== SUNRISE DENTAL CLINIC ===\n" +
          "OFFICIAL INVOICE VERIFICATION\n" +
          "Bill No: ${bill.billNumber}\n" +
          "Date: <fmt:formatDate value='${bill.issuedDateSql}' pattern='dd-MM-yyyy'/>\n" +
          "Status: ${bill.billStatus}\n\n" +
          "-- CUSTOMER DETAILS --\n" +
          "Patient: ${bill.patientName}\n" +
          "Patient ID: ${bill.patientNumber}\n" +
          "Phone: ${not empty bill.patientPhone ? bill.patientPhone : 'N/A'}\n" +
          "Address: ${not empty bill.patientAddress ? bill.patientAddress : 'N/A'}\n\n" +
          "-- CLINICAL & BILLING --\n" +
          "Dentist: ${bill.dentistName}\n" +
          "Treatment: ${bill.treatmentName}\n" +
          "Grand Total: LKR <fmt:formatNumber value='${bill.grandTotal}' type='number' minFractionDigits='2'/>\n" +
          "Amount Paid: LKR <fmt:formatNumber value='${bill.amountPaid}' type='number' minFractionDigits='2'/>\n" +
          "Balance Due: LKR <fmt:formatNumber value='${bill.balanceDue}' type='number' minFractionDigits='2'/>\n\n" +
          "Verify Online: " + window.location.origin + "${pageContext.request.contextPath}/verify-bill?num=${bill.billNumber}";

        var portalUrl = window.location.origin + "${pageContext.request.contextPath}/verify-bill?num=${bill.billNumber}";

        var qrInstance = null;

        window.renderQr = function(mode) {
          qrContainer.innerHTML = "";
          var content = (mode === 'url') ? portalUrl : directText;
          
          qrInstance = new QRCode(qrContainer, {
            text: content,
            width: 156,
            height: 156,
            colorDark: "#1e3a8a",
            colorLight: "#ffffff",
            correctLevel: QRCode.CorrectLevel.M
          });

          var btnText = document.getElementById("btnQrText");
          var btnUrl  = document.getElementById("btnQrUrl");
          if (mode === 'url') {
            if (btnUrl)  btnUrl.classList.add("active");
            if (btnText) btnText.classList.remove("active");
          } else {
            if (btnText) btnText.classList.add("active");
            if (btnUrl)  btnUrl.classList.remove("active");
          }
        };

        // Initialize with direct text scan view
        window.renderQr('text');
      })();
    </script>

    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
