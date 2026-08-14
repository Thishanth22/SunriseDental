-- =============================================================
-- SUNRISE DENTAL CLINIC MANAGEMENT SYSTEM
-- Database Schema — sunrise_dental_db
-- Version: 1.0
-- Author : Sunrise Dental Dev Team
-- Date   : 2026-08-23
-- =============================================================
-- Execute order:
--   1. schema.sql       (this file)
--   2. seed.sql
--   3. procedures.sql
--   4. functions.sql
--   5. triggers.sql
-- =============================================================

-- Create and select the database
CREATE DATABASE IF NOT EXISTS sunrise_dental_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sunrise_dental_db;

-- Disable FK checks during table creation
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- TABLE: roles
-- Stores user roles (ADMIN, RECEPTIONIST, DENTIST)
-- =============================================================
CREATE TABLE IF NOT EXISTS roles (
    role_id      INT          NOT NULL AUTO_INCREMENT,
    role_name    VARCHAR(50)  NOT NULL,
    description  VARCHAR(255) DEFAULT NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id),
    UNIQUE KEY uq_role_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='User roles for RBAC';

-- =============================================================
-- TABLE: users
-- System users who log in to the application
-- =============================================================
CREATE TABLE IF NOT EXISTS users (
    user_id        INT          NOT NULL AUTO_INCREMENT,
    username       VARCHAR(50)  NOT NULL,
    password_hash  VARCHAR(255) NOT NULL COMMENT 'BCrypt hashed password',
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(100) DEFAULT NULL,
    phone          VARCHAR(20)  DEFAULT NULL,
    role_id        INT          NOT NULL,
    is_active      TINYINT(1)   NOT NULL DEFAULT 1,
    last_login     DATETIME     DEFAULT NULL,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_username    (username),
    UNIQUE KEY uq_user_email  (email),
    KEY fk_user_role          (role_id),
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Application users';

-- =============================================================
-- TABLE: patients
-- Patient demographic and contact information
-- =============================================================
CREATE TABLE IF NOT EXISTS patients (
    patient_id        INT          NOT NULL AUTO_INCREMENT,
    patient_number    VARCHAR(20)  NOT NULL COMMENT 'Auto-generated e.g. PAT-2026-000001',
    first_name        VARCHAR(60)  NOT NULL,
    last_name         VARCHAR(60)  NOT NULL,
    date_of_birth     DATE         DEFAULT NULL,
    gender            ENUM('MALE','FEMALE','OTHER') DEFAULT NULL,
    address           TEXT         DEFAULT NULL,
    city              VARCHAR(60)  DEFAULT NULL,
    contact_number    VARCHAR(20)  NOT NULL,
    alt_contact       VARCHAR(20)  DEFAULT NULL,
    email             VARCHAR(100) DEFAULT NULL,
    emergency_contact_name  VARCHAR(100) DEFAULT NULL,
    emergency_contact_phone VARCHAR(20)  DEFAULT NULL,
    emergency_contact_relation VARCHAR(50) DEFAULT NULL,
    blood_group       VARCHAR(5)   DEFAULT NULL,
    allergies         TEXT         DEFAULT NULL,
    medical_notes     TEXT         DEFAULT NULL,
    registration_date DATE         NOT NULL DEFAULT (CURRENT_DATE),
    status            ENUM('ACTIVE','INACTIVE','DECEASED') NOT NULL DEFAULT 'ACTIVE',
    created_by        INT          DEFAULT NULL,
    created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (patient_id),
    UNIQUE KEY uq_patient_number  (patient_number),
    KEY idx_patient_contact       (contact_number),
    KEY idx_patient_name          (last_name, first_name),
    KEY idx_patient_status        (status),
    KEY fk_patient_created_by     (created_by),
    CONSTRAINT fk_patient_created_by FOREIGN KEY (created_by) REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Dental clinic patients';

-- =============================================================
-- TABLE: dentists
-- Dentist professional and availability information
-- =============================================================
CREATE TABLE IF NOT EXISTS dentists (
    dentist_id       INT          NOT NULL AUTO_INCREMENT,
    dentist_number   VARCHAR(20)  NOT NULL COMMENT 'e.g. DEN-2026-000001',
    first_name       VARCHAR(60)  NOT NULL,
    last_name        VARCHAR(60)  NOT NULL,
    specialization   VARCHAR(100) NOT NULL DEFAULT 'General Dentistry',
    qualification    VARCHAR(255) DEFAULT NULL,
    license_number   VARCHAR(50)  DEFAULT NULL,
    contact_number   VARCHAR(20)  NOT NULL,
    email            VARCHAR(100) DEFAULT NULL,
    -- Weekly availability stored as JSON-like flags
    available_monday    TINYINT(1) NOT NULL DEFAULT 1,
    available_tuesday   TINYINT(1) NOT NULL DEFAULT 1,
    available_wednesday TINYINT(1) NOT NULL DEFAULT 1,
    available_thursday  TINYINT(1) NOT NULL DEFAULT 1,
    available_friday    TINYINT(1) NOT NULL DEFAULT 1,
    available_saturday  TINYINT(1) NOT NULL DEFAULT 0,
    available_sunday    TINYINT(1) NOT NULL DEFAULT 0,
    work_start_time  TIME         NOT NULL DEFAULT '09:00:00',
    work_end_time    TIME         NOT NULL DEFAULT '17:00:00',
    status           ENUM('ACTIVE','ON_LEAVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    notes            TEXT         DEFAULT NULL,
    user_id          INT          DEFAULT NULL COMMENT 'Linked login user account',
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (dentist_id),
    UNIQUE KEY uq_dentist_number  (dentist_number),
    UNIQUE KEY uq_dentist_license (license_number),
    KEY idx_dentist_status        (status),
    KEY idx_dentist_name          (last_name, first_name),
    KEY fk_dentist_user           (user_id),
    CONSTRAINT fk_dentist_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Clinic dentists';

-- =============================================================
-- TABLE: treatments
-- Catalog of dental treatments with pricing
-- =============================================================
CREATE TABLE IF NOT EXISTS treatments (
    treatment_id    INT            NOT NULL AUTO_INCREMENT,
    treatment_code  VARCHAR(20)    NOT NULL COMMENT 'e.g. TRT-001',
    treatment_name  VARCHAR(150)   NOT NULL,
    category        VARCHAR(60)    DEFAULT 'General',
    description     TEXT           DEFAULT NULL,
    base_cost       DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    duration_mins   INT            NOT NULL DEFAULT 30 COMMENT 'Expected duration in minutes',
    requires_followup TINYINT(1)   NOT NULL DEFAULT 0,
    status          ENUM('ACTIVE','DISCONTINUED') NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (treatment_id),
    UNIQUE KEY uq_treatment_code  (treatment_code),
    UNIQUE KEY uq_treatment_name  (treatment_name),
    KEY idx_treatment_category    (category),
    KEY idx_treatment_status      (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Treatment catalog with pricing';

-- =============================================================
-- TABLE: appointments
-- Core appointment scheduling table
-- =============================================================
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id      INT          NOT NULL AUTO_INCREMENT,
    appointment_number  VARCHAR(25)  NOT NULL COMMENT 'e.g. APT-2026-000001',
    patient_id          INT          NOT NULL,
    dentist_id          INT          NOT NULL,
    treatment_id        INT          NOT NULL,
    appointment_date    DATE         NOT NULL,
    appointment_time    TIME         NOT NULL,
    end_time            TIME         DEFAULT NULL COMMENT 'Calculated from treatment duration',
    status              ENUM('SCHEDULED','CONFIRMED','COMPLETED','CANCELLED','NO_SHOW','RESCHEDULED')
                            NOT NULL DEFAULT 'SCHEDULED',
    priority            ENUM('NORMAL','URGENT','EMERGENCY') NOT NULL DEFAULT 'NORMAL',
    notes               TEXT         DEFAULT NULL,
    cancellation_reason TEXT         DEFAULT NULL,
    rescheduled_from    INT          DEFAULT NULL COMMENT 'Previous appointment_id if rescheduled',
    created_by          INT          DEFAULT NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (appointment_id),
    UNIQUE KEY uq_appointment_number (appointment_number),
    KEY idx_appointment_date         (appointment_date),
    KEY idx_appointment_time         (appointment_time),
    KEY idx_appointment_status       (status),
    KEY idx_appointment_dentist_date (dentist_id, appointment_date, appointment_time),
    KEY idx_appointment_patient      (patient_id),
    KEY fk_appointment_patient       (patient_id),
    KEY fk_appointment_dentist       (dentist_id),
    KEY fk_appointment_treatment     (treatment_id),
    KEY fk_appointment_created_by    (created_by),
    KEY fk_appointment_rescheduled   (rescheduled_from),
    CONSTRAINT fk_appointment_patient    FOREIGN KEY (patient_id)    REFERENCES patients   (patient_id),
    CONSTRAINT fk_appointment_dentist    FOREIGN KEY (dentist_id)    REFERENCES dentists   (dentist_id),
    CONSTRAINT fk_appointment_treatment  FOREIGN KEY (treatment_id)  REFERENCES treatments (treatment_id),
    CONSTRAINT fk_appointment_created_by FOREIGN KEY (created_by)    REFERENCES users      (user_id) ON DELETE SET NULL,
    CONSTRAINT fk_appointment_rescheduled FOREIGN KEY (rescheduled_from) REFERENCES appointments (appointment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Patient appointment scheduling';

-- =============================================================
-- TABLE: appointment_status_history
-- Audit trail for appointment status changes (populated by trigger)
-- =============================================================
CREATE TABLE IF NOT EXISTS appointment_status_history (
    history_id          INT         NOT NULL AUTO_INCREMENT,
    appointment_id      INT         NOT NULL,
    old_status          VARCHAR(20) DEFAULT NULL,
    new_status          VARCHAR(20) NOT NULL,
    changed_at          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id  INT         DEFAULT NULL,
    remarks             TEXT        DEFAULT NULL,
    PRIMARY KEY (history_id),
    KEY fk_ash_appointment  (appointment_id),
    KEY fk_ash_user         (changed_by_user_id),
    CONSTRAINT fk_ash_appointment FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id) ON DELETE CASCADE,
    CONSTRAINT fk_ash_user        FOREIGN KEY (changed_by_user_id) REFERENCES users (user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Appointment status change audit trail';

-- =============================================================
-- TABLE: bills
-- Invoice / bill header per appointment
-- =============================================================
CREATE TABLE IF NOT EXISTS bills (
    bill_id             INT            NOT NULL AUTO_INCREMENT,
    bill_number         VARCHAR(25)    NOT NULL COMMENT 'e.g. BIL-2026-000001',
    appointment_id      INT            NOT NULL,
    patient_id          INT            NOT NULL,
    consultation_fee    DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    treatment_cost      DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    additional_charges  DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    additional_desc     VARCHAR(255)   DEFAULT NULL,
    discount_percent    DECIMAL(5,2)   NOT NULL DEFAULT 0.00,
    discount_amount     DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    tax_percent         DECIMAL(5,2)   NOT NULL DEFAULT 0.00,
    tax_amount          DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    sub_total           DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    grand_total         DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    amount_paid         DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    balance_due         DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    bill_status         ENUM('DRAFT','ISSUED','PAID','PARTIALLY_PAID','CANCELLED','REFUNDED')
                            NOT NULL DEFAULT 'DRAFT',
    notes               TEXT           DEFAULT NULL,
    issued_date         DATE           DEFAULT NULL,
    due_date            DATE           DEFAULT NULL,
    created_by          INT            DEFAULT NULL,
    created_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (bill_id),
    UNIQUE KEY uq_bill_number        (bill_number),
    UNIQUE KEY uq_bill_appointment   (appointment_id),
    KEY idx_bill_status              (bill_status),
    KEY idx_bill_patient             (patient_id),
    KEY idx_bill_issued_date         (issued_date),
    KEY fk_bill_appointment          (appointment_id),
    KEY fk_bill_patient              (patient_id),
    KEY fk_bill_created_by           (created_by),
    CONSTRAINT fk_bill_appointment  FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id),
    CONSTRAINT fk_bill_patient      FOREIGN KEY (patient_id)     REFERENCES patients     (patient_id),
    CONSTRAINT fk_bill_created_by   FOREIGN KEY (created_by)     REFERENCES users        (user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Bill / invoice header';

-- =============================================================
-- TABLE: bill_items
-- Line items for each bill (multiple treatments or charges)
-- =============================================================
CREATE TABLE IF NOT EXISTS bill_items (
    item_id         INT            NOT NULL AUTO_INCREMENT,
    bill_id         INT            NOT NULL,
    item_type       ENUM('CONSULTATION','TREATMENT','MEDICATION','MATERIAL','OTHER')
                        NOT NULL DEFAULT 'TREATMENT',
    description     VARCHAR(255)   NOT NULL,
    unit_price      DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    quantity        DECIMAL(8,2)   NOT NULL DEFAULT 1.00,
    total_price     DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    PRIMARY KEY (item_id),
    KEY fk_bi_bill (bill_id),
    CONSTRAINT fk_bi_bill FOREIGN KEY (bill_id) REFERENCES bills (bill_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Bill line items';

-- =============================================================
-- TABLE: payments
-- Individual payment transactions against a bill
-- =============================================================
CREATE TABLE IF NOT EXISTS payments (
    payment_id      INT            NOT NULL AUTO_INCREMENT,
    payment_number  VARCHAR(25)    NOT NULL COMMENT 'e.g. PAY-2026-000001',
    bill_id         INT            NOT NULL,
    patient_id      INT            NOT NULL,
    amount          DECIMAL(10,2)  NOT NULL,
    payment_method  ENUM('CASH','CARD','BANK_TRANSFER','ONLINE','CHEQUE')
                        NOT NULL DEFAULT 'CASH',
    payment_status  ENUM('PENDING','COMPLETED','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    transaction_ref VARCHAR(100)   DEFAULT NULL COMMENT 'Card/bank transaction reference',
    payment_date    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT           DEFAULT NULL,
    received_by     INT            DEFAULT NULL,
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (payment_id),
    UNIQUE KEY uq_payment_number  (payment_number),
    KEY idx_payment_bill          (bill_id),
    KEY idx_payment_patient       (patient_id),
    KEY idx_payment_date          (payment_date),
    KEY idx_payment_status        (payment_status),
    KEY fk_payment_bill           (bill_id),
    KEY fk_payment_patient        (patient_id),
    KEY fk_payment_received_by    (received_by),
    CONSTRAINT fk_payment_bill        FOREIGN KEY (bill_id)      REFERENCES bills    (bill_id),
    CONSTRAINT fk_payment_patient     FOREIGN KEY (patient_id)   REFERENCES patients (patient_id),
    CONSTRAINT fk_payment_received_by FOREIGN KEY (received_by)  REFERENCES users    (user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Payment transactions';

-- =============================================================
-- TABLE: notifications
-- Notification messages sent to staff/patients
-- =============================================================
CREATE TABLE IF NOT EXISTS notifications (
    notification_id   INT          NOT NULL AUTO_INCREMENT,
    recipient_user_id INT          DEFAULT NULL COMMENT 'Internal user recipient',
    recipient_type    ENUM('USER','PATIENT','SYSTEM') NOT NULL DEFAULT 'USER',
    subject           VARCHAR(255) NOT NULL,
    message           TEXT         NOT NULL,
    notification_type ENUM('APPOINTMENT_CONFIRMATION','APPOINTMENT_REMINDER',
                           'APPOINTMENT_CANCELLATION','PAYMENT_RECEIPT',
                           'SYSTEM_ALERT','GENERAL') NOT NULL DEFAULT 'GENERAL',
    related_entity    VARCHAR(50)  DEFAULT NULL COMMENT 'e.g. APPOINTMENT, BILL',
    related_id        INT          DEFAULT NULL,
    is_read           TINYINT(1)   NOT NULL DEFAULT 0,
    sent_at           DATETIME     DEFAULT NULL,
    created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id),
    KEY idx_notif_recipient   (recipient_user_id),
    KEY idx_notif_type        (notification_type),
    KEY idx_notif_is_read     (is_read),
    KEY fk_notif_user         (recipient_user_id),
    CONSTRAINT fk_notif_user FOREIGN KEY (recipient_user_id) REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='System notifications';

-- =============================================================
-- TABLE: audit_logs
-- Complete audit trail of all system actions
-- =============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id        BIGINT       NOT NULL AUTO_INCREMENT,
    user_id       INT          DEFAULT NULL,
    username      VARCHAR(50)  DEFAULT NULL COMMENT 'Snapshot at time of action',
    action        VARCHAR(50)  NOT NULL COMMENT 'e.g. LOGIN, PATIENT_CREATED',
    entity_type   VARCHAR(50)  DEFAULT NULL COMMENT 'e.g. PATIENT, APPOINTMENT',
    entity_id     INT          DEFAULT NULL,
    description   TEXT         DEFAULT NULL,
    ip_address    VARCHAR(45)  DEFAULT NULL,
    user_agent    VARCHAR(500) DEFAULT NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id),
    KEY idx_audit_user       (user_id),
    KEY idx_audit_action     (action),
    KEY idx_audit_entity     (entity_type, entity_id),
    KEY idx_audit_created_at (created_at),
    KEY fk_audit_user        (user_id),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='System-wide audit log';

-- =============================================================
-- TABLE: system_settings
-- Key-value store for configurable clinic settings
-- =============================================================
CREATE TABLE IF NOT EXISTS system_settings (
    setting_id    INT          NOT NULL AUTO_INCREMENT,
    setting_key   VARCHAR(100) NOT NULL,
    setting_value TEXT         DEFAULT NULL,
    description   VARCHAR(255) DEFAULT NULL,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (setting_id),
    UNIQUE KEY uq_setting_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Configurable system settings';

-- =============================================================
-- TABLE: prescriptions & prescription_items
-- E-Prescriptions Module
-- =============================================================
CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id     INT          NOT NULL AUTO_INCREMENT,
    prescription_number VARCHAR(50)  NOT NULL,
    patient_id          INT          NOT NULL,
    dentist_id          INT          NOT NULL,
    appointment_id      INT          DEFAULT NULL,
    notes               TEXT         DEFAULT NULL,
    created_by          INT          NOT NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (prescription_id),
    UNIQUE KEY uq_rx_number (prescription_number),
    KEY fk_rx_patient (patient_id),
    KEY fk_rx_dentist (dentist_id),
    KEY fk_rx_appt (appointment_id),
    CONSTRAINT fk_rx_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    CONSTRAINT fk_rx_dentist FOREIGN KEY (dentist_id) REFERENCES dentists(dentist_id),
    CONSTRAINT fk_rx_appt FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Patient prescriptions';

CREATE TABLE IF NOT EXISTS prescription_items (
    item_id         INT          NOT NULL AUTO_INCREMENT,
    prescription_id INT          NOT NULL,
    drug_name       VARCHAR(100) NOT NULL,
    dosage          VARCHAR(100) NOT NULL,
    frequency       VARCHAR(100) NOT NULL,
    duration        VARCHAR(100) NOT NULL,
    instructions    VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (item_id),
    KEY fk_rx_item_presc (prescription_id),
    CONSTRAINT fk_rx_item_presc FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Individual drugs inside a prescription';

-- Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- Verify tables
-- =============================================================
SHOW TABLES;
