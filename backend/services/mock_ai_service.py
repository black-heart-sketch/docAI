import time
import uuid

# Mock database for documents
DOCUMENTS_DB = {}

def simulate_ai_analysis(document_id):
    """Simulates a long-running AI analysis task."""
    print(f"AI Service: Starting analysis for document {document_id}...")
    time.sleep(5)  # Simulate 5 seconds of work

    if document_id in DOCUMENTS_DB:
        DOCUMENTS_DB[document_id]['analysis_status'] = 'completed'
        DOCUMENTS_DB[document_id]['analysis_result'] = {
            "accuracy_score": 85.5,
            "feedback": {
                "Abstract": {"status": "found", "score": 100},
                "Introduction": {"status": "found", "score": 75, "notes": "Missing subheading."},
                "Literature Review": {"status": "missing", "score": 0}
            }
        }
    print(f"AI Service: Analysis for document {document_id} completed.")
    return DOCUMENTS_DB.get(document_id)

def get_document_status(document_id):
    return DOCUMENTS_DB.get(document_id)