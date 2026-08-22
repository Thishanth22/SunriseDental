package com.sunrise.dental.decorator;

import java.math.BigDecimal;
import java.util.List;

/**
 * SedationAnesthesiaDecorator — Concrete Decorator for painless sedation.
 *
 * Adds computer-controlled local nerve anesthesia or nitrous oxide twilight sedation.
 * Cost: +Rs. 1,500.00
 * Duration: +10 minutes
 */
public class SedationAnesthesiaDecorator extends DentalProcedureDecorator {

    private static final BigDecimal SEDATION_FEE    = new BigDecimal("1500.00");
    private static final int        EXTRA_TIME_MINS = 10;

    public SedationAnesthesiaDecorator(DentalProcedure wrappedProcedure) {
        super(wrappedProcedure);
    }

    @Override
    public String getDescription() {
        return wrappedProcedure.getDescription() + " + [Painless Local Sedation]";
    }

    @Override
    public BigDecimal getCost() {
        return wrappedProcedure.getCost().add(SEDATION_FEE);
    }

    @Override
    public int getDurationMinutes() {
        return wrappedProcedure.getDurationMinutes() + EXTRA_TIME_MINS;
    }

    @Override
    public List<String> getClinicalAddons() {
        List<String> list = super.getClinicalAddons();
        list.add("Painless Computerized Local Anesthesia & Sedation (+Rs. 1,500.00)");
        return list;
    }
}
