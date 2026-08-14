-- =============================================================
-- SUNRISE DENTAL CLINIC MANAGEMENT SYSTEM
-- Seed Data — Initial records for development & testing
-- =============================================================
-- Run AFTER schema.sql
-- =============================================================

USE sunrise_dental_db;

-- =============================================================
-- 1. ROLES
-- =============================================================
INSERT INTO roles (role_name, description) VALUES
    ('ADMIN',        'Full system access — manage users, settings, all modules'),
    ('RECEPTIONIST', 'Patient registration, appointment scheduling, billing, payments'),
    ('DENTIST',      'View own schedule, update appointment status, view patient records');

-- =============================================================
-- 2. USERS
-- Passwords (BCrypt, cost=12):
--   admin123     → $2a$12$...  (generated below as literal hash)
--   recept123    → $2a$12$...
--   dentist123   → $2a$12$...
--
-- For seed data we store pre-computed BCrypt hashes.
-- Plain-text mapping for testing ONLY:
--   admin      / admin123
--   reception1 / recept123
--   dr.silva   / dentist123
--   dr.perera  / dentist123
--   dr.fernando/ dentist123
-- =============================================================
INSERT INTO users (username, password_hash, full_name, email, phone, role_id) VALUES
-- ADMIN
('admin',
 '$2a$12$5ikfnlacWwRKRO/kNH5AmeFYEndlceNs7qKkr.RVWlvIIU0brj1x.',
 'System Administrator',
 'admin@sunrisedental.lk',
 '0112345678',
 (SELECT role_id FROM roles WHERE role_name = 'ADMIN')),

-- RECEPTIONISTS
('reception1',
 '$2a$12$9pbxJkSe2/vtkbdpkCE9a.wsUw34l8aAdZ8wss/p/TNzWs..RXUd6',
 'Nimali Perera',
 'nimali@sunrisedental.lk',
 '0771234567',
 (SELECT role_id FROM roles WHERE role_name = 'RECEPTIONIST')),

('reception2',
 '$2a$12$9pbxJkSe2/vtkbdpkCE9a.wsUw34l8aAdZ8wss/p/TNzWs..RXUd6',
 'Kasun Fernando',
 'kasun@sunrisedental.lk',
 '0772345678',
 (SELECT role_id FROM roles WHERE role_name = 'RECEPTIONIST')),

-- DENTISTS
('dr.silva',
 '$2a$12$q2iW1eYt6UeRz5EtLI82fO8l3QgQ/hXOdskyJvUcx1HNmhXgEYTbe',
 'Dr. Chamara Silva',
 'silva@sunrisedental.lk',
 '0773456789',
 (SELECT role_id FROM roles WHERE role_name = 'DENTIST')),

('dr.perera',
 '$2a$12$q2iW1eYt6UeRz5EtLI82fO8l3QgQ/hXOdskyJvUcx1HNmhXgEYTbe',
 'Dr. Sanduni Perera',
 'sperera@sunrisedental.lk',
 '0774567890',
 (SELECT role_id FROM roles WHERE role_name = 'DENTIST')),

('dr.fernando',
 '$2a$12$q2iW1eYt6UeRz5EtLI82fO8l3QgQ/hXOdskyJvUcx1HNmhXgEYTbe',
 'Dr. Rohan Fernando',
 'rfernando@sunrisedental.lk',
 '0775678901',
 (SELECT role_id FROM roles WHERE role_name = 'DENTIST'));

-- NOTE: The application's PasswordUtil.java will generate proper BCrypt hashes.
-- The above hashes are placeholders. The InitializationServlet (or a DB-init
-- script) should hash and update on first run.
-- For testing, use the built-in /setup page to reset admin password.

-- =============================================================
-- 3. DENTISTS
-- =============================================================
INSERT INTO dentists (
    dentist_number, first_name, last_name, specialization, qualification,
    license_number, contact_number, email,
    available_monday, available_tuesday, available_wednesday,
    available_thursday, available_friday, available_saturday, available_sunday,
    work_start_time, work_end_time, status, user_id
) VALUES
(
    'DEN-2026-000001', 'Chamara', 'Silva',
    'General Dentistry', 'BDS (Colombo), MDS',
    'SLDC-2018-001', '0773456789', 'silva@sunrisedental.lk',
    1, 1, 1, 1, 1, 1, 0,
    '08:30:00', '17:00:00', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'dr.silva')
),
(
    'DEN-2026-000002', 'Sanduni', 'Perera',
    'Orthodontics', 'BDS (Peradeniya), Dip.Ortho',
    'SLDC-2019-045', '0774567890', 'sperera@sunrisedental.lk',
    1, 1, 0, 1, 1, 1, 0,
    '09:00:00', '17:30:00', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'dr.perera')
),
(
    'DEN-2026-000003', 'Rohan', 'Fernando',
    'Oral Surgery', 'BDS (Kelaniya), FDSRCS',
    'SLDC-2015-112', '0775678901', 'rfernando@sunrisedental.lk',
    0, 1, 1, 1, 1, 0, 0,
    '09:00:00', '16:00:00', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'dr.fernando')
),
(
    'DEN-2026-000004', 'Amali', 'Jayawardena',
    'Periodontics', 'BDS (Colombo), MSc Perio',
    'SLDC-2020-078', '0776789012', 'amali@sunrisedental.lk',
    1, 0, 1, 0, 1, 1, 0,
    '10:00:00', '18:00:00', 'ACTIVE',
    NULL
);

