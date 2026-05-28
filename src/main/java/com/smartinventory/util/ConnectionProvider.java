package com.smartinventory.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class ConnectionProvider {
    private static String url;
    private static String username;
    private static String password;
    private static String driver;

    static {
        try {
            Properties props = new Properties();
            InputStream in = ConnectionProvider.class.getClassLoader().getResourceAsStream("db.properties");
            if (in == null) {
                // Fallback for standalone command line tests
                in = ConnectionProvider.class.getResourceAsStream("/db.properties");
            }
            if (in != null) {
                props.load(in);
                url = props.getProperty("db.url");
                username = props.getProperty("db.username");
                password = props.getProperty("db.password");
                driver = props.getProperty("db.driver");
                Class.forName(driver);
            } else {
                throw new RuntimeException("db.properties file not found in classpath!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error initializing database ConnectionProvider: " + e.getMessage());
        }
    }

    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(url, username, password);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
