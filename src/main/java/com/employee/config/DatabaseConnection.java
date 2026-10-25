package com.employee.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Opens a connection using environment variables; no credentials are stored in code. */
public final class DatabaseConnection {
    private DatabaseConnection() { }
    public static Connection getConnection() throws SQLException {
        String url = System.getenv().getOrDefault("DB_URL", "jdbc:mysql://localhost:3306/payroll_hr_demo?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata");
        String user = System.getenv("DB_USERNAME");
        String password = System.getenv("DB_PASSWORD");
        if (user == null || password == null) throw new SQLException("Set DB_USERNAME and DB_PASSWORD before starting the application.");
        // Register the driver from this web application's class loader.
        // Tomcat may initialize DriverManager before it scans WEB-INF/lib.
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("MySQL JDBC driver is missing from the application.", ex);
        }
        return DriverManager.getConnection(url, user, password);
    }
}
