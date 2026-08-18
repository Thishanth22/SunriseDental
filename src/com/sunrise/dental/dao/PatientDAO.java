package com.sunrise.dental.dao;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Patient;
import java.util.List;

/**
 * PatientDAO — Data access interface for Patient entities.
 */
public interface PatientDAO {

    /** Persist a new patient. Returns generated patient_id. */
    int save(Patient patient) throws ApplicationException;

    /** Find by primary key. Returns null if not found. */
    Patient findById(int patientId) throws ApplicationException;

    /** Find by patient_number (e.g. PAT-2026-000001). */
    Patient findByPatientNumber(String patientNumber) throws ApplicationException;

    /** Find by contact number (used for quick search at reception). */
    List<Patient> findByContactNumber(String contactNumber) throws ApplicationException;

    /** Full-text search across name, contact, email. */
    List<Patient> search(String query, int offset, int limit) throws ApplicationException;

    /** Count records matching search query (for pagination). */
    int countSearch(String query) throws ApplicationException;

    /** Return all active patients, paginated. */
    List<Patient> findAll(int offset, int limit) throws ApplicationException;

    /** Total count (for pagination). */
    int count() throws ApplicationException;

    /** Update patient details. */
    void update(Patient patient) throws ApplicationException;

    /** Change patient status (ACTIVE, INACTIVE, DECEASED). */
    void updateStatus(int patientId, String status) throws ApplicationException;

    /** Generate next patient number for the current year. */
    String generatePatientNumber() throws ApplicationException;
}
