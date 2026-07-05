[README.md](https://github.com/user-attachments/files/29671756/README.md)
# CPU4-103 NHS Database Project — Individual SQL Scripts

Individual contribution by Marek Karasz to the CPU4-103 (Introduction to Database) group project: a relational database for a fictional NHS scenario, built for Fly-tech Ltd.

Group logical design (Part A, ER diagram and 3NF normalisation) was led by my teammate and is documented in my individual report. The scripts below are my individual physical implementation, querying, and security work (Parts B, C and D).

## Contents

| File | Part | Description |
|---|---|---|
| `01_ddl.sql` | B1 | Creates the `nhs_db` database and six InnoDB tables (patient, doctor, clinic, medication, appointment, prescription) with primary/foreign keys and constraints. Includes ALTER TABLE, TRUNCATE and DROP demonstrations. |
| `02_dml.sql` | B1 | Populates all tables with sample NHS data (12 patients, 10 doctors, 6 clinics, 10 medications, 15 appointments, 15 prescriptions). Includes UPDATE and DELETE demonstrations. |
| `03_part_c_queries.sql` | C | Six advanced queries: an aggregate query, LEFT JOIN, RIGHT JOIN, a FULL JOIN emulated via UNION, a stored procedure (`GetPatientAppointments`), and a trigger (`trg_after_appointment_insert`) with an audit table. |
| `04_part_d_security.sql` | D | Role-based access control for four user types (admin, doctor, receptionist, patient), SHA-256 password hashing, a SQL injection vulnerability/defence demonstration, and a basic transaction example. |

## How to run

Requires MySQL 8.0+. Run the scripts in order against a MySQL server:

```
SOURCE 01_ddl.sql;
SOURCE 02_dml.sql;
SOURCE 03_part_c_queries.sql;
SOURCE 04_part_d_security.sql;
```

## Note on tooling

MySQL Workbench crashed on connection on my machine (a known macOS compatibility issue). All scripts were executed and verified via the MySQL command-line client instead. Screenshots of execution and output are included in the individual report.
