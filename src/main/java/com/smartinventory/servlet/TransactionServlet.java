package com.smartinventory.servlet;

import com.smartinventory.dao.ProductDAO;
import com.smartinventory.dao.TransactionDAO;
import com.smartinventory.model.Product;
import com.smartinventory.model.Transaction;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class TransactionServlet extends HttpServlet {
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        listTransactions(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String type = request.getParameter("type"); // STOCK_IN or STOCK_OUT
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String notes = request.getParameter("notes");
            int userId = (Integer) session.getAttribute("userId");
            
            if (quantity <= 0) {
                request.setAttribute("error", "Quantity must be greater than zero.");
                listTransactions(request, response);
                return;
            }

            Product product = productDAO.getProductById(productId);
            if (product == null) {
                request.setAttribute("error", "Selected product does not exist.");
                listTransactions(request, response);
                return;
            }

            // Validation: Check for stock levels before allowing STOCK_OUT
            if ("STOCK_OUT".equalsIgnoreCase(type) && product.getStockQuantity() < quantity) {
                request.setAttribute("error", "Insufficient stock! Only " + product.getStockQuantity() + " units available.");
                listTransactions(request, response);
                return;
            }

            // Assemble Transaction Model
            Transaction t = new Transaction();
            t.setProductId(productId);
            t.setUserId(userId);
            t.setType(type);
            t.setQuantity(quantity);
            t.setNotes(notes);

            boolean success = transactionDAO.addTransaction(t);
            if (success) {
                request.setAttribute("success", "Stock transaction processed successfully.");
            } else {
                request.setAttribute("error", "Failed to process stock transaction.");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid numeric values entered.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
        }

        listTransactions(request, response);
    }

    private void listTransactions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Transaction> transactions = transactionDAO.getAllTransactions();
        List<Product> products = productDAO.getAllProducts();
        
        request.setAttribute("transactions", transactions);
        request.setAttribute("products", products);
        
        request.getRequestDispatcher("/transactions.jsp").forward(request, response);
    }
}
