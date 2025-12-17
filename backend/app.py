from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()


from config import config_by_name
from extensions import mongo


# Import Blueprints
from routes.auth_routes import auth_bp
from routes.document_routes import document_bp
from routes.payment_routes import payment_bp
from routes.user_routes import user_bp

def create_app(config_name='default'):
    """Application factory pattern."""
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])

    # Initialize extensions
    CORS(app, origins=app.config['CORS_ORIGINS'])
    mongo.init_app(app)


    # Register Blueprints
    app.register_blueprint(auth_bp)
    app.register_blueprint(document_bp)
    app.register_blueprint(payment_bp)
    app.register_blueprint(user_bp)
    
    from routes.admin_routes import admin_bp
    app.register_blueprint(admin_bp)

    from routes.chat_routes import chat_bp
    app.register_blueprint(chat_bp)



    return app

if __name__ == '__main__':
    # Get config from environment variable or default to 'dev'
    config_name = 'dev' 
    app = create_app(config_name)
    app.run(host='13.62.49.69', port=5003, debug=True)