-- =============================================================
-- 4. TREATMENTS — Treatment catalog
-- =============================================================
INSERT INTO treatments (
    treatment_code, treatment_name, category, description,
    base_cost, duration_mins, requires_followup, status
) VALUES
('TRT-001', 'Dental Consultation',    'Consultation',
 'Initial or follow-up consultation with dentist',          1500.00,  30, 0, 'ACTIVE'),
('TRT-002', 'Dental Cleaning',        'Preventive',
 'Professional scaling and polishing of teeth',             4500.00,  45, 0, 'ACTIVE'),
('TRT-003', 'Tooth Extraction',       'Surgical',
 'Simple extraction of a single tooth',                     3500.00,  45, 1, 'ACTIVE'),
('TRT-004', 'Surgical Extraction',    'Surgical',
 'Surgical removal of impacted or complex teeth',           8500.00,  90, 1, 'ACTIVE'),
('TRT-005', 'Dental Filling (Composite)', 'Restorative',
 'Tooth-colored composite resin filling',                   5000.00,  60, 0, 'ACTIVE'),
('TRT-006', 'Dental Filling (Amalgam)',   'Restorative',
 'Silver amalgam filling for posterior teeth',              3000.00,  45, 0, 'ACTIVE'),
('TRT-007', 'Root Canal Treatment',   'Endodontic',
 'Complete root canal therapy including obturation',       18000.00, 120, 1, 'ACTIVE'),
('TRT-008', 'Dental X-Ray (Periapical)', 'Diagnostic',
 'Single periapical radiograph',                            1200.00,  15, 0, 'ACTIVE'),
('TRT-009', 'Dental X-Ray (Panoramic)', 'Diagnostic',
 'Full mouth panoramic radiograph (OPG)',                   3500.00,  20, 0, 'ACTIVE'),
('TRT-010', 'Teeth Whitening',        'Cosmetic',
 'Professional in-office teeth whitening treatment',       15000.00,  90, 0, 'ACTIVE'),
('TRT-011', 'Dental Crown (Porcelain)','Prosthetic',
 'Porcelain fused to metal or all-ceramic crown',          25000.00,  60, 1, 'ACTIVE'),
('TRT-012', 'Dental Crown (Metal)',   'Prosthetic',
 'Full metal crown for posterior teeth',                   18000.00,  60, 1, 'ACTIVE'),
('TRT-013', 'Complete Denture',       'Prosthetic',
 'Full set of removable dentures (upper or lower)',        45000.00, 120, 1, 'ACTIVE'),
('TRT-014', 'Partial Denture',        'Prosthetic',
 'Removable partial denture',                              28000.00,  90, 1, 'ACTIVE'),
('TRT-015', 'Dental Bridge',          'Prosthetic',
 'Fixed dental bridge (per unit)',                         22000.00,  90, 1, 'ACTIVE'),
('TRT-016', 'Braces Consultation',    'Orthodontic',
 'Initial orthodontic assessment and treatment planning',   2500.00,  60, 1, 'ACTIVE'),
('TRT-017', 'Orthodontic Treatment',  'Orthodontic',
 'Fixed metal or ceramic braces (monthly fee)',            12000.00,  45, 1, 'ACTIVE'),
('TRT-018', 'Fluoride Treatment',     'Preventive',
 'Professional fluoride application for cavity prevention', 2000.00,  20, 0, 'ACTIVE'),
('TRT-019', 'Pit & Fissure Sealant', 'Preventive',
 'Sealant application to protect molars',                   2500.00,  30, 0, 'ACTIVE'),
('TRT-020', 'Emergency Treatment',    'Emergency',
 'Emergency dental care — pain relief, temporary filling', 6000.00,  45, 1, 'ACTIVE');

