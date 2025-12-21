from flask import Blueprint, request, jsonify
from controllers.auth_controller import login_user, register_user

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    result = login_user(data.get('email'), data.get('password'))
    if "error" in result:
        return jsonify(result), 401
    return jsonify(result)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    # Validate input (basic)
    if not data or not data.get('email') or not data.get('password') or not data.get('name'):
        return jsonify({"error": "Missing required fields"}), 400
        
    result = register_user(data.get('name'), data.get('email'), data.get('password'), data.get('class_name'))
    if "error" in result:
        return jsonify(result), 400
    return jsonify(result), 201