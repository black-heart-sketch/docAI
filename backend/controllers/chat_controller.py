from flask import request, jsonify
from services.chat_service import chat_with_document_context, chat_with_template_context
from models.document import Document
from models.template import Template
from extensions import mongo

def chat_document():
    data = request.json
    document_id = data.get('document_id')
    user_message = data.get('message')
    history = data.get('history', [])
    
    if not document_id or not user_message:
        return {"error": "Missing document_id or message"}
    
    # Retrieve document to get file path
    doc = Document.get_by_id(document_id)
    if not doc:
        return {"error": "Document not found"}
        
    if not doc.file_path:
        return {"error": "Document file path is missing"}
        
    return chat_with_document_context(doc.file_path, history, user_message)

def chat_template():
    data = request.json
    template_id = data.get('template_id')
    user_message = data.get('message')
    history = data.get('history', [])
    
    print(f"[DEBUG] chat_template called with template_id: {template_id}, message: {user_message}")
    
    if not template_id or not user_message:
        return {"error": "Missing template_id or message"}
        
    template = Template.get_by_id(template_id)
    if not template:
        print(f"[DEBUG] Template not found: {template_id}")
        return {"error": "Template not found"}
    
    print(f"[DEBUG] Template found, calling chat service...")
    result = chat_with_template_context(template['structure'], history, user_message)
    print(f"[DEBUG] Chat service result: {result}")
    return result
