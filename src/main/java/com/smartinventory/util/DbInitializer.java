package com.smartinventory.util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DbInitializer {
    public static void main(String[] args) {
        String jdbcUrl = "jdbc:postgresql://aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?sslmode=require";
        String user = "postgres.wrzgzswlpblqvcjrbunn";
        String password = "Praveen@2005<>";
        String sqlFilePath = "supabase_schema.sql";

        System.out.println("Initializing database connection...");
        try {
            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(jdbcUrl, user, password);
                 Statement stmt = conn.createStatement()) {
                
                System.out.println("Connected to Supabase database successfully.");
                System.out.println("Reading schema script: " + sqlFilePath);

                StringBuilder sb = new StringBuilder();
                try (BufferedReader br = new BufferedReader(new FileReader(sqlFilePath))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        // Skip comments and empty lines
                        if (line.trim().startsWith("--") || line.trim().isEmpty()) {
                            continue;
                        }
                        sb.append(line).append("\n");
                    }
                }

                // Split statements by semicolon
                String[] statements = sb.toString().split(";");
                System.out.println("Executing SQL statements (" + statements.length + " found)...");

                for (String sql : statements) {
                    String trimmedSql = sql.trim();
                    if (!trimmedSql.isEmpty()) {
                        System.out.println("Executing SQL: " + (trimmedSql.length() > 60 ? trimmedSql.substring(0, 60) + "..." : trimmedSql));
                        stmt.execute(trimmedSql);
                    }
                }

                System.out.println("Database schema and seed data initialized successfully on Supabase!");
            }
        } catch (Exception e) {
            System.err.println("Error initializing Supabase database:");
            e.printStackTrace();
            System.exit(1);
        }
    }
}
