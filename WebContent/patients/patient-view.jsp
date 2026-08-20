<%-- patients/patient-view.jsp — Patient Details & Medical History --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="${patient.fullName}"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle"><i class="bi bi-list fs-5"></i></button>
      <div>
        <div class="topbar-title">Patient Profile</div>
        <div class="topbar-subtitle">Patient: ${patient.fullName}</div>
      </div>
      <div class="topbar-right">
        <a href="${pageContext.request.contextPath}/patients?action=edit&id=${patient.patientId}" class="btn btn-primary btn-sm">
          <i class="bi bi-pencil-fill me-1"></i> Edit Profile
        </a>
        <a href="${pageContext.request.contextPath}/patients" class="btn btn-outline-secondary btn-sm">
          <i class="bi bi-arrow-left me-1"></i> Back to List
        </a>
      </div>
    </div>

    <div class="page-content">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/patients">Patients</a></li>
          <li class="breadcrumb-item active">${patient.fullName}</li>
        </ol>
      </nav>

      <!-- Message notifications -->
      <c:if test="${param.msg == 'saved'}">
        <div class="alert alert-success auto-dismiss"><i class="bi bi-check-circle-fill me-2"></i>Patient registered successfully.</div>
      </c:if>
      <c:if test="${param.msg == 'updated'}">
        <div class="alert alert-success auto-dismiss"><i class="bi bi-check-circle-fill me-2"></i>Patient profile updated.</div>
      </c:if>
      <c:if test="${param.msg == 'activated'}">
        <div class="alert alert-success auto-dismiss"><i class="bi bi-check-circle-fill me-2"></i>Patient account activated.</div>
      </c:if>

      <div class="row g-3">
        <!-- Profile summary card -->
        <div class="col-lg-4">
          <div class="card mb-3">
            <div class="card-body text-center py-4">
              <div class="avatar avatar-lg mx-auto mb-3" style="width:72px;height:72px;font-size:1.8rem;">
                ${patient.firstName.substring(0,1).toUpperCase()}${patient.lastName.substring(0,1).toUpperCase()}
              </div>
              <h5 class="fw-800 mb-1">${patient.fullName}</h5>
              <p class="text-muted mb-2"><code style="font-size:.85rem;">${patient.patientNumber}</code></p>
              <div class="mb-3">
                <c:choose>
                  <c:when test="${patient.status == 'ACTIVE'}">
                    <span class="badge bg-success">Active</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-secondary">Inactive</span>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="border-top pt-3 text-start">
                <div class="row g-2" style="font-size:.85rem;">
                  <div class="col-5 text-secondary fw-600">Gender:</div>
                  <div class="col-7 text-primary-custom fw-700">${patient.gender}</div>
                  
                  <div class="col-5 text-secondary fw-600">Date of Birth:</div>
                  <div class="col-7 text-primary-custom fw-700">
                    <c:choose>
                      <c:when test="${not empty patient.dateOfBirth}">
                        <fmt:parseDate value="${patient.dateOfBirth}" pattern="yyyy-MM-dd" var="dobParsed"/>
                        <fmt:formatDate value="${dobParsed}" pattern="dd MMM yyyy"/> (${patient.age} yrs)
                      </c:when>
                      <c:otherwise>Not Provided</c:otherwise>
                    </c:choose>
                  </div>

                  <div class="col-5 text-secondary fw-600">Blood Group:</div>
                  <div class="col-7">
                    <c:choose>
                      <c:when test="${not empty patient.bloodGroup}">
                        <span class="badge bg-danger">${patient.bloodGroup}</span>
                      </c:when>
                      <c:otherwise><span class="text-muted">Unknown</span></c:otherwise>
                    </c:choose>
                  </div>

                  <div class="col-5 text-secondary fw-600">Registered:</div>
                  <div class="col-7">
                    <fmt:formatDate value="${patient.registrationDateSql}" pattern="dd MMM yyyy"/>
                  </div>
                </div>
              </div>
            </div>
            <div class="card-footer d-flex gap-2">
              <c:choose>
                <c:when test="${patient.status == 'ACTIVE'}">
                  <form action="${pageContext.request.contextPath}/patients" method="POST" class="w-100">
                    <input type="hidden" name="action" value="deactivate"/>
                    <input type="hidden" name="id" value="${patient.patientId}"/>
                    <button type="submit" class="btn btn-outline-danger btn-sm w-100" data-confirm="Are you sure you want to deactivate this patient account?">
                      <i class="bi bi-person-dash-fill me-1"></i>Deactivate
                    </button>
                  </form>
                </c:when>
                <c:otherwise>
                  <form action="${pageContext.request.contextPath}/patients" method="POST" class="w-100">
                    <input type="hidden" name="action" value="activate"/>
                    <input type="hidden" name="id" value="${patient.patientId}"/>
                    <button type="submit" class="btn btn-outline-success btn-sm w-100">
                      <i class="bi bi-person-check-fill me-1"></i>Activate
                    </button>
                  </form>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

          <!-- Emergency Contact Panel -->
          <div class="card mb-3">
            <div class="card-header">
              <i class="bi bi-exclamation-triangle-fill text-warning"></i>
              <h6>Emergency Contact</h6>
            </div>
            <div class="card-body" style="font-size:.85rem;">
              <c:choose>
                <c:when test="${not empty patient.emergencyContactName}">
                  <div class="mb-2"><strong>Name:</strong> ${patient.emergencyContactName}</div>
                  <div class="mb-2"><strong>Phone:</strong> ${patient.emergencyContactPhone}</div>
                  <div><strong>Relationship:</strong> ${patient.emergencyContactRelation}</div>
                </c:when>
                <c:otherwise>
                  <p class="text-muted mb-0">No emergency contact registered.</p>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <!-- Contact & Medical details -->
        <div class="col-lg-8">
          <div class="card mb-3">
            <div class="card-header">
              <i class="bi bi-telephone-fill text-primary"></i>
              <h6>Contact Information &amp; Address</h6>
            </div>
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <div class="text-secondary fw-600 mb-1" style="font-size:.8rem;text-transform:uppercase;">Primary Phone</div>
                  <div class="fw-700 fs-5 text-primary-custom">${patient.contactNumber}</div>
                </div>
                <div class="col-md-6">
                  <div class="text-secondary fw-600 mb-1" style="font-size:.8rem;text-transform:uppercase;">Alternative Phone</div>
                  <div class="fw-700">${not empty patient.altContact ? patient.altContact : '—'}</div>
                </div>
                <div class="col-md-6">
                  <div class="text-secondary fw-600 mb-1" style="font-size:.8rem;text-transform:uppercase;">Email Address</div>
                  <div class="fw-700">${not empty patient.email ? patient.email : '—'}</div>
                </div>
                <div class="col-md-6">
                  <div class="text-secondary fw-600 mb-1" style="font-size:.8rem;text-transform:uppercase;">Residential Address</div>
                  <div class="fw-700">${not empty patient.address ? patient.address.concat(', ').concat(patient.city) : '—'}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Medical records panel -->
          <div class="card mb-3">
            <div class="card-header justify-content-between">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-clipboard2-pulse-fill text-danger"></i>
                <h6>Medical Alert &amp; Notes</h6>
              </div>
              <c:if test="${sessionScope.role == 'DENTIST' || sessionScope.role == 'ADMIN'}">
                <button type="button" class="btn btn-sm btn-outline-danger" data-bs-toggle="modal" data-bs-target="#editNotesModal">
                  <i class="bi bi-pencil-square"></i> Update Notes
                </button>
              </c:if>
            </div>
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <div class="text-danger fw-700 mb-2" style="font-size:.85rem;text-transform:uppercase;">
                    <i class="bi bi-exclamation-octagon-fill"></i> Drug &amp; Material Allergies
                  </div>
                  <div class="p-3 bg-light rounded text-dark fw-600" style="min-height:80px;font-size:.9rem;border-left:4px solid var(--danger);">
                    <c:choose>
                      <c:when test="${not empty patient.allergies}"><c:out value="${patient.allergies}"/></c:when>
                      <c:otherwise><span class="text-muted">No known allergies reported.</span></c:otherwise>
                    </c:choose>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="text-secondary fw-700 mb-2" style="font-size:.85rem;text-transform:uppercase;">
                    <i class="bi bi-card-text"></i> Clinical &amp; Treatment Notes
                  </div>
                  <div class="p-3 bg-light rounded text-dark" style="min-height:80px;font-size:.9rem;border-left:4px solid var(--primary);">
                    <c:choose>
                      <c:when test="${not empty patient.medicalNotes}"><c:out value="${patient.medicalNotes}"/></c:when>
                      <c:otherwise><span class="text-muted">No clinical notes available.</span></c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- E-Prescriptions History -->
          <div class="card mb-3">
            <div class="card-header bg-white d-flex justify-content-between align-items-center py-2">
              <div>
                <i class="bi bi-capsule-pill text-success fs-5"></i>
                <h6 class="d-inline-block ms-2 mb-0">E-Prescription History</h6>
              </div>
              <a href="${pageContext.request.contextPath}/prescriptions?action=new&patientId=${patient.patientId}" class="btn btn-sm btn-outline-success">
                <i class="bi bi-prescription"></i> Write New Prescription
              </a>
            </div>
            <div class="card-body p-0">
              <c:choose>
                <c:when test="${empty prescriptions}">
                  <div class="text-center py-4 text-muted">
                    <i class="bi bi-capsule-pill d-block fs-3 mb-2" style="color:var(--text-muted);"></i>
                    <span>No prescriptions issued yet for this patient.</span>
                  </div>
                </c:when>
                <c:otherwise>
                  <div class="table-responsive">
                    <table class="table table-hover mb-0" style="font-size: .85rem;">
                      <thead>
                        <tr>
                          <th>Rx Number</th>
                          <th>Date Issued</th>
                          <th>Prescribed By</th>
                          <th>Remarks</th>
                          <th class="text-center">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        <c:forEach var="rx" items="${prescriptions}">
                          <tr>
                            <td><code class="fw-700">${rx.prescriptionNumber}</code></td>
                            <td><fmt:formatDate value="${rx.createdAtSql}" pattern="dd MMM yyyy"/></td>
                            <td>${rx.dentistName}</td>
                            <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                              ${empty rx.notes ? '—' : rx.notes}
                            </td>
                            <td class="text-center">
                              <a href="${pageContext.request.contextPath}/prescriptions?action=view&id=${rx.prescriptionId}" class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: .75rem;">
                                <i class="bi bi-printer-fill me-1"></i> Print Rx
                              </a>
                            </td>
                          </tr>
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

          <!-- Quick booking shortcut card -->
          <div class="card p-3 bg-light text-center border-dashed">
            <p class="mb-2 text-secondary fw-600">Need to schedule a treatment for this patient?</p>
            <div>
              <a href="${pageContext.request.contextPath}/appointments?action=new&patientId=${patient.patientId}" class="btn btn-success btn-sm">
                <i class="bi bi-calendar-plus-fill me-1"></i> Book New Appointment
              </a>
            </div>
          </div>

        </div>
      </div>

    </div>

    <!-- ===== UPDATE CLINICAL NOTES MODAL ===== -->
    <div class="modal fade" id="editNotesModal" tabindex="-1" aria-labelledby="editNotesModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="editNotesModalLabel"><i class="bi bi-clipboard2-pulse-fill text-danger me-2"></i>Update Clinical Records</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <form action="${pageContext.request.contextPath}/patients" method="POST" class="needs-validation" novalidate>
            <input type="hidden" name="action" value="updateNotes"/>
            <input type="hidden" name="id" value="${patient.patientId}"/>
            
            <div class="modal-body">
              <div class="mb-3">
                <label for="modalAllergies" class="form-label text-danger fw-700">
                  <i class="bi bi-exclamation-triangle-fill"></i> Drug &amp; Material Allergies
                </label>
                <textarea id="modalAllergies" name="allergies" class="form-control" rows="2" placeholder="List drug allergies, latex allergy, etc...">${patient.allergies}</textarea>
                <div class="form-text text-muted">Leave empty or type 'None' if the patient has no allergies.</div>
              </div>

              <div class="mb-3">
                <label for="modalMedicalNotes" class="form-label text-primary-custom fw-700">
                  <i class="bi bi-card-text"></i> Clinical &amp; Treatment Notes
                </label>
                
                <!-- Autotext Quick-Templates -->
                <div class="mb-2 p-2 bg-light rounded border">
                  <span class="small text-secondary fw-600 d-block mb-1">Click a clinical autotext template to insert:</span>
                  <div class="d-flex flex-wrap gap-1">
                    <button type="button" class="btn btn-xs btn-outline-primary py-1 px-2" style="font-size: 0.72rem;" onclick="insertClinicalTemplate('Scaling & root planing performed. Removed supragingival and subgingival calculus. Polished with pumice. Oral hygiene instructions given.')">
                      🦷 Scaling &amp; Polish
                    </button>
                    <button type="button" class="btn btn-xs btn-outline-primary py-1 px-2" style="font-size: 0.72rem;" onclick="insertClinicalTemplate('Prepared cavity, acid etched, bonded, light-cured composite resin restoration. Finished and polished. Checked occlusion.')">
                      💎 Composite Filling
                    </button>
                    <button type="button" class="btn btn-xs btn-outline-primary py-1 px-2" style="font-size: 0.72rem;" onclick="insertClinicalTemplate('Administered 1.8ml 2% Lidocaine local infiltration. Elevators and forceps used for extraction of tooth #__. Hemostasis achieved.')">
                      💉 Tooth Extraction
                    </button>
                    <button type="button" class="btn btn-xs btn-outline-primary py-1 px-2" style="font-size: 0.72rem;" onclick="insertClinicalTemplate('Accessed pulp chamber. Cleared, shaped, and obturated root canals. Placed temporary filling. Patient advised post-op instructions.')">
                      🔬 Root Canal Therapy
                    </button>
                  </div>
                </div>

                <textarea id="modalMedicalNotes" name="medicalNotes" class="form-control" rows="6" placeholder="Enter clinical notes or treatment logs here...">${patient.medicalNotes}</textarea>
              </div>
            </div>
            
            <div class="modal-footer bg-light">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
              <button type="submit" class="btn btn-danger">
                <i class="bi bi-check-circle-fill me-1"></i> Save Clinical Records
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Alert dismissal banner for notes update success -->
    <c:if test="${param.msg == 'notes_updated'}">
      <script>
        alert("Clinical records updated successfully.");
      </script>
    </c:if>

    <script>
      function insertClinicalTemplate(text) {
        const area = document.getElementById('modalMedicalNotes');
        if (area.value.trim() !== '') {
          area.value += "\n\n" + text;
        } else {
          area.value = text;
        }
        area.focus();
      }
    </script>

    <%@ include file="/WEB-INF/jspf/footer.jsp" %>
  </div>
</div>
