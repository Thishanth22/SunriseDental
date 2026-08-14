-- =============================================================
-- SUNRISE DENTAL CLINIC MANAGEMENT SYSTEM
-- Stored Procedures
-- =============================================================
-- Run AFTER schema.sql and seed.sql
-- =============================================================

USE sunrise_dental_db;

DELIMITER $$

-- =============================================================
-- PROCEDURE: sp_get_patient_history
-- Returns full appointment, bill, and payment history for a patient
-- =============================================================
DROP PROCEDURE IF EXISTS sp_get_patient_history $$
CREATE PROCEDURE sp_get_patient_history(
    IN p_patient_id INT
)
BEGIN
    -- Patient details
    SELECT
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        p.patient_number,
        p.contact_number,
        p.email,
        p.date_of_birth,
        p.blood_group,
        p.allergies,
        p.registration_date,
        p.status
    FROM patients p
    WHERE p.patient_id = p_patient_id;

    -- Appointment history with dentist and treatment details
    SELECT
        a.appointment_id,
        a.appointment_number,
        a.appointment_date,
        a.appointment_time,
        a.status,
        a.priority,
        CONCAT(d.first_name, ' ', d.last_name) AS dentist_name,
        d.specialization,
        t.treatment_name,
        t.base_cost AS treatment_cost,
        a.notes
    FROM appointments a
    JOIN dentists   d ON a.dentist_id    = d.dentist_id
    JOIN treatments t ON a.treatment_id  = t.treatment_id
    WHERE a.patient_id = p_patient_id
    ORDER BY a.appointment_date DESC, a.appointment_time DESC;

    -- Billing history
    SELECT
        b.bill_id,
        b.bill_number,
        b.issued_date,
        b.grand_total,
        b.amount_paid,
        b.balance_due,
        b.bill_status
    FROM bills b
    WHERE b.patient_id = p_patient_id
    ORDER BY b.issued_date DESC;

    -- Payment history
    SELECT
        p2.payment_number,
        p2.payment_date,
        p2.amount,
        p2.payment_method,
        p2.payment_status,
        b.bill_number
    FROM payments p2
    JOIN bills b ON p2.bill_id = b.bill_id
    WHERE p2.patient_id = p_patient_id
    ORDER BY p2.payment_date DESC;
END$$

-- =============================================================
-- PROCEDURE: sp_get_dentist_schedule
-- Returns appointments for a dentist for a given date range
-- =============================================================
DROP PROCEDURE IF EXISTS sp_get_dentist_schedule $$
CREATE PROCEDURE sp_get_dentist_schedule(
    IN p_dentist_id  INT,
    IN p_date_from   DATE,
    IN p_date_to     DATE
)
BEGIN
    SELECT
        a.appointment_id,
        a.appointment_number,
        a.appointment_date,
        a.appointment_time,
        a.end_time,
        a.status,
        a.priority,
        CONCAT(p.first_name, ' ', p.last_name)  AS patient_name,
        p.contact_number                         AS patient_phone,
        t.treatment_name,
        t.duration_mins,
        a.notes
    FROM appointments a
    JOIN patients   p ON a.patient_id    = p.patient_id
    JOIN treatments t ON a.treatment_id  = t.treatment_id
    WHERE a.dentist_id      = p_dentist_id
      AND a.appointment_date BETWEEN p_date_from AND p_date_to
      AND a.status NOT IN ('CANCELLED','NO_SHOW')
    ORDER BY a.appointment_date ASC, a.appointment_time ASC;
END$$

-- =============================================================
-- PROCEDURE: sp_check_dentist_availability
-- Returns 1 if slot is available, 0 if already booked
-- =============================================================
DROP PROCEDURE IF EXISTS sp_check_dentist_availability $$
CREATE PROCEDURE sp_check_dentist_availability(
    IN  p_dentist_id        INT,
    IN  p_appointment_date  DATE,
    IN  p_start_time        TIME,
    IN  p_end_time          TIME,
    IN  p_exclude_appt_id   INT,        -- Pass 0 for new bookings
    OUT p_is_available      TINYINT
)
BEGIN
    DECLARE conflict_count INT;

    SELECT COUNT(*) INTO conflict_count
    FROM appointments
    WHERE dentist_id       = p_dentist_id
      AND appointment_date = p_appointment_date
      AND status NOT IN ('CANCELLED', 'NO_SHOW', 'RESCHEDULED')
      AND appointment_id   <> p_exclude_appt_id
      AND (
          -- new slot overlaps with existing slot
          (p_start_time < end_time AND p_end_time > appointment_time)
      );

    SET p_is_available = IF(conflict_count = 0, 1, 0);
END$$

