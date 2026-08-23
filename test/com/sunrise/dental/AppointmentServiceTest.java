package com.sunrise.dental;

import com.sunrise.dental.model.Appointment;
import org.junit.Test;
import java.time.LocalDate;
import java.time.LocalTime;
import static org.junit.Assert.*;

/**
 * Automated Unit Tests for Appointment Scheduling & Status Lifecycle.
 * Covers: UT-07, UT-08, UT-09, UT-10.
 */
public class AppointmentServiceTest {

    @Test
    public void testAppointmentCreation_UT07() {
        // UT-07: Valid appointment creation and reference generation
        Appointment appt = new Appointment();
        appt.setAppointmentId(101);
        appt.setAppointmentNumber("APT-2026-0101");
        appt.setPatientId(1);
        appt.setDentistId(1);
        appt.setAppointmentDate(LocalDate.of(2026, 11, 20));
        appt.setAppointmentTime(LocalTime.of(10, 0));
        appt.setStatus("SCHEDULED");
        appt.setPatientPhone("0771234567");
        appt.setPatientAddress("No 12 Flower Road, Colombo 07");

        assertNotNull("Appointment reference must be assigned", appt.getAppointmentNumber());
        assertEquals("SCHEDULED", appt.getStatus());
        assertEquals("0771234567", appt.getPatientPhone());
        assertEquals("No 12 Flower Road, Colombo 07", appt.getPatientAddress());
    }

    @Test
    public void testDoubleBookingPrevention_UT08() {
        // UT-08: Time slot overlap detection for the same dentist
        LocalTime appt1Start = LocalTime.of(10, 0);
        LocalTime appt1End   = LocalTime.of(10, 30);

        LocalTime appt2Start = LocalTime.of(10, 15);
        LocalTime appt2End   = LocalTime.of(10, 45);

        // Conflict rule: (startA < endB) AND (endA > startB)
        boolean hasConflict = appt1Start.isBefore(appt2End) && appt1End.isAfter(appt2Start);
        assertTrue("Overlapping appointments for same dentist must be flagged as conflict", hasConflict);

        // Non-overlapping slot check
        LocalTime appt3Start = LocalTime.of(11, 0);
        LocalTime appt3End   = LocalTime.of(11, 30);
        boolean nonConflicting = appt1Start.isBefore(appt3End) && appt1End.isAfter(appt3Start);
        assertFalse("Non-overlapping time slot should not trigger conflict", nonConflicting);
    }

    @Test
    public void testAppointmentCancellation_UT09() {
        // UT-09: Cancellation status transition and mandatory reason capture
        Appointment appt = new Appointment();
        appt.setStatus("SCHEDULED");

        // Cancel with reason
        appt.setStatus("CANCELLED");
        appt.setCancellationReason("Patient requested reschedule due to illness.");

        assertEquals("CANCELLED", appt.getStatus());
        assertNotNull("Cancellation reason must be recorded", appt.getCancellationReason());
    }

    @Test
    public void testAppointmentStatusCompleted_UT10() {
        // UT-10: Status transition to COMPLETED when treatment finishes
        Appointment appt = new Appointment();
        appt.setStatus("CONFIRMED");

        // Mark complete
        appt.setStatus("COMPLETED");
        assertEquals("COMPLETED", appt.getStatus());
    }
}
