package com.sunrise.dental.model;

import java.time.LocalTime;
import java.time.LocalDateTime;

/**
 * Dentist — Dental professional with availability and specialization.
 */
public class Dentist {

    private int           dentistId;
    private String        dentistNumber;
    private String        firstName;
    private String        lastName;
    private String        specialization;
    private String        qualification;
    private String        licenseNumber;
    private String        contactNumber;
    private String        email;

    // Weekly availability flags
    private boolean       availableMonday;
    private boolean       availableTuesday;
    private boolean       availableWednesday;
    private boolean       availableThursday;
    private boolean       availableFriday;
    private boolean       availableSaturday;
    private boolean       availableSunday;

    private LocalTime     workStartTime;
    private LocalTime     workEndTime;
    private String        status;     // ACTIVE, ON_LEAVE, INACTIVE
    private String        notes;
    private int           userId;    // linked user account
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // -------------------------------------------------------
    // Computed properties
    // -------------------------------------------------------
    public String getFullName() {
        return "Dr. " + (firstName == null ? "" : firstName)
                      + " " + (lastName == null ? "" : lastName);
    }

    public String getDisplayName() {
        return getFullName() + " (" + specialization + ")";
    }

    public boolean isActive() { return "ACTIVE".equalsIgnoreCase(status); }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int        getDentistId()              { return dentistId; }
    public void       setDentistId(int v)         { this.dentistId = v; }

    public String     getDentistNumber()          { return dentistNumber; }
    public void       setDentistNumber(String v)  { this.dentistNumber = v; }

    public String     getFirstName()              { return firstName; }
    public void       setFirstName(String v)      { this.firstName = v; }

    public String     getLastName()               { return lastName; }
    public void       setLastName(String v)       { this.lastName = v; }

    public String     getSpecialization()         { return specialization; }
    public void       setSpecialization(String v) { this.specialization = v; }

    public String     getQualification()          { return qualification; }
    public void       setQualification(String v)  { this.qualification = v; }

    public String     getLicenseNumber()          { return licenseNumber; }
    public void       setLicenseNumber(String v)  { this.licenseNumber = v; }

    public String     getContactNumber()          { return contactNumber; }
    public void       setContactNumber(String v)  { this.contactNumber = v; }

    public String     getEmail()                  { return email; }
    public void       setEmail(String v)          { this.email = v; }

    public boolean    isAvailableMonday()              { return availableMonday; }
    public void       setAvailableMonday(boolean v)    { this.availableMonday = v; }

    public boolean    isAvailableTuesday()             { return availableTuesday; }
    public void       setAvailableTuesday(boolean v)   { this.availableTuesday = v; }

    public boolean    isAvailableWednesday()            { return availableWednesday; }
    public void       setAvailableWednesday(boolean v)  { this.availableWednesday = v; }

    public boolean    isAvailableThursday()             { return availableThursday; }
    public void       setAvailableThursday(boolean v)   { this.availableThursday = v; }

    public boolean    isAvailableFriday()               { return availableFriday; }
    public void       setAvailableFriday(boolean v)     { this.availableFriday = v; }

    public boolean    isAvailableSaturday()             { return availableSaturday; }
    public void       setAvailableSaturday(boolean v)   { this.availableSaturday = v; }

    public boolean    isAvailableSunday()               { return availableSunday; }
    public void       setAvailableSunday(boolean v)     { this.availableSunday = v; }

    public LocalTime  getWorkStartTime()              { return workStartTime; }
    public void       setWorkStartTime(LocalTime v)   { this.workStartTime = v; }

    public LocalTime  getWorkEndTime()                { return workEndTime; }
    public void       setWorkEndTime(LocalTime v)     { this.workEndTime = v; }

    public String     getStatus()                 { return status; }
    public void       setStatus(String v)         { this.status = v; }

    public String     getNotes()                  { return notes; }
    public void       setNotes(String v)          { this.notes = v; }

    public int        getUserId()                 { return userId; }
    public void       setUserId(int v)            { this.userId = v; }

    public LocalDateTime getCreatedAt()               { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()               { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    @Override
    public String toString() {
        return "Dentist{id=" + dentistId + ", name='" + getFullName()
                + "', specialization='" + specialization + "'}";
    }
}
