package com.sunrise.dental.dao;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Treatment;
import java.util.List;

/**
 * TreatmentDAO — Data access interface for Treatment catalog.
 */
public interface TreatmentDAO {

    int save(Treatment treatment) throws ApplicationException;

    Treatment findById(int treatmentId) throws ApplicationException;

    Treatment findByCode(String code) throws ApplicationException;

    List<Treatment> findAll() throws ApplicationException;

    List<Treatment> findAllActive() throws ApplicationException;

    List<Treatment> findByCategory(String category) throws ApplicationException;

    List<Treatment> search(String query, int offset, int limit) throws ApplicationException;

    int countSearch(String query) throws ApplicationException;

    void update(Treatment treatment) throws ApplicationException;

    void updateStatus(int treatmentId, String status) throws ApplicationException;

    int count() throws ApplicationException;
}
