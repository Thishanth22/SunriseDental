-- =============================================================
-- SUNRISE DENTAL CLINIC MANAGEMENT SYSTEM
-- MySQL Functions
-- =============================================================
-- Run AFTER schema.sql and seed.sql
-- =============================================================

USE sunrise_dental_db;

DELIMITER $$

-- =============================================================
-- FUNCTION: fn_calculate_bill_total
-- Purpose : Calculates the grand total for a bill given the
--           individual components. Centralises the formula
--           so both Java and SQL agree on the calculation.
-- Formula : sub_total  = consultation_fee + treatment_cost + additional_charges
--           discount   = sub_total * (discount_pct / 100)
--           after_disc = sub_total - discount
--           tax        = after_disc * (tax_pct / 100)
--           grand_total = after_disc + tax
-- =============================================================
DROP FUNCTION IF EXISTS fn_calculate_bill_total $$
CREATE FUNCTION fn_calculate_bill_total(
    p_consultation_fee   DECIMAL(10,2),
    p_treatment_cost     DECIMAL(10,2),
    p_additional_charges DECIMAL(10,2),
    p_discount_pct       DECIMAL(5,2),
    p_tax_pct            DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
COMMENT 'Calculates bill grand total from fee components'
BEGIN
    DECLARE v_sub_total    DECIMAL(10,2);
    DECLARE v_discount     DECIMAL(10,2);
    DECLARE v_after_disc   DECIMAL(10,2);
    DECLARE v_tax          DECIMAL(10,2);
    DECLARE v_grand_total  DECIMAL(10,2);

    SET v_sub_total   = p_consultation_fee + p_treatment_cost + p_additional_charges;
    SET v_discount    = ROUND(v_sub_total * (p_discount_pct / 100), 2);
    SET v_after_disc  = v_sub_total - v_discount;
    SET v_tax         = ROUND(v_after_disc * (p_tax_pct / 100), 2);
    SET v_grand_total = v_after_disc + v_tax;

    RETURN v_grand_total;
END$$

-- =============================================================
-- FUNCTION: fn_get_age
-- Purpose : Returns patient age in years from date_of_birth
-- =============================================================
DROP FUNCTION IF EXISTS fn_get_age $$
CREATE FUNCTION fn_get_age(
    p_dob DATE
)
RETURNS INT
DETERMINISTIC
COMMENT 'Returns patient age in years from date of birth'
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_dob, CURDATE());
END$$

-- =============================================================
-- FUNCTION: fn_format_phone_lk
-- Purpose : Formats a Sri Lankan phone number to standard 07X form.
--           Strips spaces, dashes, and country code prefix.
--           Returns NULL if number is not a recognised SL format.
-- =============================================================
DROP FUNCTION IF EXISTS fn_format_phone_lk $$
CREATE FUNCTION fn_format_phone_lk(
    p_phone VARCHAR(30)
)
RETURNS VARCHAR(15)
DETERMINISTIC
COMMENT 'Normalises Sri Lankan phone number to 07XXXXXXXX format'
BEGIN
    DECLARE v_clean VARCHAR(20);

    -- Remove spaces, dashes, parentheses
    SET v_clean = REPLACE(REPLACE(REPLACE(REPLACE(p_phone, ' ', ''), '-', ''), '(', ''), ')', '');

    -- Replace leading +94 or 0094 with 0
    IF v_clean REGEXP '^\\+94[0-9]{9}$' THEN
        SET v_clean = CONCAT('0', SUBSTRING(v_clean, 4));
    ELSEIF v_clean REGEXP '^0094[0-9]{9}$' THEN
        SET v_clean = CONCAT('0', SUBSTRING(v_clean, 5));
    END IF;

    -- Must now match 07XXXXXXXX or 01XXXXXXXX etc. (10 digits, starts 0)
    IF v_clean REGEXP '^0[0-9]{9}$' THEN
        RETURN v_clean;
    ELSE
        RETURN NULL;  -- invalid
    END IF;
END$$

