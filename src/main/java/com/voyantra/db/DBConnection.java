package com.voyantra.db;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import com.voyantra.util.AppConfig;

public class DBConnection {

    // ---- Database configuration (env vars override these for deployment) ----
    private static final String URL = AppConfig.get("DB_URL",
        "jdbc:mysql://localhost:3306/travel_planner_db?useUnicode=true&characterEncoding=UTF-8");
    private static final String USER = AppConfig.get("DB_USER", "root");
    private static final String PASSWORD = AppConfig.get("DB_PASSWORD", "root123");

    // ---- Method to get a connection ----
    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Load MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Create connection
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("✅ Database connected successfully!");

        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL JDBC Driver not found.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ Connection failed.");
            e.printStackTrace();
        }
        return conn;
    }

    // ---- Test method (run this file directly to test connection) ----
    public static void main(String[] args) {
        Connection conn = getConnection();
        if (conn != null) {
            System.out.println("🎉 Connection object created: " + conn);
        } else {
            System.out.println("⚠️ Connection is null — check your credentials.");
        }
    }

}
