<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.dao.ProductDAO" %>
<%@ page import="com.smartinventory.dao.TransactionDAO" %>
<%@ page import="com.smartinventory.model.Transaction" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.google.gson.Gson" %>
<%
    // Page metadata for sidebar highlighting and titles
    request.setAttribute("pageTitle", "Dashboard");
    request.setAttribute("activePage", "dashboard");
    
    // Server-side dynamic query metrics
    ProductDAO productDAO = new ProductDAO();
    TransactionDAO transactionDAO = new TransactionDAO();
    
    int totalProducts = productDAO.getTotalProductCount();
    int lowStock = productDAO.getLowStockCount();
    int expiredCount = productDAO.getExpiredCount();
    int nearExpiry = productDAO.getNearExpiryCount();
    
    List<Transaction> recentTransactions = transactionDAO.getAllTransactions();
    if (recentTransactions.size() > 5) {
        recentTransactions = recentTransactions.subList(0, 5); // Limit to top 5 recent activities
    }
    
    // Process Category distribution for Chart.js
    Map<String, Integer> categoryDistribution = productDAO.getCategoryDistribution();
    Gson gson = new Gson();
    String chartLabelsJson = gson.toJson(categoryDistribution.keySet());
    String chartDataJson = gson.toJson(categoryDistribution.values());
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<!-- Page Title Section -->
<div class="page-header">
    <div>
        <h1 class="page-title">Welcome Back, <%= session.getAttribute("fullname") %></h1>
        <div class="page-subtitle">Here is a real-time status of your warehouse inventory.</div>
    </div>
    <div class="d-flex gap-2">
        <a href="<%= request.getContextPath() %>/transactions" class="btn btn-primary d-flex align-items-center gap-2">
            <i class="bi bi-plus-circle"></i> Log Stock Move
        </a>
    </div>
</div>

<!-- Grid Cards Section -->
<div class="row g-4 mb-5">
    <!-- Stat Item 1: Total Products -->
    <div class="col-sm-6 col-xl-3">
        <div class="glass-panel stat-card">
            <div class="stat-icon icon-blue">
                <i class="bi bi-box"></i>
            </div>
            <div class="stat-value text-white"><%= totalProducts %></div>
            <div class="stat-label">Unique Products</div>
        </div>
    </div>

    <!-- Stat Item 2: Low Stock -->
    <div class="col-sm-6 col-xl-3">
        <div class="glass-panel stat-card">
            <div class="stat-icon icon-amber">
                <i class="bi bi-exclamation-triangle"></i>
            </div>
            <div class="stat-value text-warning"><%= lowStock %></div>
            <div class="stat-label">Low Stock Alerts</div>
        </div>
    </div>

    <!-- Stat Item 3: Expired Products -->
    <div class="col-sm-6 col-xl-3">
        <div class="glass-panel stat-card">
            <div class="stat-icon icon-red">
                <i class="bi bi-trash"></i>
            </div>
            <div class="stat-value text-danger"><%= expiredCount %></div>
            <div class="stat-label">Expired Items</div>
        </div>
    </div>

    <!-- Stat Item 4: Near Expiry -->
    <div class="col-sm-6 col-xl-3">
        <div class="glass-panel stat-card">
            <div class="stat-icon icon-green">
                <i class="bi bi-calendar-event"></i>
            </div>
            <div class="stat-value text-success"><%= nearExpiry %></div>
            <div class="stat-label">Near Expiry (30 days)</div>
        </div>
    </div>
</div>

<!-- Graph and Recent Logs Grid -->
<div class="row g-4 mb-4">
    <!-- Category breakdown Chart.js widget -->
    <div class="col-lg-5">
        <div class="glass-panel h-100 p-4">
            <h5 class="mb-4 text-white d-flex align-items-center gap-2">
                <i class="bi bi-pie-chart-fill text-primary"></i> Category Distribution
            </h5>
            <div class="d-flex align-items-center justify-content-center" style="position: relative; height: 260px;">
                <% if (categoryDistribution.isEmpty()) { %>
                    <div class="text-muted fs-6">No products available yet.</div>
                <% } else { %>
                    <canvas id="categoryChart"></canvas>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Scrollable transactional logs -->
    <div class="col-lg-7">
        <div class="glass-panel h-100 p-4">
            <h5 class="mb-4 text-white d-flex align-items-center justify-content-between">
                <span class="d-flex align-items-center gap-2">
                    <i class="bi bi-clock-history text-primary"></i> Recent Stock Move Logs
                </span>
                <a href="<%= request.getContextPath() %>/transactions" class="text-decoration-none fs-7 text-primary">View All</a>
            </h5>
            
            <div class="table-responsive">
                <table class="table glass-table text-start align-middle">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Type</th>
                            <th>Quantity</th>
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
                                    <div class="fw-semibold text-white"><%= t.getProductName() %></div>
                                    <div class="text-muted fs-7"><%= t.getSku() %></div>
                                </td>
                                <td><%= typeBadge %></td>
                                <td class="fw-bold text-white"><%= t.getQuantity() %></td>
                                <td>
                                    <div class="text-white"><%= t.getUserFullname() %></div>
                                    <div class="text-muted fs-7"><%= t.getTransactionDate().toString().substring(0, 16) %></div>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Chart JS Script integration -->
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
                        '#4e8cff',
                        '#00f2fe',
                        '#00e676',
                        '#ffb300',
                        '#ff5252',
                        '#ae52ff'
                    ],
                    borderColor: 'rgba(9, 14, 26, 0.8)',
                    borderWidth: 2,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#94a3b8',
                            font: {
                                family: 'Plus Jakarta Sans',
                                size: 11
                            },
                            padding: 15
                        }
                    }
                },
                cutout: '65%'
            }
        });
        <% } %>
    });
</script>

<jsp:include page="includes/footer.jsp" />
