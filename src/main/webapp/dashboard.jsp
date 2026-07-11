<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.dao.ProductDAO" %>
<%@ page import="com.smartinventory.dao.TransactionDAO" %>
<%@ page import="com.smartinventory.model.Transaction" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.google.gson.Gson" %>
<%
    request.setAttribute("pageTitle", "Dashboard");
    request.setAttribute("activePage", "dashboard");

    ProductDAO productDAO = new ProductDAO();
    TransactionDAO transactionDAO = new TransactionDAO();

    Map<String, Integer> metrics = productDAO.getDashboardMetrics();
    int totalProducts  = metrics.getOrDefault("total_products", 0);
    int lowStock       = metrics.getOrDefault("low_stock", 0);
    int expiredCount   = metrics.getOrDefault("expired", 0);
    int nearExpiry     = metrics.getOrDefault("near_expiry", 0);

    List<Transaction> recentTransactions = transactionDAO.getRecentTransactions(5);

    Map<String, Integer> categoryDistribution = productDAO.getCategoryDistribution();
    Gson gson = new Gson();
    String chartLabelsJson = gson.toJson(categoryDistribution.keySet());
    String chartDataJson   = gson.toJson(categoryDistribution.values());
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Welcome Back, <%= session.getAttribute("fullname") %></h1>
        <div class="page-subtitle">Real-time status of your warehouse inventory.</div>
    </div>
    <div class="d-flex gap-2">
        <a href="<%= request.getContextPath() %>/transactions" class="btn btn-primary d-flex align-items-center gap-2">
            <i class="bi bi-plus-circle"></i> Log Stock Move
        </a>
    </div>
</div>

<div class="row g-4 mb-5">
    <div class="col-sm-6 col-xl-3">
        <a href="<%= request.getContextPath() %>/products" class="text-decoration-none">
            <div class="stat-card" style="cursor:pointer;">
                <div class="stat-icon icon-blue"><i class="bi bi-box"></i></div>
                <div class="stat-value"><%= totalProducts %></div>
                <div class="stat-label">Total Products</div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-xl-3">
        <a href="<%= request.getContextPath() %>/alerts?filter=LOW_STOCK" class="text-decoration-none">
            <div class="stat-card" style="cursor:pointer;">
                <div class="stat-icon icon-amber"><i class="bi bi-exclamation-triangle"></i></div>
                <div class="stat-value" style="color:#d97706"><%= lowStock %></div>
                <div class="stat-label">Low Stock Alerts</div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-xl-3">
        <a href="<%= request.getContextPath() %>/alerts?filter=NEAR_EXPIRY" class="text-decoration-none">
            <div class="stat-card" style="cursor:pointer;">
                <div class="stat-icon icon-blue"><i class="bi bi-calendar-event"></i></div>
                <div class="stat-value" style="color:#2563eb"><%= nearExpiry %></div>
                <div class="stat-label">Near Expiry (30 days)</div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-xl-3">
        <a href="<%= request.getContextPath() %>/alerts?filter=EXPIRED" class="text-decoration-none">
            <div class="stat-card" style="cursor:pointer;">
                <div class="stat-icon icon-red"><i class="bi bi-x-circle"></i></div>
                <div class="stat-value" style="color:#dc2626"><%= expiredCount %></div>
                <div class="stat-label">Expired Items</div>
            </div>
        </a>
    </div>
</div>

<div class="row g-4 mb-4">
    <div class="col-lg-5">
        <div class="glass-panel h-100 p-4">
            <h5 class="mb-4 d-flex align-items-center gap-2" style="color:var(--navy);">
                <i class="bi bi-pie-chart-fill" style="color:var(--blue);"></i> Category Distribution
            </h5>
            <div style="position:relative; height:280px;">
                <% if (categoryDistribution.isEmpty()) { %>
                    <div class="text-muted fs-6 d-flex align-items-center justify-content-center h-100">No products available yet.</div>
                <% } else { %>
                    <canvas id="categoryChart"></canvas>
                <% } %>
            </div>
        </div>
    </div>

    <div class="col-lg-7">
        <div class="glass-panel h-100 p-4">
            <h5 class="mb-4 d-flex align-items-center justify-content-between" style="color:var(--navy);">
                <span class="d-flex align-items-center gap-2">
                    <i class="bi bi-clock-history" style="color:var(--blue);"></i> Recent Stock Move Logs
                </span>
                <a href="<%= request.getContextPath() %>/transactions" class="text-decoration-none fw-600" style="font-size:.85rem;color:var(--blue);">View All</a>
            </h5>
            <div class="table-responsive">
                <table class="table glass-table align-middle">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Type</th>
                            <th>Qty</th>
                            <th>Logged By</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentTransactions.isEmpty()) { %>
                            <tr><td colspan="4" class="text-center py-4 text-muted">No stock actions recorded yet.</td></tr>
                        <% } else {
                            for (Transaction t : recentTransactions) {
                                String typeBadge = "STOCK_IN".equals(t.getType())
                                    ? "<span class='badge-custom badge-in-stock'><i class='bi bi-arrow-down-left-circle-fill'></i> Stock In</span>"
                                    : "<span class='badge-custom badge-out-stock'><i class='bi bi-arrow-up-right-circle-fill'></i> Stock Out</span>";
                        %>
                        <tr>
                            <td>
                                <div class="fw-semibold"><%= t.getProductName() %></div>
                                <div class="text-muted" style="font-size:.78rem;"><%= t.getSku() %></div>
                            </td>
                            <td><%= typeBadge %></td>
                            <td class="fw-bold"><%= t.getQuantity() %></td>
                            <td>
                                <div><%= t.getUserFullname() %></div>
                                <div class="text-muted" style="font-size:.78rem;"><%= t.getTransactionDate().toString().substring(0, 16) %></div>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    <% if (!categoryDistribution.isEmpty()) { %>
    const ctx = document.getElementById("categoryChart").getContext("2d");
    const palette = [
        "#6366f1","#f59e0b","#10b981","#ef4444","#3b82f6",
        "#ec4899","#14b8a6","#f97316","#8b5cf6","#84cc16",
        "#06b6d4","#e11d48","#a855f7","#22c55e","#eab308"
    ];
    const labels = <%= chartLabelsJson %>;
    const data   = <%= chartDataJson %>;
    const total  = data.reduce((a, b) => a + b, 0);
    const colors = labels.map((_, i) => palette[i % palette.length]);
    new Chart(ctx, {
        type: "doughnut",
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: colors,
                borderColor: "#ffffff",
                borderWidth: 3,
                hoverOffset: 14,
                hoverBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: "62%",
            animation: { animateRotate: true, duration: 900 },
            plugins: {
                legend: {
                    position: "bottom",
                    labels: {
                        color: "#374151",
                        font: { family: "Inter", size: 11.5 },
                        padding: 14,
                        usePointStyle: true,
                        pointStyleWidth: 10,
                        boxHeight: 10
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const val = context.parsed;
                            const pct = ((val / total) * 100).toFixed(1);
                            return "  " + context.label + ": " + val + " products (" + pct + "%)";
                        }
                    },
                    backgroundColor: "rgba(17,24,39,0.92)",
                    titleFont: { family: "Inter", size: 13 },
                    bodyFont:  { family: "Inter", size: 12 },
                    padding: 12,
                    cornerRadius: 10
                }
            }
        }
    });
    <% } %>
});
</script>

<jsp:include page="includes/footer.jsp" />