-- =============================================================
-- PROCEDURE: sp_generate_daily_revenue
-- Revenue summary for a specific date
-- =============================================================
DROP PROCEDURE IF EXISTS sp_generate_daily_revenue $$
CREATE PROCEDURE sp_generate_daily_revenue(
    IN p_date DATE
)
BEGIN
    -- Summary totals
    SELECT
        COUNT(DISTINCT b.bill_id)                                     AS total_bills,
        COUNT(DISTINCT b.appointment_id)                              AS total_appointments,
        COALESCE(SUM(b.grand_total), 0)                               AS total_billed,
        COALESCE(SUM(b.amount_paid), 0)                               AS total_collected,
        COALESCE(SUM(b.balance_due), 0)                               AS total_outstanding,
        COALESCE(SUM(CASE WHEN b.bill_status='PAID' THEN 1 ELSE 0 END), 0) AS fully_paid_count,
        COALESCE(SUM(CASE WHEN b.bill_status='PARTIALLY_PAID' THEN 1 ELSE 0 END), 0) AS partial_paid_count
    FROM bills b
    WHERE b.issued_date = p_date;

    -- Detail by payment method
    SELECT
        pay.payment_method,
        COUNT(*)              AS transaction_count,
        SUM(pay.amount)       AS total_amount
    FROM payments pay
    WHERE DATE(pay.payment_date) = p_date
      AND pay.payment_status = 'COMPLETED'
    GROUP BY pay.payment_method
    ORDER BY total_amount DESC;

    -- Top treatments billed today
    SELECT
        t.treatment_name,
        COUNT(*)                              AS appointment_count,
        SUM(b.treatment_cost)                 AS treatment_revenue
    FROM bills b
    JOIN appointments a  ON b.appointment_id = a.appointment_id
    JOIN treatments   t  ON a.treatment_id   = t.treatment_id
    WHERE b.issued_date = p_date
    GROUP BY t.treatment_id, t.treatment_name
    ORDER BY treatment_revenue DESC
    LIMIT 10;
END$$

-- =============================================================
-- PROCEDURE: sp_generate_monthly_revenue
-- Revenue summary for a given year and month
-- =============================================================
DROP PROCEDURE IF EXISTS sp_generate_monthly_revenue $$
CREATE PROCEDURE sp_generate_monthly_revenue(
    IN p_year  INT,
    IN p_month INT
)
BEGIN
    -- Monthly totals
    SELECT
        p_year                                                           AS report_year,
        p_month                                                          AS report_month,
        COUNT(DISTINCT b.bill_id)                                        AS total_bills,
        COUNT(DISTINCT b.appointment_id)                                 AS total_appointments,
        COALESCE(SUM(b.grand_total), 0)                                  AS total_billed,
        COALESCE(SUM(b.amount_paid), 0)                                  AS total_collected,
        COALESCE(SUM(b.balance_due), 0)                                  AS total_outstanding
    FROM bills b
    WHERE YEAR(b.issued_date) = p_year
      AND MONTH(b.issued_date) = p_month
      AND b.bill_status <> 'CANCELLED';

    -- Daily breakdown within the month
    SELECT
        b.issued_date                      AS report_date,
        COUNT(DISTINCT b.bill_id)          AS bills_count,
        COALESCE(SUM(b.grand_total), 0)    AS billed,
        COALESCE(SUM(b.amount_paid), 0)    AS collected
    FROM bills b
    WHERE YEAR(b.issued_date) = p_year
      AND MONTH(b.issued_date) = p_month
      AND b.bill_status <> 'CANCELLED'
    GROUP BY b.issued_date
    ORDER BY b.issued_date ASC;

    -- Revenue by dentist
    SELECT
        CONCAT(d.first_name, ' ', d.last_name)  AS dentist_name,
        d.specialization,
        COUNT(DISTINCT b.bill_id)                AS appointments_billed,
        COALESCE(SUM(b.grand_total), 0)          AS revenue_generated
    FROM bills b
    JOIN appointments a ON b.appointment_id = a.appointment_id
    JOIN dentists     d ON a.dentist_id     = d.dentist_id
    WHERE YEAR(b.issued_date) = p_year
      AND MONTH(b.issued_date) = p_month
      AND b.bill_status <> 'CANCELLED'
    GROUP BY d.dentist_id, d.first_name, d.last_name, d.specialization
    ORDER BY revenue_generated DESC;

    -- Revenue by treatment category
    SELECT
        t.category,
        COUNT(*)                               AS count,
        COALESCE(SUM(b.treatment_cost), 0)     AS category_revenue
    FROM bills b
    JOIN appointments a ON b.appointment_id = a.appointment_id
    JOIN treatments   t ON a.treatment_id   = t.treatment_id
    WHERE YEAR(b.issued_date) = p_year
      AND MONTH(b.issued_date) = p_month
      AND b.bill_status <> 'CANCELLED'
    GROUP BY t.category
    ORDER BY category_revenue DESC;
