<%-- footer.jsp — Shared page footer with scripts --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

  <!-- ===== FOOTER ===== -->
  <footer class="text-center py-3 mt-auto no-print"
          style="font-size:.75rem;color:var(--text-muted);border-top:1px solid var(--border);background:var(--surface);">
    &copy; 2026 Sunrise Dental Clinic Management System &mdash; All rights reserved.
  </footer>

  <!-- Bootstrap 5 JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <!-- Chart.js (for dashboard) -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <!-- App JS -->
  <script src="${pageContext.request.contextPath}/js/app.js"></script>

  <%-- Page-specific inline script placeholder --%>
  <c:if test="${not empty pageScript}">
    <script>${pageScript}</script>
  </c:if>

</body>
</html>
