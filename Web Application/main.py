import os
from dotenv import load_dotenv
from flask import Flask, render_template, jsonify, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from database import *

app = Flask(__name__)

init_db(app)


#The web application design code starts here

@app.route('/')
def base():
    return render_template('base.html')

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/patients')
def patients_page():
    return render_template('patients.html')

@app.route('/patients/add')
def add_patient_page():
    return render_template('add_patient.html')

@app.route('/staff/share')
def staff_share_page():
    return render_template('staff_share.html')

@app.route('/inventory/low-stock')
def low_stock_page():
    return render_template('low_stock.html')

# API Routes (return JSON data)
@app.route('/api/patients')
def api_patients():
    try:
        limit = request.args.get('limit', 20, type=int)
        result = list_patients_ordered_by_last_name(limit)        
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/patients/add', methods=['POST'])
def api_add_patient():
    try:
        data = request.get_json()
        
        insert_patient(
            iid=data['iid'],
            cin=data['cin'],
            full_name=data['full_name'],
            birth=data['birth'],
            sex=data['sex'],
            blood=data['blood'],
            phone=data['phone']
        )
        
        return jsonify({
            "success": True,
            "message": "Patient added successfully"
        }), 201
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 400

@app.route('/api/staff/share')
def api_staff_share():
    try:
        result = get_staff_share()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/inventory/low-stock')
def api_low_stock():
    try:
        result = get_low_stock()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/dashboard/stats")
def api_dashboard_stats():
    try:
        stats = get_dashboard_stats()
        return jsonify(stats)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# === Recent Patients ===
@app.route("/api/dashboard/recent-patients")
def api_recent_patients():
    try:
        limit = request.args.get("limit", 5, type=int)
        patients = get_recent_patients(limit)
        return jsonify(patients)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# === Critical Low Stock Items ===
@app.route("/api/dashboard/critical-stock")
def api_critical_stock():
    try:
        limit = request.args.get("limit", 5, type=int)
        items = get_critical_stock_items(limit)
        return jsonify(items)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)