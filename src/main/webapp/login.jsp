<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.model.User" %>
<%
    // If user is already authenticated, skip login and forward to dashboard
    HttpSession currentSession = request.getSession(false);
    if (currentSession != null && currentSession.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }
    
    String error = (String) request.getAttribute("error");
    String logout = request.getParameter("logout");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In | Smart Inventory Control System</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>
<body class="auth-wrapper">

    <div class="auth-card glass-panel text-center">
        <div class="mb-4">
            <div class="auth-logo">
                <i class="bi bi-shield-lock me-2"></i>Smart Inventory
            </div>
            <div class="text-muted">Enter credentials to manage your inventory</div>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger d-flex align-items-center py-2 px-3 mb-3 rounded-3 text-start" role="alert" style="background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; font-size: 0.85rem;">
                <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                <div><%= error %></div>
            </div>
        <% } %>

        <% if ("true".equals(logout)) { %>
            <div class="alert alert-success d-flex align-items-center py-2 px-3 mb-3 rounded-3 text-start" role="alert" style="background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; font-size: 0.85rem;">
                <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                <div>Signed out successfully.</div>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/auth/login" method="POST" class="text-start">
            <div class="mb-3">
                <label for="username" class="form-label">Username</label>
                <div class="input-group">
                    <span class="input-group-text" style="background: #f1f5f9; border: 1px solid #cbd5e1; border-right: none; color: var(--text-muted);"><i class="bi bi-person-fill"></i></span>
                    <input type="text" class="form-control" id="username" name="username" placeholder="e.g. admin" required autocomplete="off" style="border-left: none;">
                </div>
            </div>

            <div class="mb-4">
                <label for="password" class="form-label">Password</label>
                <div class="input-group">
                    <span class="input-group-text" style="background: #f1f5f9; border: 1px solid #cbd5e1; border-right: none; color: var(--text-muted);"><i class="bi bi-key-fill"></i></span>
                    <input type="password" class="form-control" id="password" name="password" placeholder="••••••••" required style="border-left: none;">
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100 mb-3">
                <i class="bi bi-box-arrow-in-right me-2"></i>Authenticate
            </button>
        </form>

        <div class="mt-4 pt-3 border-top" style="border-color: #e2e8f0 !important;">
            <button type="button" class="btn btn-primary w-100" onclick="loginDemo('demo','demo123')">
                <i class="bi bi-play-circle-fill me-2"></i>Demo
            </button>
        </div>
        <script>
            function loginDemo(user, pass) {
                document.getElementById('username').value = user;
                document.getElementById('password').value = pass;
                document.querySelector('form').submit();
            }
        </script>
    </div>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
