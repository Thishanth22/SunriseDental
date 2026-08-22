package com.sunrise.dental.decorator;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * InsuranceCoverageDecorator — Concrete Decorator for medical insurance deductions.
 *
 * Applies dynamic medical insurance co-pay discount on decorated dental procedures.
 */
public class InsuranceCoverageDecorator extends DentalProcedureDecorator {

    private final BigDecimal coveragePercentage;

    public InsuranceCoverageDecorator(DentalProcedure wrappedProcedure, double percentage) {
        super(wrappedProcedure);
        this.coveragePercentage = BigDecimal.valueOf(percentage).setScale(2, RoundingMode.HALF_UP);
    }

    public InsuranceCoverageDecorator(DentalProcedure wrappedProcedure) {
        this(wrappedProcedure, 20.0); // Default 20% insurance discount
    }

    @Override
    public String getDescription() {
        return wrappedProcedure.getDescription() + " - [Insurance Coverage (" + coveragePercentage + "%)]";
    }

    @Override
    public BigDecimal getCost() {
        BigDecimal currentCost = wrappedProcedure.getCost();
        BigDecimal coverage = currentCost.multiply(coveragePercentage)
                .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        BigDecimal net = currentCost.subtract(coverage);
        return net.compareTo(BigDecimal.ZERO) > 0 ? net : BigDecimal.ZERO;
    }

    @Override
    public List<String> getClinicalAddons() {
        List<String> list = super.getClinicalAddons();
        list.add("Dental Insurance Benefit Applied (" + coveragePercentage + "% Coverage)");
        return list;
    }
}
