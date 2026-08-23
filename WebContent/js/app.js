/**
 * app.js — Sunrise Dental Clinic — Main JavaScript
 * ===================================================
 * Handles:
 *   - Alert auto-dismiss
 *   - Sidebar mobile toggle
 *   - Form validation (client-side, level 1)
 *   - Double-booking AJAX check
 *   - Confirmation dialogs
 *   - DataTables init
 *   - Chart.js dashboard charts
 *   - Phone number formatting
 *   - Search debounce
 *   - Print receipts
 *   - General UI enhancements
 */

'use strict';

// =========================================================
// 1. DOCUMENT READY
// =========================================================
document.addEventListener('DOMContentLoaded', function () {
  initAlertDismiss();
  initSidebarToggle();
  initFormValidation();
  initConfirmDialogs();
  initAppointmentForm();
  initSearchDebounce();
  initPhoneFormatter();
  initTooltips();
  highlightActiveSidebarLink();
  initDashboardCharts();
});

// =========================================================
// 2. ALERT AUTO-DISMISS (5 seconds)
// =========================================================
function initAlertDismiss() {
  const alerts = document.querySelectorAll('.alert.auto-dismiss');
  alerts.forEach(function (alert) {
    setTimeout(function () {
      alert.style.opacity = '0';
      alert.style.transition = 'opacity .5s ease';
      setTimeout(function () { alert.remove(); }, 500);
    }, 5000);
  });
}

// =========================================================
// 3. SIDEBAR MOBILE TOGGLE
// =========================================================
function initSidebarToggle() {
  const toggleBtn = document.getElementById('sidebarToggle');
  const sidebar   = document.querySelector('.sidebar');
  const overlay   = document.getElementById('sidebarOverlay');

  if (toggleBtn && sidebar) {
    toggleBtn.addEventListener('click', function () {
      sidebar.classList.toggle('open');
      if (overlay) overlay.classList.toggle('active');
    });
  }
  if (overlay) {
    overlay.addEventListener('click', function () {
      if (sidebar) sidebar.classList.remove('open');
      overlay.classList.remove('active');
    });
  }
}

// =========================================================
// 4. SIDEBAR ACTIVE LINK HIGHLIGHT
// =========================================================
function highlightActiveSidebarLink() {
  const path = window.location.pathname;
  document.querySelectorAll('.sidebar-link').forEach(function (link) {
    const href = link.getAttribute('href');
    if (href && path.includes(href.split('?')[0])) {
      link.classList.add('active');
    }
  });
}

// =========================================================
// 5. FORM VALIDATION — Client-Side (Level 1)
// =========================================================
function initFormValidation() {
  // Bootstrap 5 form validation
  const forms = document.querySelectorAll('.needs-validation');
  forms.forEach(function (form) {
    form.addEventListener('submit', function (e) {
      if (!form.checkValidity()) {
        e.preventDefault();
        e.stopPropagation();
        // Scroll to first invalid field
        const firstInvalid = form.querySelector(':invalid');
        if (firstInvalid) {
          firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
          firstInvalid.focus();
        }
      }
      form.classList.add('was-validated');
    }, false);
  });
}

// =========================================================
// 6. CONFIRMATION DIALOGS
// =========================================================
function initConfirmDialogs() {
  document.querySelectorAll('[data-confirm]').forEach(function (el) {
    el.addEventListener('click', function (e) {
      const message = el.getAttribute('data-confirm') || 'Are you sure?';
      if (!confirm(message)) {
        e.preventDefault();
        e.stopPropagation();
      }
    });
  });
}

