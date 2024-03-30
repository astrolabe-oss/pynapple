from flask_sqlalchemy import SQLAlchemy
from redis import Redis

from pynapple.config import DevelopmentConfig
from pynapple.flask_app import app

db = SQLAlchemy(app)
redis = Redis(host=DevelopmentConfig.REDIS_HOST)


class Pynapple(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    ripeness = db.Column(db.Integer, nullable=False)
    selfie = db.Column(db.String(4), nullable=False)  # Assuming 1-4 length for an emoji

    def to_dict(self):
        return {'id': self.id, 'ripeness': self.ripeness, 'selfie': self.selfie}


with app.app_context():
    db.create_all()
