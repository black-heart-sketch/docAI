from flask import Blueprint, request, jsonify
from models.system_config import SystemConfig
from models.template import Template
from models.user import User
from models.pricing_tier import PricingTier

admin_bp = Blueprint('admin', __name__, url_prefix='/api/admin')

@admin_bp.route('/config', methods=['GET', 'POST']) # Renamed from /pricing but keeping logic
def manage_config():
    if request.method == 'POST':
        data = request.json
        price = data.get('price_cents')
        due_date = data.get('due_date')
        
        response = {}
        if price is not None:
            SystemConfig.set_print_price(price)
            response['price_cents'] = price
        if due_date is not None:
            SystemConfig.set_due_date(due_date)
            response['due_date'] = due_date
            
        return jsonify({"message": "Config updated successfully", "config": response})
    
    return jsonify({
        "price_cents": SystemConfig.get_print_price(),
        "due_date": SystemConfig.get_due_date()
    })

# Kept for backward compatibility if frontend calls it
@admin_bp.route('/pricing', methods=['GET', 'POST']) 
def manage_pricing_legacy():
    return manage_config()

@admin_bp.route('/templates', methods=['POST'])
def create_template():
    data = request.json
    template = Template(
        id=data.get('id'),
        name=data.get('name'),
        structure=data.get('structure')
    )
    Template.create(template.to_json())
    return jsonify({"message": "Template created", "template": template.to_json()})

@admin_bp.route('/templates/<template_id>', methods=['PUT'])
def update_template(template_id):
    data = request.json
    success = Template.update(template_id, data)
    if success:
        return jsonify({"message": "Template updated"})
    return jsonify({"error": "Failed to update"}), 400

@admin_bp.route('/templates/<template_id>', methods=['DELETE'])
def delete_template(template_id):
    success = Template.delete(template_id)
    if success:
        return jsonify({"message": "Template deleted"})
    return jsonify({"error": "Failed to delete"}), 400

@admin_bp.route('/users', methods=['GET'])
def get_users():
    return jsonify(User.get_all())

# --- Pricing Tiers ---
@admin_bp.route('/pricing-tiers', methods=['GET'])
def get_pricing_tiers():
    return jsonify(PricingTier.get_all())

@admin_bp.route('/pricing-tiers', methods=['POST'])
def create_pricing_tier():
    data = request.json
    new_tier = PricingTier.create(data)
    return jsonify({"message": "Tier created", "tier": new_tier})

@admin_bp.route('/pricing-tiers/<tier_id>', methods=['PUT'])
def update_pricing_tier(tier_id):
    data = request.json
    PricingTier.update(tier_id, data)
    return jsonify({"message": "Tier updated"})

@admin_bp.route('/pricing-tiers/<tier_id>', methods=['DELETE'])
def delete_pricing_tier(tier_id):
    PricingTier.delete(tier_id)
    return jsonify({"message": "Tier deleted"})

@admin_bp.route('/pricing-tiers/<tier_id>/activate', methods=['POST'])
def activate_pricing_tier(tier_id):
    PricingTier.set_active(tier_id)
    return jsonify({"message": "Tier activated"})