// =========================================================
// 7. APPOINTMENT FORM — AJAX AVAILABILITY CHECK
// =========================================================
function initAppointmentForm() {
  const patientSel   = document.getElementById('patientId');
  const phoneInput   = document.getElementById('patientPhone');
  const addrInput    = document.getElementById('patientAddress');
  const dentistSel   = document.getElementById('dentistId');
  const dateSel      = document.getElementById('appointmentDate');
  const timeSel      = document.getElementById('appointmentTime');
  const treatSel     = document.getElementById('treatmentId');
  const availStatus  = document.getElementById('availabilityStatus');
  const submitBtn    = document.getElementById('apptSubmitBtn');
  const excludeIdEl  = document.getElementById('excludeId');
  const schedBadge   = document.getElementById('dentistScheduleBadge');
  const dateBadge    = document.getElementById('dateAvailabilityBadge');
  const timeGuidance = document.getElementById('timeGuidance');
  const contextPath  = document.querySelector('meta[name="contextPath"]')?.content || '';

  if (!dentistSel || !dateSel || !timeSel) return;

  function syncPatientFields() {
    if (!patientSel) return;
    const opt = patientSel.options[patientSel.selectedIndex];
    if (opt && opt.value) {
      if (phoneInput && !phoneInput.value) phoneInput.value = opt.getAttribute('data-phone') || '';
      if (addrInput && !addrInput.value)   addrInput.value  = opt.getAttribute('data-address') || '';
    }
  }

  // Initial sync on load (e.g. if patientId was pre-selected from URL)
  syncPatientFields();
  if (patientSel) {
    patientSel.addEventListener('change', function () {
      const opt = patientSel.options[patientSel.selectedIndex];
      if (opt && opt.value) {
        if (phoneInput) phoneInput.value = opt.getAttribute('data-phone') || '';
        if (addrInput)  addrInput.value  = opt.getAttribute('data-address') || '';
      }
      checkAvailability();
    });
  }

  const dayMap = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
  const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  function updateDentistSchedule() {
    const opt = dentistSel.options[dentistSel.selectedIndex];
    if (!opt || !opt.value) {
      if (schedBadge) schedBadge.textContent = '';
      if (dateBadge)  dateBadge.textContent = '';
      if (timeGuidance) timeGuidance.textContent = '';
      timeSel.removeAttribute('min');
      timeSel.removeAttribute('max');
      return true;
    }

    const start = opt.getAttribute('data-start') || '';
    const end   = opt.getAttribute('data-end') || '';
    const days  = opt.getAttribute('data-days') || '';

    if (schedBadge) {
      schedBadge.innerHTML = '<i class="bi bi-clock-fill me-1 text-primary"></i>' +
        'Shift: <strong>' + (start ? start.substring(0, 5) : 'N/A') + ' - ' + (end ? end.substring(0, 5) : 'N/A') + '</strong> ' +
        '<span class="text-muted ms-2"><i class="bi bi-calendar-check me-1"></i>Days: ' + days + '</span>';
    }

    if (start) timeSel.min = start.substring(0, 5);
    if (end)   timeSel.max = end.substring(0, 5);
    if (timeGuidance && start && end) {
      timeGuidance.textContent = 'Shift: ' + start.substring(0, 5) + ' to ' + end.substring(0, 5);
    }

    // Check date against dentist's day-of-week availability
    if (dateSel.value) {
      const parts = dateSel.value.split('-');
      if (parts.length === 3) {
        const dObj = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
        const dayIdx = dObj.getDay();
        const attrKey = 'data-' + dayMap[dayIdx];
        const isAvail = opt.getAttribute(attrKey) === 'true' || opt.getAttribute(attrKey) === '1';

        if (!isAvail) {
          if (dateBadge) {
            dateBadge.innerHTML = '<span class="text-danger fw-semibold"><i class="bi bi-exclamation-triangle-fill me-1"></i>Not in clinic on ' +
              dayNames[dayIdx] + 's. Available: ' + days + '</span>';
          }
          if (availStatus) {
            availStatus.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle-fill me-1"></i>Selected dentist is not in clinic on ' +
              dayNames[dayIdx] + 's. Please choose another date (' + days + ').</span>';
          }
          if (submitBtn) submitBtn.disabled = true;
          return false;
        } else {
          if (dateBadge) dateBadge.innerHTML = '<span class="text-success"><i class="bi bi-check-circle-fill me-1"></i>Dentist available on ' + dayNames[dayIdx] + 's</span>';
        }
      }
    }
    return true;
  }

  let checkTimeout = null;

  function checkAvailability() {
    const isDayValid = updateDentistSchedule();
    if (!isDayValid) return;

    const dId     = dentistSel.value;
    const date    = dateSel.value;
    const time    = timeSel.value;
    const treatId = treatSel ? treatSel.value : '';
    const pId     = patientSel ? patientSel.value : '';
    const exclId  = excludeIdEl ? excludeIdEl.value : '0';

    if (!dId || !date || !time) return;

    if (availStatus) {
      availStatus.innerHTML = '<span class="text-muted"><i class="bi bi-hourglass-split"></i> Checking availability...</span>';
    }

    const url = contextPath + '/appointments?action=check-availability' +
      '&dentistId='  + encodeURIComponent(dId) +
      '&patientId='  + encodeURIComponent(pId) +
      '&date='       + encodeURIComponent(date) +
      '&time='       + encodeURIComponent(time) +
      '&treatmentId='+ encodeURIComponent(treatId) +
      '&excludeId='  + encodeURIComponent(exclId);

    fetch(url, { headers: { 'Accept': 'application/json' } })
      .then(function (resp) { return resp.json(); })
      .then(function (data) {
        if (availStatus) {
          if (data.available) {
            availStatus.innerHTML =
              '<span class="text-success fw-semibold"><i class="bi bi-check-circle-fill me-1"></i>' +
              data.message + '</span>';
            if (submitBtn) submitBtn.disabled = false;
          } else {
            availStatus.innerHTML =
              '<span class="text-danger fw-semibold"><i class="bi bi-x-circle-fill me-1"></i>' +
              data.message + '</span>';
            if (submitBtn) submitBtn.disabled = true;
          }
        }
      })
      .catch(function () {
        if (availStatus) {
          availStatus.innerHTML =
            '<span class="text-warning"><i class="bi bi-exclamation-triangle me-1"></i> Unable to verify availability.</span>';
        }
      });
  }

  // Initial schedule badge if dentist is selected
  updateDentistSchedule();

  [dentistSel, dateSel, timeSel].forEach(function (el) {
    if (!el) return;
    el.addEventListener('change', function () {
      clearTimeout(checkTimeout);
      checkTimeout = setTimeout(checkAvailability, 300);
    });
  });

  if (treatSel) {
    treatSel.addEventListener('change', function () {
      clearTimeout(checkTimeout);
      checkTimeout = setTimeout(checkAvailability, 300);

      // Show duration & cost
      const option = treatSel.options[treatSel.selectedIndex];
      const dur    = option ? option.getAttribute('data-duration') : '';
      const durEl  = document.getElementById('treatmentDuration');
      if (durEl && dur) durEl.textContent = 'Estimated duration: ' + dur + ' minutes';
    });
  }
}

