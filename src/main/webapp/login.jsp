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
            <div class="alert alert-danger d-flex align-items-center py-2 px-3 mb-3 border-0 rounded-3 text-start" role="alert" style="background: rgba(255, 82, 82, 0.15); color: #ff8080; font-size: 0.85rem;">
                <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                <div><%= error %></div>
            </div>
        <% } %>

        <% if ("true".equals(logout)) { %>
            <div class="alert alert-success d-flex align-items-center py-2 px-3 mb-3 border-0 rounded-3 text-start" role="alert" style="background: rgba(0, 230, 118, 0.12); color: #80ffd4; font-size: 0.85rem;">
                <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                <div>Signed out successfully.</div>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/auth/login" method="POST" class="text-start">
            <div class="mb-3">
                <label for="username" class="form-label">Username</label>
                <div class="input-group">
                    <span class="input-group-text border-0" style="background: rgba(15,23,42,0.6); color: var(--text-muted);"><i class="bi bi-person-fill"></i></span>
                    <input type="text" class="form-control" id="username" name="username" placeholder="e.g. admin" required autocomplete="off">
                </div>
            </div>

            <div class="mb-4">
                <label for="password" class="form-label">Password</label>
                <div class="input-group">
                    <span class="input-group-text border-0" style="background: rgba(15,23,42,0.6); color: var(--text-muted);"><i class="bi bi-key-fill"></i></span>
                    <input type="password" class="form-control" id="password" name="password" placeholder="••••••••" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100 mb-3">
                <i class="bi bi-box-arrow-in-right me-2"></i>Authenticate
            </button>
        </form>

        <div class="mt-4 pt-3 border-top" style="border-color: rgba(255,255,255,0.06) !important;">
            <div style="font-size: 0.75rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">
                Demo Credentials
            </div>
            <div class="d-flex justify-content-around text-start mt-2">
                <div class="px-2 py-1 rounded" style="background: rgba(255,255,255,0.03); border: 1px solid var(--glass-border); font-size: 0.75rem;">
                    <div style="color: var(--primary); font-weight: 700;">ADMIN</div>
                    <div style="color: var(--text-main);">User: <b>admin</b></div>
                    <div style="color: var(--text-muted);">Pass: <b>admin123</b></div>
                </div>
                <div class="px-2 py-1 rounded" style="background: rgba(255,255,255,0.03); border: 1px solid var(--glass-border); font-size: 0.75rem;">
                    <div style="color: var(--success-green); font-weight: 700;">MANAGER</div>
                    <div style="color: var(--text-main);">User: <b>manager</b></div>
                    <div style="color: var(--text-muted);">Pass: <b>manager123</b></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
