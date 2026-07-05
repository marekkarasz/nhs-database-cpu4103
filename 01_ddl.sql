-- ============================================================
-- CPU4_103 NHS Database Project - Part B: Physical Implementation
-- Task B1 - DDL: Database and Table Creation
-- Engine: MySQL
-- Schema source: teammate's Part A 3NF logical design (Patient, Doctor,
-- Clinic, Appointment, Medication, Prescription) + Team Notes naming rules
-- ============================================================

-- 1. CREATE DATABASE
DROP DATABASE IF EXISTS nhs_db;
CREATE DATABASE nhs_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE nhs_db;

-- ============================================================
-- 2. CREATE TABLES (in FK-safe order: parents before children)
-- ============================================================

CREATE TABLE patient (
    PatientID   VARCHAR(4)   NOT NULL,
    PatientName VARCHAR(50)  NOT NULL,
    Address     VARCHAR(100) NOT NULL,
    PRIMARY KEY (PatientID)
) ENGINE = InnoDB;

CREATE TABLE doctor (
    DoctorID    VARCHAR(4)   NOT NULL,
    DoctorName  VARCHAR(100) NOT NULL,
    Speciality  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (DoctorID)
) ENGINE = InnoDB;

CREATE TABLE clinic (
    ClinicID      VARCHAR(4)   NOT NULL,
    ClinicName    VARCHAR(100) NOT NULL,
    ClinicAddress VARCHAR(100) NOT NULL,
    PRIMARY KEY (ClinicID)
) ENGINE = InnoDB;

CREATE TABLE medication (
    MedicationID   VARCHAR(4)   NOT NULL,
    MedicationName VARCHAR(100) NOT NULL,
    PRIMARY KEY (MedicationID)
) ENGINE = InnoDB;

CREATE TABLE appointment (
    AppointmentID   VARCHAR(4)  NOT NULL,
    PatientID       VARCHAR(4)  NOT NULL,
    DoctorID        VARCHAR(4)  NOT NULL,
    ClinicID        VARCHAR(4)  NOT NULL,
    AppointmentDate DATE        NOT NULL,
    AppointmentTime TIME        NOT NULL,
    Notes           VARCHAR(255),
    PRIMARY KEY (AppointmentID),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (PatientID)
        REFERENCES patient (PatientID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (DoctorID)
        REFERENCES doctor (DoctorID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_clinic FOREIGN KEY (ClinicID)
        REFERENCES clinic (ClinicID)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Junction table resolving the Patient <-> Medication M:M relationship
CREATE TABLE prescription (
    PatientID    VARCHAR(4) NOT NULL,
    MedicationID VARCHAR(4) NOT NULL,
    PRIMARY KEY (PatientID, MedicationID),
    CONSTRAINT fk_prescription_patient FOREIGN KEY (PatientID)
        REFERENCES patient (PatientID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_prescription_medication FOREIGN KEY (MedicationID)
        REFERENCES medication (MedicationID)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- ============================================================
-- 3. ALTER TABLE demonstration
-- Adding a Status column to appointment after initial creation,
-- to show ALTER TABLE ... ADD COLUMN and a follow-up constraint.
-- ============================================================
ALTER TABLE appointment
    ADD COLUMN Status VARCHAR(20) NOT NULL DEFAULT 'Scheduled'
    AFTER Notes;

ALTER TABLE appointment
    ADD CONSTRAINT chk_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled'));

-- ============================================================
-- 4. DROP / TRUNCATE demonstration
-- A disposable scratch table is used so the real NHS data is never at risk.
-- ============================================================
CREATE TABLE scratch_demo (
    DemoID INT PRIMARY KEY,
    Note   VARCHAR(50)
) ENGINE = InnoDB;

INSERT INTO scratch_demo VALUES (1, 'row to be removed');

TRUNCATE TABLE scratch_demo;   -- removes all rows, keeps table structure

DROP TABLE scratch_demo;       -- removes the table entirely

-- ============================================================
-- End of DDL script
-- ============================================================
