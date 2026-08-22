package com.sunrise.dental.decorator;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * DentalProcedureDecorator — Base Decorator in the Decorator Design Pattern.
 *
 * Design Pattern: Decorator (GoF)
 * Purpose: Maintains a reference to a DentalProcedure component and conforms to
 *          the DentalProcedure interface, allowing subclasses to wrap additional
 *          behaviors, costs, and durations transparently.
 */
public abstract class DentalProcedureDecorator implements DentalProcedure {

    protected final DentalProcedure wrappedProcedure;

    public DentalProcedureDecorator(DentalProcedure wrappedProcedure) {
        if (wrappedProcedure == null) {
            throw new IllegalArgumentException("Wrapped dental procedure cannot be null.");
        }
        this.wrappedProcedure = wrappedProcedure;
    }

    @Override
    public String getDescription() {
        return wrappedProcedure.getDescription();
    }

    @Override
    public BigDecimal getCost() {
        return wrappedProcedure.getCost();
    }

    @Override
    public int getDurationMinutes() {
        return wrappedProcedure.getDurationMinutes();
    }

    @Override
    public List<String> getClinicalAddons() {
        return new ArrayList<>(wrappedProcedure.getClinicalAddons());
    }
}
