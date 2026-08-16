package com.sunrise.dental.model;

import java.time.LocalDateTime;

/**
 * User — System user who can log in.
 * Roles: ADMIN, RECEPTIONIST, DENTIST
 */
public class User {

    private int           userId;
    private String        username;
    private String        passwordHash;   // Never expose in JSP
    private String        fullName;
    private String        email;
    private String        phone;
    private int           roleId;
    private String        roleName;       // Joined from roles table
    private boolean       active;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // -------------------------------------------------------
    // Constructors
    // -------------------------------------------------------
    public User() {}

    public User(int userId, String username, String fullName, String roleName, boolean active) {
        this.userId   = userId;
        this.username = username;
        this.fullName = fullName;
        this.roleName = roleName;
        this.active   = active;
    }

    // -------------------------------------------------------
    // Role helpers
    // -------------------------------------------------------
    public boolean isAdmin()        { return "ADMIN".equalsIgnoreCase(roleName); }
    public boolean isReceptionist() { return "RECEPTIONIST".equalsIgnoreCase(roleName); }
    public boolean isDentist()      { return "DENTIST".equalsIgnoreCase(roleName); }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int           getUserId()       { return userId; }
    public void          setUserId(int v)  { this.userId = v; }

    public String        getUsername()        { return username; }
    public void          setUsername(String v){ this.username = v; }

    public String        getPasswordHash()        { return passwordHash; }
    public void          setPasswordHash(String v){ this.passwordHash = v; }

    public String        getFullName()        { return fullName; }
    public void          setFullName(String v){ this.fullName = v; }

    public String        getEmail()        { return email; }
    public void          setEmail(String v){ this.email = v; }

    public String        getPhone()        { return phone; }
    public void          setPhone(String v){ this.phone = v; }

    public int           getRoleId()       { return roleId; }
    public void          setRoleId(int v)  { this.roleId = v; }

    public String        getRoleName()        { return roleName; }
    public void          setRoleName(String v){ this.roleName = v; }

    public boolean       isActive()        { return active; }
    public void          setActive(boolean v){ this.active = v; }

    public LocalDateTime getLastLogin()           { return lastLogin; }
    public void          setLastLogin(LocalDateTime v){ this.lastLogin = v; }

    public LocalDateTime getCreatedAt()           { return createdAt; }
    public void          setCreatedAt(LocalDateTime v){ this.createdAt = v; }

    public LocalDateTime getUpdatedAt()           { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v){ this.updatedAt = v; }

    @Override
    public String toString() {
        return "User{userId=" + userId + ", username='" + username
                + "', role='" + roleName + "'}";
    }
}
