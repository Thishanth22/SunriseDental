<%-- billing/bill-form.jsp — Generate Invoice --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Generate Invoice"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Create Invoice</div>
        <div class="topbar-subtitle">Generate invoice for treatment session</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/billing" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back
        </a>
      </div>
    </div>

    <div class="page-content">
      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <c:choose>
        <c:when test="${empty appointment}">
          <!-- Select Completed Appointment First -->
          <div class="card">
            <div class="card-header">
              <i class="bi bi-calendar2-check-fill text-primary"></i>
              <h6>Select Session to Invoice</h6>
            </div>
            <div class="card-body">
              <p class="text-secondary" style="font-size:.9rem;">
                Select a completed treatment session to generate a billing invoice.
              </p>
              
              <%-- Realize search/select for completed appointments --%>
              <div class="alert alert-info">
                Please visit the <a href="${pageContext.request.contextPath}/appointments?status=COMPLETED" class="alert-link fw-700">Completed Appointments</a> list and click <strong>"Generate Invoice/Bill"</strong> for the respective patient session.
              </div>
            </div>
          </div>
        </c:when>
        
        <c:otherwise>
          <!-- Bill generation parameters form -->
          <form action="${pageContext.request.contextPath}/billing"
                method="POST"
                class="needs-validation form-with-loading"
                id="billingForm"
                novalidate>
            
            <input type="hidden" name="action" value="generate"/>
            <input type="hidden" name="appointmentId" value="${appointment.appointmentId}"/>

            <div class="row g-3">
              <!-- Left Column — Pricing Variables -->
              <div class="col-lg-8">
                
                <!-- Session Details -->
                <div class="card mb-3">
                  <div class="card-header">
                    <i class="bi bi-info-circle-fill text-primary"></i>
                    <h6>Treatment Session Summary</h6>
                  </div>
                  <div class="card-body py-3">
                    <div class="row g-2" style="font-size:.85rem;">
                      <div class="col-md-6"><strong>Patient:</strong> ${appointment.patientName} (${appointment.patientNumber})</div>
                      <div class="col-md-6"><strong>Dentist:</strong> Dr. ${appointment.dentistName}</div>
                      <div class="col-md-6"><strong>Treatment:</strong> ${appointment.treatmentName}</div>
                      <div class="col-md-6"><strong>Date:</strong> <fmt:formatDate value="${appointment.appointmentDateSql}" pattern="dd MMM yyyy"/></div>
                    </div>
                  </div>
                </div>

                <!-- Fees Breakdown (Form Inputs) -->
                <div class="card mb-3">
                  <div class="card-header">
                    <i class="bi bi-cash-coin text-primary"></i>
                    <h6>Invoicing Charges &amp; Adjustments</h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <!-- Consultation Fee (READ ONLY) -->
                      <div class="col-md-6">
                        <label class="form-label" for="consultationFee">Consultation Fee (LKR) <span class="text-danger">*</span></label>
                        <input type="text" id="consultationFee" class="form-control bg-light" value="1500.00" readonly/>
                        <div class="form-text">Standard clinic consultation charges.</div>
                      </div>

                      <!-- Treatment Base Cost (READ ONLY) -->
                      <div class="col-md-6">
                        <label class="form-label" for="treatmentCost">Treatment Fee (LKR) <span class="text-danger">*</span></label>
                        <input type="text" id="treatmentCost" class="form-control bg-light"
                               value="${appointment.treatmentDurationMins > 0 ? 'Checked' : ''}"
                               data-basecost="${appointment.treatmentDurationMins}"
                               placeholder="Computed from DB treatment table" readonly/>
                        <div class="form-text">Retrieved securely from database treatment records.</div>
                      </div>

                      <!-- Additional Charges -->
                      <div class="col-md-6">
                        <label class="form-label" for="additionalCharges">Additional Charges (LKR)</label>
                        <input type="number" id="additionalCharges" name="additionalCharges"
                               class="form-control calculate-trigger"
                               min="0" step="100" placeholder="0.00"/>
                        <div class="form-text">Medicines, X-Rays, surgical consumables, etc.</div>
                      </div>

                      <!-- Additional description -->
                      <div class="col-md-6">
                        <label class="form-label" for="additionalDesc">Additional Charges Description</label>
                        <input type="text" id="additionalDesc" name="additionalDesc"
                               class="form-control" maxlength="250"
                               placeholder="e.g. Antibiotics, Extra X-ray films"/>
                      </div>

                      <!-- Discount percentage -->
                      <div class="col-md-6">
                        <label class="form-label" for="discountPercent">Discount Percentage (%)</label>
                        <input type="number" id="discountPercent" name="discountPercent"
                               class="form-control calculate-trigger"
                               min="0" max="100" step="0.5" placeholder="0.00"/>
                        <div class="form-text">Discount applicable on sub-total.</div>
                      </div>

                      <!-- Tax percent -->
                      <div class="col-md-6">
                        <label class="form-label" for="taxPercent">VAT / Service Tax (%)</label>
                        <input type="number" id="taxPercent" name="taxPercent"
                               class="form-control calculate-trigger"
                               min="0" max="30" step="0.1" value="0.0"/>
                        <div class="form-text">Standard government levies.</div>
                      </div>

                      <!-- General Notes -->
                      <div class="col-12">
                        <label class="form-label" for="notes">Invoice Comments &amp; Notes</label>
                        <textarea id="notes" name="notes" class="form-control" rows="2" maxlength="500" placeholder="Internal or client-facing invoice remarks..."></textarea>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Right Column — Live Computation Sheet -->
              <div class="col-lg-4">
                <div class="card" style="position:sticky;top:90px;">
                  <div class="card-header bg-light">
                    <i class="bi bi-calculator-fill text-primary"></i>
                    <h6>Summary Estimation</h6>
                  </div>
                  <div class="card-body">
                    <div class="d-flex justify-content-between mb-2">
                      <span class="text-secondary">Consultation Fee</span>
                      <span class="fw-600">LKR 1,500.00</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                      <span class="text-secondary">Treatment Catalog Fee</span>
                      <span class="fw-600" id="estTreatmentCost">LKR 0.00</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                      <span class="text-secondary">Consumables / Other</span>
                      <span class="fw-600" id="estAdditional">LKR 0.00</span>
                    </div>
                    
                    <hr class="my-2"/>
                    
                    <div class="d-flex justify-content-between mb-2">
                      <span class="text-secondary fw-700">Sub Total</span>
                      <span class="fw-700" id="estSubTotal">LKR 0.00</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2 text-danger">
                      <span>Discount Allowance</span>
                      <span id="estDiscount">LKR 0.00</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2 text-success">
                      <span>VAT / Service Tax</span>
                      <span id="estTax">LKR 0.00</span>
                    </div>

                    <hr class="my-2"/>

                    <div class="d-flex justify-content-between mb-3 align-items-center">
                      <span class="text-dark fw-800 fs-5">Grand Total</span>
                      <span class="fw-800 fs-4 text-primary-custom" id="estGrandTotal">LKR 0.00</span>
                    </div>

                    <div class="alert alert-warning py-2 mb-0" style="font-size:.75rem;">
                      <i class="bi bi-info-circle-fill me-1"></i>
                      Note: Calculations shown here are client-side estimations. Official totals are computed securely server-side upon invoice generation.
                    </div>
                  </div>
                  <div class="card-footer">
                    <button type="submit" class="btn btn-primary w-100 py-2">
                      <i class="bi bi-file-earmark-plus-fill me-1"></i> Generate Invoice
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </form>
        </c:otherwise>
      </c:choose>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>

