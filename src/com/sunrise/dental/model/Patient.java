package com.sunrise.dental.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Patient — Core patient entity.
 */
public class Patient {

    private int           patientId;
    private String        patientNumber;
    private String        firstName;
    private String        lastName;
    private LocalDate     dateOfBirth;
    private String        gender;
    private String        address;
    private String        city;
    private String        contactNumber;
    private String        altContact;
    private String        email;
    private String        emergencyContactName;
    private String        emergencyContactPhone;
    private String        emergencyContactRelation;
    private String        bloodGroup;
    private String        allergies;
    private String        medicalNotes;
    private LocalDate     registrationDate;
    private String        status;         // ACTIVE, INACTIVE, DECEASED
    private int           createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // -------------------------------------------------------
    // Computed properties
    // -------------------------------------------------------
    public String getFullName() {
        return (firstName == null ? "" : firstName)
             + " "
             + (lastName  == null ? "" : lastName);
    }

    public int getAge() {
        if (dateOfBirth == null) return 0;
        return java.time.Period.between(dateOfBirth, LocalDate.now()).getYears();
    }

    public boolean isActive() { return "ACTIVE".equalsIgnoreCase(status); }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int        getPatientId()              { return patientId; }
    public void       setPatientId(int v)         { this.patientId = v; }

    public String     getPatientNumber()          { return patientNumber; }
    public void       setPatientNumber(String v)  { this.patientNumber = v; }

    public String     getFirstName()              { return firstName; }
    public void       setFirstName(String v)      { this.firstName = v; }

    public String     getLastName()               { return lastName; }
    public void       setLastName(String v)       { this.lastName = v; }

    public LocalDate  getDateOfBirth()            { return dateOfBirth; }
    public void       setDateOfBirth(LocalDate v) { this.dateOfBirth = v; }

    public String     getGender()                 { return gender; }
    public void       setGender(String v)         { this.gender = v; }

    public String     getAddress()                { return address; }
    public void       setAddress(String v)        { this.address = v; }

    public String     getCity()                   { return city; }
    public void       setCity(String v)           { this.city = v; }

    public String     getContactNumber()          { return contactNumber; }
    public void       setContactNumber(String v)  { this.contactNumber = v; }

    public String     getAltContact()             { return altContact; }
    public void       setAltContact(String v)     { this.altContact = v; }

    public String     getEmail()                  { return email; }
    public void       setEmail(String v)          { this.email = v; }

    public String     getEmergencyContactName()          { return emergencyContactName; }
    public void       setEmergencyContactName(String v)  { this.emergencyContactName = v; }

    public String     getEmergencyContactPhone()         { return emergencyContactPhone; }
    public void       setEmergencyContactPhone(String v) { this.emergencyContactPhone = v; }

    public String     getEmergencyContactRelation()          { return emergencyContactRelation; }
    public void       setEmergencyContactRelation(String v)  { this.emergencyContactRelation = v; }

    public String     getBloodGroup()             { return bloodGroup; }
    public void       setBloodGroup(String v)     { this.bloodGroup = v; }

    public String     getAllergies()              { return allergies; }
    public void       setAllergies(String v)     { this.allergies = v; }

    public String     getMedicalNotes()           { return medicalNotes; }
    public void       setMedicalNotes(String v)   { this.medicalNotes = v; }

    public LocalDate  getRegistrationDate()           { return registrationDate; }
    public void       setRegistrationDate(LocalDate v){ this.registrationDate = v; }

    public java.sql.Date getRegistrationDateSql() {
        return registrationDate != null ? java.sql.Date.valueOf(registrationDate) : null;
    }

    public String     getStatus()                 { return status; }
    public void       setStatus(String v)         { this.status = v; }

    public int        getCreatedBy()              { return createdBy; }
    public void       setCreatedBy(int v)         { this.createdBy = v; }

    public LocalDateTime getCreatedAt()               { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()               { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    @Override
    public String toString() {
        return "Patient{id=" + patientId + ", number='" + patientNumber
                + "', name='" + getFullName() + "'}";
    }
}
