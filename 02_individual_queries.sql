-- =========================================================
-- CROWNFIELD EYE HOSPITAL
-- FILE: 02_individual_queries.sql
-- Contains individual queries 1 to 4.
-- =========================================================

USE crownfield_eye_hospital;


-- =========================================================
-- QUERY 1: AGGREGATE, GROUP BY AND HAVING
-- =========================================================

-- Question:
-- Which clinicians have managed two or more appointments?

SELECT
    c.clinician_id,
    c.full_name,
    COUNT(a.appointment_id) AS total_appointments
FROM clinicians c
INNER JOIN appointments a
    ON c.clinician_id = a.clinician_id
GROUP BY
    c.clinician_id,
    c.full_name
HAVING COUNT(a.appointment_id) >= 2
ORDER BY total_appointments DESC;

-- Explanation:
-- COUNT calculates the number of appointments.
-- GROUP BY groups the results by clinician.
-- HAVING filters the results to show clinicians
-- with at least two appointments.


-- =========================================================
-- QUERY 2: INNER JOIN
-- =========================================================

-- Question:
-- Can the hospital display appointment details together
-- with the patient, clinician and clinic information?

SELECT
    a.appointment_id,
    p.full_name AS patient_name,
    c.full_name AS clinician_name,
    cl.clinic_name,
    cl.location,
    a.appointment_datetime,
    a.appointment_status
FROM appointments a
INNER JOIN patients p
    ON a.patient_id = p.patient_id
INNER JOIN clinicians c
    ON a.clinician_id = c.clinician_id
INNER JOIN clinics cl
    ON a.clinic_id = cl.clinic_id
ORDER BY a.appointment_datetime;

-- Explanation:
-- INNER JOIN combines related records from four tables.
-- It displays the patient, clinician and clinic
-- connected to each appointment.


-- =========================================================
-- QUERY 3: LEFT JOIN
-- =========================================================

-- Question:
-- Which appointments do not currently have a follow-up?

SELECT
    a.appointment_id,
    p.full_name AS patient_name,
    a.appointment_datetime,
    f.follow_up_id,
    f.due_date,
    f.follow_up_status
FROM appointments a
INNER JOIN patients p
    ON a.patient_id = p.patient_id
LEFT JOIN follow_up f
    ON a.appointment_id = f.appointment_id
WHERE f.follow_up_id IS NULL;

-- Explanation:
-- LEFT JOIN keeps all appointments even when
-- no matching follow-up exists.
-- IS NULL identifies appointments without a follow-up.
-- AP011 and AP012 should appear in the results.


-- =========================================================
-- QUERY 4: SUBQUERY
-- =========================================================

-- Question:
-- Which patients have more appointments than
-- the average number of appointments per patient?

SELECT
    p.patient_id,
    p.full_name,
    COUNT(a.appointment_id) AS total_appointments
FROM patients p
INNER JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    p.full_name
HAVING COUNT(a.appointment_id) >
(
    SELECT AVG(patient_total)
    FROM
    (
        SELECT COUNT(*) AS patient_total
        FROM appointments
        GROUP BY patient_id
    ) AS appointment_totals
);

-- Explanation:
-- The inner query calculates the average number
-- of appointments per patient.
-- The outer query displays patients whose appointment
-- count is higher than that average.

-- End of queries 1 to 4.