-- =========================================================
-- CROWNFIELD EYE HOSPITAL
-- FILE: 04_security.sql
-- Security, encryption and transaction demonstration.
-- =========================================================

USE crownfield_eye_hospital;


-- =========================================================
-- PART 1: ENCRYPTION
-- =========================================================

-- Demonstration only.
-- Never upload a real encryption key to GitHub.
-- A real application should retrieve keys securely
-- from a key-management system.

SET @encryption_key = 'DEMONSTRATION_KEY_ONLY';

-- Encrypt a sample sensitive value.

SET @encrypted_value =
    AES_ENCRYPT(
        'Example sensitive patient information',
        @encryption_key
    );

-- Display encrypted information.

SELECT @encrypted_value AS encrypted_information;

-- Decrypt the demonstration value.

SELECT
    CAST(
        AES_DECRYPT(@encrypted_value, @encryption_key)
        AS CHAR(255)
    ) AS decrypted_information;


-- =========================================================
-- PART 2: SQL INJECTION PROTECTION
-- =========================================================

-- Parameterised queries separate user input from SQL code.
-- This helps reduce SQL injection risks.

PREPARE patient_search FROM
'SELECT patient_id, full_name
 FROM patients
 WHERE patient_id = ?';

SET @search_patient_id = 'PT001';

EXECUTE patient_search USING @search_patient_id;

DEALLOCATE PREPARE patient_search;


-- =========================================================
-- PART 3: TRANSACTION MANAGEMENT
-- =========================================================

-- This example updates an appointment inside a transaction.
-- ROLLBACK reverses the change so the original data remains.

START TRANSACTION;

UPDATE appointments
SET appointment_status = 'Completed'
WHERE appointment_id = 'AP011';

-- Check the temporary result inside the transaction.

SELECT
    appointment_id,
    appointment_status
FROM appointments
WHERE appointment_id = 'AP011';

-- Undo the demonstration update.

ROLLBACK;

-- Confirm that the original value remains.

SELECT
    appointment_id,
    appointment_status
FROM appointments
WHERE appointment_id = 'AP011';


-- End of security and transaction examples.