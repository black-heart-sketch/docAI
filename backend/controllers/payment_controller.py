from services.g2t_payment_service import initiate_payment as g2t_initiate_payment, check_payment_status
from models.document import Document
from models.template import Template
from models.pricing_tier import PricingTier
from models.system_config import SystemConfig

def start_payment_process(document_id, payment_type, phone_number, operator):
    """Initiates the payment process for a given document."""
    doc = Document.get_by_id(document_id)
    if not doc:
        return {"error": "Document not found"}, 404

    # Calculate Price
    # 1. Get Page Count
    pages = doc.page_count
    if not pages or pages < 1:
        pages = 1 # Default fallback
    
    # 2. Get Active Tier Price
    active_tier = PricingTier.get_active()
    # active_tier is an object, access attribute directly
    tier_price = active_tier.price_cents if active_tier else SystemConfig.get_print_price()
    
    # 3. Apply Formula: ((pages * tier_price) + 400) * 1.05
    base_price = (pages * tier_price) + 400
    total_amount = int(base_price * 1.05) 

    description = f"Print Doc {doc.filename} ({pages} pages)"

    try:
        result = g2t_initiate_payment(total_amount, phone_number, operator, description)
        return result, 200
    except Exception as e:
        return {"error": str(e)}, 500

def verify_payment(document_id, message_id):
    """Verifies payment status and updates document if paid."""
    try:
        status_data = check_payment_status(message_id)
        
        # Log for debugging
        print(f"DEBUG: Payment verification for {document_id}: {status_data}")

        # Check status field (assuming 'SUCCESSFUL' or 'SUCCESS')
        status = status_data.get('status')
        if status == 'SUCCESSFUL' or status == 'SUCCESS':
            Document.update(document_id, {'payment_status': 'paid'})
            return {"status": "paid", "details": status_data}, 200
        else:
             return {"status": status or 'pending', "details": status_data}, 200
             
    except Exception as e:
        return {"error": str(e)}, 500