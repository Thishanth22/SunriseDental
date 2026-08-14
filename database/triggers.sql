-- =============================================================
-- SUNRISE DENTAL CLINIC MANAGEMENT SYSTEM
-- MySQL Triggers
-- =============================================================
-- Run AFTER schema.sql, seed.sql, procedures.sql, functions.sql
-- =============================================================

USE sunrise_dental_db;

DELIMITER $$

-- =============================================================
-- TRIGGER: trg_appointment_status_change_update
-- Purpose : When an appointment's status is UPDATE-d,
--           automatically insert a record into appointment_status_history
--           so we have a full audit trail of every status change.
-- =============================================================
DROP TRIGGER IF EXISTS trg_appointment_status_change_update $$
CREATE TRIGGER trg_appointment_status_change_update
    AFTER UPDATE ON appointments
    FOR EACH ROW
BEGIN
    -- Only fire when status actually changed
    IF OLD.status <> NEW.status THEN
        INSERT INTO appointment_status_history (
            appointment_id,
            old_status,
            new_status,
            changed_at,
            changed_by_user_id,
            remarks
        ) VALUES (
            NEW.appointment_id,
            OLD.status,
            NEW.status,
            NOW(),
            NEW.created_by,     -- closest we can get without session user
            CONCAT('Status changed from ', OLD.status, ' to ', NEW.status)
        );
    END IF;
END$$

-- =============================================================
-- TRIGGER: trg_appointment_status_change_insert
-- Purpose : On INSERT of a new appointment, record the initial
--           status in appointment_status_history.
-- =============================================================
DROP TRIGGER IF EXISTS trg_appointment_status_change_insert $$
CREATE TRIGGER trg_appointment_status_change_insert
    AFTER INSERT ON appointments
    FOR EACH ROW
BEGIN
    INSERT INTO appointment_status_history (
        appointment_id,
        old_status,
        new_status,
        changed_at,
        changed_by_user_id,
        remarks
    ) VALUES (
        NEW.appointment_id,
        NULL,
        NEW.status,
        NOW(),
        NEW.created_by,
        'Initial appointment creation'
    );
END$$

-- =============================================================
-- TRIGGER: trg_payment_update_bill
-- Purpose : After a payment is INSERTED (status=COMPLETED),
--           recalculate the bill's amount_paid, balance_due,
--           and update bill_status accordingly.
--
--  This ensures bill totals remain consistent even if a partial
--  payment is made, and automatically marks the bill as PAID
--  when the balance reaches zero.
-- =============================================================
DROP TRIGGER IF EXISTS trg_payment_update_bill $$
CREATE TRIGGER trg_payment_update_bill
    AFTER INSERT ON payments
    FOR EACH ROW
BEGIN
    DECLARE v_total_paid   DECIMAL(10,2);
    DECLARE v_grand_total  DECIMAL(10,2);
    DECLARE v_balance      DECIMAL(10,2);
    DECLARE v_new_status   VARCHAR(20);

    -- Only act on completed payments
    IF NEW.payment_status = 'COMPLETED' THEN

        -- Sum all completed payments for this bill
        SELECT COALESCE(SUM(amount), 0) INTO v_total_paid
        FROM payments
        WHERE bill_id = NEW.bill_id
          AND payment_status = 'COMPLETED';

        -- Get bill grand total
        SELECT grand_total INTO v_grand_total
        FROM bills
        WHERE bill_id = NEW.bill_id;

        SET v_balance = v_grand_total - v_total_paid;

        -- Determine new bill status
        SET v_new_status = CASE
            WHEN v_balance <= 0                     THEN 'PAID'
            WHEN v_total_paid > 0 AND v_balance > 0 THEN 'PARTIALLY_PAID'
            ELSE 'ISSUED'
        END;

        -- Update bill
        UPDATE bills
        SET amount_paid  = v_total_paid,
            balance_due  = GREATEST(v_balance, 0),
            bill_status  = v_new_status
        WHERE bill_id = NEW.bill_id;

    END IF;
END$$

-- =============================================================
-- TRIGGER: trg_bill_items_insert
-- Purpose : After inserting a bill_item, recalculate and update
--           the treatment_cost on the parent bill.
--           (bill.treatment_cost = SUM of TREATMENT type items)
-- =============================================================
DROP TRIGGER IF EXISTS trg_bill_items_insert $$
CREATE TRIGGER trg_bill_items_insert
    AFTER INSERT ON bill_items
    FOR EACH ROW
BEGIN
    DECLARE v_treatment_total DECIMAL(10,2);

    SELECT COALESCE(SUM(total_price), 0) INTO v_treatment_total
    FROM bill_items
    WHERE bill_id = NEW.bill_id
      AND item_type = 'TREATMENT';

    UPDATE bills
    SET treatment_cost = v_treatment_total
    WHERE bill_id = NEW.bill_id;
END$$

-- =============================================================
-- TRIGGER: trg_patient_deactivation_audit
-- Purpose : When a patient's status changes to INACTIVE or DECEASED,
--           insert an audit log entry automatically.
-- =============================================================
DROP TRIGGER IF EXISTS trg_patient_deactivation_audit $$
CREATE TRIGGER trg_patient_deactivation_audit
    AFTER UPDATE ON patients
    FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status AND NEW.status IN ('INACTIVE','DECEASED') THEN
        INSERT INTO audit_logs (
            user_id,
            username,
            action,
            entity_type,
            entity_id,
            description,
            ip_address,
            created_at
        ) VALUES (
            NEW.created_by,
            NULL,
            'PATIENT_STATUS_CHANGED',
            'PATIENT',
            NEW.patient_id,
            CONCAT('Patient ', NEW.patient_number, ' status changed from ',
                   OLD.status, ' to ', NEW.status),
            NULL,
            NOW()
        );
    END IF;
END$$

-- =============================================================
-- TRIGGER: trg_appointment_end_time
-- Purpose : Before inserting/updating an appointment, automatically
--           calculate end_time from treatment.duration_mins if
--           end_time is not explicitly provided.
-- =============================================================
DROP TRIGGER IF EXISTS trg_appointment_end_time_insert $$
CREATE TRIGGER trg_appointment_end_time_insert
    BEFORE INSERT ON appointments
    FOR EACH ROW
BEGIN
    DECLARE v_duration INT;

    IF NEW.end_time IS NULL THEN
        SELECT duration_mins INTO v_duration
        FROM treatments
        WHERE treatment_id = NEW.treatment_id;

        SET NEW.end_time = ADDTIME(NEW.appointment_time,
                                    SEC_TO_TIME(v_duration * 60));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_appointment_end_time_update $$
CREATE TRIGGER trg_appointment_end_time_update
    BEFORE UPDATE ON appointments
    FOR EACH ROW
BEGIN
    DECLARE v_duration INT;

    -- Recalculate end_time if treatment or start time changed
    IF NEW.treatment_id <> OLD.treatment_id
        OR NEW.appointment_time <> OLD.appointment_time
        OR NEW.end_time IS NULL THEN

        SELECT duration_mins INTO v_duration
        FROM treatments
        WHERE treatment_id = NEW.treatment_id;

        SET NEW.end_time = ADDTIME(NEW.appointment_time,
                                    SEC_TO_TIME(v_duration * 60));
    END IF;
END$$

DELIMITER ;

SELECT 'Triggers created successfully.' AS status;
