import os
import re

class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'a-very-secret-key'
    CORS_ORIGINS = ["http://13.62.49.69:5003"]  # Production origins only
    MONGO_URI = os.environ.get('MONGO_URI') or "mongodb://localhost:27017/doc_ai_db"
    UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    # Allow all localhost and 127.0.0.1 ports, plus specific IPs for development
    CORS_ORIGINS = [
        re.compile(r"^http://localhost(:\d+)?$"),      # http://localhost or http://localhost:any_port
        re.compile(r"^http://127\.0\.0\.1(:\d+)?$"),   # http://127.0.0.1 or http://127.0.0.1:any_port
        "http://192.168.137.87:5003",                  # Local network IP
        "http://13.62.49.69:5003",
        "http://13.62.49.69:5004",                      # Production IP
    ]

class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False

config_by_name = {
    'dev': DevelopmentConfig,
    'prod': ProductionConfig,
    'default': DevelopmentConfig
}