-- =============================================================
-- 5. PATIENTS — Sample patients for testing
-- =============================================================
INSERT INTO patients (
    patient_number, first_name, last_name, date_of_birth, gender,
    address, city, contact_number, alt_contact, email,
    emergency_contact_name, emergency_contact_phone, emergency_contact_relation,
    blood_group, allergies, registration_date, status,
    created_by
) VALUES
(
    'PAT-2026-000001', 'Kamal', 'Wickramasinghe',
    '1985-03-15', 'MALE',
    '45/A, Galle Road, Colombo 03', 'Colombo',
    '0771112223', '0112345678', 'kamal.w@gmail.com',
    'Dilani Wickramasinghe', '0779988776', 'Spouse',
    'B+', 'Penicillin', '2026-01-10', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'reception1')
),
(
    'PAT-2026-000002', 'Priya', 'Jayasuriya',
    '1992-07-22', 'FEMALE',
    '12, Temple Road, Kandy', 'Kandy',
    '0762223334', NULL, 'priya.j@yahoo.com',
    'Suresh Jayasuriya', '0768887776', 'Husband',
    'O+', NULL, '2026-01-15', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'reception1')
),
(
    'PAT-2026-000003', 'Ranjit', 'Bandara',
    '1975-11-08', 'MALE',
    '78, Kurunegala Road, Negombo', 'Negombo',
    '0313334445', '0723334445', NULL,
    'Kamani Bandara', '0714445556', 'Wife',
    'A-', 'Latex', '2026-02-03', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'reception2')
),
(
    'PAT-2026-000004', 'Sunethra', 'Gunawardena',
    '1998-04-30', 'FEMALE',
    '23/5, High Level Road, Maharagama', 'Maharagama',
    '0775556667', NULL, 'sunethra.g@hotmail.com',
    'Dilshan Gunawardena', '0776667778', 'Brother',
    'AB+', NULL, '2026-02-18', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'reception1')
),
(
    'PAT-2026-000005', 'Lasith', 'Malinga',
    '2005-09-12', 'MALE',
    '5, Sea Street, Moratuwa', 'Moratuwa',
    '0784445556', '0114556677', 'lasith.m@gmail.com',
    'Anoma Malinga', '0714556677', 'Mother',
    'O-', NULL, '2026-03-05', 'ACTIVE',
    (SELECT user_id FROM users WHERE username = 'reception2')
);

-- =============================================================
-- 6. APPOINTMENTS — Sample appointments
-- =============================================================
INSERT INTO appointments (
    appointment_number, patient_id, dentist_id, treatment_id,
    appointment_date, appointment_time, end_time,
    status, priority, notes, created_by
) VALUES
(
    'APT-2026-000001',
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000001'),
    (SELECT dentist_id FROM dentists WHERE dentist_number='DEN-2026-000001'),
    (SELECT treatment_id FROM treatments WHERE treatment_code='TRT-001'),
    '2026-08-20', '09:00:00', '09:30:00',
    'COMPLETED', 'NORMAL', 'Regular check-up',
    (SELECT user_id FROM users WHERE username='reception1')
),
(
    'APT-2026-000002',
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000002'),
    (SELECT dentist_id FROM dentists WHERE dentist_number='DEN-2026-000002'),
    (SELECT treatment_id FROM treatments WHERE treatment_code='TRT-002'),
    '2026-08-21', '10:00:00', '10:45:00',
    'COMPLETED', 'NORMAL', 'Full dental cleaning',
    (SELECT user_id FROM users WHERE username='reception1')
),
(
    'APT-2026-000003',
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000003'),
    (SELECT dentist_id FROM dentists WHERE dentist_number='DEN-2026-000001'),
    (SELECT treatment_id FROM treatments WHERE treatment_code='TRT-007'),
    '2026-08-23', '11:00:00', '13:00:00',
    'CONFIRMED', 'URGENT', 'Root canal — upper right molar',
    (SELECT user_id FROM users WHERE username='reception2')
),
(
    'APT-2026-000004',
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000004'),
    (SELECT dentist_id FROM dentists WHERE dentist_number='DEN-2026-000003'),
    (SELECT treatment_id FROM treatments WHERE treatment_code='TRT-003'),
    '2026-08-23', '14:00:00', '14:45:00',
    'SCHEDULED', 'NORMAL', 'Lower left wisdom tooth extraction',
    (SELECT user_id FROM users WHERE username='reception1')
),
(
    'APT-2026-000005',
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000005'),
    (SELECT dentist_id FROM dentists WHERE dentist_number='DEN-2026-000001'),
    (SELECT treatment_id FROM treatments WHERE treatment_code='TRT-010'),
    '2026-08-25', '09:30:00', '11:00:00',
    'SCHEDULED', 'NORMAL', 'Whitening pre-assessment done',
    (SELECT user_id FROM users WHERE username='reception1')
);

