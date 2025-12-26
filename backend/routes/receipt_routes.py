from flask import Blueprint, request, jsonify
from models.receipt import Receipt
from models.user import User

receipt_routes = Blueprint('receipt_routes', __name__, url_prefix='/api')

@receipt_routes.route('/receipts', methods=['POST'])
def create_receipt():
    """Create a new payment receipt"""
    try:
        data = request.get_json()
        print(f"📝 Receipt creation request: {data}")
        
        # Validate required fields
        required_fields = ['receipt_number', 'user_id', 'document_filename', 'pages', 'amount']
        for field in required_fields:
            if field not in data:
                print(f"❌ Missing field: {field}")
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        print("✅ Creating receipt...")
        # Create receipt
        receipt = Receipt.create(data)
        print(f"✅ Receipt created: {receipt.get('_id')}")
        
        return jsonify({
            'message': 'Receipt created successfully',
            'receipt': receipt
        }), 201
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


@receipt_routes.route('/receipts/user/<user_id>', methods=['GET'])
def get_user_receipts(user_id):
    """Get all receipts for a specific user"""
    try:
        receipts = Receipt.get_by_user_id(user_id)
        return jsonify({'receipts': receipts}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@receipt_routes.route('/receipts/all', methods=['GET'])
def get_all_receipts():
    """Get all receipts (admin only), optionally filtered by class"""
    try:
        user_class = request.args.get('class')
        receipts = Receipt.get_all(user_class=user_class)
        return jsonify({'receipts': receipts}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@receipt_routes.route('/receipts/<receipt_id>/validate', methods=['PUT'])
def validate_receipt(receipt_id):
    """Validate a receipt (admin only)"""
    try:
        receipt = Receipt.update_status(receipt_id, 'validated')
        if not receipt:
            return jsonify({'error': 'Receipt not found'}), 404
        
        return jsonify({
            'message': 'Receipt validated successfully',
            'receipt': receipt
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@receipt_routes.route('/receipts/<receipt_id>/reject', methods=['PUT'])
def reject_receipt(receipt_id):
    """Reject a receipt (admin only)"""
    try:
        receipt = Receipt.update_status(receipt_id, 'rejected')
        if not receipt:
            return jsonify({'error': 'Receipt not found'}), 404
        
        return jsonify({
            'message': 'Receipt rejected successfully',
            'receipt': receipt
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