// =========================================================
// 8. SEARCH DEBOUNCE — Auto-submit search form
// =========================================================
function initSearchDebounce() {
  const searchInput = document.querySelector('.search-auto-submit');
  if (!searchInput) return;
  let timeout = null;
  searchInput.addEventListener('input', function () {
    clearTimeout(timeout);
    timeout = setTimeout(function () {
      searchInput.closest('form').submit();
    }, 500);
  });
}

// =========================================================
// 9. PHONE NUMBER FORMATTER — Sri Lankan format
// =========================================================
function initPhoneFormatter() {
  document.querySelectorAll('input[data-phone]').forEach(function (input) {
    input.addEventListener('input', function () {
      // Allow only digits
      let value = input.value.replace(/\D/g, '');
      // Limit to 10 digits
      if (value.length > 10) value = value.substring(0, 10);
      input.value = value;

      // Validation indicator
      if (value.length === 10 && /^0[1-9]/.test(value)) {
        input.classList.remove('is-invalid');
        input.classList.add('is-valid');
      } else if (value.length > 0) {
        input.classList.remove('is-valid');
        if (value.length === 10) input.classList.add('is-invalid');
      }
    });
  });
}

// =========================================================
// 10. BOOTSTRAP TOOLTIPS
// =========================================================
function initTooltips() {
  if (typeof bootstrap !== 'undefined' && bootstrap.Tooltip) {
    document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (el) {
      new bootstrap.Tooltip(el, { trigger: 'hover' });
    });
  }
}

