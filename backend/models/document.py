from extensions import mongo
from datetime import datetime

class Document:
    def __init__(self, id, student_id, template_id, filename, file_path=None, analysis_status='pending', payment_status='unpaid', analysis_result=None, created_at=None, page_count=0):
        self.id = id
        self.student_id = student_id
        self.template_id = template_id
        self.filename = filename
        self.file_path = file_path
        self.analysis_status = analysis_status
        self.payment_status = payment_status
        self.analysis_result = analysis_result
        self.created_at = created_at or datetime.utcnow()
        self.page_count = page_count

    def to_json(self):
        return {
            "id": self.id,
            "student_id": self.student_id,
            "template_id": self.template_id,
            "filename": self.filename,
            "file_path": self.file_path,
            "analysis_status": self.analysis_status,
            "payment_status": self.payment_status,
            "analysis_result": self.analysis_result,
            "created_at": self.created_at.isoformat() if hasattr(self.created_at, 'isoformat') else self.created_at,
            "page_count": self.page_count
        }

    @staticmethod
    def create(doc_data):
        mongo.db.documents.insert_one(doc_data)
        return doc_data

    @staticmethod
    def get_by_id(doc_id):
        doc_data = mongo.db.documents.find_one({"id": doc_id})
        if not doc_data:
            return None
        return Document(
            id=doc_data['id'],
            student_id=doc_data['student_id'],
            template_id=doc_data['template_id'],
            filename=doc_data['filename'],
            file_path=doc_data.get('file_path'),
            analysis_status=doc_data['analysis_status'],
            payment_status=doc_data['payment_status'],
            analysis_result=doc_data.get('analysis_result'),
            created_at=doc_data.get('created_at'),
            page_count=doc_data.get('page_count', 0)
        )

    @staticmethod
    def update(doc_id, update_data):
        mongo.db.documents.update_one({"id": doc_id}, {"$set": update_data})

    @staticmethod
    def update_status(doc_id, status, result=None):
        update_data = {"analysis_status": status}
        if result:
            update_data["analysis_result"] = result
        mongo.db.documents.update_one({"id": doc_id}, {"$set": update_data})

    @staticmethod
    def get_by_student(student_id):
        cursor = mongo.db.documents.find({"student_id": student_id}).sort("created_at", -1)
        documents = []
        for doc_data in cursor:
            documents.append(Document(
                id=doc_data['id'],
                student_id=doc_data['student_id'],
                template_id=doc_data['template_id'],
                filename=doc_data['filename'],
                file_path=doc_data.get('file_path'),
                analysis_status=doc_data['analysis_status'],
                payment_status=doc_data['payment_status'],
                analysis_result=doc_data.get('analysis_result'),
                created_at=doc_data.get('created_at'),
                page_count=doc_data.get('page_count', 0)
            ))
        return documents

    @staticmethod
    def get_all():
        """Get all documents from all users with user info."""
        cursor = mongo.db.documents.find().sort("created_at", -1)
        documents = []
        for doc_data in cursor:
            # Get user info
            user = mongo.db.users.find_one({"id": doc_data['student_id']})
            doc_json = Document(
                id=doc_data['id'],
                student_id=doc_data['student_id'],
                template_id=doc_data['template_id'],
                filename=doc_data['filename'],
                file_path=doc_data.get('file_path'),
                analysis_status=doc_data['analysis_status'],
                payment_status=doc_data['payment_status'],
                analysis_result=doc_data.get('analysis_result'),
                created_at=doc_data.get('created_at'),
                page_count=doc_data.get('page_count', 0)
            ).to_json()
            # Add user info to document
            if user:
                doc_json['user_name'] = user.get('name', 'Unknown')
                doc_json['user_email'] = user.get('email', 'N/A')
                doc_json['user_class'] = user.get('class_name', '')
            else:
                doc_json['user_name'] = 'Unknown'
                doc_json['user_email'] = 'N/A'
                doc_json['user_class'] = ''
            documents.append(doc_json)
        return documents