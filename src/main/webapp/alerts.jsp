<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.model.Alert" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "System Alerts");
    request.setAttribute("activePage", "alerts");

    List<Alert> alerts = (List<Alert>) request.getAttribute("alerts");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Notifications & Alerts</h1>
        <div class="page-subtitle">Inspect automatically generated inventory warnings, low stock flags, and expiration schedules.</div>
    </div>
    <div>
        <% if (alerts != null && !alerts.isEmpty()) { %>
            <a href="<%= request.getContextPath() %>/alerts/readAll" class="btn btn-outline-primary d-flex align-items-center gap-2">
                <i class="bi bi-envelope-open"></i> Clear All Alerts
            </a>
        <% } %>
    </div>
</div>

<div class="glass-panel p-4">
    <% if (alerts == null || alerts.isEmpty()) { %>
        <div class="text-center py-5">
            <div class="text-success fs-1 mb-3"><i class="bi bi-shield-fill-check"></i></div>
            <h5 style="color: var(--text-main);">System Status Clear</h5>
            <p class="text-muted mb-0">No low stock items, expired products, or near-expiry batches detected.</p>
        </div>
    <% } else { %>
        <div class="d-flex flex-column gap-3">
            <% for (Alert a : alerts) {
                String typeClass = a.getType(); // LOW_STOCK, NEAR_EXPIRY, EXPIRED
                String readClass = a.isRead() ? "read" : "";
                
                String icon;
                String title;
                if ("LOW_STOCK".equals(a.getType())) {
                    icon = "<i class='bi bi-exclamation-triangle-fill text-warning fs-4 me-3'></i>";
                    title = "Low Stock Limit Alarm";
                } else if ("NEAR_EXPIRY".equals(a.getType())) {
                    icon = "<i class='bi bi-calendar-event-fill text-primary fs-4 me-3'></i>";
                    title = "Near Expiry Warning (30-day window)";
                } else {
                    icon = "<i class='bi bi-trash-fill text-danger fs-4 me-3'></i>";
                    title = "Expired Product - Remove immediately";
                }
            %>
                <div class="alert-item <%= typeClass %> <%= readClass %>">
                    <div class="d-flex align-items-center">
                        <%= icon %>
                        <div>
                            <div class="fw-semibold d-flex align-items-center gap-2" style="color: var(--text-main);">
                                <%= title %>
                                <% if (!a.isRead()) { %>
                                    <span class="badge bg-danger p-1" style="font-size: 0.6rem; text-transform: uppercase;">New</span>
                                <% } %>
                            </div>
                            <div class="alert-text text-muted my-1"><%= a.getMessage() %></div>
                            <div class="alert-meta">
                                <span><i class="bi bi-clock me-1"></i><%= a.getCreatedAt().toString().substring(0, 16) %></span>
                                <span class="mx-2">•</span>
                                <span class="fw-medium" style="color: var(--text-main);"><%= a.getSku() %> | <%= a.getProductName() %></span>
                            </div>
                        </div>
                    </div>
                    
                    <div>
                        <% if (!a.isRead()) { %>
                            <a href="<%= request.getContextPath() %>/alerts/read?id=<%= a.getId() %>" class="btn btn-sm btn-outline-secondary py-1 px-3">
                                <i class="bi bi-check2 me-1"></i> Dismiss
                            </a>
                        <% } else { %>
                            <span class="text-muted fs-7"><i class="bi bi-check2-all me-1"></i> Read</span>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>
</div>

<jsp:include page="includes/footer.jsp" />
