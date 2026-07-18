package com.smartinventory.servlet;

import com.smartinventory.dao.UserDAO;
import com.smartinventory.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class AuthServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    /**
     * Offline fallback credentials — used when the Supabase database is paused/offline.
     * If the DB is online, the real DB record is fetched first (which takes priority).
     * Format: username -> [password, fullname, role, email, id]
     */
    private static final Map<String, String[]> OFFLINE_USERS = new HashMap<>();
    static {
        OFFLINE_USERS.put("admin",   new String[]{"admin123",   "Administrator",      "ADMIN",   "admin@smartinventory.com",   "1"});
        OFFLINE_USERS.put("manager", new String[]{"manager123", "Inventory Manager",  "MANAGER", "manager@smartinventory.com", "2"});
        OFFLINE_USERS.put("demo",    new String[]{"demo123",    "Demo User",          "DEMO",    "demo@smartinventory.com",    "-1"});
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && pathInfo.equals("/logout")) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp?logout=true");
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && pathInfo.equals("/login")) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Username and password are required.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            username = username.trim();
            password = password.trim();

            User user = null;

            // 1. Try the live database first (works when Supabase is online)
            //    Skip DB call for demo user since demo is always in-memory
            if (!"demo".equals(username)) {
                try {
                    user = userDAO.authenticate(username, password);
                } catch (Exception e) {
                    System.err.println("[AuthServlet] DB auth failed, will try offline fallback: " + e.getMessage());
                }
            }

            boolean isOfflineLogin = false;
            // 2. If DB is offline or returned null, fall back to built-in offline credentials
            if (user == null) {
                String[] offlineEntry = OFFLINE_USERS.get(username);
                if (offlineEntry != null && offlineEntry[0].equals(password)) {
                    user = new User();
                    user.setId(Integer.parseInt(offlineEntry[4]));
                    user.setUsername(username);
                    user.setPassword(offlineEntry[0]);
                    user.setFullname(offlineEntry[1]);
                    user.setRole(offlineEntry[2]);
                    user.setEmail(offlineEntry[3]);
                    isOfflineLogin = true;
                    System.out.println("[AuthServlet] Logged in via offline fallback: " + username + " (" + offlineEntry[2] + ")");
                }
            }

            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("fullname", user.getFullname());
                session.setAttribute("role", user.getRole());
                if (isOfflineLogin || "DEMO".equals(user.getRole())) {
                    session.setAttribute("useDemoData", true);
                } else {
                    session.setAttribute("useDemoData", false);
                }
                
                response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            } else {
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }
}
