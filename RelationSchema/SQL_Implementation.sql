-- Question 3.1 Creating the different needed tables --
CREATE DATABASE IF NOT EXISTS MNHS_DB;
USE MNHS_DB;

CREATE TABLE IF NOT EXISTS Patient (
    IID INT PRIMARY KEY,
    CIN VARCHAR(20) UNIQUE,
    Name VARCHAR(100) NOT NULL,
    Sex CHAR(1)
        CHECK (Sex IN ('M', 'F')),
    Birth DATE NOT NULL,
    BloodGroup VARCHAR(5)
        CHECK (BloodGroup IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    Phone VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS Staff (
    Staff_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Status VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Practitioner (
    Staff_ID INT PRIMARY KEY,
    LicenseNumber VARCHAR(20) NOT NULL,
    Specialty VARCHAR(50) NOT NULL,
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Caregiving (
    Staff_ID INT PRIMARY KEY,
    Ward VARCHAR(100),
    Grade VARCHAR(100),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Technical (
    Staff_ID INT PRIMARY KEY,
    Modality VARCHAR(100),
    Certifications VARCHAR(100),
    Grade VARCHAR(100),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Hospital (
    HID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    City VARCHAR(50),
    Region VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Department (
    DEP_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Specialty VARCHAR(100),
    HID INT NOT NULL,
    FOREIGN KEY (HID) REFERENCES Hospital(HID)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS WorkIn(
    Staff_ID INT NOT NULL,
    DEP_ID INT NOT NULL,
    PRIMARY KEY (Staff_ID, DEP_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE CASCADE,
    FOREIGN KEY (DEP_ID) REFERENCES Department(DEP_ID)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ClinicalActivity (
    CAID INT PRIMARY KEY,
    `Date` DATE NOT NULL,
    `Time` TIME NOT NULL,
    IID INT NOT NULL,
    Staff_ID INT NOT NULL,
    DEP_ID INT NOT NULL,
    FOREIGN KEY (IID) REFERENCES Patient(IID)
        ON DELETE NO ACTION,
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE NO ACTION,
    FOREIGN KEY (DEP_ID) REFERENCES Department(DEP_ID)
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS Appointment (
    CAID INT PRIMARY KEY,
    Reason VARCHAR(255),
    Status VARCHAR(50) NOT NULL,
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Emergency(
    CAID INT PRIMARY KEY,
    TriageLevel VARCHAR(50) NOT NULL,
    Outcome VARCHAR(50),
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
        ON DELETE CASCADE
);

-- Question 2.2 Inserting different tuples to the different tables --
INSERT INTO Hospital (HID, Name, City, Region)
VALUES 
(1, 'CHU Mohammed VI', 'Benguerir', 'Marrakech-Safi'),
(2, 'CHU Ibn Rochd', 'Casablanca', 'Casablanca-Settat'),
(3, 'Hopital Militaire', 'Rabat', 'Rabat-Sale-Kenitra'),
(4, 'CHU Mohammed VI', 'Marrakech', 'Marrakech-Safi'),
(5, 'Hopital Mohamed V', 'Tangier', 'Tanger-Tetouan-Al Hoceima');

INSERT INTO Patient (IID, CIN, Name, Sex, Birth, BloodGroup, Phone)
VALUES 
(1, 'BB532415', 'Salma', 'F', '2006-04-14', 'O+', '0612452318'),
(2, 'BJ234567', 'Hiba', 'F', '2006-06-26', 'O-', '0614567833'),
(3, 'BH123456', 'Sara', 'F', '2006-07-26', 'A+', '0616234590'),
(4, 'BH125457', 'Amine', 'M', '1982-07-26', 'A-', '0616224596'),
(5, 'BJ113426', 'Mohammed', 'M', '1998-07-26', 'A+', '0617234594');

INSERT INTO Department (DEP_ID, Name, Specialty, HID)
VALUES 
(1, 'Radiology', 'Medical imaging', 1),       
(2, 'Cardiology', 'Cardiovascular Medicine', 2),
(3, 'Neurology', 'Brain and nervous system', 3),
(4, 'Oncology', 'Cancer Treatment', 4),
(5, 'Neurosurgery', 'Brain and Nervous System', 5);

INSERT INTO Staff (Staff_ID, Name, Status)
VALUES 
(1, 'Dr Youssef Bennani', 'Active'),
(2, 'Dr Fatima Zahra Alami', 'Active'),
(3, 'Dr Hassan El Idrissi', 'Active'),
(4, 'Dr Amina Tazi', 'Active'),
(5, 'Dr Omar Kettani', 'On Leave'),
(6, 'Karima Belkadi', 'Active'),
(7, 'Said Moussaoui', 'Active'),
(8, 'Laila Benjelloun', 'Active'),
(9, 'Ahmed Tahiri', 'Active'),
(10, 'Sanaa Cherkaoui', 'Active');

INSERT INTO Practitioner (Staff_ID, LicenseNumber, Specialty)
VALUES 
(1, 'MED-RAB-2015-1234', 'Radiology'),
(2, 'MED-CAS-2012-5678', 'Cardiology'),
(3, 'MED-RAB-2010-9012', 'Neurology'),
(4, 'MED-MAR-2018-3456', 'Oncology'),
(5, 'MED-TAN-2016-7890', 'Neurosurgery');

INSERT INTO Caregiving (Staff_ID, Ward, Grade)
VALUES 
(6, 'Ward A - Cardiology', 'Senior Nurse'),
(7, 'Ward B - Radiology', 'Nurse'),
(8, 'Ward C - Neurology', 'Head Nurse');

INSERT INTO Technical (Staff_ID, Modality, Certifications, Grade)
VALUES 
(9, 'MRI and CT Scan', 'Certified Radiologic Technologist', 'Senior Technician'),
(10, 'Ultrasound', 'Diagnostic Medical Sonographer', 'Technician');

INSERT INTO WorkIn (Staff_ID, DEP_ID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 2),
(7, 1),
(8, 3),
(9, 1),
(10, 1);

INSERT INTO ClinicalActivity (CAID, `Date`, `Time`, IID, Staff_ID, DEP_ID)
VALUES 
(1, '2025-10-15', '09:00:00', 1, 1, 1),
(2, '2025-10-16', '10:30:00', 2, 2, 2),
(3, '2025-10-17', '14:00:00', 3, 3, 3),
(4, '2025-10-18', '11:00:00', 4, 4, 4),
(5, '2025-10-20', '15:30:00', 5, 5, 5),
(6, '2025-10-22', '08:30:00', 1, 1, 1),
(7, '2025-10-25', '13:00:00', 3, 2, 2),
(8, '2025-10-16', '18:45:00', 2, 2, 2),
(9, '2025-10-17', '22:15:00', 3, 3, 3),
(10, '2025-10-20', '03:30:00', 5, 5, 5);

INSERT INTO Appointment (CAID, Reason, Status)
VALUES 
(1, 'X-Ray examination', 'scheduled'),
(2, 'ECG and heart checkup', 'completed'),
(3, 'Neurological assessment', 'scheduled'),
(4, 'Cancer screening', 'scheduled'),
(5, 'Pre-surgery consultation', 'cancelled'),
(6, 'Follow-up scan', 'scheduled'),
(7, 'Cardiac stress test', 'completed');

INSERT INTO Emergency (CAID, TriageLevel, Outcome)
VALUES 
(8, 'Level 2 - High Priority', 'Admitted to ICU'),
(9, 'Level 3 - Medium Priority', 'Treated and Released'),
(10, 'Level 1 - Critical', 'Transferred to Surgery');

-- Question 3.3 --
SELECT p.Name
FROM Patient p
JOIN ClinicalActivity ca ON p.IID = ca.IID
JOIN Appointment a ON ca.CAID = a.CAID
JOIN Department d ON ca.DEP_ID = d.DEP_ID
JOIN Hospital h ON d.HID = h.HID
WHERE h.City = 'Benguerir' AND a.Status = 'scheduled';

-- We Display the Results --
SHOW TABLES;
SELECT * FROM Patient; 
SELECT * FROM Staff;
SELECT * FROM Practitioner;
SELECT * FROM Caregiving;
SELECT * FROM Technical;
SELECT * FROM Hospital;
SELECT * FROM Department;
SELECT * FROM WorkIn;
SELECT * FROM ClinicalActivity;
SELECT * FROM Appointment;
SELECT * FROM Emergency;
