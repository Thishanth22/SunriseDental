package com.sunrise.dental;

import com.sunrise.dental.builder.AppointmentBuilder;
import com.sunrise.dental.builder.BillBuilder;
import com.sunrise.dental.model.Appointment;
import com.sunrise.dental.model.Bill;
import org.junit.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

import static org.junit.Assert.*;

/**
 * Automated Unit Tests for the Builder Design Pattern (GoF).
 *
 * Verifies fluent step-by-step object assembly, default property encapsulation,
 * priority sanitization, and automated financial computation.
 */
public class BuilderPatternTest {

    @Test
    public void shouldBuildAppointmentWithCorrectDefaults() {
        Appointment appt = new AppointmentBuilder()
                .patientId(15)
                .dentistId(3)
                .treatmentId(5)
                .appointmentDate(LocalDate.of(2026, 9, 10))
                .appointmentTime(LocalTime.of(10, 30))
                .build();

        assertNotNull(appt);
        assertEquals(15, appt.getPatientId());
        assertEquals(3, appt.getDentistId());
        assertEquals(5, appt.getTreatmentId());
        assertEquals(LocalDate.of(2026, 9, 10), appt.getAppointmentDate());
        assertEquals(LocalTime.of(10, 30), appt.getAppointmentTime());
        // Check defaults enforced by Builder
        assertEquals("SCHEDULED", appt.getStatus());
        assertEquals("NORMAL", appt.getPriority());
    }

    @Test
    public void shouldSanitizePriorityInAppointmentBuilder() {
        // Urgent should normalize to URGENT
        Appointment urgentAppt = new AppointmentBuilder()
                .priority("urgent")
                .build();
        assertEquals("URGENT", urgentAppt.getPriority());

        // Emergency should normalize to EMERGENCY
        Appointment emergencyAppt = new AppointmentBuilder()
                .priority("EMERGENCY")
                .build();
        assertEquals("EMERGENCY", emergencyAppt.getPriority());

        // Invalid or empty priority should safely fallback to NORMAL
        Appointment invalidAppt = new AppointmentBuilder()
                .priority("HIGH_PRIORITY_UNKNOWN")
                .build();
        assertEquals("NORMAL", invalidAppt.getPriority());

        Appointment emptyAppt = new AppointmentBuilder()
                .priority("   ")
                .build();
        assertEquals("NORMAL", emptyAppt.getPriority());
    }

    @Test
    public void shouldRetainContactAndDisplayFieldsInAppointment() {
        Appointment appt = Appointment.builder()
                .appointmentNumber("APT-2026-999")
                .patientPhone("0779998877")
                .patientAddress("No 88 Waterfront, Colombo 03")
                .patientName("Naveen Perera")
                .dentistName("Dr. Sarah De Silva")
                .treatmentName("Dental Consultation")
                .notes("Allergic to penicillin")
                .build();

        assertEquals("APT-2026-999", appt.getAppointmentNumber());
        assertEquals("0779998877", appt.getPatientPhone());
        assertEquals("No 88 Waterfront, Colombo 03", appt.getPatientAddress());
        assertEquals("Naveen Perera", appt.getPatientName());
        assertEquals("Dr. Sarah De Silva", appt.getDentistName());
        assertEquals("Dental Consultation", appt.getTreatmentName());
        assertEquals("Allergic to penicillin", appt.getNotes());
    }

    @Test
    public void shouldAutoCalculateFinancialTotalsInBillBuilder() {
        // Consultation: 1,500 + Treatment: 5,000 + Additional: 500 = SubTotal: 7,000
        // Discount: 10% = 700 -> After Discount: 6,300
        // Tax: 5% on 6,300 = 315 -> Grand Total: 6,615
        // Paid: 2,000 -> Balance Due: 4,615
        Bill bill = Bill.builder()
                .billNumber("INV-2026-000555")
                .appointmentId(101)
                .patientId(15)
                .consultationFee(new BigDecimal("1500.00"))
                .treatmentCost(new BigDecimal("5000.00"))
                .additionalCharges(new BigDecimal("500.00"), "Special sterile consumables")
                .discount(new BigDecimal("10.0"), null)
                .tax(new BigDecimal("5.0"), null)
                .amountPaid(new BigDecimal("2000.00"))
                .calculateTotals()
                .build();

        assertNotNull(bill);
        assertEquals(0, new BigDecimal("7000.00").compareTo(bill.getSubTotal()));
        assertEquals(0, new BigDecimal("700.00").compareTo(bill.getDiscountAmount()));
        assertEquals(0, new BigDecimal("315.00").compareTo(bill.getTaxAmount()));
        assertEquals(0, new BigDecimal("6615.00").compareTo(bill.getGrandTotal()));
        assertEquals(0, new BigDecimal("4615.00").compareTo(bill.getBalanceDue()));
        assertEquals("ISSUED", bill.getBillStatus());
    }
}
