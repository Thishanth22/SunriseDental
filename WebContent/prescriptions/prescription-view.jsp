<%-- prescriptions/prescription-view.jsp — View & Print Prescription --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Prescription ${prescription.prescriptionNumber}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<!-- Print Specific Styling -->
<style>
  @media print {
    body {
      background: #fff !important;
      color: #000 !important;
      font-size: 12pt;
    }
    .sidebar, .topbar, .btn-print-group, footer {
      display: none !important;
    }
    .main-content {
      margin-left: 0 !important;
      padding: 0 !important;
    }
    .app-wrapper {
      padding: 0 !important;
    }
    .page-content {
      padding: 0 !important;
    }
    .print-prescription-slip {
      border: none !important;
      box-shadow: none !important;
      padding: 0 !important;
      max-width: 100% !important;
    }
  }
  .print-prescription-slip {
    background: #fff;
    padding: 2.5rem;
    border-radius: 12px;
    box-shadow: 0 4px 15px rgba(0,0,0,.04);
    max-width: 800px;
    margin: 0 auto;
    border: 1px solid #e2e8f0;
  }
</style>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    
    <!-- Action Toolbar (hidden on print) -->
    <div class="topbar btn-print-group">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">E-Prescription Viewer</div>
        <div class="topbar-subtitle">Digital Rx Number: <strong>${prescription.prescriptionNumber}</strong></div>
      </div>
      <div class="topbar-right gap-2">
        <a href="${pageContext.request.contextPath}/patients?action=view&id=${prescription.patientId}" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-person-fill me-1"></i> Patient Profile
        </a>
        <button onclick="window.print();" class="btn btn-primary btn-sm">
          <i class="bi bi-printer-fill me-1"></i> Print Prescription Slip
        </button>
      </div>
    </div>

    <div class="page-content">

      <!-- Success Alerts -->
      <c:if test="${param.msg == 'created'}">
        <div class="alert alert-success btn-print-group mb-3"><i class="bi bi-check-circle-fill me-2"></i>E-Prescription generated successfully!</div>
      </c:if>

      <!-- Slip Outer Layout -->
      <div class="print-prescription-slip">
        
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-start border-bottom pb-4 mb-4">
          <div>
            <h3 class="fw-800 text-primary-custom mb-1" style="font-size:1.6rem;letter-spacing:-0.5px;">SUNRISE DENTAL CLINIC</h3>
            <p class="text-secondary small mb-0">
              No. 12, Flower Road, Colombo 07, Sri Lanka<br/>
              Phone: +94 11 234 5678 | Email: info@sunrisedental.lk
            </p>
          </div>
          <div class="text-end">
            <h4 class="fw-700 text-secondary mb-1">PRESCRIPTION</h4>
            <span class="badge bg-secondary p-2 font-monospace fs-6" style="letter-spacing:0.5px;">${prescription.prescriptionNumber}</span>
          </div>
        </div>

        <!-- Meta Details Grid -->
        <div class="row g-3 mb-4 bg-light rounded p-3" style="font-size:.85rem;border-left:4px solid var(--primary-custom);">
          <div class="col-md-6">
            <div class="mb-1 text-secondary"><strong>Patient Code:</strong> ${prescription.patientNumber}</div>
            <div class="mb-1 text-secondary"><strong>Patient Name:</strong> <span class="fw-700 text-dark">${prescription.patientName}</span></div>
          </div>
          <div class="col-md-6 text-md-end">
            <div class="mb-1 text-secondary"><strong>Date Prescribed:</strong> <fmt:formatDate value="${prescription.createdAtSql}" pattern="dd MMM yyyy, HH:mm a"/></div>
            <div class="mb-1 text-secondary"><strong>Prescribing Dentist:</strong> <span class="fw-700 text-dark">${prescription.dentistName}</span></div>
          </div>
        </div>

        <!-- RX Symbol Header -->
        <div class="mb-3">
          <span style="font-size: 2.2rem; font-family: Georgia, serif; font-weight: bold; color: var(--primary-custom); line-height: 1;">℞</span>
        </div>

        <!-- Medications List Table -->
        <div class="table-responsive mb-4">
          <table class="table table-bordered align-middle" style="font-size:.9rem;">
            <thead class="bg-light">
              <tr>
                <th style="width: 45%;">Medication &amp; Strength</th>
                <th style="width: 15%;">Dosage</th>
                <th style="width: 25%;">Frequency</th>
                <th style="width: 15%;">Duration</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="item" items="${prescription.items}">
                <tr>
                  <td>
                    <div class="fw-700">${item.drugName}</div>
                    <c:if test="${not empty item.instructions}">
                      <div class="text-muted" style="font-size:.75rem;margin-top:2px;">
                        <i class="bi bi-info-circle-fill text-primary"></i> ${item.instructions}
                      </div>
                    </c:if>
                  </td>
                  <td>${item.dosage}</td>
                  <td>${item.frequency}</td>
                  <td>${item.duration}</td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>

        <!-- Doctor Notes -->
        <c:if test="${not empty prescription.notes}">
          <div class="mb-5">
            <h6 class="fw-700 text-secondary border-bottom pb-1 mb-2">Advice &amp; Clinical Remarks</h6>
            <div class="p-3 bg-light rounded text-dark" style="font-size:.85rem;white-space:pre-line;line-height:1.5;">
              <c:out value="${prescription.notes}"/>
            </div>
          </div>
        </c:if>

        <!-- Signature stamp line -->
        <div class="row pt-5 mt-5 align-items-end">
          <div class="col-6">
            <p class="text-muted small mb-0">System Generated Digital Prescription slip.</p>
          </div>
          <div class="col-6 text-end">
            <div class="d-inline-block text-center border-top pt-2" style="width: 220px;border-top: 1px solid #94a3b8 !important;">
              <div class="fw-700 text-dark" style="font-size:.85rem;">${prescription.dentistName}</div>
              <div class="text-muted small">Registered Dental Practitioner</div>
            </div>
          </div>
        </div>

      </div>

    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
