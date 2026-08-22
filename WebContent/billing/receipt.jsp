<%-- billing/receipt.jsp — Print Invoice Receipt --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Receipt — ${bill.billNumber}</title>
  <style>
    body {
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      color: #333;
      padding: 30px;
      max-width: 800px;
      margin: 0 auto;
      line-height: 1.5;
    }
    .receipt-header {
      display: flex;
      justify-content: space-between;
      border-bottom: 2px solid #eee;
      padding-bottom: 20px;
      margin-bottom: 30px;
    }
    .clinic-details h2 {
      margin: 0 0 5px 0;
      color: #1a56db;
      font-size: 24px;
      font-weight: bold;
    }
    .clinic-details p {
      margin: 0;
      font-size: 13px;
      color: #666;
    }
    .receipt-title {
      text-align: right;
    }
    .receipt-title h1 {
      margin: 0 0 5px 0;
      font-size: 28px;
      color: #333;
    }
    .receipt-title span {
      font-family: monospace;
      font-size: 15px;
      font-weight: bold;
      color: #666;
    }
    .meta-details {
      display: flex;
      justify-content: space-between;
      margin-bottom: 40px;
      font-size: 14px;
    }
    .meta-block h4 {
      margin: 0 0 8px 0;
      text-transform: uppercase;
      font-size: 12px;
      color: #999;
      letter-spacing: 0.5px;
    }
    .meta-block div {
      font-weight: bold;
    }
    .items-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 30px;
    }
    .items-table th {
      background: #f9f9f9;
      border-bottom: 2px solid #eee;
      text-align: left;
      padding: 10px;
      font-size: 12px;
      text-transform: uppercase;
      color: #666;
    }
    .items-table td {
      padding: 12px 10px;
      border-bottom: 1px solid #eee;
      font-size: 14px;
    }
    .total-calculations {
      float: right;
      width: 300px;
      font-size: 14px;
    }
    .calc-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;
    }
    .calc-row.grand-total {
      border-top: 1px solid #ddd;
      padding-top: 8px;
      font-size: 16px;
      font-weight: bold;
      color: #1a56db;
    }
    .calc-row.balance {
      font-size: 16px;
      font-weight: bold;
      color: #e02424;
    }
    .footer-note {
      margin-top: 120px;
      border-top: 1px solid #eee;
      padding-top: 20px;
      text-align: center;
      font-size: 12px;
      color: #999;
    }
    .no-print-bar {
      background: #f3f4f6;
      border: 1px solid #e5e7eb;
      padding: 10px 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
      border-radius: 6px;
    }
    @media print {
      .no-print-bar { display: none !important; }
      body { padding: 0; }
    }
  </style>
