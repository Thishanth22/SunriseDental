<%-- header.jsp — Shared HTML head section --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="robots" content="noindex, nofollow"/>
  <meta name="contextPath" content="${pageContext.request.contextPath}">
  <title>${empty pageTitle ? 'Sunrise Dental Clinic' : pageTitle.concat(' — Sunrise Dental')}</title>

  <!-- Bootstrap 5.3 CSS -->
  <link rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"/>
  <!-- Bootstrap Icons -->
  <link rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet"/>
  <!-- App CSS -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
</head>
<body>
<!-- Sidebar overlay for mobile -->
<div id="sidebarOverlay" class="d-lg-none"
     style="position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:999;display:none!important"></div>