-- =============================================================
-- 7. BILLS — for completed appointments
-- =============================================================
INSERT INTO bills (
    bill_number, appointment_id, patient_id,
    consultation_fee, treatment_cost, additional_charges,
    additional_desc, discount_percent, discount_amount,
    tax_percent, tax_amount, sub_total, grand_total,
    amount_paid, balance_due,
    bill_status, issued_date, due_date, created_by
) VALUES
(
    'BIL-2026-000001',
    (SELECT appointment_id FROM appointments WHERE appointment_number='APT-2026-000001'),
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000001'),
    1500.00, 1500.00, 0.00, NULL,
    0.00, 0.00, 0.00, 0.00,
    3000.00, 3000.00, 3000.00, 0.00,
    'PAID', '2026-08-20', '2026-08-20',
    (SELECT user_id FROM users WHERE username='reception1')
),
(
    'BIL-2026-000002',
    (SELECT appointment_id FROM appointments WHERE appointment_number='APT-2026-000002'),
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000002'),
    1500.00, 4500.00, 500.00, 'Polishing kit',
    5.00, 325.00, 0.00, 0.00,
    6500.00, 6175.00, 6175.00, 0.00,
    'PAID', '2026-08-21', '2026-08-21',
    (SELECT user_id FROM users WHERE username='reception1')
);

-- =============================================================
-- 8. BILL ITEMS
-- =============================================================
INSERT INTO bill_items (bill_id, item_type, description, unit_price, quantity, total_price) VALUES
(
    (SELECT bill_id FROM bills WHERE bill_number='BIL-2026-000001'),
    'CONSULTATION', 'Dental Consultation Fee', 1500.00, 1, 1500.00
),
(
    (SELECT bill_id FROM bills WHERE bill_number='BIL-2026-000001'),
    'TREATMENT', 'Dental Consultation (Treatment)', 1500.00, 1, 1500.00
),
(
    (SELECT bill_id FROM bills WHERE bill_number='BIL-2026-000002'),
    'CONSULTATION', 'Dental Consultation Fee', 1500.00, 1, 1500.00
),
(
    (SELECT bill_id FROM bills WHERE bill_number='BIL-2026-000002'),
    'TREATMENT', 'Dental Cleaning — Scaling & Polishing', 4500.00, 1, 4500.00
),
(
    (SELECT bill_id FROM bills WHERE bill_number='BIL-2026-000002'),
    'MATERIAL', 'Polishing Kit', 500.00, 1, 500.00
);

-- =============================================================
-- 9. PAYMENTS
-- =============================================================
INSERT INTO payments (
    payment_number, bill_id, patient_id, amount,
    payment_method, payment_status, transaction_ref,
    payment_date, received_by
) VALUES
(
    'PAY-2026-000001',
    (SELECT bill_id FROM bills WHERE bill_number='BIL-2026-000001'),
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000001'),
    3000.00, 'CASH', 'COMPLETED', NULL,
    '2026-08-20 09:45:00',
    (SELECT user_id FROM users WHERE username='reception1')
),
(
    'PAY-2026-000002',
    (SELECT bill_id FROM bills WHERE bill_number='BIL-2026-000002'),
    (SELECT patient_id FROM patients WHERE patient_number='PAT-2026-000002'),
    6175.00, 'CARD', 'COMPLETED', 'VISA-8847-2026082101',
    '2026-08-21 10:55:00',
    (SELECT user_id FROM users WHERE username='reception1')
);

-- =============================================================
-- 10. SYSTEM SETTINGS
-- =============================================================
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('clinic_name',        'Sunrise Dental Clinic',        'Clinic display name'),
('clinic_address',     'No. 15, Hospital Road, Colombo 07', 'Clinic address'),
('clinic_phone',       '0112223344',                   'Clinic contact number'),
('clinic_email',       'info@sunrisedental.lk',        'Clinic email address'),
('clinic_tagline',     'Your Smile, Our Passion',      'Marketing tagline'),
('currency_symbol',    'LKR',                          'Currency symbol'),
('tax_rate',           '0.00',                         'Default tax rate (%)'),
('consultation_fee',   '1500.00',                      'Standard consultation fee (LKR)'),
('session_timeout',    '30',                           'Session timeout in minutes'),
('appointment_slot',   '30',                           'Default appointment slot (minutes)'),
('working_hours_start','08:30',                        'Clinic opening time'),
('working_hours_end',  '18:00',                        'Clinic closing time'),
('max_appointments_per_slot', '1',                     'Max appointments per time slot per dentist'),
('enable_notifications', 'true',                       'Enable notification system'),
('default_country_code', '+94',                        'Sri Lanka country code for phone');

-- =============================================================
-- End of seed.sql
-- =============================================================
SELECT 'Seed data loaded successfully.' AS status;
