<%-- billing/verify-bill.jsp — Public Invoice & Customer QR Verification Portal --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Invoice Verification — ${verified ? bill.billNumber : 'Sunrise Dental Clinic'}</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap-icons.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css"/>
  <style>
    body {
      background-color: #f3f4f6;
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      color: #1f2937;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    .verify-container {
      max-width: 860px;
      margin: 30px auto;
      padding: 0 15px;
      width: 100%;
    }
    .verify-card {
      background: #ffffff;
      border-radius: 12px;
      box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.04);
      border: 1px solid #e5e7eb;
      overflow: hidden;
    }
    .verify-header {
      background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
      color: #ffffff;
      padding: 24px 28px;
    }
    .verified-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: rgba(16, 185, 129, 0.2);
      border: 1px solid #10b981;
      color: #d1fae5;
      padding: 6px 14px;
      border-radius: 50px;
      font-size: 0.85rem;
      font-weight: 600;
      letter-spacing: 0.3px;
    }
    .section-title {
      font-size: 0.82rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.75px;
      color: #6b7280;
      margin-bottom: 12px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .info-box {
      background: #f9fafb;
      border: 1px solid #f3f4f6;
      border-radius: 8px;
      padding: 14px 16px;
      height: 100%;
    }
    .info-label {
      font-size: 0.78rem;
      color: #6b7280;
      text-transform: uppercase;
      font-weight: 600;
    }
    .info-val {
      font-size: 0.98rem;
      font-weight: 600;
      color: #111827;
    }
    .total-table td {
      padding: 8px 14px;
    }
    .grand-total-row {
      background-color: #eff6ff;
      font-size: 1.15rem;
      font-weight: 700;
      color: #1e40af;
    }
    @media print {
      body { background: #fff; }
      .verify-container { max-width: 100%; margin: 0; padding: 0; }
      .verify-card { box-shadow: none; border: none; }
      .no-print { display: none !important; }
    }
  </style>
</head>
<body>

  <div class="verify-container">

    <c:choose>
      <c:when test="${verified}">
        <!-- VERIFIED INVOICE CARD -->
        <div class="verify-card mb-4">
          
          <!-- Header -->
          <div class="verify-header">
            <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
              <div>
                <div class="d-flex align-items-center gap-2 mb-1">
                  <i class="bi bi-hospital fs-4"></i>
                  <h3 class="mb-0 fw-800" style="letter-spacing:-0.5px;">SUNRISE DENTAL CLINIC</h3>
                </div>
                <div class="opacity-75 small">
                  123 Medical Center Road, Colombo 07, Sri Lanka | +94 11 234 5678
                </div>
              </div>
              <div class="text-sm-end">
                <div class="verified-badge mb-2">
                  <i class="bi bi-patch-check-fill text-success"></i> OFFICIAL VERIFIED INVOICE
                </div>
                <div class="font-monospace fw-700 fs-5">${bill.billNumber}</div>
              </div>
            </div>
          </div>

          <div class="p-4">

            <!-- Alert banner -->
            <div class="alert alert-success d-flex align-items-center gap-3 py-2 px-3 mb-4 rounded-3 border-success-subtle">
              <i class="bi bi-shield-lock-fill fs-3 text-success"></i>
              <div style="font-size:.88rem;">
                <strong>Digital Authenticity Confirmed:</strong> This invoice was securely generated and verified by the Sunrise Dental Clinic Electronic Records System.
              </div>
            </div>

            <!-- Row 1: Customer Details & Clinical Details -->
            <div class="row g-3 mb-4">
              <!-- Customer / Patient Details -->
              <div class="col-md-6">
                <div class="section-title">
                  <i class="bi bi-person-badge-fill text-primary"></i> Customer / Patient Details
                </div>
                <div class="info-box">
                  <div class="mb-2">
                    <div class="info-label">Full Name</div>
                    <div class="info-val fs-6 text-primary">${bill.patientName}</div>
                  </div>
                  <div class="row g-2 mb-2">
                    <div class="col-6">
                      <div class="info-label">Patient ID</div>
                      <div class="info-val font-monospace">${bill.patientNumber}</div>
                    </div>
                    <div class="col-6">
                      <div class="info-label">Phone Number</div>
                      <div class="info-val">
                        <c:choose>
                          <c:when test="${not empty bill.patientPhone}">${bill.patientPhone}</c:when>
                          <c:when test="${not empty patient.contactNumber}">${patient.contactNumber}</c:when>
                          <c:otherwise><span class="text-muted">N/A</span></c:otherwise>
                        </c:choose>
                      </div>
                    </div>
                  </div>
                  <div>
                    <div class="info-label">Residential Address</div>
                    <div class="info-val" style="font-size:.9rem;font-weight:500;">
                      <c:choose>
                        <c:when test="${not empty bill.patientAddress}">${bill.patientAddress}</c:when>
                        <c:when test="${not empty patient.address}">${patient.address}</c:when>
                        <c:otherwise><span class="text-muted">Not specified</span></c:otherwise>
                      </c:choose>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Clinical & Dentist Details -->
              <div class="col-md-6">
                <div class="section-title">
                  <i class="bi bi-heart-pulse-fill text-danger"></i> Clinical & Appointment Details
                </div>
                <div class="info-box">
                  <div class="mb-2">
                    <div class="info-label">Treating Dentist</div>
                    <div class="info-val text-dark">${bill.dentistName}</div>
                  </div>
                  <div class="mb-2">
                    <div class="info-label">Treatment Provided</div>
                    <div class="info-val text-dark">${bill.treatmentName}</div>
                  </div>
                  <div class="row g-2">
                    <div class="col-6">
                      <div class="info-label">Appointment Reference</div>
                      <div class="info-val font-monospace">${bill.appointmentNumber}</div>
                    </div>
                    <div class="col-6">
                      <div class="info-label">Issued Date</div>
                      <div class="info-val"><fmt:formatDate value="${bill.issuedDateSql}" pattern="dd MMM yyyy"/></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Row 2: Itemized Bill Items -->
            <div class="section-title">
              <i class="bi bi-receipt-cutoff text-primary"></i> Itemized Billing Details
            </div>
            <div class="table-responsive mb-4 rounded-3 border">
              <table class="table table-hover align-middle mb-0" style="font-size:.9rem;">
                <thead class="table-light">
                  <tr>
                    <th class="ps-3" style="width:40px;">#</th>
                    <th>Description</th>
                    <th>Category</th>
                    <th class="text-end">Unit Price (LKR)</th>
                    <th class="text-center" style="width:60px;">Qty</th>
                    <th class="text-end pe-3">Total (LKR)</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="item" items="${items}" varStatus="loop">
                    <tr>
                      <td class="ps-3 text-muted">${loop.index + 1}</td>
                      <td class="fw-600">${item.description}</td>
                      <td><span class="badge bg-light text-dark border">${item.itemType}</span></td>
                      <td class="text-end font-monospace"><fmt:formatNumber value="${item.unitPrice}" type="number" minFractionDigits="2"/></td>
                      <td class="text-center">${item.quantity}</td>
                      <td class="text-end pe-3 font-monospace fw-600"><fmt:formatNumber value="${item.totalPrice}" type="number" minFractionDigits="2"/></td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>

            <!-- Row 3: Financial Totals Summary -->
            <div class="row g-3 mb-4">
              <div class="col-md-6">
                <!-- Status card -->
                <div class="p-3 rounded-3 border h-100">
                  <div class="info-label mb-1">Invoice Payment Status</div>
                  <div class="mb-3">
                    <c:choose>
                      <c:when test="${bill.billStatus == 'PAID'}">
                        <span class="badge bg-success fs-6 px-3 py-2"><i class="bi bi-check2-all me-1"></i> FULLY PAID</span>
                      </c:when>
                      <c:when test="${bill.billStatus == 'PARTIALLY_PAID'}">
                        <span class="badge bg-warning text-dark fs-6 px-3 py-2"><i class="bi bi-clock-history me-1"></i> PARTIALLY PAID</span>
                      </c:when>
                      <c:when test="${bill.billStatus == 'CANCELLED'}">
                        <span class="badge bg-secondary fs-6 px-3 py-2"><i class="bi bi-x-circle me-1"></i> CANCELLED</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-primary fs-6 px-3 py-2"><i class="bi bi-file-earmark-text me-1"></i> ISSUED / UNPAID</span>
                      </c:otherwise>
                    </c:choose>
                  </div>

                  <c:if test="${not empty payments}">
                    <div class="info-label mb-2">Recorded Payment Transactions:</div>
                    <div class="list-group list-group-flush border rounded-2" style="font-size:.82rem;">
                      <c:forEach var="p" items="${payments}">
                        <div class="list-group-item d-flex justify-content-between align-items-center py-2">
                          <div>
                            <strong>${p.paymentMethod}</strong>
                            <c:if test="${not empty p.transactionRef}"> &bull; Ref: <code>${p.transactionRef}</code></c:if>
                          </div>
                          <span class="text-success fw-700 font-monospace">LKR <fmt:formatNumber value="${p.amount}" type="number" minFractionDigits="2"/></span>
                        </div>
                      </c:forEach>
                    </div>
                  </c:if>
                </div>
              </div>

              <div class="col-md-6">
                <table class="table table-bordered total-table mb-0 rounded-3 overflow-hidden" style="font-size:.9rem;">
                  <tbody>
                    <tr>
                      <td class="text-muted">Sub Total</td>
                      <td class="text-end font-monospace">LKR <fmt:formatNumber value="${bill.subTotal}" type="number" minFractionDigits="2"/></td>
                    </tr>
                    <c:if test="${bill.discountAmount > 0}">
                      <tr class="text-danger">
                        <td>Discount (${bill.discountPercent}%)</td>
                        <td class="text-end font-monospace">- LKR <fmt:formatNumber value="${bill.discountAmount}" type="number" minFractionDigits="2"/></td>
                      </tr>
                    </c:if>
                    <c:if test="${bill.taxAmount > 0}">
                      <tr class="text-secondary">
                        <td>Tax / VAT (${bill.taxPercent}%)</td>
                        <td class="text-end font-monospace">+ LKR <fmt:formatNumber value="${bill.taxAmount}" type="number" minFractionDigits="2"/></td>
                      </tr>
                    </c:if>
                    <tr class="grand-total-row">
                      <td>Grand Total</td>
                      <td class="text-end font-monospace">LKR <fmt:formatNumber value="${bill.grandTotal}" type="number" minFractionDigits="2"/></td>
                    </tr>
                    <tr class="text-success fw-600">
                      <td>Total Paid</td>
                      <td class="text-end font-monospace">LKR <fmt:formatNumber value="${bill.amountPaid}" type="number" minFractionDigits="2"/></td>
                    </tr>
                    <c:if test="${bill.balanceDue > 0}">
                      <tr class="table-danger text-danger fw-700 fs-6">
                        <td>Outstanding Balance</td>
                        <td class="text-end font-monospace">LKR <fmt:formatNumber value="${bill.balanceDue}" type="number" minFractionDigits="2"/></td>
                      </tr>
                    </c:if>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Action buttons -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pt-3 border-top no-print">
              <div class="text-muted small">
                <i class="bi bi-clock me-1"></i> Verified on: <%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(new java.util.Date()) %>
              </div>
              <div class="d-flex gap-2">
                <button onclick="window.print();" class="btn btn-outline-primary btn-sm">
                  <i class="bi bi-printer-fill me-1"></i> Print / Save PDF
                </button>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-secondary btn-sm">
                  <i class="bi bi-box-arrow-in-right me-1"></i> Staff Login
                </a>
              </div>
            </div>

          </div>
        </div>
      </c:when>

      <c:otherwise>
        <!-- INVALID / NOT FOUND CARD -->
        <div class="verify-card text-center p-5">
          <div class="text-danger mb-3">
            <i class="bi bi-exclamation-triangle-fill" style="font-size: 4rem;"></i>
          </div>
          <h4 class="fw-700 mb-2">Invoice Not Found</h4>
          <p class="text-muted mb-4" style="max-width: 480px; margin: 0 auto;">
            The requested invoice reference <c:if test="${not empty searchedQuery}"><strong>"${searchedQuery}"</strong></c:if> could not be verified in our records. Please verify the QR code or contact the clinic reception.
          </p>
          <div class="d-flex justify-content-center gap-2">
            <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-primary btn-sm">
              <i class="bi bi-house-door-fill me-1"></i> Return to Homepage
            </a>
          </div>
        </div>
      </c:otherwise>
    </c:choose>

    <!-- Footer note -->
    <div class="text-center text-muted small py-3 no-print">
      &copy; <%= java.time.Year.now().getValue() %> Sunrise Dental Clinic. All Rights Reserved. &bull; Official Digital Verification Service
    </div>

  </div>

</body>
</html>
