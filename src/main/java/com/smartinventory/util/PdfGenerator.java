package com.smartinventory.util;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfWriter;
import com.smartinventory.model.Product;
import com.smartinventory.model.Transaction;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class PdfGenerator {
    private static final Font TITLE_FONT = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
    private static final Font SUBTITLE_FONT = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14);
    private static final Font HEADER_FONT = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
    private static final Font TEXT_FONT = FontFactory.getFont(FontFactory.HELVETICA, 11);

    /**
     * Generates a PDF bill for a transaction.
     *
     * @param transaction the transaction details
     * @param product the product involved in the transaction
     * @return a byte array containing the PDF data
     * @throws DocumentException if PDF creation fails
     */
    public static byte[] generateBillPdf(Transaction transaction, Product product) throws DocumentException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document();
        PdfWriter.getInstance(document, baos);
        document.open();

        // Title
        Paragraph title = new Paragraph("Smart Inventory – Purchase Bill", TITLE_FONT);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);
        document.add(new Paragraph(" ")); // empty line

        // Transaction details
        document.add(new Paragraph("Transaction Details", SUBTITLE_FONT));
        java.sql.Timestamp txDate = transaction.getTransactionDate();
        if (txDate == null) {
            txDate = new java.sql.Timestamp(System.currentTimeMillis());
        }
        document.add(new Paragraph("Date: " + txDate.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")), TEXT_FONT));
        document.add(new Paragraph("Type: " + transaction.getType(), TEXT_FONT));
        document.add(new Paragraph("Quantity: " + transaction.getQuantity(), TEXT_FONT));
        document.add(new Paragraph("Notes: " + transaction.getNotes(), TEXT_FONT));
        document.add(new Paragraph(" "));

        // Product details
        document.add(new Paragraph("Product Details", SUBTITLE_FONT));
        document.add(new Paragraph("SKU: " + product.getSku(), TEXT_FONT));
        document.add(new Paragraph("Name: " + product.getName(), TEXT_FONT));
        document.add(new Paragraph("Category: " + product.getCategory(), TEXT_FONT));
        document.add(new Paragraph("Unit Price: INR " + String.format("%,.2f", product.getPrice()), TEXT_FONT));
        double total = product.getPrice() * transaction.getQuantity();
        document.add(new Paragraph("Total Amount: INR " + String.format("%,.2f", total), TEXT_FONT));
        document.add(new Paragraph(" "));

        // Footer / Thank you
        Paragraph thanks = new Paragraph("Thank you for your purchase!", SUBTITLE_FONT);
        thanks.setAlignment(Element.ALIGN_CENTER);
        document.add(thanks);

        document.close();
        return baos.toByteArray();
    }

    /**
     * Generates a consolidated PDF bill for multiple products purchased in one transaction.
     *
     * @param items list of {product, quantity} pairs
     * @param customerName the customer's name or notes
     * @param billDate the date of the transaction
     * @return byte array containing the PDF
     */
    public static byte[] generateMultiItemBillPdf(
            List<Product> products,
            List<Integer> quantities,
            String customerName,
            java.sql.Timestamp billDate) throws DocumentException {

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document();
        PdfWriter.getInstance(document, baos);
        document.open();

        // ── Title ──────────────────────────────────────────────────────────
        Paragraph title = new Paragraph("Smart Inventory – Customer Purchase Bill", TITLE_FONT);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);
        document.add(new Paragraph(" "));

        // ── Bill meta ──────────────────────────────────────────────────────
        if (billDate == null) billDate = new java.sql.Timestamp(System.currentTimeMillis());
        String dateStr = billDate.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd-MM-yyyy  HH:mm"));
        document.add(new Paragraph("Date   : " + dateStr, TEXT_FONT));
        document.add(new Paragraph("Customer: " + (customerName != null && !customerName.trim().isEmpty() ? customerName : "Walk-in Customer"), TEXT_FONT));
        document.add(new Paragraph(" "));

        // ── Items table ────────────────────────────────────────────────────
        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{3f, 2f, 1.2f, 2f, 2f});

        // Header row
        String[] headers = {"Product Name", "SKU", "Qty", "Unit Price (INR)", "Subtotal (INR)"};
        for (String h : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(h, HEADER_FONT));
            cell.setBackgroundColor(new com.itextpdf.text.BaseColor(30, 60, 120));
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setPadding(6);
            cell.setBorderColor(com.itextpdf.text.BaseColor.WHITE);
            table.addCell(cell);
        }

        // Data rows
        double grandTotal = 0;
        for (int i = 0; i < products.size(); i++) {
            Product p = products.get(i);
            int qty = quantities.get(i);
            double subtotal = p.getPrice() * qty;
            grandTotal += subtotal;

            table.addCell(styledCell(p.getName(), TEXT_FONT, Element.ALIGN_LEFT));
            table.addCell(styledCell(p.getSku(), TEXT_FONT, Element.ALIGN_CENTER));
            table.addCell(styledCell(String.valueOf(qty), TEXT_FONT, Element.ALIGN_CENTER));
            table.addCell(styledCell(String.format("%,.2f", p.getPrice()), TEXT_FONT, Element.ALIGN_RIGHT));
            table.addCell(styledCell(String.format("%,.2f", subtotal), TEXT_FONT, Element.ALIGN_RIGHT));
        }

        document.add(table);
        document.add(new Paragraph(" "));

        // ── Grand Total ────────────────────────────────────────────────────
        Font totalFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13);
        Paragraph grandTotalPara = new Paragraph("GRAND TOTAL:  INR " + String.format("%,.2f", grandTotal), totalFont);
        grandTotalPara.setAlignment(Element.ALIGN_RIGHT);
        document.add(grandTotalPara);
        document.add(new Paragraph(" "));

        // ── Footer ─────────────────────────────────────────────────────────
        Paragraph thanks = new Paragraph("Thank you for your purchase!", SUBTITLE_FONT);
        thanks.setAlignment(Element.ALIGN_CENTER);
        document.add(thanks);

        document.close();
        return baos.toByteArray();
    }

    private static PdfPCell styledCell(String text, Font font, int alignment) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setHorizontalAlignment(alignment);
        cell.setPadding(5);
        return cell;
    }
}
