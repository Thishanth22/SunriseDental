package com.sunrise.dental.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBConnection — Centralised JDBC connection manager.
 *
 * Architecture note (3-tier):
 *   Presentation → Servlet → Service → DAO → DBConnection → MySQL
 *
 * This class reads configuration from the application context params
 * (web.xml) at startup via DBConnectionInitializer, so credentials are
 * never hard-coded in Java source or exposed in JSP pages.
 *
 * Usage (inside a DAO):
 *   try (Connection conn = DBConnection.getConnection()) {
 *       // use connection
 *   }
 */
public final class DBConnection {

    private static final Logger logger = Logger.getLogger(DBConnection.class.getName());

    // These are set once by DBConnectionInitializer from web.xml context params
    private static String jdbcUrl;
    private static String username;
    private static String password;

    // Defaults (overridden by web.xml)
    private static final String DEFAULT_HOST     = "localhost";
    private static final String DEFAULT_PORT     = "3306";
    private static final String DEFAULT_DB       = "sunrise_dental_db";
    private static final String DEFAULT_USER     = "root";
    private static final String DEFAULT_PASS     = "";
    private static final String DRIVER_CLASS     = "com.mysql.cj.jdbc.Driver";

    // Private constructor — utility class, no instances
    private DBConnection() {}

    /**
     * Initialise the connection pool parameters.
     * Called once from DBConnectionInitializer (ServletContextListener).
     */
    public static void init(String host, String port, String dbName,
                            String user, String pass) {
        try {
            Class.forName(DRIVER_CLASS);
            jdbcUrl  = "jdbc:mysql://" + host + ":" + port + "/" + dbName
                     + "?useSSL=false"
                     + "&serverTimezone=Asia/Colombo"
                     + "&allowPublicKeyRetrieval=true"
                     + "&useUnicode=true"
                     + "&characterEncoding=UTF-8";
            username = user;
            password = pass;
            logger.info("DBConnection initialised → " + jdbcUrl);
        } catch (ClassNotFoundException e) {
            logger.log(Level.SEVERE, "MySQL JDBC driver not found: " + e.getMessage(), e);
            throw new RuntimeException("MySQL JDBC driver not found.", e);
        }
    }

    /**
     * Initialise with defaults (for first-run / fallback).
     */
    public static void initDefaults() {
        init(DEFAULT_HOST, DEFAULT_PORT, DEFAULT_DB, DEFAULT_USER, DEFAULT_PASS);
    }

    /**
     * Returns a new JDBC Connection.
     * Callers must close it (use try-with-resources).
     *
     * @return Connection to sunrise_dental_db
     * @throws SQLException if connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        if (jdbcUrl == null) {
            logger.warning("DBConnection not initialised — using defaults.");
            initDefaults();
        }
        return DriverManager.getConnection(jdbcUrl, username, password);
    }

    /**
     * Silently close a Connection.  Convenience for catch blocks.
     */
    public static void close(java.sql.Connection conn) {
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to close connection", e);
            }
        }
    }

    /**
     * Silently close a PreparedStatement.
     */
    public static void close(java.sql.PreparedStatement ps) {
        if (ps != null) {
            try { ps.close(); } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to close PreparedStatement", e);
            }
        }
    }

    /**
     * Silently close a ResultSet.
     */
    public static void close(java.sql.ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to close ResultSet", e);
            }
        }
    }

    /**
     * Roll back a transaction silently (used in catch blocks).
     */
    public static void rollback(java.sql.Connection conn) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException e) {
                logger.log(Level.WARNING, "Failed to rollback transaction", e);
            }
        }
    }
}
