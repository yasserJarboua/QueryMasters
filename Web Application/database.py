import os
from dotenv import load_dotenv
from flask_sqlalchemy import SQLAlchemy

load_dotenv()

db = SQLAlchemy()

def get_database_config():
    """Returns database configuration from environment variables"""
    return dict(
        host=os.getenv("MYSQL_HOST"),
        port=int(os.getenv("MYSQL_PORT", 3306)),
        database=os.getenv("MYSQL_DB"),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD")
    )

def init_db(app):
    """Initialize database with Flask app"""
    cfg = get_database_config()
    app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{cfg["user"]}:{cfg["password"]}@{cfg["host"]}/{cfg["database"]}'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)
    return db

def list_patients_ordered_by_last_name(limit=20):
    query = db.text("""
    SELECT IID, FullName
    FROM Patient 
    ORDER BY SUBSTRING_INDEX(FullName, ' ', -1), FullName
    LIMIT :limit
    """)
    result = db.session.execute(query, {"limit": limit})
    return result.fetchall()
        
def insert_patient(iid, cin, full_name, birth, sex, blood, phone):
    query = db.text("""
    INSERT INTO Patient(IID, CIN, FullName, Birth, Sex, BloodGroup, Phone)
    VALUES (:iid, :cin, :full_name, :birth, :sex, :blood, :phone)
    """)
    
    try:
        db.session.execute(query, {
            "iid": iid,
            "cin": cin,
            "full_name": full_name,
            "birth": birth,
            "sex": sex,
            "blood": blood,
            "phone": phone
        })
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        raise Exception(f"INSERTION FAILED: {e}")

def schedule_appointment(caid, iid, staff_id, dep_id, date_str, time_str, reason):
    ins_ca = db.text("""
        INSERT INTO ClinicalActivity(CAID, IID, STAFF_ID, DEP_ID, Date, Time)
        VALUES (:caid, :iid, :staff_id, :dep_id, :date_str, :time_str)
    """)

    ins_appt = db.text("""
        INSERT INTO Appointment(CAID, Reason, Status)
        VALUES (:caid, :reason, 'Scheduled')
    """)
    try:
        db.session.execute(ins_ca, {
            "caid": caid,
            "iid": iid,
            "staff_id": staff_id,
            "dep_id": dep_id,
            "date_str": date_str,
            "time_str": time_str
        })
        db.session.execute(ins_appt, {
            "caid": caid,
            "reason": reason
        })
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        raise Exception(f"OPERATION FAILED: {e}")

def get_low_stock():
    query = db.text("""
        SELECT
            h.HID,
            h.Name AS HospitalName,
            m.MID,
            m.Name AS MedicationName,
            COALESCE(s.Qty, 0) AS Quantity,
            COALESCE(s.ReorderLevel, 10) AS ReorderLevel
        FROM Medication m
        LEFT JOIN Stock s ON s.MID = m.MID
        JOIN Hospital h ON s.HID = h.HID
        WHERE COALESCE(s.Qty, 0) < COALESCE(s.ReorderLevel, 10)
        ORDER BY h.HID, m.Name
    """)
    try:
        result = db.session.execute(query)
        return result.fetchall()
    except Exception as e:
        db.session.rollback()
        raise Exception(f"Operation Failed: {e}")


def get_staff_share():
    query = db.text("""
    WITH staff_hosp AS (
        SELECT S.FullName, d.HID, COUNT(*) AS n,h.Name as HName
        FROM Appointment a
        JOIN ClinicalActivity c ON c.CAID = a.CAID
        JOIN Department d ON d.DEP_ID = c.DEP_ID
        JOIN Staff S ON S.STAFF_ID=c.STAFF_ID
        JOIN Hospital h ON h.HID=d.HID
        GROUP BY c.STAFF_ID, d.HID
    ),
    hosp_tot AS (
        SELECT d.HID, COUNT(*) AS n
        FROM Appointment a
        JOIN ClinicalActivity c ON c.CAID = a.CAID
        JOIN Department d ON d.DEP_ID = c.DEP_ID
        GROUP BY d.HID
    )

    SELECT sh.FullName, sh.HID, sh.n AS TotalAppointments,sh.HName,
    ROUND(100 * sh.n / ht.n, 2) AS PctOfHospital
    
    FROM staff_hosp sh
    JOIN hosp_tot ht ON ht.HID = sh.HID;
    GROUP BY sh.HID
    ORDER BY PctOfHospital DESC
    """)
    try:
        result = db.session.execute(query)
        return result.fetchall()
    except Exception as e:
        db.session.rollback()
        raise Exception(f"Operation Failed: {e}")