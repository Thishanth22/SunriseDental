<%-- treatments/treatment-form.jsp — Add / Edit Treatment --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty treatment && treatment.treatmentId > 0}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Treatment' : 'Add Treatment'}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">${isEdit ? 'Edit Treatment details' : 'Add New Treatment to Catalog'}</div>
        <div class="topbar-subtitle">Configure treatment catalog pricing, category &amp; default session minutes</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/treatments" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i>Back
        </a>
      </div>
    </div>

    <div class="page-content">
      <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-circle-fill me-2"></i>${error}</div>
      </c:if>

      <form action="${pageContext.request.contextPath}/treatments"
            method="POST"
            class="needs-validation form-with-loading"
            novalidate>
        
        <input type="hidden" name="action" value="${isEdit ? 'update' : 'save'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="treatmentId" value="${treatment.treatmentId}"/>
        </c:if>

        <div class="row g-3">
          <div class="col-lg-8">
            <div class="card mb-3">
              <div class="card-header">
                <i class="bi bi-capsule-pill text-primary"></i>
                <h6>Catalog Service configuration</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label class="form-label" for="treatmentCode">Treatment Code <span class="text-danger">*</span></label>
                    <input type="text" id="treatmentCode" name="treatmentCode" class="form-control" value="${treatment.treatmentCode}" required maxlength="10" placeholder="e.g. TR-EXT-01" ${isEdit ? 'readonly class="bg-light"' : ''}/>
                    <div class="form-text">Unique code identifier for clinical itemized billing mapping.</div>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="treatmentName">Treatment Name <span class="text-danger">*</span></label>
                    <input type="text" id="treatmentName" name="treatmentName" class="form-control" value="${treatment.treatmentName}" required maxlength="100" placeholder="e.g. Simple Extraction"/>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="category">Category <span class="text-danger">*</span></label>
                    <select id="category" name="category" class="form-select" required>
                      <option value="">-- Select Category --</option>
                      <option value="DIAGNOSTIC"   ${treatment.category == 'DIAGNOSTIC'   ? 'selected' : ''}>Diagnostic (X-Ray, Consult)</option>
                      <option value="PREVENTIVE"   ${treatment.category == 'PREVENTIVE'   ? 'selected' : ''}>Preventive (Cleaning, Sealant)</option>
                      <option value="RESTORATIVE"  ${treatment.category == 'RESTORATIVE'  ? 'selected' : ''}>Restorative (Fillings, Crowns)</option>
                      <option value="SURGICAL"     ${treatment.category == 'SURGICAL'     ? 'selected' : ''}>Surgical (Extraction, Implant)</option>
                      <option value="ORTHODONTIC"  ${treatment.category == 'ORTHODONTIC'  ? 'selected' : ''}>Orthodontic (Braces)</option>
                      <option value="COSMETIC"     ${treatment.category == 'COSMETIC'     ? 'selected' : ''}>Cosmetic (Bleaching, Veneers)</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="baseCost">Base Cost (LKR) <span class="text-danger">*</span></label>
                    <input type="number" id="baseCost" name="baseCost" class="form-control" value="${treatment.baseCost}" required min="0" step="100" placeholder="0.00"/>
                    <div class="form-text">Standard list fee. Invoices automatically fetch this value.</div>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="durationMins">Default Session Duration (Mins) <span class="text-danger">*</span></label>
                    <input type="number" id="durationMins" name="durationMins" class="form-control" value="${treatment.durationMins != null ? treatment.durationMins : 30}" required min="10" max="240" step="5"/>
                    <div class="form-text">Used for double-booking conflict schedule validation checks.</div>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label" for="status">Catalog Status</label>
                    <select id="status" name="status" class="form-select">
                      <option value="ACTIVE"       ${treatment.status == 'ACTIVE'       ? 'selected' : ''}>Active</option>
                      <option value="DISCONTINUED" ${treatment.status == 'DISCONTINUED' ? 'selected' : ''}>Discontinued</option>
                    </select>
                  </div>
                  <div class="col-12">
                    <div class="form-check mt-2">
                      <input class="form-check-input" type="checkbox" id="requiresFollowup" name="requiresFollowup" ${treatment.requiresFollowup ? 'checked' : ''}/>
                      <label class="form-check-label" for="requiresFollowup">Requires follow-up check-ups</label>
                    </div>
                  </div>
                  <div class="col-12">
                    <label class="form-label" for="description">Treatment Catalog Description</label>
                    <textarea id="description" name="description" class="form-control" rows="3" maxlength="500" placeholder="Explain details of clinical procedure &amp; exclusions...">${treatment.description}</textarea>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="d-flex gap-2 justify-content-end mt-2">
          <a href="${pageContext.request.contextPath}/treatments" class="btn btn-outline-secondary">Cancel</a>
          <button type="submit" class="btn btn-primary">${isEdit ? 'Update Entry' : 'Add Service'}</button>
        </div>

      </form>
    </div>
    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
