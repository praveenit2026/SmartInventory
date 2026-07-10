<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.model.Transaction" %>
<%@ page import="com.smartinventory.model.Product" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Stock In / Procurement");
    request.setAttribute("activePage", "stock-in");

    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    List<Product> products = (List<Product>) request.getAttribute("products");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<style>
    .stock-in-screen {
        max-width: 1180px;
    }

    .stock-in-screen .page-header {
        margin-bottom: 28px;
    }

    .stock-in-grid {
        display: grid;
        grid-template-columns: minmax(290px, 325px) minmax(560px, 1fr);
        gap: 20px;
        align-items: stretch;
    }

    .stock-in-panel {
        background: var(--bg-white);
        border: 1px solid var(--border);
        border-radius: 18px;
        box-shadow: var(--shadow-sm);
    }

    .stock-in-form-panel {
        padding: 22px;
    }

    .stock-in-log-panel {
        padding: 22px;
        min-height: 535px;
    }

    .stock-panel-title {
        color: var(--text-main);
        font-size: 1.03rem;
        font-weight: 700;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 9px;
    }

    .stock-panel-title i {
        color: var(--blue);
    }

    .stock-in-screen .form-label {
        font-size: 0.82rem;
        font-weight: 700;
        margin-bottom: 7px;
    }

    .stock-in-screen .form-control,
    .stock-in-screen .form-select {
        background: #ffffff;
        border-color: #cbd5e1;
        border-radius: 10px;
        min-height: 46px;
    }

    .stock-in-screen textarea.form-control {
        min-height: 106px;
        resize: vertical;
    }

    .stock-in-screen .form-text,
    .stock-in-screen .selected-product-meta {
        font-size: 0.78rem;
    }

    .stock-in-screen .btn-primary {
        min-height: 46px;
        border-radius: 10px;
        box-shadow: 0 4px 14px rgba(37,99,235,0.25);
    }

    .stock-log-header {
        display: grid;
        grid-template-columns: 1fr minmax(230px, 315px);
        gap: 18px;
        align-items: center;
        margin-bottom: 20px;
    }

    .stock-log-search {
        width: 100%;
    }

    .stock-log-table {
        border: 0;
        border-radius: 0;
        max-height: 420px;
        overflow-y: auto;
    }

    .stock-log-table .glass-table th {
        background: #f8fafc !important;
        padding: 14px 20px 16px;
    }

    .stock-log-table .glass-table td {
        padding: 18px 20px;
    }

    .stock-log-table .glass-table thead {
        position: sticky;
        top: 0;
        z-index: 5;
        background: #f8fafc;
    }

    .stock-log-table .search-pname {
        line-height: 1.25;
    }

    .stock-log-table .badge-custom {
        min-width: 78px;
        justify-content: center;
        white-space: normal;
        text-align: center;
        line-height: 1.05;
    }

    .autocomplete-list {
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        z-index: 1000;
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: 12px;
        max-height: 250px;
        overflow-y: auto;
        margin-top: 5px;
        box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08);
    }
    .autocomplete-item {
        padding: 12px 16px;
        cursor: pointer;
        border-bottom: 1px solid var(--glass-border);
        transition: all 0.2s ease;
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: var(--text-main);
    }
    .autocomplete-item:last-child {
        border-bottom: none;
    }
    .autocomplete-item:hover, .autocomplete-item.active {
        background: var(--blue-light);
        color: var(--blue) !important;
    }
    .autocomplete-item strong {
        color: var(--text-main);
    }
    .autocomplete-item .item-sku {
        color: var(--text-muted);
        font-size: 0.85rem;
    }
    .autocomplete-item .item-price {
        color: var(--blue);
        font-weight: 600;
    }

    @media (max-width: 1100px) {
        .stock-in-grid {
            grid-template-columns: 1fr;
        }

        .stock-log-header {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="stock-in-screen">
    <div class="page-header">
        <div>
            <h1 class="page-title">Stock In / Procurement</h1>
            <div class="page-subtitle">Log new incoming stock additions, returns, or supplier deliveries.</div>
        </div>
    </div>

<!-- Alerts Panel -->
<% if (success != null) { %>
    <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4" role="alert" style="background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; font-size: 0.9rem;">
        <i class="bi bi-check-circle-fill me-2 fs-5"></i>
        <%= success %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<% } %>

<% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-4" role="alert" style="background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; font-size: 0.9rem;">
        <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
        <%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<% } %>

<div class="stock-in-grid mb-4">
    <!-- Form Card: Register Stock In -->
    <section class="stock-in-panel stock-in-form-panel">
        <h5 class="stock-panel-title mb-4">
            <i class="bi bi-plus-circle"></i> Log Stock Inflow
        </h5>
            
        <form action="<%= request.getContextPath() %>/transactions" method="POST" id="movementForm">
            <input type="hidden" name="type" value="STOCK_IN">
                <!-- Custom Autocomplete Product Search -->
                <div class="mb-3 position-relative">
                <label for="productSearch" class="form-label">Select Product</label>
                    <input type="text" id="productSearch" class="form-control" placeholder="Type 1-2 letters to filter products..." autocomplete="off">
                    <div id="autocomplete-list" class="autocomplete-list" style="display: none;"></div>
                    <input type="hidden" name="productId" id="productId" required>
                </div>


                <div class="mb-3 selected-product-meta" id="product-meta-info" style="min-height: 24px;">
                    <!-- Selected product info will be displayed here -->
                </div>

                <div class="mb-3">
                    <label for="quantity" class="form-label">Quantity to Add</label>
                    <input type="number" class="form-control" id="quantity" name="quantity" min="1" placeholder="e.g. 25" required>
                    <div class="form-text text-muted" id="qtyHelper">Adds directly to current capacity.</div>
                </div>
                
                <div class="mb-4">
                    <label for="notes" class="form-label">Procurement Notes / Supplier Details</label>
                    <textarea class="form-control" id="notes" name="notes" rows="4" placeholder="e.g. Supplier invoice ref: 8976, from Fresh Farms Co." required></textarea>
                </div>
                
                <button type="submit" class="btn w-100" style="background:#1a3f6f; color:#fff; font-weight:600; border:none; min-height:46px; border-radius:10px; box-shadow:0 4px 14px rgba(26,63,111,0.3); transition:background 0.18s;" onmouseover="this.style.background='#142f54'" onmouseout="this.style.background='#1a3f6f'">
                    <i class="bi bi-arrow-down-left-circle me-2"></i>Process Stock In
                </button>
            </form>
    </section>

    <!-- History Auditor List -->
    <section class="stock-in-panel stock-in-log-panel">
        <div class="stock-log-header">
            <h5 class="stock-panel-title">
                <i class="bi bi-journal-text"></i> Stock In Audit Log
            </h5>
            <div>
                <input type="text" id="logSearch" class="form-control stock-log-search" placeholder="Search stock in logs...">
            </div>
        </div>
            
        <div class="table-responsive stock-log-table">
                <table class="table glass-table align-middle text-start" id="auditTable">
                <thead>
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
                                <td colspan="5" class="text-center py-4 text-muted">No stock in logs recorded yet.</td>
                            </tr>
                        <% } else {
                            boolean hasStockInRows = false;
                            for (Transaction t : transactions) {
                                if (!"STOCK_IN".equals(t.getType())) {
                                    continue;
                                }
                                hasStockInRows = true;
                        %>
                            <tr class="audit-row">
                                <td>
                                    <div class="fw-semibold search-pname" style="color: var(--text-main);"><%= t.getProductName() %></div>
                                    <div class="text-muted fs-7 search-psku"><%= t.getSku() %></div>
                                </td>
                                <td><span class='badge-custom badge-in-stock'><i class='bi bi-arrow-down-left-circle-fill'></i> Stock In</span></td>
                                <td class="fw-bold" style="color: var(--text-main);"><%= t.getQuantity() %></td>
                                <td>
                                    <div class="search-puser" style="color: var(--text-main);"><%= t.getUserFullname() %></div>
                                    <div class="text-muted fs-7"><%= t.getTransactionDate().toString().substring(0, 16) %></div>
                                </td>
                                <td class="text-muted fs-7 search-pnotes" style="max-width: 180px; white-space: normal;"><%= t.getNotes() %></td>
                            </tr>
                        <% }
                            if (!hasStockInRows) {
                        %>
                            <tr>
                                <td colspan="5" class="text-center py-4 text-muted">No stock in logs recorded yet.</td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
    </section>
</div>
</div>

<jsp:include page="includes/footer.jsp" />

<script>
    // Render product data list safely escaped (no EL parser conflict)
    const products = [
        <%
        if (products != null) {
            for (int i = 0; i < products.size(); i++) {
                Product p = products.get(i);
                String safeName = p.getName().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                String safeSku = p.getSku().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
        %>
        {
            id: <%= p.getId() %>,
            name: "<%= safeName %>",
            sku: "<%= safeSku %>",
            price: <%= p.getPrice() %>,
            stock: <%= p.getStockQuantity() %>
        }<% if (i < products.size() - 1) { %>,<% } %>
        <%
            }
        }
        %>
    ];

    document.addEventListener("DOMContentLoaded", function() {
        const quantityInput    = document.getElementById("quantity");
        const qtyHelper        = document.getElementById("qtyHelper");
        const productSearch    = document.getElementById("productSearch");
        const autocompleteList = document.getElementById("autocomplete-list");
        const productMetaInfo  = document.getElementById("product-meta-info");
        const productIdInput   = document.getElementById("productId");
        const movementForm     = document.getElementById("movementForm");

        let selectedProduct  = null;
        let activeIndex      = -1;
        let filteredProducts = [];

        // Autocomplete search filtering (instant starting from 1 letter typed)
        productSearch.addEventListener("input", function() {
            const query = this.value.toLowerCase().trim();
            activeIndex = -1;
            
            if (!query) {
                hideDropdown();
                return;
            }
            
            filteredProducts = products.filter(p => 
                p.name.toLowerCase().includes(query) || 
                p.sku.toLowerCase().includes(query)
            );
            
            renderDropdown();
        });

        function renderDropdown() {
            autocompleteList.innerHTML = "";
            if (filteredProducts.length === 0) {
                autocompleteList.innerHTML = '<div class="p-3 text-muted text-center fs-7">No products found</div>';
                autocompleteList.style.display = "block";
                return;
            }
            
            filteredProducts.forEach((p, idx) => {
                const item = document.createElement("div");
                item.className = "autocomplete-item";
                if (idx === activeIndex) item.classList.add("active");
                
                const isOutOfStock = p.stock <= 0;
                const stockBadge = isOutOfStock 
                    ? '<span class="badge bg-danger ms-2">Out of Stock</span>' 
                    : '<span class="badge bg-success ms-2">Stock: ' + p.stock + '</span>';
                
                item.innerHTML = 
                    '<div>' +
                        '<strong>' + p.name + '</strong>' +
                        '<div class="item-sku">SKU: ' + p.sku + ' ' + stockBadge + '</div>' +
                    '</div>' +
                    '<div class="item-price">INR ' + p.price.toFixed(2) + '</div>';
                
                item.addEventListener("click", () => selectProduct(p));
                autocompleteList.appendChild(item);
            });
            
            autocompleteList.style.display = "block";
        }

        function selectProduct(product) {
            selectedProduct      = product;
            productSearch.value  = product.name;
            productIdInput.value = product.id;
            hideDropdown();
            updateMetaAndValidation();
            quantityInput.focus();
        }

        function hideDropdown() {
            autocompleteList.style.display = "none";
            activeIndex = -1;
        }

        // Close dropdown on click outside
        document.addEventListener("click", function(e) {
            if (!productSearch.contains(e.target) && !autocompleteList.contains(e.target)) {
                hideDropdown();
            }
        });

        // Keyboard navigation in autocomplete list
        productSearch.addEventListener("keydown", function(e) {
            if (autocompleteList.style.display === "block") {
                if (e.key === "ArrowDown") {
                    e.preventDefault();
                    activeIndex = (activeIndex + 1) % filteredProducts.length;
                    renderDropdown();
                } else if (e.key === "ArrowUp") {
                    e.preventDefault();
                    activeIndex = (activeIndex - 1 + filteredProducts.length) % filteredProducts.length;
                    renderDropdown();
                } else if (e.key === "Enter") {
                    e.preventDefault();
                    if (activeIndex >= 0 && activeIndex < filteredProducts.length) {
                        selectProduct(filteredProducts[activeIndex]);
                    } else if (filteredProducts.length > 0) {
                        selectProduct(filteredProducts[0]);
                    }
                } else if (e.key === "Escape") {
                    hideDropdown();
                }
            } else if (e.key === "Enter") {
                e.preventDefault(); // Prevent accidental form submission
                if (selectedProduct) {
                    quantityInput.focus();
                }
            }
        });

        // Meta-info panel + qty validation
        function updateMetaAndValidation() {
            if (!selectedProduct) return;
            const isOutOfStock = selectedProduct.stock <= 0;
            productMetaInfo.innerHTML = 
                '<span class="text-info"><i class="bi bi-info-circle me-1"></i></span> ' +
                'SKU: <strong style="color: var(--text-main);">' + selectedProduct.sku + '</strong> | ' +
                'Available Stock: <strong class="' + (isOutOfStock ? 'text-danger' : 'text-success') + '">' + selectedProduct.stock + '</strong>';

            quantityInput.removeAttribute("max");
            qtyHelper.innerHTML = "<span class='text-success'>Adds directly to current capacity.</span>";
        }

        // Form submission safety check
        movementForm.addEventListener("submit", function(e) {
            if (!productIdInput.value) {
                e.preventDefault();
                alert("Please select a product from the autocomplete suggestions.");
            }
        });

        // Audit log search filter
        const logSearch = document.getElementById("logSearch");
        const rows = document.querySelectorAll(".audit-row");
        
        logSearch.addEventListener("input", function() {
            const query = logSearch.value.toLowerCase().trim();
            rows.forEach(row => {
                const pname  = row.querySelector(".search-pname").textContent.toLowerCase();
                const psku   = row.querySelector(".search-psku").textContent.toLowerCase();
                const puser  = row.querySelector(".search-puser").textContent.toLowerCase();
                const pnotes = row.querySelector(".search-pnotes").textContent.toLowerCase();
                
                row.style.display = (pname.includes(query) || psku.includes(query) ||
                                     puser.includes(query) || pnotes.includes(query))
                    ? "" : "none";
            });
        });
    });
</script>
