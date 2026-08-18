package com.sunrise.dental.dao;

import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.User;
import java.util.List;

/**
 * UserDAO — Data access interface for User entities.
 * All implementations must use PreparedStatements.
 */
public interface UserDAO {

    /** Persist a new user. */
    int save(User user) throws ApplicationException;

    /** Find by primary key. Returns null if not found. */
    User findById(int userId) throws ApplicationException;

    /** Find by username (for login). Returns null if not found. */
    User findByUsername(String username) throws ApplicationException;

    /** Find by email. Returns null if not found. */
    User findByEmail(String email) throws ApplicationException;

    /** Return all users (paginated). */
    List<User> findAll(int offset, int limit) throws ApplicationException;

    /** Total count (for pagination). */
    int count() throws ApplicationException;

    /** Update user details (not password). */
    void update(User user) throws ApplicationException;

    /** Update password hash. */
    void updatePassword(int userId, String newHash) throws ApplicationException;

    /** Update last-login timestamp. */
    void updateLastLogin(int userId) throws ApplicationException;

    /** Deactivate (soft-delete) a user. */
    void deactivate(int userId) throws ApplicationException;

    /** Activate a previously deactivated user. */
    void activate(int userId) throws ApplicationException;

    /** Check if username is already taken. */
    boolean usernameExists(String username) throws ApplicationException;
}
