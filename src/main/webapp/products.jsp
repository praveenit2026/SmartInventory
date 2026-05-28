<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.model.Product" %>
<%@ page import="com.smartinventory.model.Supplier" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Products Catalog");
    request.setAttribute("activePage", "products");

    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    String userRole = (String) session.getAttribute("role");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Products Catalog</h1>
        <div class="page-subtitle">Add, edit, or delete items in the central catalog.</div>
    </div>
    <div>
        <button class="btn btn-primary d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#addProductModal">
            <i class="bi bi-plus-circle-fill"></i> Add Product
        </button>
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

<!-- Search and Filtering Bar -->
<div class="glass-panel p-3 mb-4">
    <div class="row g-3">
        <div class="col-md-7">
            <div class="input-group">
                <span class="input-group-text border-0" style="background: rgba(15,23,42,0.6); color: var(--text-muted);"><i class="bi bi-search"></i></span>
                <input type="text" id="searchInput" class="form-control" placeholder="Search by SKU, Product Name, Category...">
            </div>
        </div>
        <div class="col-md-5">
            <div class="input-group">
                <span class="input-group-text border-0" style="background: rgba(15,23,42,0.6); color: var(--text-muted);"><i class="bi bi-funnel-fill"></i></span>
                <select id="categoryFilter" class="form-select">
                    <option value="">All Categories</option>
                    <option value="Electronics">Electronics</option>
                    <option value="Pharmaceuticals">Pharmaceuticals</option>
                    <option value="Office Supplies">Office Supplies</option>
                </select>
            </div>
        </div>
    </div>
</div>

