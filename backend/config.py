import os

class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'a-very-secret-key'
    CORS_ORIGINS = ["http://localhost:3000", "http://127.0.0.1:3000", "http://192.168.137.87:5003"]
    MONGO_URI = os.environ.get('MONGO_URI') or "mongodb://localhost:27017/doc_ai_db"
    UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True

class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False

config_by_name = {
    'dev': DevelopmentConfig,
    'prod': ProductionConfig,
    'default': DevelopmentConfig
}