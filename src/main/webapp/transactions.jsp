<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.model.Transaction" %>
<%@ page import="com.smartinventory.model.Product" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Stock Movements");
    request.setAttribute("activePage", "transactions");

    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    List<Product> products = (List<Product>) request.getAttribute("products");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Stock Movements</h1>
        <div class="page-subtitle">Log new inventory actions and review physical movement audits.</div>
    </div>
</div>

<!-- Alerts Panel -->
<% if (success != null) { %>
    <div class="alert alert-success alert-dismissible fade show border-0 rounded-3 mb-4" role="alert" style="background: rgba(0, 230, 118, 0.12); color: #80ffd4; font-size: 0.9rem;">
        <i class="bi bi-check-circle-fill me-2 fs-5"></i>
        <%= success %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="filter: invert(1);"></button>
    </div>
<% } %>

<% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show border-0 rounded-3 mb-4" role="alert" style="background: rgba(255, 82, 82, 0.15); color: #ff8080; font-size: 0.9rem;">
        <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
        <%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="filter: invert(1);"></button>
    </div>
<% } %>

<div class="row g-4 mb-4">
    <!-- Form Card: Register Stock Movement -->
    <div class="col-lg-4">
        <div class="glass-panel p-4 h-100">
            <h5 class="mb-4 text-white d-flex align-items-center gap-2">
                <i class="bi bi-plus-slash-minus text-primary"></i> Record Stock Movement
            </h5>
            
            <form action="<%= request.getContextPath() %>/transactions" method="POST">
                <div class="mb-3">
                    <label for="productId" class="form-label">Select Product</label>
                    <select class="form-select" id="productId" name="productId" required>
                        <option value="">-- Choose Product --</option>
                        <% if (products != null) {
                            for (Product p : products) {
                        %>
                            <option value="<%= p.getId() %>" data-stock="<%= p.getStockQuantity() %>">
                                <%= p.getSku() %> | <%= p.getName() %> (Qty: <%= p.getStockQuantity() %>)
                            </option>
                        <% } } %>
                    </select>
                </div>
                
                <div class="mb-3">
                    <label for="type" class="form-label">Movement Type</label>
                    <select class="form-select" id="type" name="type" required>
                        <option value="STOCK_IN">Stock In (Procurement / Return)</option>
                        <option value="STOCK_OUT">Stock Out (Dispatch / Sales / Expired)</option>
                    </select>
                </div>
                
                <div class="mb-3">
                    <label for="quantity" class="form-label">Quantity</label>
                    <input type="number" class="form-control" id="quantity" name="quantity" min="1" placeholder="e.g. 10" required>
                    <div class="form-text text-muted" id="qtyHelper">Enter a positive integer amount.</div>
                </div>
                
                <div class="mb-4">
                    <label for="notes" class="form-label">Movement Notes / Reason</label>
                    <textarea class="form-control" id="notes" name="notes" rows="3" placeholder="e.g. Received new stock from Tech Corp India" required></textarea>
                </div>
                
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-arrow-down-up me-2"></i>Process Transaction
                </button>
            </form>
        </div>
    </div>

    <!-- History Auditor List -->
    <div class="col-lg-8">
        <div class="glass-panel p-4 h-100">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="text-white m-0 d-flex align-items-center gap-2">
                    <i class="bi bi-journal-text text-primary"></i> Stock Audit Log Book
                </h5>
                <input type="text" id="logSearch" class="form-control form-control-sm w-50" placeholder="Quick search audit history...">
            </div>
            
            <div class="table-responsive" style="max-height: 480px; overflow-y: auto;">
                <table class="table glass-table align-middle text-start" id="auditTable">
                    <thead style="position: sticky; top: 0; z-index: 10;">
                        <tr>
                            <th>Product</th>
                            <th>Action</th>
                            <th>Qty</th>
                            <th>Operator</th>
                            <th>Notes</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (transactions == null || transactions.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="text-center py-4 text-muted">No stock actions recorded yet.</td>
                            </tr>
                        <% } else {
                            for (Transaction t : transactions) {
                                String typeBadge = "STOCK_IN".equals(t.getType()) 
                                    ? "<span class='badge-custom badge-in-stock'><i class='bi bi-arrow-down-left-circle-fill'></i> Stock In</span>"
                                    : "<span class='badge-custom badge-out-stock'><i class='bi bi-arrow-up-right-circle-fill'></i> Stock Out</span>";
                        %>
                            <tr class="audit-row">
                                <td>
                                    <div class="fw-semibold text-white search-pname"><%= t.getProductName() %></div>
                                    <div class="text-muted fs-7 search-psku"><%= t.getSku() %></div>
                                </td>
                                <td><%= typeBadge %></td>
                                <td class="fw-bold text-white"><%= t.getQuantity() %></td>
                                <td>
                                    <div class="text-white search-puser"><%= t.getUserFullname() %></div>
                                    <div class="text-muted fs-7"><%= t.getTransactionDate().toString().substring(0, 16) %></div>
                                </td>
                                <td class="text-muted fs-7 search-pnotes" style="max-width: 180px; white-space: normal;"><%= t.getNotes() %></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

<!-- Form client validations & quick filters -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const productSelect = document.getElementById("productId");
        const typeSelect = document.getElementById("type");
        const quantityInput = document.getElementById("quantity");
        const qtyHelper = document.getElementById("qtyHelper");
        
        function updateQtyValidation() {
            const selectedOpt = productSelect.options[productSelect.selectedIndex];
            const type = typeSelect.value;
            
            if (selectedOpt && selectedOpt.value !== "") {
                const stock = parseInt(selectedOpt.dataset.stock);
                if (type === "STOCK_OUT") {
                    quantityInput.setAttribute("max", stock);
                    qtyHelper.innerHTML = "<span class='text-warning'>Available stock: " + stock + " units max.</span>";
                } else {
                    quantityInput.removeAttribute("max");
                    qtyHelper.innerHTML = "<span class='text-success'>Adds directly to current capacity.</span>";
                }
            } else {
                quantityInput.removeAttribute("max");
                qtyHelper.textContent = "Enter a positive integer amount.";
            }
        }
        
        productSelect.addEventListener("change", updateQtyValidation);
        typeSelect.addEventListener("change", updateQtyValidation);
        
        // Log search filter
        const logSearch = document.getElementById("logSearch");
        const rows = document.querySelectorAll(".audit-row");
        
        logSearch.addEventListener("input", function() {
            const query = logSearch.value.toLowerCase().trim();
            rows.forEach(row => {
                const pname = row.querySelector(".search-pname").textContent.toLowerCase();
                const psku = row.querySelector(".search-psku").textContent.toLowerCase();
                const puser = row.querySelector(".search-puser").textContent.toLowerCase();
                const pnotes = row.querySelector(".search-pnotes").textContent.toLowerCase();
                
                if (pname.includes(query) || psku.includes(query) || puser.includes(query) || pnotes.includes(query)) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        });
    });
</script>
