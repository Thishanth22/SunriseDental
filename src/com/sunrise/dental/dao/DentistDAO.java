package com.sunrise.dental.dao;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.Dentist;
import java.util.List;

/**
 * DentistDAO — Data access interface for Dentist entities.
 */
public interface DentistDAO {

    int save(Dentist dentist) throws ApplicationException;

    Dentist findById(int dentistId) throws ApplicationException;

    Dentist findByUserId(int userId) throws ApplicationException;

    Dentist findByNumber(String dentistNumber) throws ApplicationException;

    List<Dentist> findAll() throws ApplicationException;

    List<Dentist> findAllActive() throws ApplicationException;

    List<Dentist> search(String query, int offset, int limit) throws ApplicationException;

    int countSearch(String query) throws ApplicationException;

    void update(Dentist dentist) throws ApplicationException;

    void updateStatus(int dentistId, String status) throws ApplicationException;

    String generateDentistNumber() throws ApplicationException;

    int count() throws ApplicationException;
}