<!-- Central Products Grid Table -->
<div class="glass-panel p-4">
    <div class="table-responsive">
        <table class="table glass-table text-start align-middle" id="productsTable">
            <thead>
                <tr>
                    <th>SKU</th>
                    <th>Product Name</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th>Stock Qty</th>
                    <th>Supplier</th>
                    <th>Expiry Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (products == null || products.isEmpty()) { %>
                    <tr>
                        <td colspan="8" class="text-center py-4 text-muted">No products available in the database.</td>
                    </tr>
                <% } else {
                    for (Product p : products) {
                        String stockBadge;
                        if (p.getStockQuantity() <= 0) {
                            stockBadge = "<span class='badge-custom badge-out-stock'><i class='bi bi-x-circle-fill'></i> Out of Stock</span>";
                        } else if (p.getStockQuantity() <= p.getMinStockLevel()) {
                            stockBadge = String.format("<span class='badge-custom badge-low-stock'><i class='bi bi-exclamation-circle-fill'></i> Low Stock (%d)</span>", p.getStockQuantity());
                        } else {
                            stockBadge = String.format("<span class='badge-custom badge-in-stock'><i class='bi bi-check-circle-fill'></i> %d Units</span>", p.getStockQuantity());
                        }
                %>
                    <tr class="product-row" data-category="<%= p.getCategory() %>">
                        <td class="fw-bold text-white search-sku"><%= p.getSku() %></td>
                        <td class="search-name">
                            <div class="fw-semibold text-white"><%= p.getName() %></div>
                            <div class="text-muted fs-7"><%= p.getDescription() != null ? p.getDescription() : "" %></div>
                        </td>
                        <td class="search-category"><span class="badge bg-secondary py-1 px-2"><%= p.getCategory() %></span></td>
                        <td class="fw-semibold text-white">INR <%= String.format("%,.2f", p.getPrice()) %></td>
                        <td><%= stockBadge %></td>
                        <td><%= p.getSupplierName() != null ? p.getSupplierName() : "<span class='text-muted fs-7'>None</span>" %></td>
                        <td class="fs-7 <%= p.getExpiryDate() != null ? "text-warning" : "text-muted" %>">
                            <%= p.getExpiryDate() != null ? p.getExpiryDate().toString() : "N/A" %>
                        </td>
                        <td>
                            <div class="d-flex gap-2">
                                <button class="btn btn-sm btn-outline-primary py-1 px-2 edit-btn" 
                                        data-id="<%= p.getId() %>"
                                        data-sku="<%= p.getSku() %>"
                                        data-name="<%= p.getName() %>"
                                        data-desc="<%= p.getDescription() != null ? p.getDescription() : "" %>"
                                        data-cat="<%= p.getCategory() %>"
                                        data-price="<%= p.getPrice() %>"
                                        data-stock="<%= p.getStockQuantity() %>"
                                        data-min="<%= p.getMinStockLevel() %>"
                                        data-expiry="<%= p.getExpiryDate() != null ? p.getExpiryDate().toString() : "" %>"
                                        data-sup="<%= p.getSupplierId() %>"
                                        data-bs-toggle="modal" 
                                        data-bs-target="#editProductModal"
                                        title="Edit Product">
                                    <i class="bi bi-pencil-fill"></i>
                                </button>
                                
                                <% if ("ADMIN".equals(userRole)) { %>
                                    <a href="<%= request.getContextPath() %>/products/delete?id=<%= p.getId() %>" 
                                       class="btn btn-sm btn-outline-danger py-1 px-2"
                                       onclick="return confirm('Are you sure you want to delete this product?');"
                                       title="Delete Product">
                                        <i class="bi bi-trash3-fill"></i>
                                    </a>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <% } } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal: Add Product -->
<div class="modal fade" id="addProductModal" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-panel">
            <div class="modal-header border-0">
                <h5 class="modal-title text-white" id="addProductModalLabel"><i class="bi bi-plus-circle me-2 text-primary"></i>Add Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: invert(1);"></button>
            </div>
            <form action="<%= request.getContextPath() %>/products/add" method="POST">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="addSku" class="form-label">SKU Code</label>
                            <input type="text" class="form-control" id="addSku" name="sku" placeholder="e.g. SKU-LAP-101" required>
                        </div>
                        <div class="col-md-6">
                            <label for="addName" class="form-label">Product Name</label>
                            <input type="text" class="form-control" id="addName" name="name" placeholder="e.g. ThinkPad L14" required>
                        </div>
                        <div class="col-md-6">
                            <label for="addCategory" class="form-label">Category</label>
                            <select class="form-select" id="addCategory" name="category" required>
                                <option value="Electronics">Electronics</option>
                                <option value="Pharmaceuticals">Pharmaceuticals</option>
                                <option value="Office Supplies">Office Supplies</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="addPrice" class="form-label">Price (INR)</label>
                            <input type="number" step="0.01" class="form-control" id="addPrice" name="price" placeholder="e.g. 54999.00" required>
                        </div>
                        <div class="col-md-6">
                            <label for="addStock" class="form-label">Initial Stock Quantity</label>
                            <input type="number" class="form-control" id="addStock" name="stockQuantity" placeholder="e.g. 10" required>
                        </div>
                        <div class="col-md-6">
                            <label for="addMinLevel" class="form-label">Min Stock Threshold Level</label>
                            <input type="number" class="form-control" id="addMinLevel" name="minStockLevel" value="5" placeholder="e.g. 3" required>
                        </div>
                        <div class="col-md-6">
                            <label for="addExpiry" class="form-label">Expiry Date (Optional)</label>
                            <input type="date" class="form-control" id="addExpiry" name="expiryDate">
                        </div>
                        <div class="col-md-6">
                            <label for="addSupplier" class="form-label">Supplier Partner</label>
                            <select class="form-select" id="addSupplier" name="supplierId">
                                <option value="">No Supplier Assigned</option>
                                <% if (suppliers != null) {
                                    for (Supplier s : suppliers) {
                                %>
                                    <option value="<%= s.getId() %>"><%= s.getName() %></option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="col-12">
                            <label for="addDesc" class="form-label">Product Description</label>
                            <textarea class="form-control" id="addDesc" name="description" rows="3" placeholder="Enter short product specifications..."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save me-2"></i>Save Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Edit Product -->
<div class="modal fade" id="editProductModal" tabindex="-1" aria-labelledby="editProductModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content glass-panel">
            <div class="modal-header border-0">
                <h5 class="modal-title text-white" id="editProductModalLabel"><i class="bi bi-pencil-square me-2 text-primary"></i>Modify Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: invert(1);"></button>
            </div>
            <form action="<%= request.getContextPath() %>/products/update" method="POST">
                <input type="hidden" id="editId" name="id">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="editSku" class="form-label">SKU Code</label>
                            <input type="text" class="form-control" id="editSku" name="sku" readonly required style="background: rgba(255,255,255,0.03); opacity: 0.7;">
                        </div>
                        <div class="col-md-6">
                            <label for="editName" class="form-label">Product Name</label>
                            <input type="text" class="form-control" id="editName" name="name" required>
                        </div>
                        <div class="col-md-6">
                            <label for="editCategory" class="form-label">Category</label>
                            <select class="form-select" id="editCategory" name="category" required>
                                <option value="Electronics">Electronics</option>
                                <option value="Pharmaceuticals">Pharmaceuticals</option>
                                <option value="Office Supplies">Office Supplies</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="editPrice" class="form-label">Price (INR)</label>
                            <input type="number" step="0.01" class="form-control" id="editPrice" name="price" required>
                        </div>
                        <div class="col-md-6">
                            <label for="editStock" class="form-label">Current Stock Quantity</label>
                            <input type="number" class="form-control" id="editStock" name="stockQuantity" required>
                        </div>
                        <div class="col-md-6">
                            <label for="editMinLevel" class="form-label">Min Stock Threshold Level</label>
                            <input type="number" class="form-control" id="editMinLevel" name="minStockLevel" required>
                        </div>
                        <div class="col-md-6">
                            <label for="editExpiry" class="form-label">Expiry Date (Optional)</label>
                            <input type="date" class="form-control" id="editExpiry" name="expiryDate">
                        </div>
                        <div class="col-md-6">
                            <label for="editSupplier" class="form-label">Supplier Partner</label>
                            <select class="form-select" id="editSupplier" name="supplierId">
                                <option value="">No Supplier Assigned</option>
                                <% if (suppliers != null) {
                                    for (Supplier s : suppliers) {
                                %>
                                    <option value="<%= s.getId() %>"><%= s.getName() %></option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="col-12">
                            <label for="editDesc" class="form-label">Product Description</label>
                            <textarea class="form-control" id="editDesc" name="description" rows="3"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save2 me-2"></i>Update Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

<!-- Catalog Filter / Modal fill script utilities -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Populating the Edit Modal fields automatically when clicking on edit
        const editButtons = document.querySelectorAll(".edit-btn");
        editButtons.forEach(btn => {
            btn.addEventListener("click", function() {
                document.getElementById("editId").value = this.dataset.id;
                document.getElementById("editSku").value = this.dataset.sku;
                document.getElementById("editName").value = this.dataset.name;
                document.getElementById("editDesc").value = this.dataset.desc;
                document.getElementById("editCategory").value = this.dataset.cat;
                document.getElementById("editPrice").value = this.dataset.price;
                document.getElementById("editStock").value = this.dataset.stock;
                document.getElementById("editMinLevel").value = this.dataset.min;
                document.getElementById("editExpiry").value = this.dataset.expiry;
                document.getElementById("editSupplier").value = this.dataset.sup || "";
            });
        });

        // Instant Dynamic Search & Filtering on catalog listings
        const searchInput = document.getElementById("searchInput");
        const categoryFilter = document.getElementById("categoryFilter");
        const rows = document.querySelectorAll(".product-row");

        function filterProducts() {
            const query = searchInput.value.toLowerCase().trim();
            const categoryValue = categoryFilter.value;

            rows.forEach(row => {
                const sku = row.querySelector(".search-sku").textContent.toLowerCase();
                const name = row.querySelector(".search-name").textContent.toLowerCase();
                const category = row.querySelector(".search-category").textContent;
                
                const matchesSearch = sku.includes(query) || name.includes(query);
                const matchesCategory = categoryValue === "" || row.dataset.category === categoryValue;

                if (matchesSearch && matchesCategory) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        }

        searchInput.addEventListener("input", filterProducts);
        categoryFilter.addEventListener("change", filterProducts);
    });
</script>
