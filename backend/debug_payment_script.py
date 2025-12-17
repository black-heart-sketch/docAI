import sys
import os
from dotenv import load_dotenv

# Add current directory to path
sys.path.append(os.getcwd())

# Load env vars
load_dotenv()

print("--- Starting Payment Debug Script ---")

# Check API Key from Env
api_key_env = os.environ.get('G2T_PAY_API_KEY')
if not api_key_env:
    print("WARNING: G2T_PAY_API_KEY is not set in environment variables.")
else:
    masked_key = api_key_env[:4] + "*" * (len(api_key_env) - 8) + api_key_env[-4:] if len(api_key_env) > 8 else "****"
    print(f"Environment API Key found: {masked_key}")

# Import service
try:
    from services.g2t_payment_service import initiate_payment, G2TPayService
    print("Successfully imported initiate_payment")
except ImportError as e:
    print(f"CRITICAL: Failed to import service: {e}")
    sys.exit(1)

# Inspect Service Instance Key
try:
    service = G2TPayService()
    service_key = service.api_key
    masked_service_key = service_key[:4] + "*" * (len(service_key) - 8) + service_key[-4:] if service_key and len(service_key) > 8 else "****"
    print(f"Service initialized with API Key: {masked_service_key}")
except Exception as e:
    print(f"Error inspecting service instance: {e}")


# Test Data
amount = 500
phone = "677554433"
operator = "MTN_CMR"
description = "Debug Payment Script"

print(f"\nInitiating payment with:")
print(f"  Amount: {amount}")
print(f"  Phone: {phone}")
print(f"  Operator: {operator}")

try:
    print("\nSending request to G2T API...")
    result = initiate_payment(amount, phone, operator, description)
    print("\n✅ SUCCESS: Payment initiated successfully!")
    print("Response Data:")
    print(result)
except Exception as e:
    print("\n❌ FAILED: Payment initiation failed.")
    print(f"Error Details: {str(e)}")
    # Print specific help if 403
    if "403" in str(e):
        print("\n[!] 403 Forbidden indicates the API Key is invalid or not authorized for this endpoint.")
    
print("\n--- End of Script ---")
