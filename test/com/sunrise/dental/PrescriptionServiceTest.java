package com.sunrise.dental;

import com.sunrise.dental.model.PrescriptionItem;
import com.sunrise.dental.util.ValidationUtil;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Automated Unit Tests for Prescription Validation.
 * Covers: UT-17, UT-18.
 */
public class PrescriptionServiceTest {

    @Test
    public void testPrescriptionValidation_UT17() {
        // UT-17: Valid prescription item populated with complete dosage details
        PrescriptionItem item = new PrescriptionItem();
        item.setDrugName("Amoxicillin 500mg");
        item.setDosage("1 Capsule");
        item.setFrequency("TDS (Three times daily)");
        item.setDuration("5 days");
        item.setInstructions("Take after meals with plenty of water.");

        assertNotNull("Medication name must be present", item.getDrugName());
        assertFalse("Dosage cannot be empty", ValidationUtil.isNullOrEmpty(item.getDosage()));
        assertFalse("Frequency cannot be empty", ValidationUtil.isNullOrEmpty(item.getFrequency()));
        assertNotNull("Duration must be specified", item.getDuration());
    }

    @Test
    public void testMissingDosage_UT18() {
        // UT-18: Validation detects and rejects missing dosage
        PrescriptionItem item = new PrescriptionItem();
        item.setDrugName("Paracetamol 500mg");
        item.setDosage(""); // Missing dosage

        boolean isValid = ValidationUtil.hasValue(item.getDrugName())
                && ValidationUtil.hasValue(item.getDosage());

        assertFalse("Prescription with missing dosage must fail validation", isValid);
    }
}
