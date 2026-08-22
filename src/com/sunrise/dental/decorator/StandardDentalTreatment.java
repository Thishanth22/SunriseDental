package com.sunrise.dental.decorator;

import com.sunrise.dental.model.Treatment;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * StandardDentalTreatment — Concrete Component in the Decorator Pattern.
 *
 * Represents the fundamental, unadorned dental treatment (e.g., Tooth Extraction,
 * Dental Scaling, Root Canal, Composite Filling) before clinical add-ons are applied.
 */
public class StandardDentalTreatment implements DentalProcedure {

    private final String     treatmentName;
    private final BigDecimal baseCost;
    private final int        durationMinutes;

    public StandardDentalTreatment(String treatmentName, BigDecimal baseCost, int durationMinutes) {
        this.treatmentName   = (treatmentName != null) ? treatmentName : "Standard Dental Procedure";
        this.baseCost        = (baseCost != null) ? baseCost : BigDecimal.ZERO;
        this.durationMinutes = Math.max(durationMinutes, 15);
    }

    public StandardDentalTreatment(Treatment treatment) {
        if (treatment != null) {
            this.treatmentName   = treatment.getTreatmentName();
            this.baseCost        = treatment.getBaseCost() != null ? treatment.getBaseCost() : BigDecimal.ZERO;
            this.durationMinutes = treatment.getDurationMins() > 0 ? treatment.getDurationMins() : 30;
        } else {
            this.treatmentName   = "Standard Dental Consultation";
            this.baseCost        = new BigDecimal("1500.00");
            this.durationMinutes = 30;
        }
    }

    @Override
    public String getDescription() {
        return treatmentName;
    }

    @Override
    public BigDecimal getCost() {
        return baseCost;
    }

    @Override
    public int getDurationMinutes() {
        return durationMinutes;
    }

    @Override
    public List<String> getClinicalAddons() {
        return Collections.emptyList();
    }
}