<!-- Inline JavaScript for client-side live calculator -->
<c:if test="${not empty appointment}">
  <script>
    document.addEventListener('DOMContentLoaded', function () {
      const treatmentIdSelect = document.getElementById('treatmentId');
      
      // Since treatment ID select is not in this form, we retrieve base treatment cost from appointment request attribute.
      // We can output the treatment base cost directly from appointment's treatment cost in DB!
      // Wait, in billing servlet we fetch the treatment from the database, but let's query the treatment base cost
      // or we can pass the treatment cost from controller.
      // For calculation, let's look at the treatment cost from appointment.
      // Wait, appointment model has treatment base cost if joined, or we can fetch it.
      // In appointment-form, we output it. In this JSP, the controller doesn't output treatment cost directly to form,
      // but let's fetch it using a data attribute or hardcoded JSTL.
      // Let's get the treatment base cost via JSTL!
      // In database, the treatment_id is linked. We can get it from treatments catalog:
      let treatmentBaseCost = 0;
      <c:catch var="err">
        <%-- Let's fetch it from treatment DAO or pass from servlet. We can fallback to a dummy if needed,
             but since we want it accurate, let's pull it from database. --%>
        <%
          try {
            com.sunrise.dental.model.Appointment app = (com.sunrise.dental.model.Appointment) request.getAttribute("appointment");
            if (app != null) {
              com.sunrise.dental.model.Treatment tr = new com.sunrise.dental.dao.impl.TreatmentDAOImpl().findById(app.getTreatmentId());
              if (tr != null) {
                out.print("treatmentBaseCost = " + tr.getBaseCost() + ";");
              }
            }
          } catch(Exception e) {}
        %>
      </c:catch>

      const consultFee = 1500.00;
      const additionalInput = document.getElementById('additionalCharges');
      const discountInput   = document.getElementById('discountPercent');
      const taxInput        = document.getElementById('taxPercent');

      const estTreatmentCost = document.getElementById('estTreatmentCost');
      const estAdditional    = document.getElementById('estAdditional');
      const estSubTotal      = document.getElementById('estSubTotal');
      const estDiscount      = document.getElementById('estDiscount');
      const estTax           = document.getElementById('estTax');
      const estGrandTotal    = document.getElementById('estGrandTotal');

      // Populate readonly input with base cost
      const treatmentCostInput = document.getElementById('treatmentCost');
      if (treatmentCostInput) {
        treatmentCostInput.value = treatmentBaseCost.toFixed(2);
      }

      function formatLKR(val) {
        return 'LKR ' + val.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
      }

      function calculate() {
        const additional = parseFloat(additionalInput.value) || 0;
        const discountPct = parseFloat(discountInput.value) || 0;
        const taxPct = parseFloat(taxInput.value) || 0;

        const subTotal = consultFee + treatmentBaseCost + additional;
        const discountAmt = subTotal * (discountPct / 100);
        const afterDiscount = subTotal - discountAmt;
        const taxAmt = afterDiscount * (taxPct / 100);
        const grandTotal = afterDiscount + taxAmt;

        estTreatmentCost.textContent = formatLKR(treatmentBaseCost);
        estAdditional.textContent    = formatLKR(additional);
        estSubTotal.textContent      = formatLKR(subTotal);
        estDiscount.textContent      = '- ' + formatLKR(discountAmt);
        estTax.textContent           = '+ ' + formatLKR(taxAmt);
        estGrandTotal.textContent    = formatLKR(grandTotal);
      }

      // Bind triggers
      document.querySelectorAll('.calculate-trigger').forEach(el => {
        el.addEventListener('input', calculate);
      });

      // Initial call
      calculate();
    });
  </script>
</c:if>
