package com.sunrise.dental;

import com.sunrise.dental.decorator.*;
import org.junit.Test;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.Assert.*;

/**
 * Automated Unit Tests for the Decorator Design Pattern (GoF).
 *
 * Verifies dynamic runtime extension of dental procedures with clinical
 * enhancements, additive cost computation, chair time aggregation,
 * and clinical addon tracking.
 */
public class DecoratorPatternTest {

    @Test
    public void shouldReturnBaseTreatmentProperties() {
        DentalProcedure procedure = new StandardDentalTreatment(
                "Tooth Extraction", new BigDecimal("3500.00"), 30);

        assertEquals("Tooth Extraction", procedure.getDescription());
        assertEquals(0, new BigDecimal("3500.00").compareTo(procedure.getCost()));
        assertEquals(30, procedure.getDurationMinutes());
        assertTrue(procedure.getClinicalAddons().isEmpty());
    }

    @Test
    public void shouldDecorateWithSterilizationSafetyPack() {
        DentalProcedure base = new StandardDentalTreatment(
                "Composite Dental Filling", new BigDecimal("4500.00"), 40);

        DentalProcedure decorated = new SterilizationSafetyPackDecorator(base);

        // Cost: 4,500 + 500 = 5,000
        assertEquals(0, new BigDecimal("5000.00").compareTo(decorated.getCost()));
        // Duration: 40 + 5 = 45 mins
        assertEquals(45, decorated.getDurationMinutes());
        assertTrue(decorated.getDescription().contains("[Sterilization & PPE Pack]"));
        assertEquals(1, decorated.getClinicalAddons().size());
    }

    @Test
    public void shouldStackMultipleClinicalDecoratorsCorrectly() {
        // Base: Root Canal Treatment — Rs. 8,000, 60 mins
        DentalProcedure procedure = new StandardDentalTreatment(
                "Root Canal Treatment", new BigDecimal("8000.00"), 60);

        // Decorator 1: Sterilization Safety (+Rs. 500, +5 mins) -> 8,500, 65 mins
        procedure = new SterilizationSafetyPackDecorator(procedure);

        // Decorator 2: Painless Local Sedation (+Rs. 1,500, +10 mins) -> 10,000, 75 mins
        procedure = new SedationAnesthesiaDecorator(procedure);

        // Decorator 3: Senior Specialist Review (+Rs. 2,500, +15 mins) -> 12,500, 90 mins
        procedure = new SpecialistConsultantDecorator(procedure);

        // Decorator 4: Emergency Priority Surcharge (20% on 12,500 = +2,500) -> 15,000, 90 mins
        procedure = new EmergencySurchargeDecorator(procedure, 20.0);

        assertEquals(0, new BigDecimal("15000.00").compareTo(procedure.getCost()));
        assertEquals(90, procedure.getDurationMinutes());

        List<String> addons = procedure.getClinicalAddons();
        assertEquals(4, addons.size());
        assertTrue(procedure.getDescription().contains("Root Canal Treatment"));
        assertTrue(procedure.getDescription().contains("Sterilization"));
        assertTrue(procedure.getDescription().contains("Sedation"));
        assertTrue(procedure.getDescription().contains("Specialist"));
        assertTrue(procedure.getDescription().contains("Emergency Surcharge"));
    }

    @Test
    public void shouldApplyInsuranceDeductionDecorator() {
        // Decorated procedure worth Rs. 10,000
        DentalProcedure procedure = new StandardDentalTreatment(
                "Dental Crown", new BigDecimal("8000.00"), 45);
        procedure = new SpecialistConsultantDecorator(procedure); // +2,500 = 10,500

        // Apply 20% insurance benefit deduction
        // 20% of 10,500 = 2,100 -> Net: 8,400
        DentalProcedure insured = new InsuranceCoverageDecorator(procedure, 20.0);

        assertEquals(0, new BigDecimal("8400.00").compareTo(insured.getCost()));
        assertTrue(insured.getDescription().contains("Insurance Coverage (20.00%)"));
    }
}
