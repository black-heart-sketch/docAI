import uuid
import os
from flask import current_app
from werkzeug.utils import secure_filename
from models.document import Document
from models.template import Template
from services.ai_service import analyze_document

# Mock database for templates (Removed in favor of MongoDB)
# TEMPLATES_DB = [...]

def get_all_templates():
    """Returns a list of all available document templates."""
    return Template.get_all()


def create_document(template_id, student_id, file=None, filename=None):
    """Creates a new document record, saves file if present, and triggers analysis."""
    doc_id = str(uuid.uuid4())
    file_path = None
    
    print(f"DEBUG: create_document called. Template ID: {template_id}, Student ID: {student_id}")
    
    if file:
        print(f"DEBUG: File object received: {file.filename}")
        filename = secure_filename(file.filename)
        upload_folder = current_app.config['UPLOAD_FOLDER']
        print(f"DEBUG: Upload folder: {upload_folder}")
        
        if not os.path.exists(upload_folder):
            print("DEBUG: Upload folder does not exist. Creating it.")
            os.makedirs(upload_folder)
            
        file_path = os.path.join(upload_folder, f"{doc_id}_{filename}")
        print(f"DEBUG: Saving file to: {file_path}")
        try:
            file.save(file_path)
            print("DEBUG: File saved successfully.")
        except Exception as e:
             print(f"ERROR: Failed to save file: {e}")
             return {"error": f"Failed to save file: {e}"}
             
    elif filename:
         print(f"DEBUG: Only filename provided (legacy/mock): {filename}")
    else:
        print("DEBUG: No file or filename provided.")

    new_doc = Document(
        id=doc_id,
        student_id=student_id,
        template_id=template_id,
        filename=filename,
        file_path=file_path
    )
    
    # Save to MongoDB
    # Create the document first with 'pending' status
    print("DEBUG: Creating document record in MongoDB.")
    Document.create(new_doc.to_json())

    # Fetch the template structure
    print(f"DEBUG: Fetching template {template_id}")
    template = Template.get_by_id(template_id)
    template_structure = template['structure'] if template else []
    print(f"DEBUG: Template structure found: {len(template_structure)} sections")

    # Trigger the REAL AI analysis
    try:
        if file_path:
            print("DEBUG: Starting AI analysis...")
            analysis_result = analyze_document(doc_id, file_path, template_structure)
            print(f"DEBUG: AI analysis result received. Status: {analysis_result.get('analysis_status')}")
            
            # Update Document with results
            if "error" in analysis_result:
                print(f"ERROR: Analysis returned error: {analysis_result['error']}")
                Document.update_status(doc_id, "failed", result=analysis_result)
            else:
                 # Extract the inner result if nested (depending on service return structure)
                 final_result = analysis_result.get('analysis_result', analysis_result)
                 # Inject page_count into result for frontend access
                 final_result['page_count'] = analysis_result.get('page_count', 1)
                 
                 # Update status and page count
                 Document.update_status(doc_id, "completed", result=final_result)
                 if 'page_count' in analysis_result:
                     Document.update(doc_id, {'page_count': analysis_result['page_count']})
                 
                 print("DEBUG: Document status updated to completed.")
        else:
            print("ERROR: No file path available for analysis.")
            Document.update_status(doc_id, "failed", result={"error": "No file provided for analysis"})

    except Exception as e:
        print(f"ERROR: Controller Exception during analysis: {e}")
        Document.update_status(doc_id, "failed", result={"error": str(e)})
    
    return {"message": "Upload successful, analysis completed.", "document_id": doc_id}

def get_analysis_status(document_id):
    """Gets the current status of a document's analysis."""
    # Try fetching from DB first
    doc = Document.get_by_id(document_id)
    
    if doc:
         return {
            "status": doc.analysis_status,
            "result": doc.analysis_result
        }
    
    return {"error": "Document not found"}

def get_student_documents(student_id):
    """Retrieves all documents for a specific student."""
    docs = Document.get_by_student(student_id)
    return [doc.to_json() for doc in docs]