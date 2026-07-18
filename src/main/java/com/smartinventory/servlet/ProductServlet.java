package com.smartinventory.servlet;

import com.smartinventory.dao.ProductDAO;
import com.smartinventory.dao.SupplierDAO;
import com.smartinventory.model.Product;
import com.smartinventory.model.User;
import com.smartinventory.service.AlertScheduler;
import com.smartinventory.util.UserContext;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

public class ProductServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && pathInfo.equals("/delete")) {
            // Access control check - Only Admin can delete products
            String role = (String) session.getAttribute("role");
            if (!"ADMIN".equals(role) && !"DEMO".equals(role)) {
                request.setAttribute("error", "Access Denied: Only Administrators and Demo users can delete products.");
                listProducts(request, response);
                return;
            }

            try {
                int id = Integer.parseInt(request.getParameter("id"));
                if (productDAO.deleteProduct(id)) {
                    request.setAttribute("success", "Product deleted successfully.");
                } else {
                    request.setAttribute("error", "Failed to delete product.");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid Product ID.");
            }
            listProducts(request, response);
        } else {
            listProducts(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && (pathInfo.equals("/add") || pathInfo.equals("/update"))) {
            try {
                Product p = new Product();
                
                String idStr = request.getParameter("id");
                if (idStr != null && !idStr.trim().isEmpty()) {
                    p.setId(Integer.parseInt(idStr));
                }
                
                p.setSku(request.getParameter("sku"));
                p.setName(request.getParameter("name"));
                p.setDescription(request.getParameter("description"));
                p.setCategory(request.getParameter("category"));
                p.setPrice(Double.parseDouble(request.getParameter("price")));
                
                String stockStr = request.getParameter("stockQuantity");
                p.setStockQuantity(stockStr != null ? Integer.parseInt(stockStr) : 0);
                
                String minStr = request.getParameter("minStockLevel");
                p.setMinStockLevel(minStr != null ? Integer.parseInt(minStr) : 5);
                
                String expiryStr = request.getParameter("expiryDate");
                if (expiryStr != null && !expiryStr.trim().isEmpty()) {
                    p.setExpiryDate(Date.valueOf(expiryStr));
                } else {
                    p.setExpiryDate(null);
                }
                
                String supplierStr = request.getParameter("supplierId");
                if (supplierStr != null && !supplierStr.trim().isEmpty()) {
                    p.setSupplierId(Integer.parseInt(supplierStr));
                }
                
                boolean result;
                if (pathInfo.equals("/add")) {
                    result = productDAO.addProduct(p);
                    if (result) {
                        request.setAttribute("success", "Product added successfully.");
                        // Immediately check alerts for the new product (no need to wait for scheduler)
                        if (!UserContext.isDemo()) {
                            AlertScheduler.checkSingleProduct(p);
                        }
                    } else {
                        request.setAttribute("error", "Failed to add product. SKU may already exist.");
                    }
                } else {
                    // Update flow
                    result = productDAO.updateProduct(p);
                    if (result) {
                        request.setAttribute("success", "Product updated successfully.");
                        // Immediately re-check alerts when product is edited (e.g. expiry date changed)
                        if (!UserContext.isDemo()) {
                            AlertScheduler.checkSingleProduct(p);
                        }
                    } else {
                        request.setAttribute("error", "Failed to update product.");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Invalid inputs: " + e.getMessage());
            }
            listProducts(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Product> products = productDAO.getAllProducts();
        request.setAttribute("products", products);
        request.setAttribute("suppliers", supplierDAO.getAllSuppliers());
        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }
}
