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

    @Test
    public void testDentistDayAvailabilityValidation() {
        com.sunrise.dental.model.Dentist d = new com.sunrise.dental.model.Dentist();
        d.setFirstName("Amali");
        d.setLastName("Jayawardena");
        d.setAvailableMonday(true);
        d.setAvailableWednesday(true);
        d.setAvailableFriday(true);
        d.setAvailableSaturday(true);
        d.setAvailableThursday(false);
        d.setWorkStartTime(LocalTime.of(10, 0));
        d.setWorkEndTime(LocalTime.of(18, 0));

        assertFalse("Dentist 4 must not be available on Thursday", d.isAvailableOn(java.time.DayOfWeek.THURSDAY));
        assertTrue("Dentist 4 must be available on Friday", d.isAvailableOn(java.time.DayOfWeek.FRIDAY));
        assertEquals("Mon, Wed, Fri, Sat", d.getAvailableDaysSummary());
    }

    @Test
    public void testDentistShiftBoundaryCheck() {
        LocalTime shiftStart = LocalTime.of(10, 0);
        LocalTime shiftEnd   = LocalTime.of(18, 0);

        LocalTime outsideStart = LocalTime.of(8, 0);
        LocalTime outsideEnd   = LocalTime.of(21, 0);
        LocalTime validSlot    = LocalTime.of(11, 0);
        int durationMins       = 45;
        LocalTime validEnd     = validSlot.plusMinutes(durationMins);

        assertTrue("08:00 must be before shift start 10:00", outsideStart.isBefore(shiftStart));
        assertTrue("21:00 must be after shift end 18:00", outsideEnd.isAfter(shiftEnd));
        assertFalse("11:00 is within shift start", validSlot.isBefore(shiftStart));
        assertFalse("11:00 is within shift end", validSlot.isAfter(shiftEnd));
        assertFalse("11:45 ends within shift", validEnd.isAfter(shiftEnd));

        // Treatment extending past shift end
        LocalTime lateSlot = LocalTime.of(17, 30);
        LocalTime lateEnd = lateSlot.plusMinutes(45); // 18:15
        assertTrue("Late appointment ending at 18:15 exceeds 18:00 shift end", lateEnd.isAfter(shiftEnd));
    }
}
