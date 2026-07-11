<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.dao.AlertDAO" %>
<%@ page import="java.util.List" %>
<%
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "dashboard";

    AlertDAO sidebarAlertDAO = new AlertDAO();
    int unreadAlertsCount = sidebarAlertDAO.getUnreadAlertsCount();

    String userRole     = (String) session.getAttribute("role");
    String userFullname = (String) session.getAttribute("fullname");
%>
<aside class="app-sidebar">
    <div class="sidebar-brand">
        <i class="bi bi-shield-check me-2"></i>Smart Inventory
    </div>

    <ul class="sidebar-menu">
        <li>
            <a href="<%= request.getContextPath() %>/dashboard.jsp"
               class="sidebar-link <%= "dashboard".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-grid-1x2-fill"></i> Dashboard
            </a>
        </li>
        <li>
            <a href="<%= request.getContextPath() %>/products"
               class="sidebar-link <%= "products".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-box-seam-fill"></i> Products
            </a>
        </li>
        <li>
            <a href="<%= request.getContextPath() %>/transactions"
               class="sidebar-link <%= ("transactions".equals(activePage) || "stock-in".equals(activePage)) ? "active" : "" %>">
                <i class="bi bi-arrow-down-left-circle-fill"></i> Stock In
            </a>
        </li>
        <li>
            <a href="<%= request.getContextPath() %>/stock-sales"
               class="sidebar-link <%= "stock-sales".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-cart-fill"></i> Stock Sales
            </a>
        </li>
        <li>
            <a href="<%= request.getContextPath() %>/alerts"
               class="sidebar-link <%= "alerts".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-bell-fill"></i> Alerts
                <% if (unreadAlertsCount > 0) { %>
                    <span class="badge-sidebar" id="sidebar-alert-badge"><%= unreadAlertsCount %></span>
                <% } %>
            </a>
        </li>
        <li>
            <a href="<%= request.getContextPath() %>/reports"
               class="sidebar-link <%= "reports".equals(activePage) ? "active" : "" %>">
                <i class="bi bi-file-earmark-bar-graph-fill"></i> Reports
            </a>
        </li>
    </ul>

    <div class="sidebar-user">
        <div class="d-flex align-items-center justify-content-between mb-2">
            <div>
                <div class="user-name" title="<%= userFullname %>"><%= userFullname %></div>
                <div class="user-role"><%= userRole %></div>
            </div>
            <i class="bi bi-person-badge-fill text-muted fs-4"></i>
        </div>
        <hr class="my-2" style="border-color: rgba(255,255,255,0.1);">
        <a href="<%= request.getContextPath() %>/auth/logout" class="btn btn-sm btn-outline-danger w-100 mt-1 d-flex align-items-center justify-content-start gap-2" style="padding: 8px 6px;">
            <i class="bi bi-box-arrow-right fs-6" style="width: 20px; text-align: center;"></i> Sign Out
        </a>
    </div>
</aside>

<main class="app-content">
