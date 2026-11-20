-- =========================================================
-- CROWNFIELD EYE HOSPITAL
-- FILE: 03_procedure_and_trigger.sql
-- Contains stored procedure and triggers.
-- =========================================================

USE crownfield_eye_hospital;


-- =========================================================
-- QUERY 5: STORED PROCEDURE WITH INPUT PARAMETER
-- =========================================================

-- Question:
-- Can the hospital retrieve all appointments for a patient
-- by entering that patient's ID?

DROP PROCEDURE IF EXISTS sp_patient_appointments;

DELIMITER //

CREATE PROCEDURE sp_patient_appointments(
    IN p_patient_id VARCHAR(10)
)
BEGIN

    SELECT
        a.appointment_id,
        p.full_name AS patient_name,
        a.appointment_datetime,
        a.appointment_status,
        c.full_name AS clinician_name,
        cl.clinic_name,
        cl.location
    FROM appointments a

    INNER JOIN patients p
        ON a.patient_id = p.patient_id

    INNER JOIN clinicians c
        ON a.clinician_id = c.clinician_id

    INNER JOIN clinics cl
        ON a.clinic_id = cl.clinic_id

    WHERE a.patient_id = p_patient_id

    ORDER BY a.appointment_datetime;

END //

DELIMITER ;

-- Example:
-- This retrieves appointments for patient PT001.

CALL sp_patient_appointments('PT001');


-- =========================================================
-- QUERY 6: BEFORE INSERT TRIGGER
-- =========================================================

-- Business rule:
-- A follow-up due date must be later than the
-- original appointment date.

DROP TRIGGER IF EXISTS trg_validate_follow_up;

DELIMITER //

CREATE TRIGGER trg_validate_follow_up
BEFORE INSERT ON follow_up
FOR EACH ROW
BEGIN

    DECLARE v_appointment_date DATE;

    SELECT DATE(appointment_datetime)
    INTO v_appointment_date
    FROM appointments
    WHERE appointment_id = NEW.appointment_id;

    IF NEW.due_date <= v_appointment_date THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Follow-up date must be later than appointment date';

    END IF;

END //

DELIMITER ;


-- =========================================================
-- ADDITIONAL TRIGGER: AFTER INSERT AUDIT RECORD
-- =========================================================

-- Purpose:
-- Records when a new follow-up is created.

DROP TRIGGER IF EXISTS trg_audit_follow_up;

DELIMITER //

CREATE TRIGGER trg_audit_follow_up
AFTER INSERT ON follow_up
FOR EACH ROW
BEGIN

    INSERT INTO follow_up_audit
    (
        follow_up_id,
        action_description,
        action_datetime
    )
    VALUES
    (
        NEW.follow_up_id,
        'New follow-up record created',
        CURRENT_TIMESTAMP
    );

END //

DELIMITER ;


-- =========================================================
-- TESTING EXAMPLES
-- =========================================================

-- Test the stored procedure:
CALL sp_patient_appointments('PT001');

-- Test the trigger with an invalid date.
-- AP011 appointment date is 17 November 2026.
-- This test should be rejected.

-- INSERT INTO follow_up
-- (appointment_id, due_date, priority, follow_up_status, notes)
-- VALUES
-- ('AP011', '2026-11-01', 'Routine', 'Pending',
--  'Invalid date test');


-- Test the trigger with a valid date.
-- Remove the comment marks to run this test.
-- It should insert the follow-up and create an audit record.

-- INSERT INTO follow_up
-- (appointment_id, due_date, priority, follow_up_status, notes)
-- VALUES
-- ('AP011', '2026-12-17', 'Routine', 'Pending',
--  'Valid follow-up test');

-- Check audit records:
SELECT * FROM follow_up_audit;

-- End of procedure and trigger file.