from datetime import datetime
from extensions import mongo
from bson import ObjectId

class Receipt:
    collection_name = 'receipts'
    
    @staticmethod
    def get_all(user_class=None):
        """Get all receipts ordered by created_at descending, optionally filtered by class"""
        query = {}
        if user_class:
            query['user_class'] = user_class
        
        receipts = list(mongo.db[Receipt.collection_name].find(query).sort('created_at', -1))
        for receipt in receipts:
            receipt['_id'] = str(receipt['_id'])
        return receipts
    
    @staticmethod
    def get_by_user_id(user_id):
        """Get all receipts for a specific user"""
        receipts = list(mongo.db[Receipt.collection_name].find({'user_id': user_id}).sort('created_at', -1))
        for receipt in receipts:
            receipt['_id'] = str(receipt['_id'])
        return receipts
    
    @staticmethod
    def get_by_id(receipt_id):
        """Get receipt by ID"""
        try:
            receipt = mongo.db[Receipt.collection_name].find_one({'_id': ObjectId(receipt_id)})
            if receipt:
                receipt['_id'] = str(receipt['_id'])
            return receipt
        except:
            return None
    
    @staticmethod
    def create(receipt_data):
        """Create a new receipt (Idempotent)"""
        print(f"🔧 Creating receipt with data: {receipt_data}")
        
        # Check if receipt already exists
        existing_receipt = mongo.db[Receipt.collection_name].find_one({
            'receipt_number': receipt_data['receipt_number']
        })
        
        if existing_receipt:
            print(f"⚠️ Receipt #{receipt_data['receipt_number']} already exists. Returning existing receipt.")
            existing_receipt['_id'] = str(existing_receipt['_id'])
            return existing_receipt

        receipt = {
            'receipt_number': receipt_data['receipt_number'],
            'user_id': receipt_data['user_id'],
            'user_class': receipt_data.get('user_class'),
            'phone_number': receipt_data.get('phone_number'),
            'document_filename': receipt_data['document_filename'],
            'pages': receipt_data['pages'],
            'amount': receipt_data['amount'],
            'status': 'pending',
            'created_at': datetime.utcnow()
        }
        
        print(f"📦 Receipt object prepared: {receipt}")
        result = mongo.db[Receipt.collection_name].insert_one(receipt)
        receipt['_id'] = str(result.inserted_id)
        print(f"✅ Receipt inserted with ID: {receipt['_id']}")
        return receipt
    
    @staticmethod
    def update_status(receipt_id, new_status):
        """Update receipt status"""
        try:
            mongo.db[Receipt.collection_name].update_one(
                {'_id': ObjectId(receipt_id)},
                {'$set': {'status': new_status}}
            )
            return Receipt.get_by_id(receipt_id)
        except:
            return None
