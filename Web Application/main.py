import os
from dotenv import load_dotenv
from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from database import *

app = Flask(__name__)

load_dotenv()

init_db(app)


#The web application design code starts here

@app.route('/')
def index():
    res = get_staff_share()
    return res

if __name__ == '__main__':
    app.run(debug=True)