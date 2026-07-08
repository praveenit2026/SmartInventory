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

    int totalProducts  = productDAO.getTotalProductCount();
    int lowStock       = productDAO.getLowStockCount();
    int expiredCount   = productDAO.getExpiredCount();
    int nearExpiry     = productDAO.getNearExpiryCount();

    List<Transaction> recentTransactions = transactionDAO.getAllTransactions();
    if (recentTransactions.size() > 5) {
        recentTransactions = recentTransactions.subList(0, 5);
    }

    Map<String, Integer> categoryDistribution = productDAO.getCategoryDistribution();
    Gson gson = new Gson();
    String chartLabelsJson = gson.toJson(categoryDistribution.keySet());
    String chartDataJson   = gson.toJson(categoryDistribution.values());
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<!-- Page Header -->
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

<!-- Stat Cards -->
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
        <a href="<%= request.getContextPath() %>/alerts" class="text-decoration-none">
            <div class="stat-card" style="cursor:pointer;">
                <div class="stat-icon icon-amber"><i class="bi bi-exclamation-triangle"></i></div>
                <div class="stat-value" style="color:#d97706"><%= lowStock %></div>
                <div class="stat-label">Low Stock Alerts</div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-xl-3">
        <a href="<%= request.getContextPath() %>/alerts" class="text-decoration-none">
            <div class="stat-card" style="cursor:pointer;">
                <div class="stat-icon icon-blue"><i class="bi bi-calendar-event"></i></div>
                <div class="stat-value" style="color:#2563eb"><%= nearExpiry %></div>
                <div class="stat-label">Near Expiry (30 days)</div>
            </div>
        </a>
    </div>
    <div class="col-sm-6 col-xl-3">
        <a href="<%= request.getContextPath() %>/alerts" class="text-decoration-none">
            <div class="stat-card" style="cursor:pointer;">
                <div class="stat-icon icon-red"><i class="bi bi-x-circle"></i></div>
                <div class="stat-value" style="color:#dc2626"><%= expiredCount %></div>
                <div class="stat-label">Expired Items</div>
            </div>
        </a>
    </div>
</div>

<!-- Charts + Recent Logs -->
<div class="row g-4 mb-4">
    <!-- Doughnut Chart -->
    <div class="col-lg-5">
        <div class="glass-panel h-100 p-4">
            <h5 class="mb-4 d-flex align-items-center gap-2" style="color:var(--navy);">
                <i class="bi bi-pie-chart-fill" style="color:var(--blue);"></i> Category Distribution
            </h5>
            <div class="d-flex align-items-center justify-content-center" style="position:relative;height:260px;">
                <% if (categoryDistribution.isEmpty()) { %>
                    <div class="text-muted fs-6">No products available yet.</div>
                <% } else { %>
                    <canvas id="categoryChart"></canvas>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Recent Transactions -->
    <div class="col-lg-7">
        <div class="glass-panel h-100 p-4">
            <h5 class="mb-4 d-flex align-items-center justify-content-between" style="color:var(--navy);">
                <span class="d-flex align-items-center gap-2">
                    <i class="bi bi-clock-history" style="color:var(--blue);"></i> Recent Stock Move Logs
                </span>
                <a href="<%= request.getContextPath() %>/transactions"
                   class="text-decoration-none fw-600"
                   style="font-size:.85rem;color:var(--blue);">View All</a>
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
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">No stock actions recorded yet.</td>
                            </tr>
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
    const ctx = document.getElementById('categoryChart').getContext('2d');
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: <%= chartLabelsJson %>,
            datasets: [{
                data: <%= chartDataJson %>,
                backgroundColor: [
                    '#1a3f6f','#2563eb','#3b82f6','#60a5fa','#93c5fd','#bfdbfe'
                ],
                borderColor: '#ffffff',
                borderWidth: 3,
                hoverOffset: 10
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        color: '#6b7280',
                        font: { family: 'Inter', size: 12 },
                        padding: 16,
                        usePointStyle: true
                    }
                }
            },
            cutout: '68%'
        }
    });
    <% } %>
});
</script>

<jsp:include page="includes/footer.jsp" />
