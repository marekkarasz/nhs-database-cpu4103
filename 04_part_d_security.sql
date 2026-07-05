-- ============================================================
-- CPU4_103 NHS Database Project
-- Part D (Individual): Security, Data Protection, Transaction Management
-- Author: Marek Karasz
-- ============================================================

USE nhs_db;

-- ============================================================
-- TASK D1: Roles and Privileges for 4 user types
-- ============================================================

-- 1. Administrator - full control over the database
CREATE ROLE 'db_admin';
GRANT ALL PRIVILEGES ON nhs_db.* TO 'db_admin';

-- 2. Doctor - can view patient/clinic data, manage own appointments
--    and prescriptions, but cannot alter core reference data
CREATE ROLE 'doctor_role';
GRANT SELECT ON nhs_db.patient TO 'doctor_role';
GRANT SELECT ON nhs_db.clinic TO 'doctor_role';
GRANT SELECT, UPDATE ON nhs_db.appointment TO 'doctor_role';
GRANT SELECT, INSERT, UPDATE ON nhs_db.prescription TO 'doctor_role';
GRANT SELECT ON nhs_db.medication TO 'doctor_role';

-- 3. Receptionist - manages bookings and patient contact records,
--    but has no access to clinical prescription data
CREATE ROLE 'receptionist_role';
GRANT SELECT, INSERT, UPDATE ON nhs_db.patient TO 'receptionist_role';
GRANT SELECT, INSERT, UPDATE, DELETE ON nhs_db.appointment TO 'receptionist_role';
GRANT SELECT ON nhs_db.doctor TO 'receptionist_role';
GRANT SELECT ON nhs_db.clinic TO 'receptionist_role';

-- 4. Patient - read-only access to their own appointment/prescription
--    history via a restricted view (see below); no direct table access
CREATE ROLE 'patient_role';

CREATE OR REPLACE VIEW patient_own_records AS
SELECT
    p.PatientID,
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    d.DoctorName,
    c.ClinicName,
    m.MedicationName
FROM patient p
JOIN appointment a ON p.PatientID = a.PatientID
JOIN doctor d ON a.DoctorID = d.DoctorID
JOIN clinic c ON a.ClinicID = c.ClinicID
LEFT JOIN prescription pr ON p.PatientID = pr.PatientID
LEFT JOIN medication m ON pr.MedicationID = m.MedicationID;

GRANT SELECT ON nhs_db.patient_own_records TO 'patient_role';

-- Example: creating individual login accounts and assigning roles
-- (usernames/hosts are illustrative)
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'ChangeMe_Admin123!';
GRANT 'db_admin' TO 'admin_user'@'localhost';

CREATE USER 'dr_adams'@'localhost' IDENTIFIED BY 'ChangeMe_Doctor123!';
GRANT 'doctor_role' TO 'dr_adams'@'localhost';

CREATE USER 'reception1'@'localhost' IDENTIFIED BY 'ChangeMe_Reception123!';
GRANT 'receptionist_role' TO 'reception1'@'localhost';

CREATE USER 'patient_p001'@'localhost' IDENTIFIED BY 'ChangeMe_Patient123!';
GRANT 'patient_role' TO 'patient_p001'@'localhost';

-- Activate default roles automatically on login
SET DEFAULT ROLE 'db_admin' TO 'admin_user'@'localhost';
SET DEFAULT ROLE 'doctor_role' TO 'dr_adams'@'localhost';
SET DEFAULT ROLE 'receptionist_role' TO 'reception1'@'localhost';
SET DEFAULT ROLE 'patient_role' TO 'patient_p001'@'localhost';

FLUSH PRIVILEGES;

-- ============================================================
-- TASK D2: Data Protection - Password Hashing
-- Sensitive login credentials are never stored in plain text.
-- SHA-256 (via SHA2) is used to hash passwords before storage.
-- ============================================================

CREATE TABLE useraccount (
    UserID       INT AUTO_INCREMENT PRIMARY KEY,
    Username     VARCHAR(50)  NOT NULL UNIQUE,
    PasswordHash CHAR(64)     NOT NULL,   -- SHA2-256 output length
    RoleName     VARCHAR(20)  NOT NULL,
    LinkedID     VARCHAR(4)               -- e.g. PatientID or DoctorID
);

-- Insert accounts with hashed passwords (never store plain text)
INSERT INTO useraccount (Username, PasswordHash, RoleName, LinkedID)
VALUES
('admin_user',    SHA2('ChangeMe_Admin123!', 256),     'Administrator', NULL),
('dr_adams',      SHA2('ChangeMe_Doctor123!', 256),    'Doctor',        'D001'),
('reception1',    SHA2('ChangeMe_Reception123!', 256), 'Receptionist',  NULL),
('patient_p001',  SHA2('ChangeMe_Patient123!', 256),   'Patient',       'P001');

-- Example login check: compare hash of supplied password, never the
-- plain text, against the stored hash
SELECT UserID, Username, RoleName
FROM useraccount
WHERE Username = 'patient_p001'
  AND PasswordHash = SHA2('ChangeMe_Patient123!', 256);

-- ============================================================
-- TASK D2 (Extra credit): SQL Injection Awareness
-- ============================================================

-- VULNERABLE example (do not use): building a query by concatenating
-- raw user input directly into the SQL string, e.g. in application code:
--   query = "SELECT * FROM useraccount WHERE Username = '" + userInput + "'";
-- If userInput = "' OR '1'='1" the resulting query becomes:
--   SELECT * FROM useraccount WHERE Username = '' OR '1'='1'
-- which returns every row and bypasses authentication entirely.

-- SAFE example: parameterised/prepared statement, so user input is
-- always treated as data and never as executable SQL syntax.
PREPARE safe_login FROM
    'SELECT UserID, Username, RoleName FROM useraccount
     WHERE Username = ? AND PasswordHash = SHA2(?, 256)';

SET @uname := 'patient_p001';
SET @pword := 'ChangeMe_Patient123!';

EXECUTE safe_login USING @uname, @pword;

DEALLOCATE PREPARE safe_login;

-- ============================================================
-- TASK D2 (bonus): Basic transaction management example
-- Demonstrates atomicity when booking an appointment and linking a
-- prescription together - either both succeed or neither is applied.
-- ============================================================
START TRANSACTION;

INSERT INTO appointment (AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes, Status)
VALUES ('A017', 'P006', 'D006', 'C003', '2024-06-10', '11:00:00', 'Post-op review', 'Scheduled');

INSERT INTO prescription (PatientID, MedicationID)
VALUES ('P006', 'M008');

COMMIT;
-- If either INSERT had failed, ROLLBACK would undo both changes,
-- keeping the database in a consistent state.

-- ============================================================
-- End of Part D script
-- ============================================================
