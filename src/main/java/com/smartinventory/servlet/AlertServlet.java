package com.smartinventory.servlet;

import com.google.gson.Gson;
import com.smartinventory.dao.AlertDAO;
import com.smartinventory.model.Alert;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AlertServlet extends HttpServlet {
    private final AlertDAO alertDAO = new AlertDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            String format = request.getParameter("format");
            if ("json".equals(format)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        String format = request.getParameter("format");

        if ("json".equals(format)) {
            // REST endpoint to retrieve live unread counts for custom widgets
            List<Alert> unread = alertDAO.getUnreadAlerts();
            Map<String, Object> data = new HashMap<>();
            data.put("count", unread.size());
            data.put("alerts", unread);
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print(gson.toJson(data));
            }
            return;
        }

        if (pathInfo != null) {
            if (pathInfo.equals("/read")) {
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    alertDAO.markAsRead(id);
                } catch (NumberFormatException ignored) {}
                response.sendRedirect(request.getContextPath() + "/alerts");
                return;
            } else if (pathInfo.equals("/readAll")) {
                alertDAO.markAllAsRead();
                response.sendRedirect(request.getContextPath() + "/alerts");
                return;
            }
        }

        listAlerts(request, response);
    }

    private void listAlerts(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Alert> alerts = alertDAO.getAllAlerts();
        request.setAttribute("alerts", alerts);
        request.getRequestDispatcher("/alerts.jsp").forward(request, response);
    }
}
