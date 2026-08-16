package com.sunrise.dental.model;

import java.time.LocalDateTime;

/**
 * AuditLog — Immutable audit trail entry.
 * Stores who did what, to which entity, when and from where.
 *
 * Action examples: LOGIN, LOGOUT, PATIENT_CREATED, PATIENT_UPDATED,
 *   APPOINTMENT_CREATED, APPOINTMENT_CANCELLED, BILL_CREATED,
 *   PAYMENT_CREATED, USER_CREATED, etc.
 */
public class AuditLog {

    private long          logId;
    private int           userId;
    private String        username;
    private String        action;
    private String        entityType;
    private int           entityId;
    private String        description;
    private String        ipAddress;
    private String        userAgent;
    private LocalDateTime createdAt;

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public long       getLogId()               { return logId; }
    public void       setLogId(long v)         { this.logId = v; }

    public int        getUserId()              { return userId; }
    public void       setUserId(int v)         { this.userId = v; }

    public String     getUsername()            { return username; }
    public void       setUsername(String v)    { this.username = v; }

    public String     getAction()              { return action; }
    public void       setAction(String v)      { this.action = v; }

    public String     getEntityType()          { return entityType; }
    public void       setEntityType(String v)  { this.entityType = v; }

    public int        getEntityId()            { return entityId; }
    public void       setEntityId(int v)       { this.entityId = v; }

    public String     getDescription()         { return description; }
    public void       setDescription(String v) { this.description = v; }

    public String     getIpAddress()           { return ipAddress; }
    public void       setIpAddress(String v)   { this.ipAddress = v; }

    public String     getUserAgent()           { return userAgent; }
    public void       setUserAgent(String v)   { this.userAgent = v; }

    public LocalDateTime getCreatedAt()               { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    @Override
    public String toString() {
        return "AuditLog{logId=" + logId + ", user='" + username
                + "', action='" + action + "', entity='"
                + entityType + "#" + entityId + "'}";
    }
}
