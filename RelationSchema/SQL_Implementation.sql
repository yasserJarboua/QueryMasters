CREATE DATABASE IF NOT EXISTS MNHS_DB;
USE MNHS_DB;

CREATE TABLE IF NOT EXISTS Patient (
    IID INT PRIMARY KEY,
    CIN VARCHAR(20) UNIQUE,
    Name VARCHAR(100) NOT NULL,
    Sex CHAR(1)
        CHECK (Sex IN ('M', 'F')),
    Birth DATE NOT NULL
        CHECK (Birth <= CURRENT_DATE),
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
    Date DATE NOT NULL,
    Time TIME NOT NULL,
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


INSERT INTO Hospital (HID, Name, City, Region)
VALUES 
(40, 'Hospital A', 'Benguerir', 'Region A'),
(50, 'Hospital B', 'Casablanca', 'Region B'),
(60, 'Hospital C', 'Rabat', 'Region C'),
(70, 'Hospital D', 'Marrakech', 'Region D'),
(80, 'Hospital E', 'Tangier', 'Region E');


INSERT INTO Patient (IID, CIN, Name, Sex, Birth, BloodGroup, Phone)
VALUES 
(1001, 'BB532415', 'Salma', 'F', '2006-04-14', 'O+', '0612452318'),
(1002, 'BJ234567', 'Hiba', 'F', '2006-06-26', 'O-', '0614567833'),
(1003, 'BH123456', 'Sara', 'F', '2006-07-26', 'A+', '0616234590'),
(1004, 'BH125457', 'Amine', 'M', '1982-07-26', 'A-', '0616224596'),
(1005, 'BJ113426', 'Mohammed', 'M', '1998-07-26', 'A+', '0617234594');

INSERT INTO Department (DEP_ID, Name, Specialty, HID)
VALUES 
(1, 'Radiology', 'Medical imaging', 40),       
(2, 'Cardiology', 'Cardiovascular Medicine', 50),
(3, 'Neurology', 'Brain and nervous system', 60),
(4, 'Oncology', 'Cancer Treatment', 70),
(5, 'Neurosurgery', 'Brain and Nervous System', 80);

SELECT p.Name
FROM Patient p
JOIN ClinicalActivity ca ON p.IID = ca.IID
JOIN Appointment a ON ca.CAID = a.CAID
JOIN Department d ON ca.DEP_ID = d.DEP_ID
JOIN Hospital h ON d.HID = h.HID
WHERE h.City = 'Benguerir' AND a.Status = 'scheduled';

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
