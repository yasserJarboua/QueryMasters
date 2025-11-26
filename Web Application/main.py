import os
from dotenv import load_dotenv
from flask import Flask
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)

load_dotenv()

cfg = dict(
    host = os.getenv("MYSQL_HOST"),
    port=int(os.getenv("MYSQL_PORT", 3306)),
    database=os.getenv("MYSQL_DB"),
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD")
)

app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{cfg["user"]}:{cfg["password"]}@{cfg["host"]}/{cfg["database"]}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)


def list_patients_ordered_by_last_name(limit=20):
    query = """
    SELECT IID, FullName
    FROM Patient 
    ORDER BY SUBSTRING_INDEX(FullName, ' ', -1), FullName
    LIMIT :limit
    """
    result = db.session.execute(query, {"limit": limit})
    return result.fetchall()
        
def insert_patient(iid, cin, full_name, birth, sex, blood, phone):
    query = """
    INSERT INTO Patient(IID, CIN, FullName, Birth, Sex, BloodGroup, Phone)
    VALUES (%s , %s , %s , %s , %s , %s , %s )
    """
    
    try:
        db.session.execute(query)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        raise f"INSERTION FAILED: {e}"

def schedule_appointment(caid, iid, staff_id, dep_id, date_str, time_str, reason):
    ins_ca = db.text("""
        INSERT INTO ClinicalActivity(CAID, IID, STAFF_ID, DEP_ID, Date, Time)
        VALUES (:caid , :iid , :staff_id , :dep_id , :date_str , :date_str, :time_str)
    """)

    ins_appt = db.text("""
        INSERT INTO Appointment(CAID, Reason, Status)
        VALUES (:caid , :reason , 'Scheduled')
    """)
    try:
        db.session.execute(ins_ca)
        db.session.execute(ins_appt)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        raise f"OPERATION FAILED: {e}"

