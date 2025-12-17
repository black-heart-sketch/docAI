from models.user import User

def login_user(email, password):
    """Authenticates a user and returns user data or an error."""
    # Ensure default users exist (optional, kept for dev convenience)
    User.seed_users()
    
    user = User.verify_credentials(email, password)
    
    if user:
         mock_token = f"mock-jwt-for-{user.id}"
         return {"token": mock_token, "user": user.to_json()}
            
    return {"error": "Invalid credentials"}

def register_user(name, email, password):
    """Registers a new user."""
    # Check if user already exists
    if User.get_by_email(email):
        return {"error": "User already exists"}
        
    new_user = User.create(name, email, password)
    mock_token = f"mock-jwt-for-{new_user.id}"
    return {"token": mock_token, "user": new_user.to_json()}