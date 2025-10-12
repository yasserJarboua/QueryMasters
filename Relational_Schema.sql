CREATE DATABASE IF NOT EXISTS my_database;
USE my_database;

CREATE TABLE IF NOT EXISTS Patient (
    IID INT PRIMARY KEY,
    CIN VARCHAR(20) UNIQUE
        CHECK (CHAR_LENGTH(CIN) BETWEEN 10 AND 20 AND REGEXP_LIKE(CIN, '^[A-Za-z0-9]+$')),
    Name VARCHAR(100) NOT NULL
        CHECK (CHAR_LENGTH(Name) >= 2 AND REGEXP_LIKE(Name, '^[A-Za-z ]+$')),
    Sex CHAR(1)
        CHECK (Sex IN ('M', 'F')),
    Birth DATE NOT NULL
        CHECK (Birth <= CURRENT_DATE),
    BloodGroup VARCHAR(5)
        CHECK (CHAR_LENGTH(BloodGroup) <= 5),
    Phone VARCHAR(10)
        CHECK (REGEXP_LIKE(Phone, '^[0-9]{10}$'))
);

CREATE TABLE IF NOT EXISTS Staff (
    STAFF_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
        CHECK (CHAR_LENGTH(Name) >= 2),
    Status VARCHAR(50)
);

CREATE TABLE Practitioner (
    Staff_ID INT PRIMARY KEY,
    LicenseNumber INT
        CHECK (LicenseNumber > 0),
    Specialty VARCHAR(50) NOT NULL
        CHECK (CHAR_LENGTH(Specialty) >= 3),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(STAFF_ID)
);


CREATE TABLE Caregiving (
    Staff_ID INT PRIMARY KEY,
    Ward VARCHAR(100)
        CHECK (CHAR_LENGTH(Ward) >= 2),
    Grade VARCHAR(100)
        CHECK (CHAR_LENGTH(Grade) >= 2),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(STAFF_ID)
);

CREATE TABLE Technical (
    Staff_ID INT PRIMARY KEY,
    Modality VARCHAR(100)
        CHECK (CHAR_LENGTH(Modality) >= 2),
    Certifications VARCHAR(100)
        CHECK (CHAR_LENGTH(Certifications) >= 3),
    Grade VARCHAR(100),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(STAFF_ID)
);

CREATE TABLE Hospital (
    HID INT PRIMARY KEY,
    Name VARCHAR(50),
    City VARCHAR(50),
    Region VARCHAR(50)
);

CREATE TABLE Department (
    DEP_ID INT PRIMARY KEY,
    Name VARCHAR(100)
        CHECK (CHAR_LENGTH(Name) >= 2),
    Specialty VARCHAR(100)
        CHECK (CHAR_LENGTH(Specialty) >= 2),
    HID INT NOT NULL,
    FOREIGN KEY (HID) REFERENCES Hospital(HID)
        ON DELETE CASCADE
);

CREATE TABLE WorkIn(
STAFF_ID INT,
DEP_ID INT ,
PRIMARY KEY (STAFF_ID, DEP_ID),
FOREIGN KEY (STAFF_ID) REFERENCES Staff(STAFF_ID),
FOREIGN KEY (DEP_ID) REFERENCES Department(DEP_ID)
);
CREATE TABLE ClinicalActivity (
    CAID INT PRIMARY KEY,
    Date DATE,
    Time TIME,
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
CREATE TABLE Appointment (
    CAID INT PRIMARY KEY,
    Reason VARCHAR(255),
    Status VARCHAR(50),
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);
CREATE TABLE Emergency(
    CAID INT PRIMARY KEY,
    TriageLevel VARCHAR(50),
    Outcome VARCHAR(50),
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);






