import os
from dotenv import load_dotenv
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from database import *

app = Flask(__name__)

load_dotenv()

init_db(app)


#The web application design code starts here