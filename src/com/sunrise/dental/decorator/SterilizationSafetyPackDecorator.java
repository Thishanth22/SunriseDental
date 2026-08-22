package com.sunrise.dental.decorator;

import java.math.BigDecimal;
import java.util.List;

/**
 * SterilizationSafetyPackDecorator — Concrete Decorator for clinical safety enhancements.
 *
 * Adds OSHA/CDC hospital-grade sterilization, sterile drape kits, and clinical PPE.
 * Cost: +Rs. 500.00
 * Duration: +5 minutes
 */
public class SterilizationSafetyPackDecorator extends DentalProcedureDecorator {

    private static final BigDecimal STERILIZATION_FEE = new BigDecimal("500.00");
    private static final int        EXTRA_TIME_MINS   = 5;

    public SterilizationSafetyPackDecorator(DentalProcedure wrappedProcedure) {
        super(wrappedProcedure);
    }

    @Override
    public String getDescription() {
        return wrappedProcedure.getDescription() + " + [Sterilization & PPE Pack]";
    }

    @Override
    public BigDecimal getCost() {
        return wrappedProcedure.getCost().add(STERILIZATION_FEE);
    }

    @Override
    public int getDurationMinutes() {
        return wrappedProcedure.getDurationMinutes() + EXTRA_TIME_MINS;
    }

    @Override
    public List<String> getClinicalAddons() {
        List<String> list = super.getClinicalAddons();
        list.add("OSHA/CDC Hospital-Grade Sterilization & Disposable Barrier Pack (+Rs. 500.00)");
        return list;
    }
}
