<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.dao.ProductDAO" %>
<%@ page import="com.smartinventory.dao.TransactionDAO" %>
<%@ page import="com.smartinventory.model.Product" %>
<%@ page import="com.smartinventory.model.Transaction" %>
<%@ page import="java.util.List" %>
<%
    // Session validation is handled by header.jsp
    String pageTitle = "Stock Sales";
    request.setAttribute("pageTitle", pageTitle);
    request.setAttribute("activePage", "stock-sales");

    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    String triggerBill = (String) request.getAttribute("triggerBill");

    if (products == null) {
        products = new ProductDAO().getAllProducts();
    }
    if (transactions == null) {
        transactions = new TransactionDAO().getAllTransactions();
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<style>
    .autocomplete-wrapper {
        position: relative;
        width: 100%;
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
    .autocomplete-item .item-stock {
        font-size: 0.8rem;
    }
    .bill-empty-state {
        min-height: 140px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
        border: 1px dashed #cbd5e1;
        border-radius: 12px;
        background: #f8fafc;
        padding: 20px;
    }
    .bill-empty-state i {
        font-size: 2.2rem;
        color: var(--blue);
        margin-bottom: 10px;
    }
    .bill-empty-state h6 {
        color: var(--text-main);
        font-size: 0.95rem;
        margin-bottom: 6px;
    }
    .bill-empty-state p {
        color: var(--text-muted);
        max-width: 300px;
        margin: 0;
        font-size: 0.82rem;
    }
    /* ── Tab switcher ── */
    .right-tabs {
        display: flex;
        gap: 6px;
        margin-bottom: 20px;
        background: #f1f5f9;
        border-radius: 10px;
        padding: 4px;
    }
    .right-tab-btn {
        flex: 1;
        padding: 8px 12px;
        border: none;
        border-radius: 7px;
        background: transparent;
        color: var(--text-muted);
        font-size: 0.85rem;
        font-weight: 500;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        transition: background 0.2s, color 0.2s;
    }
    .right-tab-btn.active {
        background: var(--blue);
        color: #fff;
        box-shadow: 0 2px 10px rgba(37, 99, 235, 0.3);
    }
    .right-tab-btn:not(.active):hover {
        background: #e2e8f0;
        color: var(--text-main);
    }
    .tab-pane { display: none; }
    .tab-pane.active { display: block; }
    /* ── Scrollable log ── */
    .sales-log-scroll {
        max-height: 400px;
        overflow-y: auto;
        overflow-x: hidden;
    }
    .sales-log-scroll::-webkit-scrollbar { width: 4px; }
    .sales-log-scroll::-webkit-scrollbar-track { background: #f1f5f9; }
    .sales-log-scroll::-webkit-scrollbar-thumb {
        background: #bfdbfe;
        border-radius: 4px;
    }
    .log-row-new {
        background: var(--blue-light);
        border-left: 3px solid var(--blue);
    }
    .tab-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 8px;
        height: 8px;
        background: var(--blue);
        border-radius: 50%;
        animation: pulse 1.5s infinite;
    }
    @keyframes pulse {
        0%,100% { opacity:1; transform:scale(1); }
        50%      { opacity:0.6; transform:scale(1.3); }
    }
</style>

<div class="page-header">
    <div>
        <h1 class="page-title">Stock Out / Billing Desk</h1>
        <div class="page-subtitle">Process customer transactions, manage shopping cart, and view/print invoices instantly.</div>
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
    <!-- Left Column: Checkout Desk & Cart -->
    <div class="col-lg-6" id="leftColCart">
        <div class="glass-panel p-4">
            <h5 class="mb-4 d-flex align-items-center gap-2" style="color: var(--text-main);">
                <i class="bi bi-cart3 text-primary"></i> Shopping Cart
            </h5>
            
            <form id="saleForm" action="<%= request.getContextPath() %>/stock-sales" method="POST">
                <!-- Customer Name -->
                <div class="mb-4">
                    <label for="customerName" class="form-label">Customer Name</label>
                    <input type="text" class="form-control" id="customerName" name="customerName" placeholder="Walk-in Customer (Optional)">
                </div>
                
                <hr style="border-color: rgba(255,255,255,0.1);">
                <h6 class="text-muted mb-3">Add Product</h6>
                
                <!-- Search + Qty + Add to Cart on one aligned row -->
                <div class="mb-3">
                    <label for="productSearch" class="form-label">Search Product</label>
                    <div class="d-flex gap-2 align-items-stretch">
                        <!-- Autocomplete wrapper -->
                        <div class="position-relative flex-grow-1">
                            <input type="text" class="form-control h-100" id="productSearch" placeholder="Type product name or SKU..." autocomplete="off" style="height:46px;">
                            <div id="autocomplete-list" class="autocomplete-list" style="display: none;"></div>
                        </div>
                        <!-- Quantity -->
                        <input type="number" class="form-control" id="quantity" min="1" placeholder="Qty" style="width:90px; flex-shrink:0; height:46px;">
                        <!-- Add to Cart button -->
                        <button type="button" class="btn btn-sm d-flex align-items-center gap-1" id="addToCartBtn"
                            style="background:#1a3f6f;color:#fff;font-weight:600;border:none;white-space:nowrap;padding:0 18px;height:46px;border-radius:10px;box-shadow:0 4px 12px rgba(26,63,111,0.25);flex-shrink:0;transition:background 0.18s;"
                            onmouseover="this.style.background='#142f54'" onmouseout="this.style.background='#1a3f6f'">
                            <i class="bi bi-plus-lg"></i> Add to Cart
                        </button>
                    </div>
                </div>

                <!-- Selected product meta info -->
                <div id="product-meta-info" class="text-muted mb-3" style="font-size:0.82rem; min-height:20px;"></div>

                <!-- Cart Table -->
                <div class="table-responsive mb-4" style="overflow-x: auto; border: 1px solid var(--border); border-radius: var(--radius-sm); max-width: 100%;">
                    <table class="table glass-table align-middle text-start mb-0" id="cartTable" style="display: none; width: 100%; min-width: 480px;">
                        <thead>
                            <tr>
                                <th style="padding: 10px 8px !important;">Product</th>
                                <th style="padding: 10px 8px !important;">SKU</th>
                                <th style="padding: 10px 8px !important;">Qty</th>
                                <th style="padding: 10px 8px !important;">Price</th>
                                <th style="padding: 10px 8px !important;">Subtotal</th>
                                <th style="padding: 10px 8px !important;">Action</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>

                <input type="hidden" name="cartData" id="cartData">

                <!-- Grand Total -->
                <div id="cart-total-panel" class="d-flex justify-content-between align-items-center mb-4 p-3 rounded-3" style="background: #f0fdf4; border: 1px solid #bbf7d0; display: none !important;">
                    <span class="fw-bold" style="color: var(--text-main);">Grand Total:</span>
                    <span class="fs-5 fw-bold text-success" id="cartGrandTotal">INR 0.00</span>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn w-100" id="generateBillBtn" disabled
                    style="background:#1a3f6f;color:#fff;font-weight:600;border:none;min-height:46px;border-radius:10px;box-shadow:0 4px 14px rgba(26,63,111,0.3);transition:background 0.18s;"
                    onmouseover="this.style.background='#142f54'" onmouseout="this.style.background='#1a3f6f'">
                    <i class="bi bi-file-earmark-pdf me-2"></i>Complete Sale &amp; Generate Bill
                </button>
            </form>
        </div>
    </div>

    <!-- Right Column: Tabbed Panel (Bill Preview | Recent Transactions) -->
    <div class="col-lg-6" id="rightColTabs">
        <div class="glass-panel p-4">

            <!-- Tab buttons -->
            <div class="right-tabs" id="rightTabs">
                <button class="right-tab-btn active" id="tabBtnBill" onclick="switchTab('bill')">
                    <i class="bi bi-printer"></i> Bill Preview
                </button>
                <button class="right-tab-btn" id="tabBtnLog" onclick="switchTab('log')">
                    <i class="bi bi-clock-history"></i> Recent Transactions
                    <% if ("true".equals(triggerBill) && success != null) { %>
                        <span class="tab-badge ms-1"></span>
                    <% } %>
                </button>
            </div>

            <!-- TAB 1: Bill Preview -->
            <div class="tab-pane active" id="pane-bill">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <span class="text-muted" style="font-size:0.82rem;">
                        <% if ("true".equals(triggerBill) && success != null) { %>
                            Invoice generated successfully.
                        <% } else { %>
                            Complete a sale to generate the invoice.
                        <% } %>
                    </span>
                    <% if ("true".equals(triggerBill) && success != null) { %>
                        <div class="d-flex gap-2">
                            <a href="<%= request.getContextPath() %>/stock-sales/download-bill"
                               class="btn btn-sm btn-outline-success py-1 px-2" download="bill.pdf">
                                <i class="bi bi-download me-1"></i>Download
                            </a>
                            <button type="button" class="btn btn-sm btn-outline-info py-1 px-2" onclick="printIframe()">
                                <i class="bi bi-printer me-1"></i>Print
                            </button>
                        </div>
                    <% } %>
                </div>

                <% if ("true".equals(triggerBill) && success != null) { %>
                    <div style="height: 440px;">
                        <iframe id="billIframe"
                            src="<%= request.getContextPath() %>/stock-sales/download-bill#toolbar=0&navpanes=0"
                            class="rounded-3 w-100 h-100 border border-secondary"
                            style="background: white;">
                        </iframe>
                    </div>
                <% } else { %>
                    <div class="bill-empty-state" style="min-height: 440px;">
                        <i class="bi bi-receipt-cutoff"></i>
                        <h6>Bill preview will appear here</h6>
                        <p>Add products to the cart and click &ldquo;Complete Sale &amp; Generate Bill&rdquo; to view the invoice.</p>
                    </div>
                <% } %>
            </div>

            <!-- TAB 2: Recent Transactions -->
            <div class="tab-pane" id="pane-log">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <span class="text-muted" style="font-size:0.82rem;">All outgoing sales transactions</span>
                    <input type="text" id="logSearch" class="form-control form-control-sm" style="max-width: 200px;" placeholder="Search logs...">
                </div>

                <div class="sales-log-scroll">
                    <table class="table glass-table align-middle text-start mb-0" id="auditTable">
                        <thead style="position: sticky; top: 0; z-index: 2; background: #f8fafc;">
                            <tr>
                                <th style="padding: 10px 12px;">Product</th>
                                <th style="padding: 10px 12px;">Qty</th>
                                <th style="padding: 10px 12px;">Date &amp; Operator</th>
                                <th style="padding: 10px 12px;">Customer / Notes</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (transactions == null || transactions.isEmpty()) { %>
                                <tr><td colspan="4" class="text-center py-4 text-muted">No sales recorded yet.</td></tr>
                            <% } else {
                                boolean hasSalesRows = false;
                                int rowCount = 0;
                                for (Transaction t : transactions) {
                                    if (!"STOCK_OUT".equals(t.getType())) continue;
                                    hasSalesRows = true;
                                    boolean isLatest = (rowCount == 0 && "true".equals(triggerBill) && success != null);
                                    String rowCls = isLatest ? "audit-row log-row-new" : "audit-row";
                                    rowCount++;
                            %>
                                <tr class="<%= rowCls %>">
                                    <td style="padding: 10px 12px;">
                                        <div class="fw-semibold text-white search-pname" style="font-size:0.9rem;"><%= t.getProductName() %></div>
                                        <div class="text-muted search-psku" style="font-size:0.78rem;"><%= t.getSku() %></div>
                                    </td>
                                    <td class="fw-bold text-white" style="padding:10px 12px;"><%= t.getQuantity() %></td>
                                    <td style="padding:10px 12px;">
                                        <div class="text-white search-puser" style="font-size:0.88rem;"><%= t.getUserFullname() %></div>
                                        <div class="text-muted" style="font-size:0.76rem;"><%= t.getTransactionDate().toString().substring(0, 16) %></div>
                                    </td>
                                    <td class="text-muted search-pnotes" style="padding:10px 12px; font-size:0.8rem; max-width:140px; white-space:normal;"><%= t.getNotes() %></td>
                                </tr>
                            <% }
                                if (!hasSalesRows) { %>
                                <tr><td colspan="4" class="text-center py-4 text-muted">No sales recorded yet.</td></tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

<script>
    // Render product data list safely escaped
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

    const productSearch = document.getElementById('productSearch');
    const autocompleteList = document.getElementById('autocomplete-list');
    const productMetaInfo = document.getElementById('product-meta-info');
    const quantityInput = document.getElementById('quantity');
    const addToCartBtn = document.getElementById('addToCartBtn');
    const cartTable = document.getElementById('cartTable');
    const cartBody = cartTable ? cartTable.querySelector('tbody') : null;
    const cartTotalPanel = document.getElementById('cart-total-panel');
    const cartGrandTotal = document.getElementById('cartGrandTotal');
    const generateBtn = document.getElementById('generateBillBtn');
    const cartDataInput = document.getElementById('cartData');

    let selectedProduct = null;
    let filteredProducts = [];
    let activeIndex = -1;
    const cart = [];
    // ── Tab switcher ─────────────────────────────────────────
    function switchTab(tab) {
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.right-tab-btn').forEach(b => b.classList.remove('active'));

        const leftCol = document.getElementById('leftColCart');
        const rightCol = document.getElementById('rightColTabs');

        if (tab === 'bill') {
            document.getElementById('pane-bill').classList.add('active');
            document.getElementById('tabBtnBill').classList.add('active');
            if (leftCol && rightCol) {
                leftCol.style.display = '';
                rightCol.className = 'col-lg-6';
            }
        } else {
            document.getElementById('pane-log').classList.add('active');
            document.getElementById('tabBtnLog').classList.add('active');
            if (leftCol && rightCol) {
                leftCol.style.display = 'none';
                rightCol.className = 'col-lg-12';
            }
        }
    }

    // Auto-activate correct tab on page load
    (function() {
        const billGenerated = '<%= "true".equals(triggerBill) && success != null ? "true" : "false" %>';
        if (billGenerated === 'true') {
            switchTab('bill');   // show bill right after sale
        } else {
            switchTab('bill');   // default to bill tab
        }
    })();

    // ── Log search filter ─────────────────────────────────────
    document.getElementById('logSearch') && document.getElementById('logSearch').addEventListener('input', function() {
        const q = this.value.toLowerCase();
        document.querySelectorAll('#auditTable .audit-row').forEach(row => {
            const text = row.innerText.toLowerCase();
            row.style.display = text.includes(q) ? '' : 'none';
        });
    });

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
        hideDropdown();
        
        const isOutOfStock = product.stock <= 0;
        productMetaInfo.innerHTML = 
            '<span class="text-info"><i class="bi bi-info-circle me-1"></i></span> ' +
            'SKU: <strong class="text-white">' + product.sku + '</strong> | ' +
            'Price: <strong class="text-success">INR ' + product.price.toFixed(2) + '</strong> | ' +
            'Available Stock: <strong class="' + (isOutOfStock ? 'text-danger' : 'text-white') + '">' + product.stock + '</strong>';
        
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

    // Prevent accidental form submission on Enter inside quantity
    quantityInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            addItemToCart();
        }
    });

    // Add product to cart logic
    function addItemToCart() {
        const qty = parseInt(quantityInput.value);
        if (!selectedProduct) {
            alert('Please search and select a product first.');
            return;
        }
        if (isNaN(qty) || qty <= 0) {
            alert('Please enter a valid quantity.');
            return;
        }
        
        // Check if item already in cart, accumulate quantity
        const existingItem = cart.find(item => item.productId === selectedProduct.id);
        const currentQtyInCart = existingItem ? existingItem.quantity : 0;
        const totalQty = currentQtyInCart + qty;
        
        if (totalQty > selectedProduct.stock) {
            alert(`Insufficient stock. Available: ${selectedProduct.stock}. You already have ${currentQtyInCart} in your cart.`);
            return;
        }

        if (existingItem) {
            existingItem.quantity = totalQty;
        } else {
            cart.push({
                productId: selectedProduct.id,
                name: selectedProduct.name,
                sku: selectedProduct.sku,
                price: selectedProduct.price,
                quantity: qty // matches servlet attribute parsing
            });
        }

        // Reset product fields
        productSearch.value = '';
        quantityInput.value = '';
        productMetaInfo.innerHTML = '';
        selectedProduct = null;
        
        refreshCart();
    }

    addToCartBtn.addEventListener('click', addItemToCart);

    function refreshCart() {
        cartBody.innerHTML = '';
        let grandTotal = 0;
        
        cart.forEach((item, idx) => {
            const subtotal = item.price * item.quantity;
            grandTotal += subtotal;
            
            const row = document.createElement('tr');
            row.innerHTML = 
                '<td style="padding: 10px 8px !important;"><div class="fw-semibold text-white">' + item.name + '</div></td>' +
                '<td style="padding: 10px 8px !important;"><span class="text-muted fs-7">' + item.sku + '</span></td>' +
                '<td style="padding: 10px 8px !important;" class="text-white">' + item.quantity + '</td>' +
                '<td style="padding: 10px 8px !important;">INR ' + item.price.toFixed(2) + '</td>' +
                '<td style="padding: 10px 8px !important;" class="fw-bold text-white">INR ' + subtotal.toFixed(2) + '</td>' +
                '<td style="padding: 10px 8px !important;">' +
                    '<button type="button" class="btn btn-sm btn-outline-danger py-1 px-2" onclick="removeItem(' + idx + ')">' +
                        '<i class="bi bi-trash"></i>' +
                    '</button>' +
                '</td>';
            cartBody.appendChild(row);
        });
        
        if (cart.length > 0) {
            cartTable.style.display = 'table';
            cartTotalPanel.setAttribute('style', 'display: flex !important;'); // show total panel
            generateBtn.disabled = false;
        } else {
            cartTable.style.display = 'none';
            cartTotalPanel.setAttribute('style', 'display: none !important;'); // hide total panel
            generateBtn.disabled = true;
        }
        
        cartGrandTotal.textContent = 'INR ' + grandTotal.toFixed(2);
        cartDataInput.value = JSON.stringify(cart);
    }

    window.removeItem = function(index) {
        cart.splice(index, 1);
        refreshCart();
    };

    // PDF Viewer print logic
    window.printIframe = function() {
        const iframe = document.getElementById('billIframe');
        if (iframe) {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
        }
    };

    // Recent Sales audit log search filter
    const logSearch = document.getElementById("logSearch");
    if (logSearch) {
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
    }
</script>
