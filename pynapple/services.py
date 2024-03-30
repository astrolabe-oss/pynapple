import json
from pynapple.models import Pynapple


class PynappleService:
    def __init__(self, db, redis):
        self.db = db
        self.redis = redis

    def get_pynapples(self):
        # Check cache first
        cached_pynapples = self.redis.get('pynapples')
        if cached_pynapples:
            return json.loads(cached_pynapples), 'cache'

        # Fall back to database if not in cache
        pynapples = Pynapple.query.all()
        pynapples_list = [pynapple.to_dict() for pynapple in pynapples]
        self.redis.set('pynapples', json.dumps(pynapples_list), ex=60)  # Refresh cache
        return pynapples_list, 'db'

    def add_pynapple(self, ripeness, selfie):
        new_pynapple = Pynapple(ripeness=ripeness, selfie=selfie)
        self.db.session.add(new_pynapple)
        self.db.session.commit()
        self.invalidate_cache()  # Invalidate cache after adding a new entry
        return new_pynapple.to_dict()

    def get_pynapple_by_id(self, id):
        return Pynapple.query.get_or_404(id).to_dict()

    def invalidate_cache(self):
        self.redis.delete('pynapples')
