-- ============================================================
-- CPU4_103 NHS Database Project
-- Part C (Individual): Data Manipulation and Validation Queries
-- Author: Marek Karasz
-- ============================================================

USE nhs_db;

-- ------------------------------------------------------------
-- Query 1: Aggregate function
-- Count how many appointments each doctor has, and the earliest
-- and latest appointment date on their books.
-- ------------------------------------------------------------
SELECT
    d.DoctorID,
    d.DoctorName,
    d.Speciality,
    COUNT(a.AppointmentID) AS TotalAppointments,
    MIN(a.AppointmentDate) AS FirstAppointment,
    MAX(a.AppointmentDate) AS LastAppointment
FROM doctor d
JOIN appointment a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.DoctorName, d.Speciality
ORDER BY TotalAppointments DESC;

-- ------------------------------------------------------------
-- Query 2: LEFT JOIN
-- List every patient with their appointments, including patients
-- who have never had an appointment booked (NULL appointment columns).
-- ------------------------------------------------------------
SELECT
    p.PatientID,
    p.PatientName,
    a.AppointmentID,
    a.AppointmentDate,
    a.Status
FROM patient p
LEFT JOIN appointment a ON p.PatientID = a.PatientID
ORDER BY p.PatientID;

-- ------------------------------------------------------------
-- Query 3: RIGHT JOIN
-- List every appointment together with its doctor, including any
-- doctor record that (hypothetically) has no appointments assigned.
-- ------------------------------------------------------------
SELECT
    a.AppointmentID,
    a.AppointmentDate,
    d.DoctorID,
    d.DoctorName,
    d.Speciality
FROM appointment a
RIGHT JOIN doctor d ON a.DoctorID = d.DoctorID
ORDER BY d.DoctorID;

-- ------------------------------------------------------------
-- Query 4: FULL JOIN (emulated - MySQL has no native FULL JOIN)
-- Combine LEFT and RIGHT joins via UNION to show every patient AND
-- every medication, matched where a prescription links them, and
-- unmatched rows on either side (NULLs) otherwise.
-- ------------------------------------------------------------
SELECT
    p.PatientID,
    p.PatientName,
    m.MedicationID,
    m.MedicationName
FROM patient p
LEFT JOIN prescription pr ON p.PatientID = pr.PatientID
LEFT JOIN medication m ON pr.MedicationID = m.MedicationID

UNION

SELECT
    p.PatientID,
    p.PatientName,
    m.MedicationID,
    m.MedicationName
FROM patient p
RIGHT JOIN prescription pr ON p.PatientID = pr.PatientID
RIGHT JOIN medication m ON pr.MedicationID = m.MedicationID
ORDER BY PatientID;

-- ------------------------------------------------------------
-- Query 5: Stored Procedure
-- Returns a patient's full appointment history (doctor, clinic,
-- date/time) given a PatientID parameter.
-- ------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE GetPatientAppointments (IN in_PatientID VARCHAR(4))
BEGIN
    SELECT
        p.PatientID,
        p.PatientName,
        a.AppointmentID,
        a.AppointmentDate,
        a.AppointmentTime,
        d.DoctorName,
        d.Speciality,
        c.ClinicName,
        a.Status
    FROM patient p
    JOIN appointment a ON p.PatientID = a.PatientID
    JOIN doctor d ON a.DoctorID = d.DoctorID
    JOIN clinic c ON a.ClinicID = c.ClinicID
    WHERE p.PatientID = in_PatientID
    ORDER BY a.AppointmentDate;
END //

DELIMITER ;

-- Example call:
CALL GetPatientAppointments('P001');

-- ------------------------------------------------------------
-- Query 6: Trigger
-- Automatically logs every new appointment into an audit table,
-- supporting traceability / data integrity monitoring.
-- ------------------------------------------------------------
CREATE TABLE appointment_audit (
    AuditID        INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID  VARCHAR(4),
    PatientID      VARCHAR(4),
    DoctorID       VARCHAR(4),
    ActionType     VARCHAR(20),
    ActionTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER trg_after_appointment_insert
AFTER INSERT ON appointment
FOR EACH ROW
BEGIN
    INSERT INTO appointment_audit (AppointmentID, PatientID, DoctorID, ActionType)
    VALUES (NEW.AppointmentID, NEW.PatientID, NEW.DoctorID, 'INSERT');
END //

DELIMITER ;

-- Test the trigger:
INSERT INTO appointment (AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes, Status)
VALUES ('A016', 'P004', 'D004', 'C004', '2024-06-05', '10:15:00', 'Trigger test booking', 'Scheduled');

SELECT * FROM appointment_audit;

-- ------------------------------------------------------------
-- Query 7 (additional): Aggregate + HAVING
-- Clinics that have handled more than 2 appointments.
-- ------------------------------------------------------------
SELECT
    c.ClinicID,
    c.ClinicName,
    COUNT(a.AppointmentID) AS AppointmentsHandled
FROM clinic c
JOIN appointment a ON c.ClinicID = a.ClinicID
GROUP BY c.ClinicID, c.ClinicName
HAVING COUNT(a.AppointmentID) > 2
ORDER BY AppointmentsHandled DESC;

-- ============================================================
-- End of Part C script
-- ============================================================
