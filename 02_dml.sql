-- ============================================================
-- CPU4_103 NHS Database Project - Part B: Physical Implementation
-- Task B1 - DML: Sample Data Population (10+ records per main table)
-- ============================================================

USE nhs_db;

-- ------------------------------------------------------------
-- PATIENT (12 records)
-- ------------------------------------------------------------
INSERT INTO patient (PatientID, PatientName, Address) VALUES
('P001', 'John Smith',      '123 Hill Rd, Leeds'),
('P002', 'Mary Jones',      '456 Lake Ave, Leeds'),
('P003', 'Ahmed Khan',      '12 Oak Street, Bradford'),
('P004', 'Sarah Williams',  '78 Elm Close, Bradford'),
('P005', 'David Brown',     '5 Church Lane, Manchester'),
('P006', 'Emily Davies',    '19 Kings Road, Manchester'),
('P007', 'Priya Patel',     '34 Station Rd, Sheffield'),
('P008', 'James Wilson',    '2 Mill Lane, Sheffield'),
('P009', 'Olivia Taylor',   '88 Victoria St, York'),
('P010', 'Liam Johnson',    '15 Park Avenue, York'),
('P011', 'Grace Thompson',  '41 Queen Street, Leeds'),
('P012', 'Noah Anderson',   '9 Bridge Road, Bradford');

-- ------------------------------------------------------------
-- DOCTOR (10 records)
-- ------------------------------------------------------------
INSERT INTO doctor (DoctorID, DoctorName, Speciality) VALUES
('D001', 'Dr. Adams',    'Cardiology'),
('D002', 'Dr. Brown',    'General Practice'),
('D003', 'Dr. Clarke',   'Paediatrics'),
('D004', 'Dr. Evans',    'Dermatology'),
('D005', 'Dr. Foster',   'General Practice'),
('D006', 'Dr. Green',    'Orthopaedics'),
('D007', 'Dr. Harris',   'Neurology'),
('D008', 'Dr. Ibrahim',  'General Practice'),
('D009', 'Dr. Jackson',  'Endocrinology'),
('D010', 'Dr. Khan',     'Cardiology');

-- ------------------------------------------------------------
-- CLINIC (6 records)
-- ------------------------------------------------------------
INSERT INTO clinic (ClinicID, ClinicName, ClinicAddress) VALUES
('C001', 'Clinic A', '10 Main St, Leeds'),
('C002', 'Clinic B', '22 River Rd, Bradford'),
('C003', 'Clinic C', '5 High St, Manchester'),
('C004', 'Clinic D', '30 Park Lane, Sheffield'),
('C005', 'Clinic E', '18 Market St, York'),
('C006', 'Clinic F', '7 Union Rd, Leeds');

-- ------------------------------------------------------------
-- MEDICATION (10 records)
-- ------------------------------------------------------------
INSERT INTO medication (MedicationID, MedicationName) VALUES
('M001', 'Aspirin'),
('M002', 'Beta Blocker'),
('M003', 'Paracetamol'),
('M004', 'Ibuprofen'),
('M005', 'Amoxicillin'),
('M006', 'Metformin'),
('M007', 'Insulin'),
('M008', 'Salbutamol Inhaler'),
('M009', 'Omeprazole'),
('M010', 'Atorvastatin');

-- ------------------------------------------------------------
-- APPOINTMENT (15 records)
-- ------------------------------------------------------------
INSERT INTO appointment (AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes, Status) VALUES
('A001', 'P001', 'D001', 'C001', '2024-05-01', '10:00:00', 'Follow-up in 2 weeks',   'Completed'),
('A002', 'P002', 'D002', 'C002', '2024-05-03', '09:00:00', 'First visit',            'Completed'),
('A003', 'P001', 'D001', 'C001', '2024-05-10', '11:30:00', 'Blood pressure check',   'Completed'),
('A004', 'P003', 'D003', 'C003', '2024-05-12', '13:00:00', 'Child immunisation',     'Completed'),
('A005', 'P004', 'D004', 'C004', '2024-05-14', '14:15:00', 'Skin rash review',       'Completed'),
('A006', 'P005', 'D002', 'C002', '2024-05-15', '09:30:00', 'General check-up',      'Completed'),
('A007', 'P006', 'D006', 'C003', '2024-05-16', '10:45:00', 'Knee pain assessment',   'Completed'),
('A008', 'P007', 'D009', 'C005', '2024-05-18', '15:00:00', 'Diabetes review',        'Completed'),
('A009', 'P008', 'D007', 'C004', '2024-05-19', '11:00:00', 'Migraine consultation',  'Completed'),
('A010', 'P009', 'D005', 'C005', '2024-05-20', '09:15:00', 'Routine physical',       'Scheduled'),
('A011', 'P010', 'D008', 'C006', '2024-05-21', '13:30:00', 'Flu symptoms',           'Scheduled'),
('A012', 'P002', 'D002', 'C002', '2024-05-22', '10:00:00', 'Prescription renewal',   'Scheduled'),
('A013', 'P011', 'D010', 'C001', '2024-05-23', '14:00:00', 'Cardiac review',         'Scheduled'),
('A014', 'P012', 'D003', 'C003', '2024-05-24', '09:45:00', 'Vaccination',            'Scheduled'),
('A015', 'P003', 'D003', 'C003', '2024-05-30', '10:30:00', 'Follow-up appointment',  'Scheduled');

-- ------------------------------------------------------------
-- PRESCRIPTION (junction table, 15 records - resolves 1NF repeating group)
-- ------------------------------------------------------------
INSERT INTO prescription (PatientID, MedicationID) VALUES
('P001', 'M001'),
('P001', 'M002'),
('P002', 'M003'),
('P003', 'M003'),
('P004', 'M004'),
('P005', 'M009'),
('P006', 'M004'),
('P007', 'M006'),
('P007', 'M007'),
('P008', 'M004'),
('P009', 'M010'),
('P010', 'M003'),
('P010', 'M005'),
('P011', 'M001'),
('P011', 'M010');

-- ============================================================
-- UPDATE demonstration
-- Mark a completed appointment's notes as reviewed
-- ============================================================
UPDATE appointment
SET Notes = 'Follow-up in 2 weeks - reviewed by consultant'
WHERE AppointmentID = 'A001';

-- ============================================================
-- DELETE demonstration
-- Insert then remove a duplicate test appointment to show safe DELETE
-- (uses WHERE to target a single row, avoiding accidental mass deletion)
-- ============================================================
INSERT INTO appointment (AppointmentID, PatientID, DoctorID, ClinicID, AppointmentDate, AppointmentTime, Notes, Status)
VALUES ('A999', 'P001', 'D001', 'C001', '2024-06-01', '09:00:00', 'Duplicate test booking', 'Cancelled');

DELETE FROM appointment
WHERE AppointmentID = 'A999';

-- ============================================================
-- End of DML script
-- ============================================================
