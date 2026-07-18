package com.smartinventory.servlet;

import com.smartinventory.util.UserContext;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class SessionFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            HttpSession session = httpRequest.getSession(false);
            if (session != null) {
                String role = (String) session.getAttribute("role");
                if (role != null) {
                    UserContext.setRole(role);
                }
                Boolean useDemo = (Boolean) session.getAttribute("useDemoData");
                if (useDemo != null) {
                    UserContext.setUseDemoData(useDemo);
                }
            }
        }
        try {
            chain.doFilter(request, response);
        } finally {
            UserContext.clear();
        }
    }

    @Override
    public void destroy() {}
}
