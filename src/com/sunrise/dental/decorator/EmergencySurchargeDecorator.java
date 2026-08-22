package com.sunrise.dental.decorator;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * EmergencySurchargeDecorator — Concrete Decorator applying an emergency priority multiplier.
 *
 * Design Pattern: Decorator (GoF)
 * Purpose: Dynamically calculates out-of-hours or emergency chair surcharge without
 *          hardcoding surcharge logic inside standard treatment domain models.
 */
public class EmergencySurchargeDecorator extends DentalProcedureDecorator {

    private final BigDecimal surchargePercentage;

    public EmergencySurchargeDecorator(DentalProcedure wrappedProcedure, double percentage) {
        super(wrappedProcedure);
        this.surchargePercentage = BigDecimal.valueOf(percentage).setScale(2, RoundingMode.HALF_UP);
    }

    public EmergencySurchargeDecorator(DentalProcedure wrappedProcedure) {
        this(wrappedProcedure, 20.0); // Default 20% emergency surcharge
    }

    @Override
    public String getDescription() {
        return wrappedProcedure.getDescription() + " + [Emergency Surcharge (" + surchargePercentage + "%)]";
    }

    @Override
    public BigDecimal getCost() {
        BigDecimal base = wrappedProcedure.getCost();
        BigDecimal surcharge = base.multiply(surchargePercentage)
                .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        return base.add(surcharge);
    }

    @Override
    public List<String> getClinicalAddons() {
        List<String> list = super.getClinicalAddons();
        list.add("Emergency Out-of-Hours Priority Surcharge (" + surchargePercentage + "%)");
        return list;
    }
}
