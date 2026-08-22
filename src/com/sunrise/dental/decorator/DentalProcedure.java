package com.sunrise.dental.decorator;

import java.math.BigDecimal;
import java.util.List;

/**
 * DentalProcedure — Component Interface for the Decorator Design Pattern.
 *
 * Design Pattern: Decorator Pattern (GoF)
 * Purpose: Defines the common interface for dental treatments and clinical add-ons,
 *          allowing dynamic extension of procedural costs, durations, and clinical notes
 *          without altering existing classes.
 */
public interface DentalProcedure {

    /**
     * @return Human-readable description of the procedure and all attached enhancements
     */
    String getDescription();

    /**
     * @return Cumulative procedural cost in LKR (Rs.)
     */
    BigDecimal getCost();

    /**
     * @return Total clinical chair time required in minutes
     */
    int getDurationMinutes();

    /**
     * @return List of all clinical add-ons applied to this procedure
     */
    List<String> getClinicalAddons();
}
