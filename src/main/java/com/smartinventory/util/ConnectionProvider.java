package com.smartinventory.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.util.Properties;

public class ConnectionProvider {
    private static HikariDataSource dataSource;

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
                String url = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : props.getProperty("db.url");
                String username = System.getenv("DB_USERNAME") != null ? System.getenv("DB_USERNAME") : props.getProperty("db.username");
                String password = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : props.getProperty("db.password");
                String driver = props.getProperty("db.driver");

                HikariConfig config = new HikariConfig();
                config.setDriverClassName(driver);
                config.setJdbcUrl(url);
                config.setUsername(username);
                config.setPassword(password);

                // Connection Pool Tuning Optimization
                config.setMaximumPoolSize(15);
                config.setMinimumIdle(3);
                config.setIdleTimeout(300000); // 5 minutes
                config.setMaxLifetime(1800000); // 30 minutes
                // Avoid failing deployment if database is temporarily offline
                config.setInitializationFailTimeout(-1);
                // Fail fast if database is unreachable (3 seconds instead of 30)
                config.setConnectionTimeout(3000);

                // PostgreSQL connection optimizations
                config.addDataSourceProperty("reWriteBatchedInserts", "true");

                dataSource = new HikariDataSource(config);
            } else {
                System.err.println("db.properties file not found in classpath!");
            }
        } catch (Exception e) {
            System.err.println("Error initializing database ConnectionProvider: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static Connection getConnection() {
        try {
            if (dataSource != null) {
                return dataSource.getConnection();
            }
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}
