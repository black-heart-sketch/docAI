from flask import Blueprint, jsonify
from controllers.chat_controller import chat_document, chat_template

chat_bp = Blueprint('chat', __name__, url_prefix='/api/chat')

@chat_bp.route('/document', methods=['POST'])
def route_chat_document():
    result = chat_document()
    status = 200
    if "error" in result:
        status = 400 if result['error'] in ['Missing document_id or message', 'Document not found'] else 500
    return jsonify(result), status

@chat_bp.route('/template', methods=['POST'])
def route_chat_template():
    result = chat_template()
    status = 200
    if "error" in result:
         status = 400
    return jsonify(result), status
