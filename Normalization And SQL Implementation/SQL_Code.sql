CREATE DATABASE IF NOT EXISTS MNHS;
USE MNHS;

CREATE TABLE Patient (
    IID INT PRIMARY KEY,
    CIN VARCHAR(10) UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Birth DATE,
    Sex ENUM('M', 'F') NOT NULL,
    BloodGroup ENUM('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'),
    Phone VARCHAR(15)
);

CREATE TABLE Hospital (
    HID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Region VARCHAR(50)
);

CREATE TABLE Department (
    DEP_ID INT PRIMARY KEY,
    HID INT not null,
    Name VARCHAR(100) NOT NULL,
    Specialty VARCHAR(100),
    FOREIGN KEY (HID) REFERENCES Hospital(HID)
);

CREATE TABLE Staff (
    STAFF_ID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Status ENUM('Active', 'Retired') DEFAULT 'Active'
);

CREATE TABLE Practitioner (
    STAFF_ID INT PRIMARY KEY,
    LicenseNumber VARCHAR(50),
    Specialty VARCHAR(100),
    FOREIGN KEY (STAFF_ID) REFERENCES Staff(STAFF_ID)
);

CREATE TABLE Caregiving (
    STAFF_ID INT PRIMARY KEY,
    Grade VARCHAR(50),
    Ward VARCHAR(50),
    FOREIGN KEY (STAFF_ID) REFERENCES Staff(STAFF_ID)
);

CREATE TABLE Technical (
    STAFF_ID INT PRIMARY KEY,
    Certifications VARCHAR(200),
    Modality VARCHAR(100),
    FOREIGN KEY (STAFF_ID) REFERENCES Staff(STAFF_ID)
);

CREATE TABLE Work_in (
    STAFF_ID INT,
    Dep_ID INT,
    PRIMARY KEY (STAFF_ID, Dep_ID),
    FOREIGN KEY (STAFF_ID) REFERENCES Staff(STAFF_ID),
    FOREIGN KEY (Dep_ID) REFERENCES Department(DEP_ID)
);

CREATE TABLE ClinicalActivity (
    CAID INT PRIMARY KEY,
    IID INT NOT NULL,
    STAFF_ID INT NOT NULL,
    DEP_ID INT NOT NULL,
    Date DATE NOT NULL,
    Time TIME,
    FOREIGN KEY (IID) REFERENCES Patient(IID),
    FOREIGN KEY (STAFF_ID) REFERENCES Staff(STAFF_ID),
    FOREIGN KEY (DEP_ID) REFERENCES Department(DEP_ID)
);

