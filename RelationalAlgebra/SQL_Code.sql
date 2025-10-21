-- Query 1: Find the names of patients who have had at least one clinical activity handled by active staff.
SELECT DISTINCT p.FullName
FROM Patient p
JOIN ClinicalActivity CA ON p.IID = CA.IID
JOIN Staff s ON s.STAFF_ID = CA.STAFF_ID
WHERE s.Status = 'Active';

-- Query 2: Find Staff IDs of staff who are either 'Active' or have issued at least one prescription.
SELECT CA.STAFF_ID
FROM ClinicalActivity CA
JOIN Prescription Pre ON CA.CAID = Pre.CAID
UNION
SELECT s.STAFF_ID
FROM Staff s
WHERE s.Status = 'Active';

-- Query 3: Find Hospital IDs of hospitals located in 'Benguerir' or having at least one department with the specialty 'Cardiology'.
SELECT H.HID
FROM Hospital H
WHERE H.City = 'Benguerir'
UNION
SELECT D.HID
FROM Department D
WHERE D.Name = 'Cardiology';

-- Query 4: Find Hospital IDs of hospitals that have both 'Cardiology' and 'Pediatrics' departments.
SELECT DISTINCT D1.HID
FROM Department D1
JOIN Department D2 ON D1.HID = D2.HID
WHERE D1.Name = 'Cardiology'
  AND D2.Name = 'Pediatrics';

-- Query 5: Find staff members who have worked in every department of the hospital with HID = 1.
SELECT s.STAFF_ID, s.FullName
FROM Staff s
WHERE NOT EXISTS (
    SELECT d.DEP_ID
    FROM Department d
    WHERE d.HID = 1
    AND NOT EXISTS (
        SELECT 1
        FROM ClinicalActivity ca
        WHERE ca.STAFF_ID = s.STAFF_ID
        AND ca.DEP_ID = d.DEP_ID
    )
);

-- Query 6: Find staff members who participated in every clinical activity of the department with DEP_ID = 2.
SELECT s.STAFF_ID, s.FullName
FROM Staff s
WHERE NOT EXISTS (
    SELECT ca.CAID
    FROM ClinicalActivity ca
    WHERE ca.DEP_ID = 2
    AND NOT EXISTS (
        SELECT 1
        FROM ClinicalActivity ca2
        WHERE ca2.STAFF_ID = s.STAFF_ID
        AND ca2.CAID = ca.CAID
    )
);

-- Query 7: Find pairs of staff members (s1, s2) such that s1 has handled more clinical activities than s2.
WITH R1 AS (
    SELECT STAFF_ID, COUNT(*) AS num
    FROM ClinicalActivity
    GROUP BY STAFF_ID
)
SELECT R1.STAFF_ID AS Staff1, R2.STAFF_ID AS Staff2
FROM R1
JOIN R1 AS R2 ON R1.num > R2.num AND R1.STAFF_ID != R2.STAFF_ID;

-- Query 8: Find Patient IDs of patients who had clinical activities with at least two different staff members.
SELECT CA.IID
FROM ClinicalActivity CA
GROUP BY CA.IID
HAVING COUNT(DISTINCT CA.STAFF_ID) >= 2;

-- Query 9: Find CAIDs of clinical activities performed in September 2025 at hospitals located in "Benguerir".
SELECT CA.CAID
FROM ClinicalActivity CA
JOIN Department D ON CA.DEP_ID = D.DEP_ID
JOIN Hospital H ON D.HID = H.HID
WHERE H.City = 'Benguerir'
  AND CA.Date BETWEEN '2025-09-01' AND '2025-09-30';

-- Query 10: Find Staff IDs of staff who have issued more than one prescription.
SELECT CA.STAFF_ID
FROM ClinicalActivity CA
JOIN Prescription Pre ON CA.CAID = Pre.CAID
GROUP BY CA.STAFF_ID
HAVING COUNT(*) > 1;

-- Query 11: List IIDs of patients who have scheduled appointments in more than one department.
SELECT CA.IID
FROM ClinicalActivity CA
JOIN Appointment A ON CA.CAID = A.CAID
WHERE A.Status = 'Scheduled'
GROUP BY CA.IID
HAVING COUNT(DISTINCT CA.DEP_ID) >= 2;

-- Query 12: Find Staff IDs who have NO scheduled appointments on the day of the Green March holiday (November 6).
SELECT s.STAFF_ID
FROM Staff s
WHERE NOT EXISTS (
    SELECT 1
    FROM ClinicalActivity CA
    JOIN Appointment A ON A.CAID = CA.CAID
    WHERE CA.STAFF_ID = s.STAFF_ID
      AND CA.Date = '2025-11-06'
      AND A.Status = 'Scheduled'
);

-- Query 13: Find departments whose average number of clinical activities is below the global departmental average.
WITH R1 AS (
    SELECT DEP_ID, COUNT(*) AS num
    FROM ClinicalActivity
    GROUP BY DEP_ID
),
R1_Avg AS (
    SELECT AVG(num) AS Avr FROM R1
)
SELECT R1.DEP_ID
FROM R1
CROSS JOIN R1_Avg
WHERE R1.num < R1_Avg.Avr;

-- Query 14: For each staff member, return the patient who has the greatest number of completed appointments with that staff member.
WITH R1 AS (
    SELECT CA.STAFF_ID, CA.IID, COUNT(*) AS num_completion
    FROM Appointment A
    JOIN ClinicalActivity CA ON A.CAID = CA.CAID
    WHERE A.Status = 'Completed'
    GROUP BY CA.STAFF_ID, CA.IID
),
R2 AS (
    SELECT STAFF_ID, MAX(num_completion) AS max_num
    FROM R1
    GROUP BY STAFF_ID
)
SELECT R1.STAFF_ID, R1.IID
FROM R1
JOIN R2 ON R1.STAFF_ID = R2.STAFF_ID AND R1.num_completion = R2.max_num;

-- Query 15: List patients who had at least 3 emergency admissions during the year 2024.
SELECT P.FullName
FROM ClinicalActivity CA
JOIN Patient P ON P.IID = CA.IID
JOIN Emergency E ON E.CAID = CA.CAID
WHERE E.Outcome = 'Admitted'
  AND YEAR(CA.Date) = 2024
GROUP BY CA.IID, P.FullName
HAVING COUNT(*) >= 3;