// =========================================================
// 11. DASHBOARD CHARTS (Chart.js)
// =========================================================
function initDashboardCharts() {

  // -- Appointments Chart (line) --
  const apptCtx = document.getElementById('appointmentsChart');
  if (apptCtx) {
    const apptData = window.dashboardData && window.dashboardData.appointments;
    if (apptData) {
      new Chart(apptCtx, {
        type: 'bar',
        data: {
          labels: apptData.labels || [],
          datasets: [{
            label: 'Appointments',
            data:  apptData.values || [],
            backgroundColor: 'rgba(37,99,235,.15)',
            borderColor:     'rgba(37,99,235,1)',
            borderWidth: 2,
            borderRadius: 6,
            borderSkipped: false
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false },
            tooltip: { mode: 'index' }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: { stepSize: 1 },
              grid: { color: 'rgba(0,0,0,.05)' }
            },
            x: { grid: { display: false } }
          }
        }
      });
    }
  }

  // -- Revenue Chart (line) --
  const revCtx = document.getElementById('revenueChart');
  if (revCtx) {
    const revData = window.dashboardData && window.dashboardData.revenue;
    if (revData) {
      new Chart(revCtx, {
        type: 'line',
        data: {
          labels: revData.labels || [],
          datasets: [{
            label: 'Revenue (LKR)',
            data:  revData.values || [],
            backgroundColor: 'rgba(5,150,105,.08)',
            borderColor:     'rgba(5,150,105,1)',
            borderWidth: 2.5,
            pointBackgroundColor: 'rgba(5,150,105,1)',
            pointRadius: 4,
            tension: 0.4,
            fill: true
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: false },
            tooltip: {
              callbacks: {
                label: function (ctx) {
                  return 'LKR ' + Number(ctx.raw).toLocaleString();
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              grid: { color: 'rgba(0,0,0,.05)' },
              ticks: {
                callback: function (v) {
                  return 'LKR ' + (v >= 1000 ? (v/1000)+'k' : v);
                }
              }
            },
            x: { grid: { display: false } }
          }
        }
      });
    }
  }

  // -- Appointment Status Donut --
  const statusCtx = document.getElementById('statusChart');
  if (statusCtx && window.dashboardData && window.dashboardData.statusData) {
    const d = window.dashboardData.statusData;
    new Chart(statusCtx, {
      type: 'doughnut',
      data: {
        labels: d.labels,
        datasets: [{
          data: d.values,
          backgroundColor: ['#2563eb','#059669','#d97706','#dc2626','#64748b'],
          borderWidth: 0,
          hoverOffset: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '70%',
        plugins: { legend: { position: 'right', labels: { boxWidth: 12, padding: 12 } } }
      }
    });
  }
}

// =========================================================
// 12. PRINT RECEIPT
// =========================================================
function printReceipt() {
  window.print();
}

// =========================================================
// 13. UTILITY FUNCTIONS
// =========================================================

/** Format a number as currency string (LKR). */
function formatCurrency(amount) {
  return 'LKR ' + Number(amount).toLocaleString('en-LK', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

/** Get URL query parameter value. */
function getParam(name) {
  const url = new URL(window.location.href);
  return url.searchParams.get(name);
}

/** Show a toast notification. */
function showToast(message, type) {
  type = type || 'info';
  const toast = document.createElement('div');
  toast.className = 'alert alert-' + type + ' position-fixed bottom-0 end-0 m-3 auto-dismiss';
  toast.style.zIndex = '9999';
  toast.style.maxWidth = '360px';
  toast.style.boxShadow = '0 4px 16px rgba(0,0,0,.15)';
  toast.innerHTML = '<i class="bi bi-info-circle-fill"></i> ' + message;
  document.body.appendChild(toast);
  setTimeout(function () {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity .4s';
    setTimeout(function () { toast.remove(); }, 400);
  }, 4000);
}

/** Toggle loading state on a button. */
function setButtonLoading(btn, loading) {
  if (!btn) return;
  if (loading) {
    btn.dataset.originalText = btn.innerHTML;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processing...';
    btn.disabled = true;
  } else {
    btn.innerHTML = btn.dataset.originalText || 'Submit';
    btn.disabled = false;
  }
}

/** Forms with class 'form-with-loading' show spinner on submit. */
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.form-with-loading').forEach(function (form) {
    form.addEventListener('submit', function () {
      const btn = form.querySelector('[type="submit"]');
      setButtonLoading(btn, true);
    });
  });
});
