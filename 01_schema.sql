-- =========================================================
-- CROWNFIELD EYE HOSPITAL DATABASE
-- FILE: 01_schema.sql
-- Creates database, tables, constraints and sample data.
-- MySQL 8.0.16 or later recommended.
-- =========================================================

CREATE DATABASE IF NOT EXISTS crownfield_eye_hospital;
USE crownfield_eye_hospital;

-- Drop tables in dependency order so this script can be rerun.
DROP TABLE IF EXISTS follow_up_audit;
DROP TABLE IF EXISTS follow_up;
DROP TABLE IF EXISTS prescription_items;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS prescriptions;
DROP TABLE IF EXISTS diagnoses;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS clinics;
DROP TABLE IF EXISTS clinicians;
DROP TABLE IF EXISTS specialties;
DROP TABLE IF EXISTS patients;

-- =========================================================
-- 1. PATIENTS
-- =========================================================

CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    postcode VARCHAR(15) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(100) UNIQUE
);

-- =========================================================
-- 2. SPECIALTIES
-- =========================================================

CREATE TABLE specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(100) NOT NULL UNIQUE
);

-- =========================================================
-- 3. CLINICIANS
-- =========================================================

CREATE TABLE clinicians (
    clinician_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty_id INT NOT NULL,

    CONSTRAINT fk_clinician_specialty
        FOREIGN KEY (specialty_id)
        REFERENCES specialties(specialty_id)
);

-- =========================================================
-- 4. CLINICS
-- =========================================================

CREATE TABLE clinics (
    clinic_id INT AUTO_INCREMENT PRIMARY KEY,
    clinic_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL
);

-- =========================================================
-- 5. APPOINTMENTS
-- =========================================================

CREATE TABLE appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    clinician_id VARCHAR(10) NOT NULL,
    clinic_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    appointment_status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',

    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_appointment_clinician
        FOREIGN KEY (clinician_id)
        REFERENCES clinicians(clinician_id),

    CONSTRAINT fk_appointment_clinic
        FOREIGN KEY (clinic_id)
        REFERENCES clinics(clinic_id),

    CONSTRAINT chk_appointment_status
        CHECK (appointment_status IN
        ('Scheduled', 'Completed', 'Cancelled'))
);

-- =========================================================
-- 6. DIAGNOSES
-- =========================================================

CREATE TABLE diagnoses (
    diagnosis_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id VARCHAR(10) NOT NULL,
    diagnosis_description VARCHAR(255) NOT NULL,

    CONSTRAINT fk_diagnosis_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
);

-- =========================================================
-- 7. PRESCRIPTIONS
-- =========================================================

CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id VARCHAR(10) NOT NULL,
    prescription_date DATE NOT NULL,

    CONSTRAINT fk_prescription_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
);

-- =========================================================
-- 8. MEDICINES
-- =========================================================

CREATE TABLE medicines (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE
);

-- =========================================================
-- 9. PRESCRIPTION ITEMS
-- Resolves the many-to-many relationship between
-- prescriptions and medicines.
-- =========================================================

CREATE TABLE prescription_items (
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dose VARCHAR(100) NOT NULL,
    route VARCHAR(50) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration_days INT NOT NULL,

    PRIMARY KEY (prescription_id, medicine_id),

    CONSTRAINT fk_item_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(prescription_id),

    CONSTRAINT fk_item_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(medicine_id),

    CONSTRAINT chk_duration
        CHECK (duration_days > 0)
);

-- =========================================================
-- 10. FOLLOW-UP
-- Assumption: maximum one follow-up per appointment.
-- =========================================================

CREATE TABLE follow_up (
    follow_up_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id VARCHAR(10) NOT NULL UNIQUE,
    due_date DATE NOT NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'Routine',
    follow_up_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    notes VARCHAR(255),

    CONSTRAINT fk_followup_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),

    CONSTRAINT chk_followup_priority
        CHECK (priority IN ('Routine', 'High', 'Urgent')),

    CONSTRAINT chk_followup_status
        CHECK (follow_up_status IN
        ('Pending', 'Completed', 'Cancelled'))
);

-- =========================================================
-- 11. FOLLOW-UP AUDIT
-- Stores a record of follow-up actions.
-- =========================================================

CREATE TABLE follow_up_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    follow_up_id INT NOT NULL,
    action_description VARCHAR(255) NOT NULL,
    action_datetime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_followup
        FOREIGN KEY (follow_up_id)
        REFERENCES follow_up(follow_up_id)
);

