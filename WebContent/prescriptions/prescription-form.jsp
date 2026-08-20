<%-- prescriptions/prescription-form.jsp — Write E-Prescription --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Write E-Prescription"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">New E-Prescription Writer</div>
        <div class="topbar-subtitle">Issue digital prescription records for clinical treatments</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/patients?action=view&id=${patient.patientId}" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back to Patient profile
        </a>
      </div>
    </div>

    <div class="page-content">

      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <div class="row g-3">
        <!-- Main Form -->
        <div class="col-lg-8">
          <div class="card">
            <div class="card-header bg-white">
              <i class="bi bi-prescription text-primary fs-5"></i>
              <h6 class="mb-0 ms-2 d-inline-block">Prescription Medications list</h6>
            </div>
            <div class="card-body">
              <form action="${pageContext.request.contextPath}/prescriptions"
                    method="POST"
                    class="needs-validation form-with-loading"
                    novalidate>

                <input type="hidden" name="action" value="save"/>
                <input type="hidden" name="patientId" value="${patient.patientId}"/>
                <input type="hidden" name="appointmentId" value="${appointmentId}"/>

                <!-- Dentist Selection (Read-only if logged in as Dentist, else Admin selects) -->
                <div class="mb-4">
                  <label class="form-label" for="dentistId">Prescribed By Dentist <span class="text-danger">*</span></label>
                  <c:choose>
                    <c:when test="${not empty selectedDentist}">
                      <input type="hidden" name="dentistId" value="${selectedDentist.dentistId}"/>
                      <input type="text" class="form-control" value="${selectedDentist.fullName} (${selectedDentist.specialization})" readonly disabled/>
                    </c:when>
                    <c:otherwise>
                      <select id="dentistId" name="dentistId" class="form-select" required>
                        <option value="">-- Select Dentist --</option>
                        <c:forEach var="d" items="${dentists}">
                          <option value="${d.dentistId}">${d.fullName} (${d.specialization})</option>
                        </c:forEach>
                      </select>
                      <div class="invalid-feedback">Please select the prescribing dentist.</div>
                    </c:otherwise>
                  </c:choose>
                </div>

                <!-- Dynamic Medication Rows -->
                <div class="mb-3">
                  <label class="form-label d-flex justify-content-between align-items-center">
                    <span>Medications &amp; Posology <span class="text-danger">*</span></span>
                    <button type="button" class="btn btn-sm btn-outline-primary" id="addDrugBtn">
                      <i class="bi bi-plus-circle-fill me-1"></i>Add Medication Line
                    </button>
                  </label>

                  <div id="drugListContainer">
                    <!-- Dynamic Rows Go Here (1 row pre-inserted) -->
                    <div class="drug-row border rounded p-3 mb-2 bg-light position-relative">
                      <div class="row g-2">
                        <!-- Drug Selector / Input -->
                        <div class="col-md-5">
                          <label class="form-label small mb-1">Medication Name</label>
                          <input type="text" name="drugName[]" class="form-control form-control-sm drug-autocomplete" placeholder="e.g. Amoxicillin 500mg" required list="popularDrugs"/>
                        </div>
                        
                        <!-- Dosage -->
                        <div class="col-md-2">
                          <label class="form-label small mb-1">Dosage</label>
                          <input type="text" name="dosage[]" class="form-control form-control-sm" placeholder="e.g. 1 tablet" required/>
                        </div>

                        <!-- Frequency -->
                        <div class="col-md-3">
                          <label class="form-label small mb-1">Frequency</label>
                          <input type="text" name="frequency[]" class="form-control form-control-sm" placeholder="e.g. 3 times daily" required list="commonFrequencies"/>
                        </div>

                        <!-- Duration -->
                        <div class="col-md-2">
                          <label class="form-label small mb-1">Duration</label>
                          <input type="text" name="duration[]" class="form-control form-control-sm" placeholder="e.g. 5 days" required/>
                        </div>

                        <!-- Instructions -->
                        <div class="col-12 mt-2">
                          <label class="form-label small mb-1">Special Instructions</label>
                          <input type="text" name="instructions[]" class="form-control form-control-sm" placeholder="e.g. Take after meals, complete the full course" list="commonInstructions"/>
                        </div>
                      </div>
                      
                      <!-- Delete Button -->
                      <button type="button" class="btn btn-sm btn-outline-danger btn-remove-row position-absolute top-0 end-0 m-2" style="display:none;">
                        <i class="bi bi-trash"></i>
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Prescription Notes -->
                <div class="mb-4">
                  <label class="form-label" for="notes">Prescription Notes / Remarks</label>
                  <textarea id="notes" name="notes" class="form-control" rows="3" placeholder="Add diagnosis, specific advice, or clinical warnings (optional)..."></textarea>
                </div>

                <!-- Datalists for autocompletion suggestions -->
                <datalist id="popularDrugs">
                  <option value="Amoxicillin 500mg">
                  <option value="Metronidazole 400mg">
                  <option value="Ibuprofen 400mg">
                  <option value="Paracetamol 500mg">
                  <option value="Amoxicillin + Clavulanic Acid 625mg (Co-Amoxiclav)">
                  <option value="Mefenamic Acid 500mg">
                  <option value="Chlorhexidine 0.2% Mouthwash">
                  <option value="Ciprofloxacin 500mg">
                  <option value="Prednisolone 5mg">
                </datalist>

                <datalist id="commonFrequencies">
                  <option value="3 times daily (TDS / TID)">
                  <option value="2 times daily (BD / BID)">
                  <option value="Once daily (OD)">
                  <option value="4 times daily (QDS / QID)">
                  <option value="Every 6 hours">
                  <option value="Every 8 hours">
                  <option value="As needed for pain (PRN)">
                </datalist>

                <datalist id="commonInstructions">
                  <option value="Take after meals (after food)">
                  <option value="Take before meals (on empty stomach)">
                  <option value="Complete the full antibiotic course">
                  <option value="Dissolve mouthwash in warm water">
                  <option value="Do not drink water for 30 mins after rinse">
                </datalist>

                <div class="d-flex gap-2 justify-content-end border-top pt-3 mt-4">
                  <a href="${pageContext.request.contextPath}/patients?action=view&id=${patient.patientId}" class="btn btn-outline-secondary">
                    <i class="bi bi-x-circle"></i> Cancel
                  </a>
                  <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-circle-fill"></i> Save &amp; Print Prescription
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- Sidebar Summary -->
        <div class="col-lg-4">
          <div class="card mb-3">
            <div class="card-header bg-light">
              <i class="bi bi-person-fill text-primary"></i>
              <h6>Patient Folder Summary</h6>
            </div>
            <div class="card-body" style="font-size:.85rem;">
              <div class="mb-2"><strong>Patient Name:</strong> ${patient.fullName}</div>
              <div class="mb-2"><strong>Patient Number:</strong> <code>${patient.patientNumber}</code></div>
              <div class="mb-2"><strong>Gender:</strong> ${patient.gender}</div>
              <div class="mb-2"><strong>Age:</strong> ${patient.age} yrs</div>
              
              <!-- Allergy warning badge -->
              <c:choose>
                <c:when test="${not empty patient.allergies}">
                  <div class="alert alert-danger mt-3 mb-0 p-2 d-flex align-items-start gap-2">
                    <i class="bi bi-exclamation-triangle-fill fs-5 mt-1"></i>
                    <div>
                      <strong class="d-block" style="font-size:.75rem;text-transform:uppercase;">Drug Allergies:</strong>
                      <span class="fw-600"><c:out value="${patient.allergies}"/></span>
                    </div>
                  </div>
                </c:when>
                <c:otherwise>
                  <div class="alert alert-success mt-3 mb-0 p-2 text-success small">
                    <i class="bi bi-check-circle-fill me-1"></i> No known drug allergies reported.
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>

    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    const container = document.getElementById('drugListContainer');
    const addBtn    = document.getElementById('addDrugBtn');

    function updateRemoveButtons() {
      const rows = container.getElementsByClassName('drug-row');
      for (let i = 0; i < rows.length; i++) {
        const removeBtn = rows[i].querySelector('.btn-remove-row');
        removeBtn.style.display = rows.length > 1 ? 'block' : 'none';
      }
    }

    addBtn.addEventListener('click', function () {
      const rows = container.getElementsByClassName('drug-row');
      const clone = rows[0].cloneNode(true);
      
      // Clear values of inputs in clone
      const inputs = clone.getElementsByTagName('input');
      for (let input of inputs) {
        input.value = '';
      }
      
      container.appendChild(clone);
      updateRemoveButtons();
    });

    container.addEventListener('click', function (e) {
      if (e.target.closest('.btn-remove-row')) {
        const row = e.target.closest('.drug-row');
        const rows = container.getElementsByClassName('drug-row');
        if (rows.length > 1) {
          row.remove();
          updateRemoveButtons();
        }
      }
    });

    updateRemoveButtons();
  });
</script>
