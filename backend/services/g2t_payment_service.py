import requests
import os

class G2TPayService:
    def __init__(self, api_key=None):
        # Load from env or use default (which is likely invalid/test)
        self.api_key = api_key or os.environ.get('G2T_PAY_API_KEY') or '54c2eaf1-7373-459e-8e7c-f484cc7dd3bb'
        self.base_url = 'https://g2tpay.net/api'

    def initiate_payment(self, amount, phone_number, operator, description):
        """
        Initiates a payment request.
        :param amount: Amount to charge
        :param phone_number: Customer phone number
        :param operator: 'MTN_CMR' or 'ORANGE_CMR'
        :param description: Payment description
        :return: JSON response from G2TPay
        """
        url = f"{self.base_url}/payments/initiate-sdk"
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        payload = {
            'apiKey': self.api_key,
            'amount': amount,
            'phoneNumber': phone_number,
            'operator': operator,
            'description': description
        }

        try:
            response = requests.post(url, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.HTTPError as err:
            # Try to get error message from response body
            try:
                error_data = response.json()
                msg = error_data.get('error') or error_data.get('message') or str(err)
                raise Exception(f"G2T API Error ({response.status_code}): {msg}")
            except ValueError:
                raise Exception(f"G2T API Error ({response.status_code}): {response.text or err}")
        except Exception as e:
            raise Exception(f"Payment Initiation Failed: {str(e)}")

    def check_status(self, message_id):
        """
        Checks the status of a payment.
        :param message_id: The ID returned by initiate_payment
        :return: JSON status
        """
        url = f"{self.base_url}/payments/status-by-message-id"
        params = {'messageId': message_id}
        headers = {'Accept': 'application/json'}

        try:
            response = requests.get(url, params=params, headers=headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.HTTPError as err:
             try:
                error_data = response.json()
                msg = error_data.get('error') or error_data.get('message') or str(err)
                raise Exception(f"G2T API Error ({response.status_code}): {msg}")
             except:
                raise Exception(f"G2T API Error ({response.status_code}): {response.text or err}")
        except Exception as e:
                raise Exception(f"Status Check Failed: {str(e)}")

# Singleton instance or helper functions
_service = G2TPayService()

def initiate_payment(amount, phone_number, operator, description):
    return _service.initiate_payment(amount, phone_number, operator, description)

def check_payment_status(message_id):
    return _service.check_status(message_id)
