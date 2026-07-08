package com.smartinventory.servlet;

import com.google.gson.Gson;
import com.smartinventory.dao.ProductDAO;
import com.smartinventory.dao.TransactionDAO;
import com.smartinventory.model.Product;
import com.smartinventory.model.Transaction;
import com.smartinventory.util.PdfGenerator;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class StockSalesServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        if ("/download-bill".equals(pathInfo)) {
            downloadBill(session, response);
            return;
        }

        listSales(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String customerName = request.getParameter("customerName");
        String cartData = request.getParameter("cartData");
        int userId = (Integer) session.getAttribute("userId");

        try {
            CartItem[] cartItems = gson.fromJson(cartData, CartItem[].class);
            if (cartItems == null || cartItems.length == 0) {
                request.setAttribute("error", "Please add at least one product to the cart.");
                listSales(request, response);
                return;
            }

            List<Product> billProducts = new ArrayList<>();
            List<Integer> billQuantities = new ArrayList<>();

            for (CartItem item : cartItems) {
                if (item == null || item.productId <= 0 || item.quantity <= 0) {
                    request.setAttribute("error", "Invalid cart item found.");
                    listSales(request, response);
                    return;
                }

                Product product = productDAO.getProductById(item.productId);
                if (product == null) {
                    request.setAttribute("error", "One selected product no longer exists.");
                    listSales(request, response);
                    return;
                }
                if (product.getStockQuantity() < item.quantity) {
                    request.setAttribute("error", "Insufficient stock for " + product.getName() + ". Available: " + product.getStockQuantity());
                    listSales(request, response);
                    return;
                }

                Transaction transaction = new Transaction();
                transaction.setProductId(product.getId());
                transaction.setUserId(userId);
                transaction.setType("STOCK_OUT");
                transaction.setQuantity(item.quantity);
                transaction.setNotes(normalizeCustomerName(customerName));

                if (!transactionDAO.addTransaction(transaction)) {
                    request.setAttribute("error", "Failed to complete the sale for " + product.getName() + ".");
                    listSales(request, response);
                    return;
                }

                billProducts.add(product);
                billQuantities.add(item.quantity);
            }

            byte[] billPdf = PdfGenerator.generateMultiItemBillPdf(
                    billProducts,
                    billQuantities,
                    normalizeCustomerName(customerName),
                    new Timestamp(System.currentTimeMillis())
            );
            session.setAttribute("latestBillPdf", billPdf);

            request.setAttribute("success", "Sale completed and bill generated successfully.");
            request.setAttribute("triggerBill", "true");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to complete sale: " + e.getMessage());
        }

        listSales(request, response);
    }

    private void listSales(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("products", productDAO.getAllProducts());
        request.setAttribute("transactions", transactionDAO.getAllTransactions());
        request.getRequestDispatcher("/stock-sales.jsp").forward(request, response);
    }

    private void downloadBill(HttpSession session, HttpServletResponse response) throws IOException {
        byte[] billPdf = (byte[]) session.getAttribute("latestBillPdf");
        if (billPdf == null || billPdf.length == 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No bill has been generated yet.");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=smart-inventory-bill.pdf");
        response.setContentLength(billPdf.length);
        try (ServletOutputStream out = response.getOutputStream()) {
            out.write(billPdf);
        }
    }

    private String normalizeCustomerName(String customerName) {
        if (customerName == null || customerName.trim().isEmpty()) {
            return "Walk-in Customer";
        }
        return customerName.trim();
    }

    private static class CartItem {
        int productId;
        int quantity;
    }
}
