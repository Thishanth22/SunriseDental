package com.sunrise.dental.decorator;

import java.math.BigDecimal;
import java.util.List;

/**
 * SpecialistConsultantDecorator — Concrete Decorator for specialist oversight.
 *
 * Adds Senior Consultant / Oral & Maxillofacial Surgeon secondary clinical review.
 * Cost: +Rs. 2,500.00
 * Duration: +15 minutes
 */
public class SpecialistConsultantDecorator extends DentalProcedureDecorator {

    private static final BigDecimal SPECIALIST_FEE  = new BigDecimal("2500.00");
    private static final int        EXTRA_TIME_MINS = 15;

    public SpecialistConsultantDecorator(DentalProcedure wrappedProcedure) {
        super(wrappedProcedure);
    }

    @Override
    public String getDescription() {
        return wrappedProcedure.getDescription() + " + [Senior Specialist Review]";
    }

    @Override
    public BigDecimal getCost() {
        return wrappedProcedure.getCost().add(SPECIALIST_FEE);
    }

    @Override
    public int getDurationMinutes() {
        return wrappedProcedure.getDurationMinutes() + EXTRA_TIME_MINS;
    }

    @Override
    public List<String> getClinicalAddons() {
        List<String> list = super.getClinicalAddons();
        list.add("Senior Consultant & Specialist Clinical Oversight (+Rs. 2,500.00)");
        return list;
    }
}