CREATE TABLE Appointment (
    CAID INT PRIMARY KEY,
    Reason VARCHAR(100),
    Status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Emergency (
    CAID INT PRIMARY KEY,
    TriageLevel INT CHECK (TriageLevel BETWEEN 1 AND 5),
    Outcome ENUM('Discharged', 'Admitted', 'Transferred', 'Deceased'),
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Insurance (
    InsID INT PRIMARY KEY,
    Type ENUM('CNOPS', 'CNSS', 'RAMED', 'Private', 'None') NOT NULL
);

CREATE TABLE Covers (
    InsID INT,
    IID INT,
    PRIMARY KEY (InsID, IID),
    FOREIGN KEY (InsID) REFERENCES Insurance(InsID),
    FOREIGN KEY (IID) REFERENCES Patient(IID)
);

CREATE TABLE Expense (
    ExpID INT PRIMARY KEY,
    InsID INT not null,
    CAID INT UNIQUE NOT NULL,
    Total DECIMAL(10,2) NOT NULL CHECK (Total >= 0),
    FOREIGN KEY (InsID) REFERENCES Insurance(InsID),
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Medication (
    MID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Form VARCHAR(50),
    Strength VARCHAR(50),
    ActiveIngredient VARCHAR(100),
    TherapeuticClass VARCHAR(100),
    Manufacturer VARCHAR(100)
);

CREATE TABLE Stock (
    HID INT,
    MID INT,
    StockTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    UnitPrice DECIMAL(10,2) CHECK (UnitPrice >= 0),
    Qty INT DEFAULT 0 CHECK (Qty >= 0),
    ReorderLevel INT DEFAULT 10 CHECK (ReorderLevel >= 0),
    PRIMARY KEY (HID, MID, StockTimestamp),
    FOREIGN KEY (HID) REFERENCES Hospital(HID),
    FOREIGN KEY (MID) REFERENCES Medication(MID)
);

CREATE TABLE Prescription (
    PID INT PRIMARY KEY,
    CAID INT UNIQUE NOT NULL,
    DateIssued DATE NOT NULL,
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Includes (
    PID INT,
    MID INT,
    Dosage VARCHAR(100),
    Duration VARCHAR(50),
    PRIMARY KEY (PID, MID),
    FOREIGN KEY (PID) REFERENCES Prescription(PID),
    FOREIGN KEY (MID) REFERENCES Medication(MID)
);

CREATE TABLE ContactLocation (
    CLID INT PRIMARY KEY,
    City VARCHAR(50),
    Province VARCHAR(50),
    Street VARCHAR(100),
    Number VARCHAR(10),
    PostalCode VARCHAR(10),
    Phone VARCHAR(15)
);

CREATE TABLE Have (
    IID INT,
    CLID INT,
    PRIMARY KEY (IID, CLID),
    FOREIGN KEY (IID) REFERENCES Patient(IID),
    FOREIGN KEY (CLID) REFERENCES ContactLocation(CLID)
);
INSERT INTO Patient (IID, CIN, FullName, Birth, Sex, BloodGroup, Phone) VALUES
(1, 'AB234567', 'Amina Benjelloun', '1985-03-15', 'F', 'O+', '0661234567'),
(2, 'CD789012', 'Youssef El Alami', '1978-11-22', 'M', 'A+', '0677890123'),
(3, 'EF345678', 'Fatima Idrissi', '1992-07-08', 'F', 'B+', '0612345678'),
(4, 'GH901234', 'Mohammed Tazi', '1965-01-30', 'M', 'AB+', '0698765432'),
(5, 'IJ567890', 'Khadija Bennani', '1988-09-12', 'F', 'O-', '0623456789');

INSERT INTO Hospital (HID, Name, City, Region) VALUES
(1, 'CHU Ibn Rochd', 'Casablanca', 'Casablanca-Settat'),
(2, 'Hôpital Cheikh Khalifa', 'Rabat', 'Rabat-Salé-Kénitra'),
(3, 'CHU Hassan II', 'Fès', 'Fès-Meknès'),
(4, 'Hôpital Avicenne', 'Marrakech', 'Marrakech-Safi'),
(5, 'CHU Mohammed VI', 'Tanger', 'Tanger-Tétouan-Al Hoceïma');

INSERT INTO Department (DEP_ID, HID, Name, Specialty) VALUES
(1, 1, 'Cardiologie', 'Maladies cardiovasculaires'),
(2, 1, 'Urgences', 'Médecine d\'urgence'),
(3, 2, 'Pédiatrie', 'Soins des enfants'),
(4, 3, 'Radiologie', 'Imagerie médicale'),
(5, 4, 'Chirurgie générale', 'Interventions chirurgicales');

INSERT INTO Staff (STAFF_ID, FullName, Status) VALUES
(1, 'Dr. Rachid Hamouda', 'Active'),
(2, 'Dr. Samira Chakir', 'Active'),
(3, 'Dr. Mehdi Alaoui', 'Active'),
(4, 'Dr. Hassan Zemmouri', 'Retired'),
(5, 'Dr. Leila Fassi', 'Active'),
(6, 'Nadia Lahlou', 'Active'),
(7, 'Laila Ouazzani', 'Active'),
(8, 'Zineb Yassin', 'Active'),
(9, 'Samira Benali', 'Active'),
(10, 'Aicha Bentayeb', 'Active'),
(11, 'Karim Bouzid', 'Active'),
(12, 'Houda Fassi', 'Active'),
(13, 'Omar Regragui', 'Active'),
(14, 'Salma Amor', 'Active'),
(15, 'Jamal Din Dibiaza', 'Active');

INSERT INTO Practitioner (STAFF_ID, LicenseNumber, Specialty) VALUES
(1, 'MED-2008-4521', 'Cardiologie'),
(2, 'MED-2012-7834', 'Pédiatrie'),
(3, 'MED-2015-9201', 'Radiologie'),
(4, 'MED-1995-1203', 'Chirurgie générale'),
(5, 'MED-2010-5678', 'Médecine d\'urgence');

INSERT INTO Caregiving (STAFF_ID, Grade, Ward) VALUES
(6, 'Aide-soignante', 'Urgences'),
(7, 'Infirmière diplômée', 'Cardiologie B'),
(8, 'Infirmière auxiliaire', 'Pédiatrie'),
(9, 'Infirmière chef', 'Chirurgie'),
(10, 'Aide-soignante', 'Radiologie');

INSERT INTO Technical (STAFF_ID, Certifications, Modality) VALUES
(11, 'Échographie cardiaque, ECG', 'Cardiologie'),
(12, 'Radiologie pédiatrique', 'Imagerie'),
(13, 'Manipulation d\'équipements', 'Laboratoire'),
(14, 'IRM, Scanner', 'Radiologie'),
(15, 'Analyses biologiques', 'Laboratoire');

INSERT INTO Work_in (STAFF_ID, Dep_ID) VALUES
(1, 1),
(2, 3),
(3, 4),
(4, 5),
(5, 2);

INSERT INTO ClinicalActivity (CAID, IID, STAFF_ID, DEP_ID, Date, Time) VALUES
(1, 1, 1, 1, '2025-10-18', '09:30:00'),
(2, 2, 2, 3, '2025-10-20', '14:00:00'),
(3, 3, 1, 1, '2025-11-12', '11:15:00'),
(4, 4, 4, 5, '2025-11-15', '10:30:00'),
(5, 1, 2, 3, '2025-12-05', '10:00:00'),
(6, 1, 5, 2, '2024-11-10', '22:15:00'),
(7, 3, 5, 2, '2024-11-05', '01:30:00'),
(8, 4, 5, 2, '2024-11-08', '18:45:00'),
(9, 2, 5, 2, '2024-10-30', '05:20:00'),
(10, 1, 5, 2, '2024-11-14', '12:00:00'),
(11, 2, 5, 2, '2024-11-01', '08:00:00'),
(12, 3, 5, 2, '2023-11-02', '09:00:00'),
(13, 4, 5, 2, '2024-11-03', '10:00:00'),
(14, 5, 5, 2, '2024-11-04', '11:00:00'),
(15, 1, 5, 2, '2025-11-06', '13:00:00'),
(16, 2, 5, 2, '2025-11-07', '14:00:00'),
(17, 3, 5, 2, '2024-11-09', '15:00:00'),
(18, 4, 5, 2, '2024-11-11', '16:00:00'),
(19, 5, 5, 2, '2024-11-12', '17:00:00'),
(20, 1, 5, 2, '2024-11-13', '18:00:00'),
(21, 2, 5, 2, '2023-11-15', '19:00:00'),
(22, 3, 5, 2, '2024-10-20', '20:00:00'),
(23, 4, 5, 2, '2024-10-21', '21:00:00'),
(24, 5, 5, 2, '2024-10-22', '22:00:00'),
(25, 1, 5, 2, '2024-10-23', '23:00:00');

INSERT INTO Appointment (CAID, Reason, Status) VALUES
(1, 'Consultation cardiaque', 'Scheduled'),
(2, 'Vaccination enfant', 'Scheduled'),
(3, 'Douleurs thoraciques', 'Scheduled'),
(4, 'Contrôle post-opératoire', 'Completed'),
(5, 'Contrôle pédiatrique', 'Cancelled');

INSERT INTO Emergency (CAID, TriageLevel, Outcome) VALUES
(6, 2, 'Admitted'),
(7, 1, 'Admitted'),
(8, 3, 'Admitted'),
(9, 4, 'Admitted'),
(10, 2, 'Admitted'),
(11, 3, 'Admitted'),
(12, 1, 'Admitted'),
(13, 2, 'Admitted'),
(14, 4, 'Admitted'),
(15, 3, 'Admitted'),
(16, 2, 'Admitted'),
(17, 1, 'Admitted'),
(18, 3, 'Admitted'),
(19, 2, 'Admitted'),
(20, 4, 'Admitted'),
(21, 3, 'Admitted'),
(22, 2, 'Discharged'),
(23, 1, 'Transferred'),
(24, 3, 'Discharged'),
(25, 2, 'Admitted');

INSERT INTO Insurance (InsID, Type) VALUES
(1, 'CNOPS'),
(2, 'CNSS'),
(3, 'RAMED'),
(4, 'Private'),
(5, 'None');

INSERT INTO Covers (InsID, IID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO Expense (ExpID, InsID, CAID, Total) VALUES
(1, 1, 1, 450.00),
(2, 2, 2, 200.00),
(3, 3, 3, 0.00),
(4, 4, 4, 1250.00),
(5, 2, 5, 180.00);

INSERT INTO Medication (MID, Name, Form, Strength, ActiveIngredient, TherapeuticClass, Manufacturer) VALUES
(1, 'Paracétamol', 'Comprimé', '500mg', 'Paracétamol', 'Analgésique', 'Sothema'),
(2, 'Amoxicilline', 'Gélule', '500mg', 'Amoxicilline', 'Antibiotique', 'Laprophan'),
(3, 'Aspirine', 'Comprimé', '100mg', 'Acide acétylsalicylique', 'Antiagrégant plaquettaire', 'Cooper Pharma'),
(4, 'Oméprazole', 'Gélule', '20mg', 'Oméprazole', 'Inhibiteur de la pompe à protons', 'Pharma 5'),
(5, 'Ciprofloxacine', 'Comprimé', '500mg', 'Ciprofloxacine', 'Antibiotique', 'Galenica');

INSERT INTO Stock (HID, MID, StockTimestamp, UnitPrice, Qty, ReorderLevel) VALUES
(1, 1, '2024-10-01 08:00:00', 2.50, 5000, 500),
(1, 2, '2024-10-01 08:00:00', 8.75, 1200, 200),
(1, 3, '2024-10-01 08:00:00', 250.00, 3500, 400),
(1, 4, '2024-10-01 08:00:00', 180.00, 800, 150),
(1, 5, '2024-10-01 08:00:00', 120.00, 50, 300),
(2, 1, '2024-10-02 09:30:00', 3.20, 3500, 400),
(2, 2, '2024-10-02 09:30:00', 15.50, 150, 200),
(2, 3, '2024-10-02 09:30:00', 300.00, 2000, 400),
(2, 4, '2024-10-02 09:30:00', 190.00, 900, 150),
(2, 5, '2024-10-02 09:30:00', 5.00, 100, 200),
(3, 1, '2024-10-03 10:15:00', 2.00, 4000, 500),
(3, 2, '2024-10-03 10:15:00', 9.00, 1100, 200), 
(3, 3, '2024-10-03 10:15:00', 280.00, 3000, 400),
(3, 4, '2024-10-03 10:15:00', 12.00, 800, 150),
(3, 5, '2024-10-03 10:15:00', 125.00, 2000, 300),
(4, 1, '2024-10-04 11:45:00', 2.80, 4500, 500),
(4, 2, '2024-10-04 11:45:00', 10.00, 1300, 200),
(4, 3, '2024-10-04 11:45:00', 320.00, 3200, 400),
(4, 4, '2024-10-04 11:45:00', 185.00, 700, 150),
(4, 5, '2024-10-04 11:45:00', 130.00, 1800, 300),
(5, 1, '2024-10-05 07:30:00', 1.50, 5500, 500),
(5, 2, '2024-10-05 07:30:00', 7.50, 1400, 200),
(5, 3, '2024-10-05 07:30:00', 260.00, 3800, 400),
(5, 4, '2024-10-05 07:30:00', 175.00, 850, 150),
(5, 5, '2024-10-05 07:30:00', 0.00, 50, 300),
(1, 4, '2024-10-06 10:00:00', 12.00, 900, 150); 

INSERT INTO Prescription (PID, CAID, DateIssued) VALUES
(1, 1, '2024-11-18'),
(2, 2, '2024-11-20'),
(3, 3, '2024-11-22'),
(4, 4, '2024-10-25'),
(5, 6, '2024-11-10');

INSERT INTO Includes (PID, MID, Dosage, Duration) VALUES
(1, 3, '1 comprimé par jour', '30 jours'),
(2, 1, '1 comprimé 3 fois/jour', '5 jours'),
(3, 5, '1 comprimé 2 fois/jour', '10 jours'),
(4, 2, '1 gélule 2 fois/jour', '7 jours'),
(5, 4, '1 gélule avant repas', '20 jours');

INSERT INTO ContactLocation (CLID, City, Province, Street, Number, PostalCode, Phone) VALUES
(1, 'Casablanca', 'Casablanca', 'Boulevard Zerktouni', '45', '20000', '0522234567'),
(2, 'Rabat', 'Rabat', 'Avenue Mohammed V', '12', '10000', '0537123456'),
(3, 'Fès', 'Fès', 'Rue Talaa Kebira', '78', '30000', '0535678901'),
(4, 'Marrakech', 'Marrakech', 'Avenue Hassan II', '23', '40000', '0524345678'),
(5, 'Tanger', 'Tanger', 'Boulevard Pasteur', '56', '90000', '0539456789');

INSERT INTO Have (IID, CLID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

UPDATE Patient
SET Phone = '+212600112233'
WHERE IID = 201;

UPDATE Hospital
SET Region = 'Marrakech–Safi'
WHERE HID = 1;

DELETE FROM Appointment
WHERE Status = 'Cancelled';


-- DDL 3 (Alter a table to add an attribute)
ALTER TABLE Patient
ADD COLUMN Email VARCHAR(50);

-- Queries

-- 1. Select all patients ordered by last name.
SELECT *
FROM Patient
ORDER BY SUBSTRING_INDEX(FullName, ' ', -1);

-- 2. List distinct insurance types.
SELECT DISTINCT Type
FROM  Insurance ;

-- 3
SELECT DISTINCT s.STAFF_ID, s.FullName
FROM Staff s
JOIN Work_in w ON s.STAFF_ID = w.STAFF_ID
JOIN Department d ON w.Dep_ID = d.DEP_ID
JOIN Hospital h ON d.HID = h.HID
WHERE h.City = 'Rabat';

-- Query 4 --
select a.*
from Appointment as a
    join ClinicalActivity as CA on a.CAID = CA.CAID
where a.Status  = "Scheduled"
	and CA.date between current_date() and date_add(current_date(), interval 7 day);

-- 5
SELECT CA.DEP_ID, COUNT(*) AS numberOfAppointement
FROM Appointment A , ClinicalActivity CA 
WHERE A.CAID = CA.CAID 
GROUP BY CA.DEP_ID;
   
-- query 6 
SELECT H.Name AS Hospital, AVG(S.UnitPrice) AS avg_unit_price
FROM Hospital H, Stock S
WHERE H.HID = S.HID
GROUP BY H.Name;

-- query 7 
SELECT H.* FROM Hospital H Where H.HID IN  
(SELECT D.HID FROM Department D  JOIN ClinicalActivity C ON D.DEP_ID=C.DEP_ID WHERE C.CAID IN   
( SELECT E.CAID FROM Emergency WHERE Outcome= 'Admitted' )
GROUP BY D.HID HAVING COUNT(C.CAID) > 20 );

--  8.Find medications in the therapeutic class Antibiotic where the unit price is below two hundred.
SELECT 
    m.MID,
    m.Name,
    m.Form,
    m.Strength,
    m.ActiveIngredient,
    m.TherapeuticClass,
    m.Manufacturer
FROM Medication m
JOIN Stock s ON m.MID = s.MID
WHERE m.TherapeuticClass = 'Antibiotique'
  AND s.UnitPrice < 200;

-- 9. For each hospital list the top three most expensive medications.
SELECT H.Name AS HospitalName, M.Name AS MedicationName, S.UnitPrice
FROM Hospital H
JOIN Stock S ON H.HID = S.HID
JOIN Medication M ON M.MID = S.MID
WHERE S.UnitPrice >= (
    SELECT MIN(UnitPrice) 
    FROM (
        SELECT UnitPrice
        FROM Stock S2
        WHERE S2.HID = H.HID
        ORDER BY UnitPrice DESC
        LIMIT 3
    ) AS top3
);

-- 10
SELECT 
    d.DEP_ID,
    (SELECT COUNT(*) FROM Appointment a 
     JOIN ClinicalActivity c ON a.cid = c.cid 
     WHERE c.DEP_ID = d.DEP_ID AND a.status = 'Scheduled') AS Scheduled_Count,
    (SELECT COUNT(*) FROM Appointment a 
     JOIN ClinicalActivity c ON a.cid = c.cid 
     WHERE c.DEP_ID = d.DEP_ID AND a.status = 'Completed') AS Completed_Count,
    (SELECT COUNT(*) FROM Appointment a 
     JOIN ClinicalActivity c ON a.cid = c.cid 
     WHERE c.DEP_ID = d.DEP_ID AND a.status = 'Cancelled') AS Cancelled_Count
FROM Departement d;
-- Query 11 --
select p.*
from Patient as p
where 
	not exists(
		select *
        from ClinicalActivity as CA
            join Appointment as A on A.CAID = CA.CAID
		where CA.IID = p.IID
			  and A.Status = "Scheduled"
              and CA.date between current_date() and date_add(current_date(), interval 30 day)
	);
-- 12
SELECT  CA.STAFF_ID, H.HID AS Hospital_Id,  COUNT(*) AS Staff_Appointments, 
COUNT(*) * 100.0 / (
        SELECT COUNT(*)
        FROM ClinicalActivity CA2
        JOIN Appointment A2 ON A2.CAID = CA2.CAID
        JOIN Department D2 ON D2.DEP_ID = CA2.DEP_ID
        WHERE D2.HID = H.HID
    ) AS Percentage 
FROM ClinicalActivity CA
JOIN Appointment A ON A.CAID = CA.CAID
JOIN Department D ON D.DEP_ID = CA.DEP_ID
JOIN Hospital H ON H.HID = D.HID
GROUP BY H.HID, CA.STAFF_ID;
 
-- query 13
SELECT M.Name AS Medication, H.Name AS Hospital
FROM Hospital H, Stock S, Medication M
WHERE H.HID = S.HID AND M.MID = S.MID AND S.Qty < S.OrderLevel;

-- query 14 
SELECT H.*  FROM Hospital H 
JOIN Stock S ON S.HID=H.HID
JOIN Medication M ON M.MID = S.MID  WHERE M.TherapeuticClass='antibiotic'
GROUP BY H.HID 
HAVING COUNT(DISTINCT M.MID )=(SELECT COUNT(*) FROM  Medication M WHERE M.TherapeuticClass='antibiotic');

-- 15. For each hospital and drug class return the average unit price and flag whether it is above the citywide average for that class.
SELECT 
    h.HID,
    m.TherapeuticClass,
    AVG(s.UnitPrice) AS AvgPriceHospital,
    CASE 
        WHEN AVG(s.UnitPrice) > (
            SELECT AVG(s2.UnitPrice)
            FROM Stock s2
            JOIN Medication m2 ON s2.MID = m2.MID
            WHERE m2.TherapeuticClass = m.TherapeuticClass
        ) THEN 'Above city avg'
        ELSE 'Not above city avg'
    END AS PriceFlag
FROM Stock s
JOIN Hospital h ON s.HID = h.HID
JOIN Medication m ON s.MID = m.MID
GROUP BY h.HID, m.TherapeuticClass;
-- 16
SELECT 
    P.IID,
    P.FullName AS PatientName,
    MIN(CA.Date) AS NextAppointmentDate
FROM 
    Patient P
    JOIN ClinicalActivity CA ON P.IID = CA.IID
    JOIN Appointment A ON CA.CAID = A.CAID
WHERE 
    A.Status = 'Scheduled'
    AND CA.Date >= CURRENT_DATE
GROUP BY 
    P.IID, P.FullName
ORDER BY 
    NextAppointmentDate;
-- 17
SELECT 
    p.IID,
    p.FullName,
    COUNT(e.CAID) AS Total_Emergency,
    MAX(c.Date) AS Latest_Emergency,
    DATEDIFF(CURRENT_DATE, MAX(c.Date)) AS Days_Since_Last_Emergency
FROM Patient p
JOIN ClinicalActivity c ON p.IID = c.IID
JOIN Emergency e ON c.CAID = e.CAID
GROUP BY p.IID, p.FullName
HAVING COUNT(e.CAID) >= 2
   AND MAX(c.Date) >= DATE_SUB(CURRENT_DATE, INTERVAL 14 DAY);

-- Query 18 --
select
	H.city,
	H.name as HospitalName,
	count(A.CAID) as CompletedAPP_ID
from Hospital as H
	Join Department D on H.HID = D.HID
	Join ClinicalActivity CA on CA.DEP_ID = D.DEP_ID
	Join Appointment A on A.CAID = CA.CAID
where
	A.Status = "Completed"
    and CA.Date >= date_sub(current_date(), interval 90 day)
Group by 
	H.city
order by H.city, CompletedAPP_ID DESC;

-- 19
SELECT  S.MID, H.City, MIN(S.UnitPrice) AS min_price, MAX(S.UnitPrice) AS max_price
FROM Hospital H
JOIN Stock S ON S.HID = H.HID
GROUP BY H.City, S.MID
HAVING (MAX(S.UnitPrice) - MIN(S.UnitPrice)) * 100.0 / MIN(S.UnitPrice) > 30;

-- query 20
SELECT *
FROM Stock
WHERE Qty < 0 OR UnitPrice <= 0;
