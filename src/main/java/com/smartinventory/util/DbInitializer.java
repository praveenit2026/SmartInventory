package com.smartinventory.util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.Map;

public class DbInitializer {
    public static void main(String[] args) {
        String password = "Praveen@2005<>";
        String sqlFilePath = "supabase_schema.sql";

        // Try different regions and usernames
        Map<String, String[]> connectionOptions = new LinkedHashMap<>();
        connectionOptions.put("Mumbai Pooler (ap-south-1)", new String[]{
            "jdbc:postgresql://aws-0-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require",
            "postgres.wrzgzswlpblqvcjrbunn"
        });
        connectionOptions.put("Seoul Pooler (ap-northeast-2)", new String[]{
            "jdbc:postgresql://aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres?sslmode=require",
            "postgres.wrzgzswlpblqvcjrbunn"
        });
        connectionOptions.put("Singapore Pooler (ap-southeast-1)", new String[]{
            "jdbc:postgresql://aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?sslmode=require",
            "postgres.wrzgzswlpblqvcjrbunn"
        });
        connectionOptions.put("Direct Connection (IPv6)", new String[]{
            "jdbc:postgresql://db.wrzgzswlpblqvcjrbunn.supabase.co:5432/postgres?sslmode=require",
            "postgres"
        });

        System.out.println("Beginning database connection diagnostic and initialization...");
        Connection conn = null;
        String selectedOptionName = null;
        String selectedUrl = null;
        String selectedUser = null;

        for (Map.Entry<String, String[]> entry : connectionOptions.entrySet()) {
            String optionName = entry.getKey();
            String url = entry.getValue()[0];
            String user = entry.getValue()[1];

            System.out.println("\nTesting connection via " + optionName + "...");
            System.out.println("URL: " + url);
            System.out.println("User: " + user);

            try {
                Class.forName("org.postgresql.Driver");
                conn = DriverManager.getConnection(url, user, password);
                System.out.println(">>> SUCCESS! Connected to Supabase via " + optionName + "!");
                selectedOptionName = optionName;
                selectedUrl = url;
                selectedUser = user;
                break;
            } catch (Exception e) {
                System.out.println(">>> FAILED. Error: " + e.getMessage());
            }
        }

        if (conn == null) {
            System.err.println("\n=======================================================");
            System.err.println("CRITICAL ERROR: Could not connect to Supabase using any of the connection options.");
            System.err.println("This usually means one of the following:");
            System.err.println("1. Your Supabase project is currently PAUSED or UNHEALTHY. Please log into Supabase and restore it.");
            System.err.println("2. The database password 'Praveen@2005<>' is incorrect or has been changed.");
            System.err.println("3. The project ID 'wrzgzswlpblqvcjrbunn' is incorrect.");
            System.err.println("=======================================================");
            System.exit(1);
        }

        // Initialize schema using the successful connection
        try (Connection activeConn = conn;
             Statement stmt = activeConn.createStatement()) {
            
            System.out.println("\nReading schema script: " + sqlFilePath);
            StringBuilder sb = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new FileReader(sqlFilePath))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.trim().startsWith("--") || line.trim().isEmpty()) {
                        continue;
                    }
                    sb.append(line).append("\n");
                }
            }

            String[] statements = sb.toString().split(";");
            System.out.println("Executing SQL statements (" + statements.length + " found)...");

            for (String sql : statements) {
                String trimmedSql = sql.trim();
                if (!trimmedSql.isEmpty()) {
                    stmt.execute(trimmedSql);
                }
            }

            System.out.println("\n=======================================================");
            System.out.println("Database schema and seed data initialized successfully on Supabase!");
            System.out.println("Connection used: " + selectedOptionName);
            System.out.println("=======================================================");

            // Also write the working properties to db.properties
            updateDbProperties(selectedUrl, selectedUser, password);

        } catch (Exception e) {
            System.err.println("Error executing schema script:");
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void updateDbProperties(String url, String user, String password) {
        try {
            java.io.File propFile = new java.io.File("src/main/resources/db.properties");
            java.io.PrintWriter pw = new java.io.PrintWriter(propFile);
            pw.println("# Database Connection Properties");
            pw.println("db.driver=org.postgresql.Driver");
            pw.println("db.url=" + url);
            pw.println("db.username=" + user);
            pw.println("db.password=" + password);
            pw.close();
            System.out.println("Successfully updated db.properties with the working connection settings!");
        } catch (Exception e) {
            System.err.println("Failed to write working settings to db.properties: " + e.getMessage());
        }
    }
}
