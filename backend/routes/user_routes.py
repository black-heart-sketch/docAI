from flask import Blueprint, request, jsonify
from models.user import User

user_bp = Blueprint('users', __name__, url_prefix='/api/users')

@user_bp.route('/<user_id>', methods=['PUT'])
def update_user(user_id):
    """Update user profile information."""
    data = request.json
    
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    # Update the user
    success = User.update(user_id, data)
    
    if success:
        # Return updated user data
        user = User.get_by_id(user_id)
        if user:
            return jsonify(user.to_json()), 200
        return jsonify({"message": "User updated successfully"}), 200
    else:
        return jsonify({"error": "Failed to update user"}), 400
