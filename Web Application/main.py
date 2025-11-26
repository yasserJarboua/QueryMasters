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