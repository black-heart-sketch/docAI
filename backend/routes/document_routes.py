from flask import Blueprint, jsonify, request
from controllers.document_controller import get_all_templates, create_document, get_analysis_status, get_student_documents

document_bp = Blueprint('documents', __name__, url_prefix='/api')

@document_bp.route('/templates', methods=['GET'])
def get_templates():
    templates = get_all_templates()
    print(templates)
    return jsonify(templates)

@document_bp.route('/documents/upload', methods=['POST'])
def upload_document():
    print("DEBUG: /documents/upload endpoint hit")
    if request.is_json:
        print("DEBUG: Request is JSON")
        data = request.json
        print(f"DEBUG: JSON data: {data}")
        result = create_document(
            template_id=data.get('template_id'),
            student_id=data.get('student_id'),
            filename=data.get('filename')
        )
    else:
        print("DEBUG: Request is NOT JSON (likely Form Data)")
        file = request.files.get('file')
        template_id = request.form.get('template_id')
        student_id = request.form.get('student_id')
        print(f"DEBUG: Form data - Template ID: {template_id}, Student ID: {student_id}, File: {file}")
        
        result = create_document(
            template_id=template_id,
            student_id=student_id,
            file=file
        )
    return jsonify(result), 202


@document_bp.route('/analysis/status/<document_id>', methods=['GET'])
def analysis_status(document_id):
    result = get_analysis_status(document_id)
    if "error" in result:
        return jsonify(result), 404
    return jsonify(result)

@document_bp.route('/documents/user/<student_id>', methods=['GET'])
def get_user_documents(student_id):
    documents = get_student_documents(student_id)
    return jsonify(documents)

@document_bp.route('/documents/all', methods=['GET'])
def get_all_documents():
    """Admin endpoint to get all documents from all users."""
    from models.document import Document
    documents = Document.get_all()
    return jsonify(documents)