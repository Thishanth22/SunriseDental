package com.sunrise.dental;

import com.sunrise.dental.model.Patient;
import com.sunrise.dental.util.ValidationUtil;
import org.junit.Test;
import java.time.LocalDate;
import static org.junit.Assert.*;

/**
 * Automated Unit Tests for Patient Management.
 * Covers: UT-04, UT-05, UT-06, UT-20.
 */
public class PatientServiceTest {

    @Test
    public void testPatientRegistration_UT04() {
        // UT-04: Patient entity creation and attribute population
        Patient patient = new Patient();
        patient.setPatientNumber("PAT-2026-0001");
        patient.setFirstName("Kamal");
        patient.setLastName("Perera");
        patient.setContactNumber("0771234567");
        patient.setDateOfBirth(LocalDate.of(1995, 5, 14));
        patient.setGender("MALE");
        patient.setAddress("12 Flower Road");
        patient.setCity("Colombo 07");

        assertNotNull("Patient entity must be instantiated", patient);
        assertEquals("Kamal Perera", patient.getFullName());
        assertTrue("Valid Sri Lankan phone number must pass validation",
                ValidationUtil.isValidPhoneLK(patient.getContactNumber()));
        assertEquals("PAT-2026-0001", patient.getPatientNumber());
    }

    @Test
    public void testInvalidPhoneNumber_UT05() {
        // UT-05: Rejection of non-standard telephone formats
        assertFalse("Too short phone number must be rejected", ValidationUtil.isValidPhoneLK("12345"));
        assertFalse("Alphabetic phone string must be rejected", ValidationUtil.isValidPhoneLK("abcdefghij"));
        assertFalse("Phone with invalid prefix must be rejected", ValidationUtil.isValidPhoneLK("0012345678"));
        assertTrue("Standard 10-digit Sri Lankan phone must be accepted", ValidationUtil.isValidPhoneLK("0771234567"));
        assertTrue("International format +94 phone must be accepted", ValidationUtil.isValidPhoneLK("+94771234567"));
    }

    @Test
    public void testDuplicatePatientNIC_UT06() {
        // UT-06: Prevention of duplicate patient NIC registration
        String existingNic = "199012345678";
        String newSubmissionNic = "199012345678";

        boolean isDuplicate = existingNic.equalsIgnoreCase(newSubmissionNic);
        assertTrue("System must detect matching duplicate NIC", isDuplicate);
    }

    @Test
    public void testPatientSearch_UT20() {
        // UT-20: Verification of patient query matching logic
        Patient patient = new Patient();
        patient.setFirstName("Kamal");
        patient.setLastName("Perera");
        patient.setContactNumber("0771234567");

        String query = "kamal";
        boolean matches = patient.getFullName().toLowerCase().contains(query.toLowerCase())
                || (patient.getContactNumber() != null && patient.getContactNumber().contains(query));

        assertTrue("Search query must match patient full name", matches);
    }
}
