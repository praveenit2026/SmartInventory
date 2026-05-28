    </main> <!-- End app-content -->
</div> <!-- End app-container -->

<!-- Bootstrap 5 Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- jQuery for AJAX and utility scripts -->
<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>

<!-- Live Notification Poller (Dynamic micro-animations and status checks) -->
<script>
    $(document).ready(function() {
        const contextPath = '<%= request.getContextPath() %>';
        
        function pollAlertNotifications() {
            $.ajax({
                url: contextPath + '/alerts?format=json',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    const badge = $('#sidebar-alert-badge');
                    const count = data.count;
                    
                    if (count > 0) {
                        if (badge.length) {
                            badge.text(count);
                            // Highlight animate pulse effect
                            badge.addClass('bg-danger');
                        } else {
                            // Badge did not exist, add it
                            const alertLink = $('a[href$="/alerts"]');
                            alertLink.append('<span class="badge-sidebar bg-danger" id="sidebar-alert-badge">' + count + '</span>');
                        }
                    } else {
                        badge.remove();
                    }
                },
                error: function(xhr, status, error) {
                    console.log("[AlertPoller] Live update check skipped: Session expired or unavailable.");
                }
            });
        }
        
        // Poll every 30 seconds for live updates
        setInterval(pollAlertNotifications, 30000);
    });
</script>
</body>
</html>
