<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.model.Product" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Reports Center");
    request.setAttribute("activePage", "reports");

    List<Product> products = (List<Product>) request.getAttribute("products");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Reports Center</h1>
        <div class="page-subtitle">Export master warehouse logs directly to formatted PDF sheets or CSV spreadsheets.</div>
    </div>
</div>

<div class="row g-4 mb-5">
    <!-- Card 1: PDF Download -->
    <div class="col-md-6">
        <div class="glass-panel p-4 text-center">
            <div class="fs-1 text-primary mb-3"><i class="bi bi-file-earmark-pdf"></i></div>
            <h5 style="color: var(--text-main);">Formatted PDF Report</h5>
            <p class="text-muted px-4 fs-7 mb-4">Generates a polished, printable corporate PDF list featuring product SKUs, prices, quantities, and low stock statuses.</p>
            <a href="<%= request.getContextPath() %>/reports/pdf" class="btn btn-primary px-4 py-2">
                <i class="bi bi-download me-2"></i> Download PDF
            </a>
        </div>
    </div>

    <!-- Card 2: CSV Download -->
    <div class="col-md-6">
        <div class="glass-panel p-4 text-center">
            <div class="fs-1 text-success mb-3"><i class="bi bi-file-earmark-spreadsheet"></i></div>
            <h5 style="color: var(--text-main);">Excel CSV Spreadsheet</h5>
            <p class="text-muted px-4 fs-7 mb-4">Exports raw inventory columns (including SKUs, pricing, supplier contacts, and status levels) to a spreadsheet file.</p>
            <a href="<%= request.getContextPath() %>/reports/csv" class="btn btn-success px-4 py-2">
                <i class="bi bi-file-earmark-excel me-2"></i> Export to CSV
            </a>
        </div>
    </div>
</div>

<!-- On Screen Master Stock Status Preview -->
<div class="glass-panel p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h5 class="m-0 d-flex align-items-center gap-2" style="color: var(--text-main);">
            <i class="bi bi-eye text-primary"></i> Stock Status Report Preview
        </h5>
        <input type="text" id="reportSearch" class="form-control form-control-sm w-25" placeholder="Search preview logs...">
    </div>
    
    <div class="table-responsive">
        <table class="table glass-table align-middle text-start" id="reportTable">
            <thead>
                <tr>
                    <th>SKU</th>
                    <th>Product</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th class="text-center">Available Stock</th>
                    <th>Supplier</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">No products available to generate reports.</td>
                    </tr>
                <% } else {
                    for (Product p : products) {
                        String statusBadge;
                        if (p.getStockQuantity() <= 0) {
                            statusBadge = "<span class='badge-custom badge-out-stock'>OUT OF STOCK</span>";
                        } else if (p.getStockQuantity() <= p.getMinStockLevel()) {
                            statusBadge = "<span class='badge-custom badge-low-stock'>LOW STOCK</span>";
                        } else {
                            statusBadge = "<span class='badge-custom badge-in-stock'>OK</span>";
                        }
                %>
                    <tr class="report-row">
                        <td class="fw-bold search-rsku" style="color: var(--text-main);"><%= p.getSku() %></td>
                        <td class="fw-semibold search-rname" style="color: var(--text-main);"><%= p.getName() %></td>
                        <td class="search-rcat"><%= p.getCategory() %></td>
                        <td style="color: var(--text-main);">INR <%= String.format("%,.2f", p.getPrice()) %></td>
                        <td class="fw-bold text-center" style="color: var(--text-main);"><%= p.getStockQuantity() %></td>
                        <td><%= p.getSupplierName() != null ? p.getSupplierName() : "N/A" %></td>
                        <td><%= statusBadge %></td>
                    </tr>
                <% } } %>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

<!-- Quick live search in preview logs -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const reportSearch = document.getElementById("reportSearch");
        const rows = document.querySelectorAll(".report-row");
        
        reportSearch.addEventListener("input", function() {
            const query = reportSearch.value.toLowerCase().trim();
            rows.forEach(row => {
                const sku = row.querySelector(".search-rsku").textContent.toLowerCase();
                const name = row.querySelector(".search-rname").textContent.toLowerCase();
                const cat = row.querySelector(".search-rcat").textContent.toLowerCase();
                
                if (sku.includes(query) || name.includes(query) || cat.includes(query)) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        });
    });
</script>
