package com.sunrise.dental.dao;

import com.sunrise.dental.dao.impl.*;

/**
 * DAOFactory — Centralised factory implementing Singleton pattern
 * to provide single instances of all system Data Access Objects (DAOs).
 *
 * Benefits:
 *   - Prevents duplicate instantiations of DAO helper classes.
 *   - Decouples services/controllers from concrete SQL/JDBC implementation classes.
 *   - Simplifies database connection testing & mocking.
 */
public class DAOFactory {

    private static final AppointmentDAO  appointmentDAO  = new AppointmentDAOImpl();
    private static final BillDAO         billDAO         = new BillDAOImpl();
    private static final DentistDAO      dentistDAO      = new DentistDAOImpl();
    private static final PatientDAO      patientDAO      = new PatientDAOImpl();
    private static final PaymentDAO      paymentDAO      = new PaymentDAOImpl();
    private static final PrescriptionDAO prescriptionDAO = new PrescriptionDAOImpl();
    private static final TreatmentDAO    treatmentDAO    = new TreatmentDAOImpl();
    private static final UserDAO         userDAO         = new UserDAOImpl();

    private DAOFactory() {
        // Prevent instantiation
    }

    public static AppointmentDAO getAppointmentDAO() {
        return appointmentDAO;
    }

    public static BillDAO getBillDAO() {
        return billDAO;
    }

    public static DentistDAO getDentistDAO() {
        return dentistDAO;
    }

    public static PatientDAO getPatientDAO() {
        return patientDAO;
    }

    public static PaymentDAO getPaymentDAO() {
        return paymentDAO;
    }

    public static PrescriptionDAO getPrescriptionDAO() {
        return prescriptionDAO;
    }

    public static TreatmentDAO getTreatmentDAO() {
        return treatmentDAO;
    }

    public static UserDAO getUserDAO() {
        return userDAO;
    }
}
