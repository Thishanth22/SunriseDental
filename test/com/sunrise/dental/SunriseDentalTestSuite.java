package com.sunrise.dental;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;

/**
 * Master Test Suite executing all 7 automated JUnit test classes (UT-01 to UT-21).
 */
@RunWith(Suite.class)
@Suite.SuiteClasses({
    AuthServiceTest.class,
    PatientServiceTest.class,
    AppointmentServiceTest.class,
    BillingServiceTest.class,
    PaymentServiceTest.class,
    PrescriptionServiceTest.class,
    AuthorizationServiceTest.class,
    BuilderPatternTest.class,
    DecoratorPatternTest.class
})
public class SunriseDentalTestSuite {

    public static void main(String[] args) {
        org.junit.runner.JUnitCore.main("com.sunrise.dental.SunriseDentalTestSuite");
    }
}
