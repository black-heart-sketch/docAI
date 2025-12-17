from flask import Blueprint, request, jsonify
from controllers.payment_controller import start_payment_process

payment_bp = Blueprint('payments', __name__, url_prefix='/api/payments')

@payment_bp.route('/initiate', methods=['POST'])
def initiate():
    data = request.json
    result, status_code = start_payment_process(
        data.get('document_id'), 
        data.get('type'),
        data.get('phone_number'),
        data.get('operator')
    )
    return jsonify(result), status_code

@payment_bp.route('/verify', methods=['POST'])
def verify():
    data = request.json
    # Verify G2T payment status
    from controllers.payment_controller import verify_payment
    result, status_code = verify_payment(data.get('document_id'), data.get('message_id'))
    return jsonify(result), status_code

# Legacy/Mock (Optional, keeping so we don't break simple tests if needed, but logic is shifted)
@payment_bp.route('/mock-success/<payment_id>', methods=['POST'])
def mock_success(payment_id):
     return jsonify({"status": "deprecated"}), 200