from extensions import mongo
from werkzeug.security import generate_password_hash, check_password_hash

class User:
    VALID_CLASSES = ['BA1A', 'BA1B', 'BA1C', 'BA1D']
    
    def __init__(self, id, email, role, name, phone=None, bio=None, class_name=None):
        self.id = id
        self.email = email
        self.role = role
        self.name = name
        self.phone = phone
        self.bio = bio
        self.class_name = class_name

    def to_json(self):
        return {
            "id": self.id,
            "email": self.email,
            "role": self.role,
            "name": self.name,
            "phone": self.phone,
            "bio": self.bio,
            "class_name": self.class_name
        }

    @staticmethod
    def get_by_email(email):
        user_data = mongo.db.users.find_one({"email": email})
        if user_data:
            return User(
                user_data['id'], 
                user_data['email'], 
                user_data['role'], 
                user_data['name'],
                user_data.get('phone'),
                user_data.get('bio'),
                user_data.get('class_name')
            )
        return None

    @staticmethod
    def get_by_id(user_id):
        """Retrieves a user by ID."""
        user_data = mongo.db.users.find_one({"id": user_id})
        if user_data:
            return User(
                user_data['id'], 
                user_data['email'], 
                user_data['role'], 
                user_data['name'],
                user_data.get('phone'),
                user_data.get('bio'),
                user_data.get('class_name')
            )
        return None

    @staticmethod
    def update(user_id, updates):
        """Updates user profile information."""
        users_collection = mongo.db.users
        
        # Only allow updating specific fields
        allowed_fields = ['name', 'email', 'phone', 'bio', 'class_name', 'role']
        update_data = {k: v for k, v in updates.items() if k in allowed_fields}
        
        # Validate role if being updated
        if 'role' in update_data:
            valid_roles = ['student', 'class_prefect', 'admin']
            if update_data['role'] not in valid_roles:
                return False
        
        if not update_data:
            return False
        
        result = users_collection.update_one(
            {"id": user_id},
            {"$set": update_data}
        )
        return result.modified_count > 0

    @staticmethod
    def seed_users():
        """Seeds default admin and student users if not present."""
        users_collection = mongo.db.users
        
        # Admin
        if not users_collection.find_one({"email": "admin@docai.com"}):
            users_collection.insert_one({
                "id": "admin_1",
                "email": "admin@docai.com",
                "role": "admin",
                "name": "Admin User",
                "password": generate_password_hash("admin123")
            })

        # Student
        if not users_collection.find_one({"email": "student@docai.com"}):
            users_collection.insert_one({
                "id": "student_1",
                "email": "student@docai.com",
                "role": "student",
                "name": "Student User",
                "password": generate_password_hash("student123")
            })

    @staticmethod
    def create(name, email, password, role="student", class_name=None):
        """Creates a new user."""
        users_collection = mongo.db.users
        import uuid
        user_id = str(uuid.uuid4())
        hashed_password = generate_password_hash(password)
        
        user_doc = {
            "id": user_id,
            "email": email,
            "name": name,
            "role": role,
            "password": hashed_password
        }
        
        # Add class_name if provided and valid
        if class_name and class_name in User.VALID_CLASSES:
            user_doc["class_name"] = class_name
        
        users_collection.insert_one(user_doc)
        return User(user_id, email, role, name, class_name=class_name)

    @staticmethod
    def verify_credentials(email, password):
        """Verifies email and password."""
        user_data = mongo.db.users.find_one({"email": email})
        if user_data and check_password_hash(user_data['password'], password):
            return User(
                user_data['id'], 
                user_data['email'], 
                user_data['role'], 
                user_data['name'],
                user_data.get('phone'),
                user_data.get('bio'),
                user_data.get('class_name')
            )
        return None

    @staticmethod
    def get_all():
        """Retrieves all users."""
        users_cursor = mongo.db.users.find()
        return [User(
            u['id'], 
            u['email'], 
            u.get('role', 'student'), 
            u.get('name', 'Unknown'),
            u.get('phone'),
            u.get('bio'),
            u.get('class_name')
        ).to_json() for u in users_cursor]