</head>
<body>

  <!-- Print action banner -->
  <div class="no-print-bar">
    <span style="font-size:14px;font-weight:bold;color:#4b5563;">Official Invoice Receipt</span>
    <button onclick="window.print();" style="background:#1a56db;color:#fff;border:none;padding:6px 16px;font-size:13px;font-weight:bold;border-radius:4px;cursor:pointer;">
      Print Receipt
    </button>
  </div>

  <div class="receipt-header">
    <div class="clinic-details">
      <h2>SUNRISE DENTAL CLINIC</h2>
      <p>
        123 Medical Center Road, Colombo 07, Sri Lanka<br/>
        Tel: +94 11 234 5678 | Email: info@sunrisedental.lk
      </p>
    </div>
    <div class="receipt-title">
      <h1>INVOICE</h1>
      <span>${bill.billNumber}</span>
    </div>
  </div>

  <div class="meta-details">
    <div class="meta-block">
      <h4>Billed To</h4>
      <div style="font-size:15px;font-weight:bold;">${bill.patientName}</div>
      <div style="font-weight:normal;color:#666;font-size:12px;margin-top:2px;">
        Patient ID: <strong>${bill.patientNumber}</strong>
      </div>
      <c:if test="${not empty bill.patientPhone}">
        <div style="font-weight:normal;color:#666;font-size:12px;">Phone: ${bill.patientPhone}</div>
      </c:if>
      <c:if test="${not empty bill.patientAddress}">
        <div style="font-weight:normal;color:#666;font-size:12px;">Address: ${bill.patientAddress}</div>
      </c:if>
    </div>
    <div class="meta-block" style="text-align:right;">
      <h4>Invoice & Clinical Info</h4>
      <div>Issued Date: <fmt:formatDate value="${bill.issuedDateSql}" pattern="dd MMM yyyy"/></div>
      <div style="font-weight:normal;color:#666;font-size:12px;margin-top:2px;">
        Due Date: <fmt:formatDate value="${bill.dueDateSql}" pattern="dd MMM yyyy"/>
      </div>
      <div style="font-weight:normal;color:#666;font-size:12px;margin-top:2px;">
        Dentist: <strong>${bill.dentistName}</strong>
      </div>
      <div style="font-weight:normal;color:#666;font-size:12px;">
        Treatment: ${bill.treatmentName}
      </div>
    </div>
  </div>

  <table class="items-table">
    <thead>
      <tr>
        <th style="width:40px;">#</th>
        <th>Item Description</th>
        <th style="width:100px;">Category</th>
        <th style="width:120px;text-align:right;">Unit Price</th>
        <th style="width:50px;text-align:center;">Qty</th>
        <th style="width:140px;text-align:right;">Total Price</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="item" items="${items}" varStatus="s">
        <tr>
          <td>${s.index + 1}</td>
          <td>${item.description}</td>
          <td>${item.itemType}</td>
          <td style="text-align:right;">LKR <fmt:formatNumber value="${item.unitPrice}" type="number" minFractionDigits="2"/></td>
          <td style="text-align:center;">${item.quantity}</td>
          <td style="text-align:right;">LKR <fmt:formatNumber value="${item.totalPrice}" type="number" minFractionDigits="2"/></td>
        </tr>
      </c:forEach>
    </tbody>
  </table>

  <!-- Bottom section: QR Code on Left, Totals on Right -->
  <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-top:20px;margin-bottom:20px;">
    <!-- QR Code Verification Stamp -->
    <div style="border:1px solid #e5e7eb;background:#f9fafb;padding:12px;border-radius:8px;text-align:center;width:170px;">
      <div id="receiptQr" style="display:inline-block;padding:4px;background:#fff;border:1px solid #ddd;border-radius:4px;"></div>
      <div style="font-size:11px;font-weight:bold;color:#1a56db;margin-top:6px;">SCAN TO VERIFY</div>
      <div style="font-size:9.5px;color:#666;line-height:1.2;margin-top:2px;">Customer & Billing Details Embedded</div>
    </div>

    <!-- Calculations Block -->
    <div class="total-calculations" style="float:none;width:320px;">
      <div class="calc-row">
        <span>Sub Total</span>
        <span>LKR <fmt:formatNumber value="${bill.subTotal}" type="number" minFractionDigits="2"/></span>
      </div>
      <c:if test="${bill.discountAmount > 0}">
        <div class="calc-row" style="color:#e02424;">
          <span>Discount (${bill.discountPercent}%)</span>
          <span>- LKR <fmt:formatNumber value="${bill.discountAmount}" type="number" minFractionDigits="2"/></span>
        </div>
      </c:if>
      <c:if test="${bill.taxAmount > 0}">
        <div class="calc-row">
          <span>Tax (${bill.taxPercent}%)</span>
          <span>+ LKR <fmt:formatNumber value="${bill.taxAmount}" type="number" minFractionDigits="2"/></span>
        </div>
      </c:if>
      <div class="calc-row grand-total">
        <span>Grand Total</span>
        <span>LKR <fmt:formatNumber value="${bill.grandTotal}" type="number" minFractionDigits="2"/></span>
      </div>
      <div class="calc-row" style="color:#057a55;font-weight:bold;">
        <span>Total Paid</span>
        <span>LKR <fmt:formatNumber value="${bill.amountPaid}" type="number" minFractionDigits="2"/></span>
      </div>
      <c:if test="${bill.balanceDue > 0}">
        <div class="calc-row balance">
          <span>Balance Due</span>
          <span>LKR <fmt:formatNumber value="${bill.balanceDue}" type="number" minFractionDigits="2"/></span>
        </div>
      </c:if>
    </div>
  </div>

  <div style="clear:both;"></div>

  <div class="footer-note">
    Thank you for choosing Sunrise Dental Clinic.<br/>
    We wish you a healthy smile! &bull; Electronic Invoice Verification Enabled
  </div>

  <script src="${pageContext.request.contextPath}/js/qrcode.min.js"></script>
  <script>
    (function() {
      var qrContainer = document.getElementById("receiptQr");
      if (!qrContainer) return;

      var qrData = 
        "=== SUNRISE DENTAL CLINIC ===\n" +
        "OFFICIAL INVOICE RECEIPT\n" +
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

      new QRCode(qrContainer, {
        text: qrData,
        width: 140,
        height: 140,
        colorDark: "#111827",
        colorLight: "#ffffff",
        correctLevel: QRCode.CorrectLevel.M
      });
    })();
  </script>

</body>
</html>
