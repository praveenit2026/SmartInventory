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
                config.setConnectionTimeout(10000); // 10 seconds

                // MySQL driver optimizations
                config.addDataSourceProperty("cachePrepStmts", "true");
                config.addDataSourceProperty("prepStmtCacheSize", "250");
                config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
                config.addDataSourceProperty("useServerPrepStmts", "true");

                dataSource = new HikariDataSource(config);
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
