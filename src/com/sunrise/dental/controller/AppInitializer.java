package com.sunrise.dental.controller;

import com.sunrise.dental.util.DBConnection;

import jakarta.servlet.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AppInitializer — ServletContextListener that runs on application startup.
 *
 * Reads JDBC connection parameters from web.xml context params
 * and initialises DBConnection once for the application lifetime.
 *
 * This ensures database credentials are NEVER hard-coded in Java source.
 */
public class AppInitializer implements ServletContextListener {

    private static final Logger logger = Logger.getLogger(AppInitializer.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();

        String host = getParam(ctx, "db.host", "localhost");
        String port = getParam(ctx, "db.port", "3306");
        String name = getParam(ctx, "db.name", "sunrise_dental_db");
        String user = getParam(ctx, "db.user", "root");
        String pass = getParam(ctx, "db.password", "");

        logger.info("=== Sunrise Dental Clinic — Application Starting ===");
        logger.info("DB: " + host + ":" + port + "/" + name + " (user=" + user + ")");

        try {
            DBConnection.init(host, port, name, user, pass);
            logger.info("Database connection pool initialised successfully.");
        } catch (Exception e) {
            logger.log(Level.SEVERE,
                "FATAL: Could not initialise database connection. " +
                "Check WAMP is running and web.xml parameters are correct.", e);
        }

        logger.info("=== Application startup complete ===");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("=== Sunrise Dental Clinic — Application Stopping ===");
    }

    private String getParam(ServletContext ctx, String name, String defaultValue) {
        String value = ctx.getInitParameter(name);
        return (value != null && !value.trim().isEmpty()) ? value.trim() : defaultValue;
    }
}
