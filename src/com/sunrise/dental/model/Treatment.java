package com.sunrise.dental.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Treatment — Dental treatment catalog entry with pricing.
 * Prices are ALWAYS retrieved from this model / MySQL.
 * They must NEVER be hard-coded in JSP or passed from browser form.
 */
public class Treatment {

    private int           treatmentId;
    private String        treatmentCode;
    private String        treatmentName;
    private String        category;
    private String        description;
    private BigDecimal    baseCost;
    private int           durationMins;
    private boolean       requiresFollowup;
    private String        status;          // ACTIVE, DISCONTINUED
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // -------------------------------------------------------
    // Computed properties
    // -------------------------------------------------------
    public boolean isActive() { return "ACTIVE".equalsIgnoreCase(status); }

    /** Formatted duration, e.g. "45 mins" or "1 hr 30 mins" */
    public String getFormattedDuration() {
        if (durationMins < 60) return durationMins + " mins";
        int hrs = durationMins / 60;
        int mins = durationMins % 60;
        return mins == 0 ? hrs + " hr" : hrs + " hr " + mins + " mins";
    }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int        getTreatmentId()              { return treatmentId; }
    public void       setTreatmentId(int v)         { this.treatmentId = v; }

    public String     getTreatmentCode()            { return treatmentCode; }
    public void       setTreatmentCode(String v)    { this.treatmentCode = v; }

    public String     getTreatmentName()            { return treatmentName; }
    public void       setTreatmentName(String v)    { this.treatmentName = v; }

    public String     getCategory()                 { return category; }
    public void       setCategory(String v)         { this.category = v; }

    public String     getDescription()              { return description; }
    public void       setDescription(String v)      { this.description = v; }

    public BigDecimal getBaseCost()                 { return baseCost; }
    public void       setBaseCost(BigDecimal v)     { this.baseCost = v; }

    public int        getDurationMins()             { return durationMins; }
    public void       setDurationMins(int v)        { this.durationMins = v; }

    public boolean    isRequiresFollowup()          { return requiresFollowup; }
    public void       setRequiresFollowup(boolean v){ this.requiresFollowup = v; }

    public String     getStatus()                   { return status; }
    public void       setStatus(String v)           { this.status = v; }

    public LocalDateTime getCreatedAt()               { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()               { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    @Override
    public String toString() {
        return "Treatment{id=" + treatmentId + ", code='" + treatmentCode
                + "', name='" + treatmentName + "', cost=" + baseCost + "}";
    }
}