-- =========================================================
-- SAMPLE DATA
-- All information below is fictional.
-- =========================================================

-- 10 PATIENTS

INSERT INTO patients
(patient_id, full_name, postcode, date_of_birth, email)
VALUES
('PT001','Amina Yusuf','NE1 4AB','1985-04-12','amina@example.com'),
('PT002','Daniel Reed','N16 7QP','1978-08-21','daniel@example.com'),
('PT003','Sofia Bennett','E8 2LD','1992-02-15','sofia@example.com'),
('PT004','Michael Okoro','SE6 3RT','1980-11-30','michael@example.com'),
('PT005','Olivia Brown','B1 1AA','1988-06-10','olivia@example.com'),
('PT006','James Wilson','B2 2BB','1975-03-20','james@example.com'),
('PT007','Emily Taylor','B3 3CC','1990-09-05','emily@example.com'),
('PT008','Noah Davies','B4 4DD','1983-12-14','noah@example.com'),
('PT009','Grace Evans','B5 5EE','1995-01-25','grace@example.com'),
('PT010','Liam Thomas','B6 6FF','1972-07-18','liam@example.com');

-- 10 SPECIALTIES

INSERT INTO specialties (specialty_name)
VALUES
('Glaucoma'),
('Retina'),
('Cornea'),
('Cataract'),
('Paediatric Ophthalmology'),
('Oculoplastics'),
('Neuro-Ophthalmology'),
('Uveitis'),
('Medical Retina'),
('Emergency Eye Care');

-- 10 CLINICIANS

INSERT INTO clinicians
(clinician_id, full_name, specialty_id)
VALUES
('CL001','Dr Maya Shah',1),
('CL002','Dr Leo Grant',2),
('CL003','Dr Priya Nair',3),
('CL004','Dr James Carter',4),
('CL005','Dr Sarah Khan',5),
('CL006','Dr Adam Lewis',6),
('CL007','Dr Emma White',7),
('CL008','Dr Oliver Green',8),
('CL009','Dr Mia Hall',9),
('CL010','Dr Jack Young',10);

-- 10 CLINICS

INSERT INTO clinics (clinic_name, location)
VALUES
('Glaucoma Clinic','City Road'),
('Retina Clinic','City Road'),
('Cornea Clinic','Croydon'),
('Cataract Clinic','Bedford'),
('Children Eye Clinic','Birmingham'),
('Oculoplastics Clinic','London'),
('Neuro Eye Clinic','Bedford'),
('Uveitis Clinic','Croydon'),
('Medical Retina Clinic','Birmingham'),
('Emergency Eye Clinic','City Road');

-- 12 APPOINTMENTS
-- PT001 has more than one appointment.
-- AP011 and AP012 have no follow-up records.

INSERT INTO appointments
(appointment_id, patient_id, clinician_id, clinic_id,
 appointment_datetime, appointment_status)
VALUES
('AP001','PT001','CL001',1,'2026-10-05 09:00:00','Completed'),
('AP002','PT002','CL002',2,'2026-10-05 09:30:00','Completed'),
('AP003','PT003','CL001',1,'2026-10-06 11:00:00','Completed'),
('AP004','PT004','CL003',3,'2026-10-07 14:00:00','Completed'),
('AP005','PT005','CL004',4,'2026-10-08 10:00:00','Completed'),
('AP006','PT006','CL005',5,'2026-10-09 11:00:00','Completed'),
('AP007','PT007','CL006',6,'2026-10-10 12:00:00','Completed'),
('AP008','PT008','CL007',7,'2026-10-11 13:00:00','Completed'),
('AP009','PT009','CL008',8,'2026-10-12 14:00:00','Completed'),
('AP010','PT001','CL001',1,'2026-11-16 10:15:00','Scheduled'),
('AP011','PT002','CL009',9,'2026-11-17 09:30:00','Scheduled'),
('AP012','PT003','CL010',10,'2026-11-18 10:30:00','Scheduled');

-- 10 DIAGNOSES

INSERT INTO diagnoses
(appointment_id, diagnosis_description)
VALUES
('AP001','Ocular hypertension'),
('AP002','Diabetic macular oedema'),
('AP003','Glaucoma suspect'),
('AP004','Keratoconus'),
('AP005','Cataract assessment'),
('AP006','Paediatric eye review'),
('AP007','Eyelid condition review'),
('AP008','Optic nerve assessment'),
('AP009','Uveitis review'),
('AP010','Ocular hypertension follow-up');

