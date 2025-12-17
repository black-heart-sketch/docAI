from extensions import mongo

class Template:
    def __init__(self, id, name, structure=None):
        self.id = id
        self.name = name
        self.structure = structure or []

    def to_json(self):
        return {
            "id": self.id,
            "name": self.name,
            "structure": self.structure
        }

    @staticmethod
    def get_all():
        """Retrieves all templates from the database. Seeds defaults if empty."""
        templates_collection = mongo.db.templates
        templates_cursor = templates_collection.find()
        templates = list(templates_cursor)
        
        if not templates:
            # Seed default templates if DB is empty
            default_templates = [
                {
                    "id": "t1", 
                    "name": "Computer Science Thesis Proposal", 
                    "structure": [
                        {"section": "Title Page", "content": "Project Title, Author Name, Date"},
                        {"section": "Abstract", "content": "Summary of the project proposal"},
                        {"section": "Introduction", "content": "Background, Problem Statement, Objectives"},
                        {"section": "Methodology", "content": "Proposed approach, tools, and techniques"},
                        {"section": "Timeline", "content": "Estimated schedule of work"},
                        {"section": "References", "content": "List of cited works"}
                    ]
                },
                {
                    "id": "t2", 
                    "name": "Business Plan Report", 
                    "structure": [
                         {"section": "Executive Summary", "content": "Overview of the business plan"},
                         {"section": "Market Analysis", "content": "Target market, competition, analysis"},
                         {"section": "Marketing Strategy", "content": "Plan for reaching customers"},
                         {"section": "Financial Plan", "content": "Budget, projections, funding needs"}
                    ]
                }
            ]
            templates_collection.insert_many(default_templates)
            templates = default_templates
        
        return [Template(t['id'], t['name'], t.get('structure')).to_json() for t in templates]
    
    @staticmethod
    def create(template_data):
        """Creates a new template."""
        mongo.db.templates.insert_one(template_data)
        return template_data

    @staticmethod
    def get_by_id(template_id):
        """Retrieves a template by ID."""
        template_data = mongo.db.templates.find_one({"id": template_id})
        if not template_data:
            return None
        return Template(
            template_data['id'], 
            template_data['name'], 
            template_data.get('structure')
        ).to_json()

    @staticmethod
    def update(template_id, data):
        """Updates an existing template."""
        if 'id' in data:
            del data['id'] # Prevent ID update
        mongo.db.templates.update_one({"id": template_id}, {"$set": data})
        return True

    @staticmethod
    def delete(template_id):
        """Deletes a template."""
        mongo.db.templates.delete_one({"id": template_id})
        return True