import uuid

# Mock database for payments
PAYMENTS_DB = {}

def initiate_payment(document_id, amount):
    """Mocks creating a payment transaction."""
    payment_id = str(uuid.uuid4())
    PAYMENTS_DB[payment_id] = {
        "id": payment_id,
        "document_id": document_id,
        "status": "pending",
        "amount": amount
    }
    mock_payment_url = f"https://mock.campay.net/pay/{payment_id}"
    return {"payment_url": mock_payment_url, "payment_id": payment_id}

def confirm_payment(payment_id):
    """Mocks a successful payment confirmation (webhook)."""
    payment = PAYMENTS_DB.get(payment_id)
    if payment:
        payment['status'] = 'successful'
        return True
    return False