-- =============================================================
-- FUNCTION: fn_appointment_number
-- Purpose : Generates next appointment number in format APT-YYYY-NNNNNN
-- =============================================================
DROP FUNCTION IF EXISTS fn_appointment_number $$
CREATE FUNCTION fn_appointment_number()
RETURNS VARCHAR(25)
NOT DETERMINISTIC
READS SQL DATA
COMMENT 'Generates the next sequential appointment number'
BEGIN
    DECLARE v_year    INT;
    DECLARE v_count   INT;
    DECLARE v_number  VARCHAR(25);

    SET v_year = YEAR(NOW());

    SELECT COUNT(*) + 1 INTO v_count
    FROM appointments
    WHERE YEAR(created_at) = v_year;

    SET v_number = CONCAT('APT-', v_year, '-', LPAD(v_count, 6, '0'));
    RETURN v_number;
END$$

-- =============================================================
-- FUNCTION: fn_bill_number
-- Purpose : Generates next bill number in format BIL-YYYY-NNNNNN
-- =============================================================
DROP FUNCTION IF EXISTS fn_bill_number $$
CREATE FUNCTION fn_bill_number()
RETURNS VARCHAR(25)
NOT DETERMINISTIC
READS SQL DATA
COMMENT 'Generates the next sequential bill number'
BEGIN
    DECLARE v_year   INT;
    DECLARE v_count  INT;
    DECLARE v_number VARCHAR(25);

    SET v_year = YEAR(NOW());

    SELECT COUNT(*) + 1 INTO v_count
    FROM bills
    WHERE YEAR(created_at) = v_year;

    SET v_number = CONCAT('BIL-', v_year, '-', LPAD(v_count, 6, '0'));
    RETURN v_number;
END$$

-- =============================================================
-- FUNCTION: fn_payment_number
-- Purpose : Generates next payment number in format PAY-YYYY-NNNNNN
-- =============================================================
DROP FUNCTION IF EXISTS fn_payment_number $$
CREATE FUNCTION fn_payment_number()
RETURNS VARCHAR(25)
NOT DETERMINISTIC
READS SQL DATA
COMMENT 'Generates the next sequential payment number'
BEGIN
    DECLARE v_year   INT;
    DECLARE v_count  INT;
    DECLARE v_number VARCHAR(25);

    SET v_year = YEAR(NOW());

    SELECT COUNT(*) + 1 INTO v_count
    FROM payments
    WHERE YEAR(created_at) = v_year;

    SET v_number = CONCAT('PAY-', v_year, '-', LPAD(v_count, 6, '0'));
    RETURN v_number;
END$$

-- =============================================================
-- FUNCTION: fn_patient_number
-- Purpose : Generates next patient number in format PAT-YYYY-NNNNNN
-- =============================================================
DROP FUNCTION IF EXISTS fn_patient_number $$
CREATE FUNCTION fn_patient_number()
RETURNS VARCHAR(25)
NOT DETERMINISTIC
READS SQL DATA
COMMENT 'Generates the next sequential patient number'
BEGIN
    DECLARE v_year   INT;
    DECLARE v_count  INT;
    DECLARE v_number VARCHAR(25);

    SET v_year = YEAR(NOW());

    SELECT COUNT(*) + 1 INTO v_count
    FROM patients
    WHERE YEAR(created_at) = v_year;

    SET v_number = CONCAT('PAT-', v_year, '-', LPAD(v_count, 6, '0'));
    RETURN v_number;
END$$

-- =============================================================
-- FUNCTION: fn_is_dentist_available
-- Purpose : Returns 1 if dentist has no conflicting appointment,
--           0 otherwise. Used in SELECT queries for validation.
-- =============================================================
DROP FUNCTION IF EXISTS fn_is_dentist_available $$
CREATE FUNCTION fn_is_dentist_available(
    p_dentist_id       INT,
    p_date             DATE,
    p_start_time       TIME,
    p_end_time         TIME,
    p_exclude_appt_id  INT
)
RETURNS TINYINT(1)
NOT DETERMINISTIC
READS SQL DATA
COMMENT 'Returns 1 if dentist slot is free, 0 if conflict exists'
BEGIN
    DECLARE v_conflict INT;

    SELECT COUNT(*) INTO v_conflict
    FROM appointments
    WHERE dentist_id       = p_dentist_id
      AND appointment_date = p_date
      AND appointment_id  <> p_exclude_appt_id
      AND status NOT IN ('CANCELLED','NO_SHOW','RESCHEDULED')
      AND (p_start_time < end_time AND p_end_time > appointment_time);

    RETURN IF(v_conflict = 0, 1, 0);
END$$

DELIMITER ;

SELECT 'MySQL functions created successfully.' AS status;
