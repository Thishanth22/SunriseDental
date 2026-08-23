<%-- help/help.jsp — Help, Documentation & User Guide --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Help & System Guide"/>
<%@ include file="/WEB-INF/jspf/header.jsp" %>

<div class="app-wrapper">
  <%@ include file="/WEB-INF/jspf/sidebar.jsp" %>
  <div class="main-content">
    
    <!-- Topbar -->
    <div class="topbar">
      <button class="btn btn-sm btn-outline-secondary d-lg-none me-2" id="sidebarToggle">
        <i class="bi bi-list fs-5"></i>
      </button>
      <div>
        <div class="topbar-title">Help &amp; System Guide</div>
        <div class="topbar-subtitle">Operational guidelines, workflow tutorials, role permissions, and FAQs</div>
      </div>
      <div class="topbar-right">
        <button onclick="window.print()" class="btn btn-outline-secondary btn-sm me-2">
          <i class="bi bi-printer me-1"></i> Print Guide
        </button>
        <c:if test="${sessionScope.role == 'ADMIN' || sessionScope.role == 'RECEPTIONIST'}">
          <a href="${pageContext.request.contextPath}/appointments?action=new" class="btn btn-primary btn-sm">
            <i class="bi bi-calendar-plus-fill me-1"></i> Book Appointment
          </a>
        </c:if>
      </div>
    </div>

    <!-- Page Content -->
    <div class="page-content">

      <!-- Breadcrumbs -->
      <nav aria-label="breadcrumb" class="breadcrumb-nav mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
          <li class="breadcrumb-item active">Help &amp; Guide</li>
        </ol>
      </nav>

      <!-- Welcome Banner -->
      <div class="card mb-4 border-0 shadow-sm" style="background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); color: #fff; border-radius: 12px;">
        <div class="card-body p-4">
          <div class="row align-items-center">
            <div class="col-md-8">
              <span class="badge bg-white text-primary fw-bold px-3 py-1 mb-2" style="font-size: .75rem; letter-spacing: .5px;">KNOWLEDGE BASE &amp; SOP</span>
              <h3 class="fw-bold mb-2 text-white">Sunrise Dental Management System Guide</h3>
              <p class="mb-0 text-white-50" style="font-size: .95rem; line-height: 1.6;">
                Welcome to the official operating guide. Here you will find step-by-step instructions for clinical workflows, appointment scheduling with contact synchronization, billing lifecycle, and role-based operational permissions.
              </p>
            </div>
            <div class="col-md-4 text-md-end mt-3 mt-md-0">
              <div class="d-inline-flex align-items-center bg-white bg-opacity-10 border border-white border-opacity-25 rounded-3 p-3 text-start">
                <i class="bi bi-headset fs-2 text-white me-3"></i>
                <div>
                  <div class="text-white-50" style="font-size: .75rem; text-transform: uppercase;">Internal Clinic Helpdesk</div>
                  <div class="fw-bold text-white fs-6">+94 11 234 5678</div>
                  <div class="text-white-50" style="font-size: .75rem;">Ext: 104 (8:00 AM – 8:00 PM)</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Category Cards -->
      <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
          <a href="#section-appointments" class="text-decoration-none">
            <div class="card h-100 border-0 shadow-sm hover-elevate">
              <div class="card-body d-flex align-items-center p-3">
                <div class="rounded-3 p-3 bg-primary-subtle text-primary me-3">
                  <i class="bi bi-calendar-check-fill fs-4"></i>
                </div>
                <div>
                  <h6 class="fw-bold mb-1 text-dark">Appointments</h6>
                  <span class="text-muted" style="font-size: .8rem;">Booking, rescheduling, conflict checks</span>
                </div>
              </div>
            </div>
          </a>
        </div>
        <div class="col-sm-6 col-xl-3">
          <a href="#section-patients" class="text-decoration-none">
            <div class="card h-100 border-0 shadow-sm hover-elevate">
              <div class="card-body d-flex align-items-center p-3">
                <div class="rounded-3 p-3 bg-success-subtle text-success me-3">
                  <i class="bi bi-person-lines-fill fs-4"></i>
                </div>
                <div>
                  <h6 class="fw-bold mb-1 text-dark">Patients</h6>
                  <span class="text-muted" style="font-size: .8rem;">Registration, records &amp; history</span>
                </div>
              </div>
            </div>
          </a>
        </div>
        <div class="col-sm-6 col-xl-3">
          <a href="#section-billing" class="text-decoration-none">
            <div class="card h-100 border-0 shadow-sm hover-elevate">
              <div class="card-body d-flex align-items-center p-3">
                <div class="rounded-3 p-3 bg-warning-subtle text-warning me-3">
                  <i class="bi bi-receipt fs-4"></i>
                </div>
                <div>
                  <h6 class="fw-bold mb-1 text-dark">Billing &amp; Finance</h6>
                  <span class="text-muted" style="font-size: .8rem;">Invoicing, payments &amp; receipts</span>
                </div>
              </div>
            </div>
          </a>
        </div>
        <div class="col-sm-6 col-xl-3">
          <a href="#section-roles" class="text-decoration-none">
            <div class="card h-100 border-0 shadow-sm hover-elevate">
              <div class="card-body d-flex align-items-center p-3">
                <div class="rounded-3 p-3 bg-info-subtle text-info me-3">
                  <i class="bi bi-shield-check fs-4"></i>
                </div>
                <div>
                  <h6 class="fw-bold mb-1 text-dark">Roles &amp; Security</h6>
                  <span class="text-muted" style="font-size: .8rem;">Permissions matrix &amp; audit trails</span>
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>

      <!-- Core Clinical Workflow -->
      <div class="card mb-4 border-0 shadow-sm">
        <div class="card-header bg-white py-3">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-diagram-3-fill text-primary"></i>
            <h6 class="fw-bold mb-0">Clinic End-to-End Operational Workflow</h6>
          </div>
        </div>
        <div class="card-body">
          <div class="row g-4">
            <div class="col-md-4">
              <div class="p-3 border rounded-3 h-100 bg-light">
                <div class="d-flex align-items-center mb-2">
                  <span class="badge bg-primary rounded-pill me-2">Step 1</span>
                  <h6 class="fw-bold mb-0">Patient Check-in / Registration</h6>
                </div>
                <p class="text-muted mb-2" style="font-size: .85rem;">
                  Search if the patient already exists by NIC, name, or phone. If new, register them with complete name, date of birth, contact number, and address.
                </p>
                <div class="small text-primary fw-semibold"><i class="bi bi-arrow-right-circle me-1"></i> Patients &gt; Register Patient</div>
              </div>
            </div>

            <div class="col-md-4">
              <div class="p-3 border rounded-3 h-100 bg-light">
                <div class="d-flex align-items-center mb-2">
                  <span class="badge bg-primary rounded-pill me-2">Step 2</span>
                  <h6 class="fw-bold mb-0">Schedule Appointment</h6>
                </div>
                <p class="text-muted mb-2" style="font-size: .85rem;">
                  Select patient, dentist, treatment type, date &amp; time. <strong>Patient Phone &amp; Address auto-populate immediately</strong> and can be verified/updated on the spot. Real-time availability check prevents double-booking.
                </p>
                <div class="small text-primary fw-semibold"><i class="bi bi-arrow-right-circle me-1"></i> Appointments &gt; Book Appointment</div>
              </div>
            </div>

            <div class="col-md-4">
              <div class="p-3 border rounded-3 h-100 bg-light">
                <div class="d-flex align-items-center mb-2">
                  <span class="badge bg-primary rounded-pill me-2">Step 3</span>
                  <h6 class="fw-bold mb-0">Consultation &amp; Treatment</h6>
                </div>
                <p class="text-muted mb-2" style="font-size: .85rem;">
                  Dentist reviews patient history, performs the procedure, and issues an electronic prescription. Once done, receptionist or dentist marks the session as <strong>Completed</strong>.
                </p>
                <div class="small text-primary fw-semibold"><i class="bi bi-arrow-right-circle me-1"></i> Appointments &gt; View &gt; Complete</div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="p-3 border rounded-3 h-100 bg-light">
                <div class="d-flex align-items-center mb-2">
                  <span class="badge bg-success rounded-pill me-2">Step 4</span>
                  <h6 class="fw-bold mb-0">Invoice Generation</h6>
                </div>
                <p class="text-muted mb-2" style="font-size: .85rem;">
                  Click <em>Generate Invoice</em> directly from the completed appointment. The treatment fee, consultation charge, discounts, and taxes calculate automatically.
                </p>
                <div class="small text-success fw-semibold"><i class="bi bi-arrow-right-circle me-1"></i> Billing &gt; New Invoice</div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="p-3 border rounded-3 h-100 bg-light">
                <div class="d-flex align-items-center mb-2">
                  <span class="badge bg-success rounded-pill me-2">Step 5</span>
                  <h6 class="fw-bold mb-0">Payment Settlement &amp; Receipt</h6>
                </div>
                <p class="text-muted mb-2" style="font-size: .85rem;">
                  Accept settlement via Cash, Card, or Online Transfer. A printable tax receipt is generated instantly, and financial reports reflect the revenue in real-time.
                </p>
                <div class="small text-success fw-semibold"><i class="bi bi-arrow-right-circle me-1"></i> Billing &gt; Record Payment &gt; Print Receipt</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Section: Appointments & Contact Synchronization -->
      <div id="section-appointments" class="card mb-4 border-0 shadow-sm">
        <div class="card-header bg-white py-3">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-calendar-plus-fill text-primary"></i>
            <h6 class="fw-bold mb-0">Appointment Booking &amp; Patient Contact Details</h6>
          </div>
        </div>
        <div class="card-body">
          <div class="alert alert-info border-0 d-flex align-items-start gap-2 mb-3">
            <i class="bi bi-info-circle-fill fs-5 mt-1 text-info"></i>
            <div>
              <strong>Instant Contact Auto-Population &amp; Sync:</strong>
              When booking an appointment, choosing any patient from the dropdown automatically fills the <strong>Phone Number</strong> and <strong>Patient Address</strong> fields. If the patient has changed their contact number or moved to a new address, you can edit these fields directly on the booking form. The system will automatically update the patient's master record upon scheduling!
            </div>
          </div>

          <div class="table-responsive">
            <table class="table table-bordered table-sm align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th style="width: 25%;">Field</th>
                  <th style="width: 25%;">Source / Behavior</th>
                  <th>Clinical Best Practice</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><strong>Patient Phone Number</strong></td>
                  <td>Auto-filled from patient profile; editable</td>
                  <td>Used for SMS reminders and appointment confirmation calls. Ensure standard 10-digit format (e.g., <code>0771234567</code>).</td>
                </tr>
                <tr>
                  <td><strong>Patient Address</strong></td>
                  <td>Auto-filled from patient profile; editable</td>
                  <td>Ensures correspondence, invoices, and emergency dental records reflect current residential location.</td>
                </tr>
                <tr>
                  <td><strong>Conflict / Availability Status</strong></td>
                  <td>Real-time AJAX validation</td>
                  <td>Prevents double-booking. If the dentist has another overlapping appointment, the system alerts and disables the submit button until a free slot is selected.</td>
                </tr>
                <tr>
                  <td><strong>Priority Level</strong></td>
                  <td>Standard, Urgent, or Emergency</td>
                  <td>Flag severe toothaches, trauma, or bleeding as <em>Emergency</em> or <em>Urgent</em> for immediate triage.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Section: Role Permissions Matrix -->
      <div id="section-roles" class="card mb-4 border-0 shadow-sm">
        <div class="card-header bg-white py-3">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-shield-lock-fill text-primary"></i>
            <h6 class="fw-bold mb-0">Role Permissions &amp; Access Control Matrix</h6>
          </div>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" style="font-size: .88rem;">
              <thead class="table-light">
                <tr>
                  <th>Feature / Action</th>
                  <th class="text-center" style="width: 18%;">Administrator</th>
                  <th class="text-center" style="width: 18%;">Receptionist</th>
                  <th class="text-center" style="width: 18%;">Dentist</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Dashboard &amp; Overview KPIs</td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Full Clinic</span></td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Full Clinic</span></td>
                  <td class="text-center"><span class="badge bg-primary"><i class="bi bi-check-lg"></i> Personal Schedule</span></td>
                </tr>
                <tr>
                  <td>Register &amp; Manage Patients</td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Yes</span></td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Yes</span></td>
                  <td class="text-center"><span class="badge bg-secondary"><i class="bi bi-eye"></i> View Profile</span></td>
                </tr>
                <tr>
                  <td>Book, Reschedule &amp; Cancel Appointments</td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Yes</span></td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Yes</span></td>
                  <td class="text-center"><span class="badge bg-secondary"><i class="bi bi-eye"></i> View &amp; Complete</span></td>
                </tr>
                <tr>
                  <td>Electronic Prescriptions</td>
                  <td class="text-center"><span class="badge bg-secondary"><i class="bi bi-eye"></i> View Only</span></td>
                  <td class="text-center"><span class="badge bg-secondary"><i class="bi bi-eye"></i> View Only</span></td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Create &amp; Sign</span></td>
                </tr>
                <tr>
                  <td>Billing, Invoices &amp; Payments</td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Full Control</span></td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Issue &amp; Collect</span></td>
                  <td class="text-center"><span class="badge bg-light text-muted"><i class="bi bi-x-lg"></i> Restricted</span></td>
                </tr>
                <tr>
                  <td>Financial Reports &amp; Analytics</td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Full Access</span></td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Daily Reports</span></td>
                  <td class="text-center"><span class="badge bg-light text-muted"><i class="bi bi-x-lg"></i> Restricted</span></td>
                </tr>
                <tr>
                  <td>User Management &amp; System Audit Logs</td>
                  <td class="text-center"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Yes</span></td>
                  <td class="text-center"><span class="badge bg-light text-muted"><i class="bi bi-x-lg"></i> Restricted</span></td>
                  <td class="text-center"><span class="badge bg-light text-muted"><i class="bi bi-x-lg"></i> Restricted</span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Section: Frequently Asked Questions (FAQ) -->
      <div class="card mb-4 border-0 shadow-sm">
        <div class="card-header bg-white py-3">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-patch-question-fill text-primary"></i>
            <h6 class="fw-bold mb-0">Frequently Asked Questions (FAQ)</h6>
          </div>
        </div>
        <div class="card-body">
          <div class="accordion" id="helpFaqAccordion">
            
            <div class="accordion-item border-0 mb-2 rounded-3 shadow-xs">
              <h2 class="accordion-header" id="faqHeading1">
                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse1">
                  1. How does the double-booking prevention system work?
                </button>
              </h2>
              <div id="faqCollapse1" class="accordion-collapse collapse" data-bs-parent="#helpFaqAccordion">
                <div class="accordion-body text-secondary" style="font-size: .9rem;">
                  Whenever you select a dentist, date, time slot, and treatment duration in the <em>Book Appointment</em> form, an automated AJAX check queries the database for existing scheduled or confirmed appointments for that dentist. If there is any time overlap, the system flags a warning banner and disables the submission button until a free time is picked.
                </div>
              </div>
            </div>

            <div class="accordion-item border-0 mb-2 rounded-3 shadow-xs">
              <h2 class="accordion-header" id="faqHeading2">
                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse2">
                  2. Can I change the patient's phone number or address when scheduling?
                </button>
              </h2>
              <div id="faqCollapse2" class="accordion-collapse collapse" data-bs-parent="#helpFaqAccordion">
                <div class="accordion-body text-secondary" style="font-size: .9rem;">
                  Yes! The booking form pre-fills the patient's existing phone number and address as soon as you choose them. If the patient informs you that they have a new mobile number or a new home address, you can simply type the updated details in the form. Upon saving the appointment, the master patient directory is synchronized automatically without requiring a separate visit to the patient profile.
                </div>
              </div>
            </div>

            <div class="accordion-item border-0 mb-2 rounded-3 shadow-xs">
              <h2 class="accordion-header" id="faqHeading3">
                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse3">
                  3. How do I generate an invoice after treatment is finished?
                </button>
              </h2>
              <div id="faqCollapse3" class="accordion-collapse collapse" data-bs-parent="#helpFaqAccordion">
                <div class="accordion-body text-secondary" style="font-size: .9rem;">
                  Once the appointment session is marked as <strong>Complete</strong>, an emerald button titled <em>Generate Invoice/Bill</em> appears on the appointment summary page. Clicking this automatically carries over the patient details, treatment items, and doctor charges to the billing form for instant settlement.
                </div>
              </div>
            </div>

            <div class="accordion-item border-0 mb-2 rounded-3 shadow-xs">
              <h2 class="accordion-header" id="faqHeading4">
                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse4">
                  4. What should I do if a patient fails to show up or cancels?
                </button>
              </h2>
              <div id="faqCollapse4" class="accordion-collapse collapse" data-bs-parent="#helpFaqAccordion">
                <div class="accordion-body text-secondary" style="font-size: .9rem;">
                  Open the appointment record and click either <em>Cancel Appointment</em> (entering a cancellation reason) or <em>Mark No Show</em>. This immediately releases the dentist's time slot for emergency walk-ins while recording the cancellation statistic for clinic auditing.
                </div>
              </div>
            </div>

            <div class="accordion-item border-0 mb-2 rounded-3 shadow-xs">
              <h2 class="accordion-header" id="faqHeading5">
                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse5">
                  5. How can a dentist see only their assigned patients?
                </button>
              </h2>
              <div id="faqCollapse5" class="accordion-collapse collapse" data-bs-parent="#helpFaqAccordion">
                <div class="accordion-body text-secondary" style="font-size: .9rem;">
                  When logging in with a <strong>DENTIST</strong> account, the dashboard automatically adapts to display your personal schedule for today, the count of appointments waiting for you, and your completed treatments, rather than clinic-wide administrative metrics.
                </div>
              </div>
            </div>

            <div class="accordion-item border-0 mb-2 rounded-3 shadow-xs">
              <h2 class="accordion-header" id="faqHeading6">
                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faqCollapse6">
                  6. Where are administrative security logs kept?
                </button>
              </h2>
              <div id="faqCollapse6" class="accordion-collapse collapse" data-bs-parent="#helpFaqAccordion">
                <div class="accordion-body text-secondary" style="font-size: .9rem;">
                  Administrators can navigate to <strong>Administration &gt; Audit Logs</strong> to inspect full chronological logs of logins, patient updates, appointment cancellations, and financial transactions, including IP addresses and timestamps.
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>

      <!-- Support & Helpdesk Card -->
      <div class="card border-0 shadow-sm">
        <div class="card-body p-4">
          <div class="row g-4 align-items-center">
            <div class="col-lg-8">
              <h5 class="fw-bold text-dark mb-1">Still need technical assistance?</h5>
              <p class="text-muted mb-3" style="font-size: .9rem;">
                If you encounter any database errors, printer configuration difficulties, or need to create a new staff account, contact our internal clinic technical administrator.
              </p>
              <div class="d-flex flex-wrap gap-4" style="font-size: .85rem;">
                <div>
                  <span class="text-muted d-block">IT Support Email:</span>
                  <strong class="text-dark">support@sunrisedental.local</strong>
                </div>
                <div>
                  <span class="text-muted d-block">Direct Telephone:</span>
                  <strong class="text-dark">+94 11 234 5678 (Ext 104)</strong>
                </div>
                <div>
                  <span class="text-muted d-block">Clinic Software Version:</span>
                  <strong class="text-dark">Sunrise Dental Enterprise v1.0.0</strong>
                </div>
              </div>
            </div>
            <div class="col-lg-4 text-lg-end">
              <a href="mailto:support@sunrisedental.local" class="btn btn-primary px-4 py-2">
                <i class="bi bi-envelope-fill me-1"></i> Contact IT Support
              </a>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</div>

<%@ include file="/WEB-INF/jspf/footer.jsp" %>
