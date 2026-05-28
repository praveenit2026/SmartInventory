package com.smartinventory.servlet;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.smartinventory.dao.ProductDAO;
import com.smartinventory.model.Product;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.List;

public class ReportServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null) {
            if (pathInfo.equals("/csv")) {
                exportCSV(response);
                return;
            } else if (pathInfo.equals("/pdf")) {
                exportPDF(response);
                return;
            }
        }

        // Default: Forward to the report panel page
        request.setAttribute("products", productDAO.getAllProducts());
        request.getRequestDispatcher("/reports.jsp").forward(request, response);
    }

    private void exportCSV(HttpServletResponse response) throws IOException {
        List<Product> products = productDAO.getAllProducts();
        
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"inventory_report.csv\"");
        
        try (PrintWriter writer = response.getWriter()) {
            // Write CSV Header
            writer.println("SKU,Product Name,Category,Price (INR),Stock Quantity,Min Stock Level,Supplier,Expiry Date,Status");
            
            for (Product p : products) {
                String status = "In Stock";
                if (p.getStockQuantity() <= 0) {
                    status = "Out of Stock";
                } else if (p.getStockQuantity() <= p.getMinStockLevel()) {
                    status = "Low Stock";
                }
                
                writer.println(String.format("\"%s\",\"%s\",\"%s\",%.2f,%d,%d,\"%s\",\"%s\",\"%s\"",
                    p.getSku(),
                    p.getName().replace("\"", "\"\""),
                    p.getCategory().replace("\"", "\"\""),
                    p.getPrice(),
                    p.getStockQuantity(),
                    p.getMinStockLevel(),
                    (p.getSupplierName() != null ? p.getSupplierName().replace("\"", "\"\"") : "None"),
                    (p.getExpiryDate() != null ? p.getExpiryDate().toString() : "N/A"),
                    status
                ));
            }
            writer.flush();
        }
    }

    private void exportPDF(HttpServletResponse response) throws IOException {
        List<Product> products = productDAO.getAllProducts();
        
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"inventory_report.pdf\"");
        
        try (OutputStream out = response.getOutputStream()) {
            Document document = new Document(PageSize.A4, 36, 36, 54, 36);
            PdfWriter.getInstance(document, out);
            document.open();
            
            // Fonts
            Font titleFont = new Font(Font.FontFamily.HELVETICA, 20, Font.BOLD, new BaseColor(18, 30, 49));
            Font subtitleFont = new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC, BaseColor.GRAY);
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, BaseColor.WHITE);
            Font bodyFont = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL, BaseColor.BLACK);
            Font lowStockFont = new Font(Font.FontFamily.HELVETICA, 8, Font.BOLD, new BaseColor(220, 53, 69));
            
            // Title Header
            Paragraph title = new Paragraph("SMART INVENTORY CONTROL SYSTEM", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            
            Paragraph subtitle = new Paragraph("Master Stock Status Report - Generated Automatically", subtitleFont);
            subtitle.setAlignment(Element.ALIGN_CENTER);
            subtitle.setSpacingAfter(20);
            document.add(subtitle);
            
            // Create Table
            PdfPTable table = new PdfPTable(7);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1.5f, 2.5f, 1.5f, 1.2f, 1.2f, 2.0f, 1.2f});
            
            // Table Headers
            String[] headers = {"SKU", "Product Name", "Category", "Price", "Stock", "Supplier", "Status"};
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, headerFont));
                cell.setBackgroundColor(new BaseColor(18, 30, 49));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPadding(6);
                table.addCell(cell);
            }
            
            // Table Body
            for (Product p : products) {
                String status = "OK";
                Font statusFont = bodyFont;
                if (p.getStockQuantity() <= 0) {
                    status = "OUT";
                    statusFont = lowStockFont;
                } else if (p.getStockQuantity() <= p.getMinStockLevel()) {
                    status = "LOW";
                    statusFont = lowStockFont;
                }
                
                table.addCell(new PdfPCell(new Phrase(p.getSku(), bodyFont)));
                table.addCell(new PdfPCell(new Phrase(p.getName(), bodyFont)));
                table.addCell(new PdfPCell(new Phrase(p.getCategory(), bodyFont)));
                table.addCell(new PdfPCell(new Phrase("INR " + p.getPrice(), bodyFont)));
                
                PdfPCell qtyCell = new PdfPCell(new Phrase(String.valueOf(p.getStockQuantity()), (status.equals("OK") ? bodyFont : lowStockFont)));
                qtyCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(qtyCell);
                
                table.addCell(new PdfPCell(new Phrase(p.getSupplierName() != null ? p.getSupplierName() : "None", bodyFont)));
                
                PdfPCell statCell = new PdfPCell(new Phrase(status, statusFont));
                statCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(statCell);
            }
            
            document.add(table);
            document.close();
            out.flush();
        } catch (DocumentException e) {
            throw new IOException("PDF generation error: " + e.getMessage(), e);
        }
    }
}
