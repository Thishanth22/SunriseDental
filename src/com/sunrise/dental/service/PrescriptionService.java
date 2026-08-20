package com.sunrise.dental.service;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Prescription;
import com.sunrise.dental.model.PrescriptionItem;
import com.sunrise.dental.model.Patient;
import com.sunrise.dental.model.Dentist;

import java.util.List;

/**
 * PrescriptionService — Business logic layer for E-Prescriptions.
 */
public class PrescriptionService {

    private final PrescriptionDAO prescriptionDAO = DAOFactory.getPrescriptionDAO();
    private final PatientDAO      patientDAO      = DAOFactory.getPatientDAO();
    private final DentistDAO      dentistDAO      = DAOFactory.getDentistDAO();
    private final AuditService    auditService    = new AuditService();

    /**
     * Create/Save a new Prescription with its items.
     * Enforces that the patient and dentist exist and are active.
     */
    public int createPrescription(Prescription p, List<PrescriptionItem> items, int createdByUserId)
            throws ApplicationException {

        // Validate basic fields
        if (p.getPatientId() <= 0) throw new ApplicationException("Patient is required.");
        if (p.getDentistId() <= 0) throw new ApplicationException("Dentist is required.");
        if (items == null || items.isEmpty()) {
            throw new ApplicationException("At least one drug item is required in a prescription.");
        }

        // Verify patient is active
        Patient patient = patientDAO.findById(p.getPatientId());
        if (patient == null || !"ACTIVE".equalsIgnoreCase(patient.getStatus())) {
            throw new ApplicationException("Selected patient is inactive or does not exist.");
        }

        // Verify dentist is active
        Dentist dentist = dentistDAO.findById(p.getDentistId());
        if (dentist == null || !"ACTIVE".equalsIgnoreCase(dentist.getStatus())) {
            throw new ApplicationException("Selected dentist is inactive or does not exist.");
        }

        // Verify each drug item has names
        for (PrescriptionItem item : items) {
            if (item.getDrugName() == null || item.getDrugName().trim().isEmpty()) {
                throw new ApplicationException("Drug name is required for all items.");
            }
            if (item.getDosage() == null || item.getDosage().trim().isEmpty()) {
                throw new ApplicationException("Dosage is required for drug: " + item.getDrugName());
            }
            if (item.getFrequency() == null || item.getFrequency().trim().isEmpty()) {
                throw new ApplicationException("Frequency is required for drug: " + item.getDrugName());
            }
            if (item.getDuration() == null || item.getDuration().trim().isEmpty()) {
                throw new ApplicationException("Duration is required for drug: " + item.getDrugName());
            }
        }

        // Generate Rx Number
        String rxNumber = prescriptionDAO.generatePrescriptionNumber();
        p.setPrescriptionNumber(rxNumber);
        p.setCreatedBy(createdByUserId);

        // Save prescription
        int rxId = prescriptionDAO.save(p);

        // Save items
        for (PrescriptionItem item : items) {
            item.setPrescriptionId(rxId);
            prescriptionDAO.saveItem(item);
        }

        // Log audit
        auditService.log(createdByUserId, null, "PRESCRIPTION_CREATED",
            "PRESCRIPTION", rxId, "E-Prescription " + rxNumber + " written for Patient #" + p.getPatientId(),
            null, null);

        return rxId;
    }

    public Prescription getPrescription(int rxId) throws ApplicationException {
        return prescriptionDAO.findById(rxId);
    }

    public List<Prescription> getPatientPrescriptions(int patientId) throws ApplicationException {
        return prescriptionDAO.findByPatientId(patientId);
    }

    public List<Prescription> getDentistPrescriptions(int dentistId) throws ApplicationException {
        return prescriptionDAO.findByDentistId(dentistId);
    }

    public List<Prescription> searchPrescriptions(String query, int offset, int limit) throws ApplicationException {
        return prescriptionDAO.search(query, offset, limit);
    }

    public int countSearch(String query) throws ApplicationException {
        return prescriptionDAO.countSearch(query);
    }
}