-- 10 PRESCRIPTIONS

INSERT INTO prescriptions
(appointment_id, prescription_date)
VALUES
('AP001','2026-10-05'),
('AP002','2026-10-05'),
('AP003','2026-10-06'),
('AP004','2026-10-07'),
('AP005','2026-10-08'),
('AP006','2026-10-09'),
('AP007','2026-10-10'),
('AP008','2026-10-11'),
('AP009','2026-10-12'),
('AP010','2026-11-16');

-- 10 MEDICINES

INSERT INTO medicines (medicine_name)
VALUES
('Latanoprost'),
('Timolol'),
('Aflibercept'),
('Sodium chloride drops'),
('Lubricating eye drops'),
('Prednisolone eye drops'),
('Cyclopentolate'),
('Artificial tears'),
('Dexamethasone eye drops'),
('Antibiotic eye drops');

-- 10 PRESCRIPTION ITEMS
-- Doses are fictional placeholders, not medical instructions.

INSERT INTO prescription_items
(prescription_id, medicine_id, dose, route, frequency, duration_days)
VALUES
(1,1,'Sample dose','Eye drops','Once daily',30),
(2,3,'Sample dose','Injection','As prescribed',28),
(3,2,'Sample dose','Eye drops','Twice daily',30),
(4,4,'Sample dose','Eye drops','As prescribed',56),
(5,5,'Sample dose','Eye drops','As prescribed',30),
(6,6,'Sample dose','Eye drops','As prescribed',14),
(7,7,'Sample dose','Eye drops','As prescribed',7),
(8,8,'Sample dose','Eye drops','As prescribed',30),
(9,9,'Sample dose','Eye drops','As prescribed',14),
(10,1,'Sample dose','Eye drops','Once daily',30);

-- 10 FOLLOW-UP RECORDS
-- AP011 and AP012 intentionally have no follow-up.

INSERT INTO follow_up
(appointment_id, due_date, priority, follow_up_status, notes)
VALUES
('AP001','2026-11-16','High','Pending','Review eye pressure'),
('AP002','2026-11-02','Urgent','Pending','OCT before review'),
('AP003','2027-04-06','Routine','Pending','Monitor condition'),
('AP004','2026-12-02','Routine','Pending','Corneal topography'),
('AP005','2026-11-08','Routine','Pending','Cataract review'),
('AP006','2026-11-09','Routine','Pending','Paediatric review'),
('AP007','2026-11-10','High','Pending','Review eyelid condition'),
('AP008','2026-11-11','Routine','Pending','Optic nerve review'),
('AP009','2026-11-12','Routine','Pending','Uveitis review'),
('AP010','2027-02-16','Routine','Pending','Visual field test');

-- 10 AUDIT RECORDS

INSERT INTO follow_up_audit
(follow_up_id, action_description)
VALUES
(1,'Initial follow-up created'),
(2,'Initial follow-up created'),
(3,'Initial follow-up created'),
(4,'Initial follow-up created'),
(5,'Initial follow-up created'),
(6,'Initial follow-up created'),
(7,'Initial follow-up created'),
(8,'Initial follow-up created'),
(9,'Initial follow-up created'),
(10,'Initial follow-up created');

-- =========================================================
-- CONTROLLED UPDATE AND DELETE DEMONSTRATION
-- A temporary test patient is inserted, updated and deleted.
-- This patient has no appointment references.
-- =========================================================

INSERT INTO patients
(patient_id, full_name, postcode, date_of_birth, email)
VALUES
('PT999','Temporary Test Patient','B9 9ZZ',
 '1990-01-01','temporary@example.com');

START TRANSACTION;

UPDATE patients
SET postcode = 'B8 8YY'
WHERE patient_id = 'PT999';

DELETE FROM patients
WHERE patient_id = 'PT999'
AND NOT EXISTS (
    SELECT 1
    FROM appointments
    WHERE appointments.patient_id = patients.patient_id
);

COMMIT;

-- =========================================================
-- CHECK THE DATA
-- =========================================================

SELECT COUNT(*) AS patient_records FROM patients;
SELECT COUNT(*) AS appointment_records FROM appointments;
SELECT COUNT(*) AS diagnosis_records FROM diagnoses;
SELECT COUNT(*) AS prescription_records FROM prescriptions;
SELECT COUNT(*) AS medicine_records FROM medicines;
SELECT COUNT(*) AS follow_up_records FROM follow_up;

-- End of 01_schema.sql