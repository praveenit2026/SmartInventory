<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartinventory.model.Alert" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "System Alerts");
    request.setAttribute("activePage", "alerts");

    List<Alert> alerts = (List<Alert>) request.getAttribute("alerts");

    // Count per type
    int cntAll = 0, cntLow = 0, cntNear = 0, cntExp = 0;
    if (alerts != null) {
        for (Alert a : alerts) {
            cntAll++;
            if ("LOW_STOCK".equals(a.getType()))  cntLow++;
            else if ("NEAR_EXPIRY".equals(a.getType())) cntNear++;
            else if ("EXPIRED".equals(a.getType()))     cntExp++;
        }
    }

    // Active filter from URL param (passed via ?filter=LOW_STOCK etc.)
    String urlFilter = request.getParameter("filter");
    if (urlFilter == null) urlFilter = "ALL";
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<style>
    /* ── Alert Filter Tabs ───────────────────────────────── */
    .alert-filter-tabs {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
        margin-bottom: 20px;
    }
    .alert-filter-btn {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        padding: 8px 18px;
        border-radius: 50px;
        font-size: 0.85rem;
        font-weight: 600;
        cursor: pointer;
        border: 1.5px solid transparent;
        transition: all 0.18s ease;
        background: #f1f5f9;
        color: #374151;
    }
    .alert-filter-btn .badge-count {
        background: rgba(0,0,0,0.12);
        border-radius: 20px;
        font-size: 0.72rem;
        font-weight: 700;
        padding: 1px 7px;
        min-width: 22px;
        text-align: center;
    }
    .alert-filter-btn:hover {
        background: #e2e8f0;
    }
    /* Active states per type */
    .alert-filter-btn.active-all      { background: #1a3f6f; color: #fff; border-color: #1a3f6f; }
    .alert-filter-btn.active-all .badge-count { background: rgba(255,255,255,0.25); color:#fff; }

    .alert-filter-btn.active-low      { background: #d97706; color: #fff; border-color: #d97706; }
    .alert-filter-btn.active-low .badge-count { background: rgba(255,255,255,0.25); color:#fff; }

    .alert-filter-btn.active-near     { background: #2563eb; color: #fff; border-color: #2563eb; }
    .alert-filter-btn.active-near .badge-count { background: rgba(255,255,255,0.25); color:#fff; }

    .alert-filter-btn.active-expired  { background: #dc2626; color: #fff; border-color: #dc2626; }
    .alert-filter-btn.active-expired .badge-count { background: rgba(255,255,255,0.25); color:#fff; }

    /* Alert items hidden by filter */
    .alert-item[data-type].hidden-by-filter { display: none !important; }

    .no-filter-results {
        display: none;
        text-align: center;
        padding: 48px 0;
        color: var(--text-muted);
    }
    .no-filter-results i { font-size: 2.5rem; margin-bottom: 12px; display: block; }
</style>

<div class="page-header">
    <div>
        <h1 class="page-title">Notifications &amp; Alerts</h1>
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

        <!-- Filter Tabs -->
        <div class="alert-filter-tabs" id="filterTabs">
            <button class="alert-filter-btn" data-filter="ALL" onclick="filterAlerts('ALL', this)">
                <i class="bi bi-bell-fill"></i> All Alerts
                <span class="badge-count"><%= cntAll %></span>
            </button>
            <button class="alert-filter-btn" data-filter="LOW_STOCK" onclick="filterAlerts('LOW_STOCK', this)">
                <i class="bi bi-exclamation-triangle-fill" style="color:inherit;"></i> Low Stock
                <span class="badge-count"><%= cntLow %></span>
            </button>
            <button class="alert-filter-btn" data-filter="NEAR_EXPIRY" onclick="filterAlerts('NEAR_EXPIRY', this)">
                <i class="bi bi-calendar-event-fill" style="color:inherit;"></i> Near Expiry
                <span class="badge-count"><%= cntNear %></span>
            </button>
            <button class="alert-filter-btn" data-filter="EXPIRED" onclick="filterAlerts('EXPIRED', this)">
                <i class="bi bi-trash-fill" style="color:inherit;"></i> Expired
                <span class="badge-count"><%= cntExp %></span>
            </button>
        </div>

        <div class="d-flex flex-column gap-3" id="alertList">
            <% for (Alert a : alerts) {
                String typeClass = a.getType(); // LOW_STOCK, NEAR_EXPIRY, EXPIRED
                String readClass = a.isRead() ? "read" : "";
                String icon;
                String title;
                if ("LOW_STOCK".equals(a.getType())) {
                    icon  = "<i class='bi bi-exclamation-triangle-fill text-warning fs-4 me-3'></i>";
                    title = "Low Stock Limit Alarm";
                } else if ("NEAR_EXPIRY".equals(a.getType())) {
                    icon  = "<i class='bi bi-calendar-event-fill text-primary fs-4 me-3'></i>";
                    title = "Near Expiry Warning (30-day window)";
                } else {
                    icon  = "<i class='bi bi-trash-fill text-danger fs-4 me-3'></i>";
                    title = "Expired Product - Remove immediately";
                }
            %>
                <div class="alert-item <%= typeClass %> <%= readClass %>" data-type="<%= a.getType() %>">
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
                                <span class="mx-2">&bull;</span>
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

        <!-- Empty state when filter finds nothing -->
        <div class="no-filter-results" id="noFilterResults">
            <i class="bi bi-funnel-fill text-muted"></i>
            <span id="noFilterMsg">No alerts match this filter.</span>
        </div>

    <% } %>
</div>

<script>
    // Map filter key -> active CSS class
    const activeClassMap = {
        "ALL":        "active-all",
        "LOW_STOCK":  "active-low",
        "NEAR_EXPIRY":"active-near",
        "EXPIRED":    "active-expired"
    };

    function filterAlerts(type, btn) {
        // Update button active state
        document.querySelectorAll(".alert-filter-btn").forEach(b => {
            b.classList.remove("active-all","active-low","active-near","active-expired");
        });
        if (btn && activeClassMap[type]) btn.classList.add(activeClassMap[type]);

        // Show/hide alert rows
        let visible = 0;
        document.querySelectorAll(".alert-item[data-type]").forEach(row => {
            if (type === "ALL" || row.dataset.type === type) {
                row.classList.remove("hidden-by-filter");
                visible++;
            } else {
                row.classList.add("hidden-by-filter");
            }
        });

        // Show/hide empty-state message
        const noResults = document.getElementById("noFilterResults");
        if (noResults) noResults.style.display = visible === 0 ? "block" : "none";
    }

    // Apply initial filter from URL on page load
    document.addEventListener("DOMContentLoaded", function() {
        const urlFilter = "<%= urlFilter %>";
        const matchBtn  = document.querySelector('.alert-filter-btn[data-filter="' + urlFilter + '"]');
        filterAlerts(urlFilter, matchBtn);
    });
</script>

<jsp:include page="includes/footer.jsp" />
