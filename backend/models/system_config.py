from extensions import mongo
from models.pricing_tier import PricingTier

class SystemConfig:
    @staticmethod
    def get_print_price():
        """Retrieves the global print price in cents from active tier."""
        # Try to get active tier first
        active_tier = PricingTier.get_active()
        if active_tier:
            return active_tier.price_cents
        
        # Fallback to legacy system_config if no active tier
        config = mongo.db.system_config.find_one({"key": "print_price"})
        if not config:
            return 500 # Default
        return config['value']

    @staticmethod
    def set_print_price(price_cents):
        """Updates the global print price (LEGACY SUPPORT)."""
        # Kept for backward compatibility if needed, but Admin UI will switch to Tiers
        mongo.db.system_config.update_one(
            {"key": "print_price"},
            {"$set": {"value": price_cents}},
            upsert=True
        )

    @staticmethod
    def get_due_date():
        """Retrieves the printing due date from active tier."""
        # Try active tier
        active_tier = PricingTier.get_active()
        if active_tier:
            return active_tier.due_date

        config = mongo.db.system_config.find_one({"key": "due_date"})
        if not config:
            return None
        return config['value']

    @staticmethod
    def set_due_date(due_date):
        """Updates the printing due date (LEGACY SUPPORT)."""
        mongo.db.system_config.update_one(
            {"key": "due_date"},
            {"$set": {"value": due_date}},
            upsert=True
        )

