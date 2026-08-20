<%-- errors/404.jsp — Page Not Found Error --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>404 Page Not Found</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;800&display=swap" rel="stylesheet"/>
  <style>
    body {
      font-family: 'Inter', sans-serif;
      background: #f1f5f9;
      height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #0f172a;
    }
    .error-card {
      background: #fff;
      padding: 3rem;
      border-radius: 20px;
      box-shadow: 0 10px 30px rgba(0,0,0,.05);
      max-width: 500px;
      text-align: center;
    }
    .error-icon {
      font-size: 4rem;
      color: #3b82f6;
      margin-bottom: 1.5rem;
    }
    h1 { font-weight: 800; font-size: 2.5rem; margin-bottom: 1rem; }
    p { color: #64748b; margin-bottom: 2rem; }
  </style>
</head>
<body>
  <div class="error-card">
    <div class="error-icon"><i class="bi bi-file-earmark-x"></i></div>
    <h1>404</h1>
    <h3>Page Not Found</h3>
    <p>
      The page you are looking for does not exist or has been moved.
    </p>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary px-4 py-2">
      <i class="bi bi-house-fill me-1"></i> Go to Dashboard
    </a>
  </div>
</body>
</html>
