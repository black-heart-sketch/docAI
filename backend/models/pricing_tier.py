from extensions import mongo
import uuid

class PricingTier:
    def __init__(self, id, name, price_cents, due_date, is_active=False):
        self.id = id
        self.name = name
        self.price_cents = price_cents
        self.due_date = due_date
        self.is_active = is_active

    def to_json(self):
        return {
            "id": self.id,
            "name": self.name,
            "price_cents": self.price_cents,
            "due_date": self.due_date,
            "is_active": self.is_active
        }

    @staticmethod
    def get_all():
        """Retrieves all pricing tiers."""
        tiers_cursor = mongo.db.pricing_tiers.find()
        return [PricingTier(t['id'], t['name'], t['price_cents'], t.get('due_date'), t.get('is_active', False)).to_json() for t in tiers_cursor]

    @staticmethod
    def get_active():
        """Retrieves the currently active pricing tier."""
        tier_data = mongo.db.pricing_tiers.find_one({"is_active": True})
        if not tier_data:
            return None
        return PricingTier(
            tier_data['id'], 
            tier_data['name'], 
            tier_data['price_cents'], 
            tier_data.get('due_date'), 
            tier_data.get('is_active')
        )

    @staticmethod
    def create(data):
        """Creates a new pricing tier."""
        tier_id = str(uuid.uuid4())
        new_tier = {
            "id": tier_id,
            "name": data['name'],
            "price_cents": int(data['price_cents']),
            "due_date": data.get('due_date'),
            "is_active": False # Default to inactive
        }
        mongo.db.pricing_tiers.insert_one(new_tier)
        if '_id' in new_tier:
            del new_tier['_id']
        return new_tier

    @staticmethod
    def update(tier_id, data):
        """Updates a pricing tier."""
        if 'id' in data:
            del data['id']
        mongo.db.pricing_tiers.update_one({"id": tier_id}, {"$set": data})
        return True
    
    @staticmethod
    def delete(tier_id):
        """Deletes a pricing tier."""
        # Prevent deleting the active tier? Or handle it? For now allow, but might leave system with no active price.
        mongo.db.pricing_tiers.delete_one({"id": tier_id})
        return True

    @staticmethod
    def set_active(tier_id):
        """Sets one tier as active and deactivates all others."""
        # 1. Deactivate all
        mongo.db.pricing_tiers.update_many({}, {"$set": {"is_active": False}})
        # 2. Activate specific
        mongo.db.pricing_tiers.update_one({"id": tier_id}, {"$set": {"is_active": True}})
        return True