END$$

-- =============================================================
-- PROCEDURE: sp_get_outstanding_payments
-- Lists bills with balance due greater than zero
-- =============================================================
DROP PROCEDURE IF EXISTS sp_get_outstanding_payments $$
CREATE PROCEDURE sp_get_outstanding_payments(
    IN p_limit  INT
)
BEGIN
    SELECT
        b.bill_number,
        b.issued_date,
        b.due_date,
        CONCAT(p.first_name,' ',p.last_name)    AS patient_name,
        p.contact_number,
        b.grand_total,
        b.amount_paid,
        b.balance_due,
        b.bill_status,
        DATEDIFF(CURRENT_DATE, b.due_date)       AS days_overdue
    FROM bills b
    JOIN patients p ON b.patient_id = p.patient_id
    WHERE b.balance_due > 0
      AND b.bill_status NOT IN ('CANCELLED','REFUNDED')
    ORDER BY days_overdue DESC, b.balance_due DESC
    LIMIT p_limit;
END$$

-- =============================================================
-- PROCEDURE: sp_get_dentist_performance
-- Appointment and revenue statistics per dentist for a period
-- =============================================================
DROP PROCEDURE IF EXISTS sp_get_dentist_performance $$
CREATE PROCEDURE sp_get_dentist_performance(
    IN p_date_from DATE,
    IN p_date_to   DATE
)
BEGIN
    SELECT
        d.dentist_id,
        CONCAT(d.first_name,' ',d.last_name)   AS dentist_name,
        d.specialization,
        COUNT(a.appointment_id)                AS total_appointments,
        SUM(CASE WHEN a.status='COMPLETED'  THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN a.status='CANCELLED'  THEN 1 ELSE 0 END) AS cancelled,
        SUM(CASE WHEN a.status='NO_SHOW'    THEN 1 ELSE 0 END) AS no_shows,
        COALESCE(SUM(b.grand_total), 0)        AS total_revenue,
        ROUND(
            SUM(CASE WHEN a.status='COMPLETED' THEN 1 ELSE 0 END) * 100.0 /
            NULLIF(COUNT(a.appointment_id),0), 2
        )                                      AS completion_rate_pct
    FROM dentists d
    LEFT JOIN appointments a
          ON a.dentist_id = d.dentist_id
         AND a.appointment_date BETWEEN p_date_from AND p_date_to
    LEFT JOIN bills b ON b.appointment_id = a.appointment_id
    WHERE d.status = 'ACTIVE'
    GROUP BY d.dentist_id, d.first_name, d.last_name, d.specialization
    ORDER BY total_revenue DESC;
END$$

-- =============================================================
-- PROCEDURE: sp_next_sequence
-- Generates next sequential number for auto-numbering
-- (Used as alternative to querying MAX+1 which has race condition)
-- =============================================================
DROP PROCEDURE IF EXISTS sp_next_sequence $$
CREATE PROCEDURE sp_next_sequence(
    IN  p_entity   VARCHAR(20),
    IN  p_year     INT,
    OUT p_next_num VARCHAR(25)
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_prefix VARCHAR(4);

    SET v_prefix = CASE p_entity
        WHEN 'PATIENT'     THEN 'PAT'
        WHEN 'DENTIST'     THEN 'DEN'
        WHEN 'APPOINTMENT' THEN 'APT'
        WHEN 'BILL'        THEN 'BIL'
        WHEN 'PAYMENT'     THEN 'PAY'
        ELSE 'GEN'
    END;

    -- Count existing records for the entity/year (uses table directly)
    IF p_entity = 'PATIENT' THEN
        SELECT COUNT(*) INTO v_count FROM patients
        WHERE YEAR(created_at) = p_year;
    ELSEIF p_entity = 'APPOINTMENT' THEN
        SELECT COUNT(*) INTO v_count FROM appointments
        WHERE YEAR(created_at) = p_year;
    ELSEIF p_entity = 'BILL' THEN
        SELECT COUNT(*) INTO v_count FROM bills
        WHERE YEAR(created_at) = p_year;
    ELSEIF p_entity = 'PAYMENT' THEN
        SELECT COUNT(*) INTO v_count FROM payments
        WHERE YEAR(created_at) = p_year;
    ELSEIF p_entity = 'DENTIST' THEN
        SELECT COUNT(*) INTO v_count FROM dentists
        WHERE YEAR(created_at) = p_year;
    ELSE
        SET v_count = 0;
    END IF;

    SET p_next_num = CONCAT(v_prefix, '-', p_year, '-', LPAD(v_count + 1, 6, '0'));
END$$

DELIMITER ;

SELECT 'Stored procedures created successfully.' AS status;
