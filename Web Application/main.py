import os
from dotenv import load_dotenv
from flask import Flask, render_template, jsonify, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from database import *

app = Flask(__name__)

init_db(app)

# ==================== PAGE ROUTES ====================

@app.route('/')
def dashboard():
    """Dashboard home page"""
    return render_template('dashboard.html')

@app.route('/patients')
def patients_page():
    """Patients list page"""
    return render_template('patients.html')

@app.route('/patients/add')
def add_patient_page():
    """Add new patient page"""
    return render_template('add_patient.html')

@app.route('/appointments/schedule')
def schedule_appointment_page():
    """Schedule appointment page"""
    return render_template('schedule_app.html')

@app.route('/staff/share')
def staff_share_page():
    """Staff analytics page"""
    return render_template('staff_share.html')

@app.route('/inventory/low-stock')
def low_stock_page():
    """Low stock inventory page"""
    return render_template('low_stock.html')

# ==================== DASHBOARD API ROUTES ====================

@app.route('/api/dashboard/stats')
def api_dashboard_stats():
    """Get dashboard statistics"""
    try:
        stats = get_dashboard_stats()
        return jsonify(stats)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/dashboard/recent-patients')
def api_recent_patients():
    """Get recent patients for dashboard"""
    try:
        limit = request.args.get('limit', 5, type=int)
        patients = get_recent_patients(limit)
        return jsonify(patients)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/dashboard/critical-stock')
def api_critical_stock():
    """Get critical stock items for dashboard"""
    try:
        limit = request.args.get('limit', 5, type=int)
        items = get_critical_stock_items(limit)
        return jsonify(items)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/dashboard/gender-distribution')
def api_gender_distribution():
    """Get gender distribution for pie chart"""
    try:
        data = get_gender_distribution()
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/dashboard/staff-distribution')
def api_staff_distribution():
    """Get staff distribution by department"""
    try:
        data = get_staff_distribution()
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/dashboard/stock-status')
def api_stock_status():
    """Get stock status distribution"""
    try:
        data = get_stock_status()
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/dashboard/appointments-trend')
def api_appointments_trend():
    """Get appointments trend by month"""
    try:
        months = request.args.get('months', 6, type=int)
        data = get_appointments_by_month(months)
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ==================== PATIENTS API ROUTES ====================

@app.route('/api/patients')
def api_patients():
    """Get list of patients"""
    try:
        limit = request.args.get('limit', 20, type=int)
        result = list_patients_ordered_by_last_name(limit)        
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/patients/add', methods=['POST'])
def api_add_patient():
    """Add a new patient"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['iid', 'cin', 'full_name', 'birth', 'sex', 'phone']
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({
                    "success": False,
                    "error": f"Missing required field: {field}"
                }), 400
        
        # Insert patient
        insert_patient(
            iid=data['iid'],
            cin=data['cin'],
            full_name=data['full_name'],
            birth=data['birth'],
            sex=data['sex'],
            blood=data.get('blood', ''),
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

# ==================== APPOINTMENTS API ROUTES ====================

@app.route('/api/appointments/schedule', methods=['POST'])
def api_schedule_appointment():
    """Schedule a new appointment"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['caid', 'iid', 'staff_id', 'dep_id', 'date_str', 'time_str', 'reason']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    "success": False,
                    "error": f"Missing required field: {field}"
                }), 400
        
        # Additional validation
        if not data['reason'] or len(data['reason'].strip()) < 10:
            return jsonify({
                "success": False,
                "error": "Reason must be at least 10 characters"
            }), 400
        
        # Schedule appointment
        schedule_appointment(
            caid=data['caid'],
            iid=data['iid'],
            staff_id=data['staff_id'],
            dep_id=data['dep_id'],
            date_str=data['date_str'],
            time_str=data['time_str'],
            reason=data['reason']
        )
        
        return jsonify({
            "success": True,
            "message": "Appointment scheduled successfully"
        }), 201
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 400

# ==================== STAFF API ROUTES ====================

@app.route('/api/staff/share')
def api_staff_share():
    """Get staff workload share analytics"""
    try:
        result = get_staff_share()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ==================== INVENTORY API ROUTES ====================

@app.route('/api/inventory/low-stock')
def api_low_stock():
    """Get low stock items"""
    try:
        result = get_low_stock()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ==================== ERROR HANDLERS ====================

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Resource not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    app.run(debug=True)