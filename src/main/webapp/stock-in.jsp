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
    .autocomplete-item .item-stock {
        font-size: 0.8rem;
    }
</style>

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

<div class="row g-4 mb-4">
    <!-- Form Card: Register Stock In -->
    <div class="col-lg-4">
        <div class="glass-panel p-4 h-100">
            <h5 class="mb-4 d-flex align-items-center gap-2" style="color: var(--text-main);">
                <i class="bi bi-plus-circle text-primary"></i> Log Stock Inflow
            </h5>
            
            <form action="<%= request.getContextPath() %>/stock-in" method="POST">
                <div class="mb-3 position-relative">
                    <label for="productSearch" class="form-label">Search Product</label>
                    <input type="text" id="productSearch" class="form-control" placeholder="Type product name or SKU..." autocomplete="off">
                    <div id="autocomplete-list" class="autocomplete-list" style="display: none;"></div>
                    <input type="hidden" name="productId" id="productId" required>
                </div>

                <div class="mb-3" id="product-meta-info" style="min-height: 24px;">
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
                
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-arrow-down-left-circle me-2"></i>Process Stock In
                </button>
            </form>
        </div>
    </div>

    <!-- History Auditor List -->
    <div class="col-lg-8">
        <div class="glass-panel p-4 h-100">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="m-0 d-flex align-items-center gap-2" style="color: var(--text-main);">
                    <i class="bi bi-journal-text text-primary"></i> Stock In Audit Log
                </h5>
                <input type="text" id="logSearch" class="form-control form-control-sm w-50" placeholder="Search stock in logs...">
            </div>
            
            <div class="table-responsive">
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
                            for (Transaction t : transactions) {
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
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
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
        // Log search filter
        const logSearch = document.getElementById("logSearch");
        const rows = document.querySelectorAll(".audit-row");
        
        if (logSearch) {
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
        }

        // Custom Product Autocomplete Dropdown Search
        let selectedProduct = null;
        const productSearch = document.getElementById('productSearch');
        const autocompleteList = document.getElementById('autocomplete-list');
        const productMetaInfo = document.getElementById('product-meta-info');
        const productIdInput = document.getElementById('productId');
        const quantityInput = document.getElementById('quantity');
        const submitForm = document.querySelector('form');
        
        let activeIndex = -1;
        let filteredProducts = [];

        // Autocomplete search filtering (instant starting from 1 letter typed)
        productSearch.addEventListener('input', function() {
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
            autocompleteList.innerHTML = '';
            if (filteredProducts.length === 0) {
                autocompleteList.innerHTML = '<div class="p-3 text-muted text-center fs-7">No products found</div>';
                autocompleteList.style.display = 'block';
                return;
            }
            
            filteredProducts.forEach((p, idx) => {
                const item = document.createElement('div');
                item.className = 'autocomplete-item';
                if (idx === activeIndex) item.classList.add('active');
                
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
                
                item.addEventListener('click', () => selectProduct(p));
                autocompleteList.appendChild(item);
            });
            
            autocompleteList.style.display = 'block';
        }

        function selectProduct(product) {
            selectedProduct = product;
            productSearch.value = product.name;
            productIdInput.value = product.id;
            hideDropdown();
            
            const isOutOfStock = product.stock <= 0;
            productMetaInfo.innerHTML = 
                '<span class="text-info"><i class="bi bi-info-circle me-1"></i></span> ' +
                'SKU: <strong style="color: var(--text-main);">' + product.sku + '</strong> | ' +
                'Available Stock: <strong class="' + (isOutOfStock ? 'text-danger' : 'text-success') + '">' + product.stock + '</strong>';
            
            quantityInput.focus();
        }

        function hideDropdown() {
            autocompleteList.style.display = 'none';
            activeIndex = -1;
        }

        // Close dropdown on click outside
        document.addEventListener('click', function(e) {
            if (!productSearch.contains(e.target) && !autocompleteList.contains(e.target)) {
                hideDropdown();
            }
        });

        // Keyboard navigation in autocomplete list
        productSearch.addEventListener('keydown', function(e) {
            if (autocompleteList.style.display === 'block') {
                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    activeIndex = (activeIndex + 1) % filteredProducts.length;
                    renderDropdown();
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    activeIndex = (activeIndex - 1 + filteredProducts.length) % filteredProducts.length;
                    renderDropdown();
                } else if (e.key === 'Enter') {
                    e.preventDefault();
                    if (activeIndex >= 0 && activeIndex < filteredProducts.length) {
                        selectProduct(filteredProducts[activeIndex]);
                    } else if (filteredProducts.length > 0) {
                        selectProduct(filteredProducts[0]);
                    }
                } else if (e.key === 'Escape') {
                    hideDropdown();
                }
            } else if (e.key === 'Enter') {
                e.preventDefault(); // Prevent accidental form submission
                if (selectedProduct) {
                    quantityInput.focus();
                }
            }
        });

        // Form submission safety check
        if (submitForm) {
            submitForm.addEventListener('submit', function(e) {
                if (!productIdInput.value) {
                    e.preventDefault();
                    alert('Please select a product from the autocomplete suggestions.');
                }
            });
        }
    });
</script>
