import json
import logging
from pynapple.models import Pynapple
from pynapple.config import Config
logger = logging.getLogger(__name__)


class PynappleService:
    def __init__(self, db, cache_client):
        self.db = db
        self.cache_client = cache_client
        self.request_count = 0
        self.cache_refresh_threshold = Config.CACHE_REFRESH_THRESHOLD  # Load the threshold from configuration

    def get_pynapples(self):
        self.request_count += 1
        if self.request_count >= self.cache_refresh_threshold:
            logger.info(f"Cache refresh threshold ({self.cache_refresh_threshold}) reached. Refreshing cache.")
            self.invalidate_cache()
            self.request_count = 0

        cached_pynapples = self.cache_client.get('pynapples')
        if cached_pynapples:
            jsapples = json.loads(cached_pynapples)
            logger.info(f"Found {len(jsapples)} pynapples using: CACHE")
            return jsapples, 'cache'

        # Fall back to database if not in cache
        pynapples = Pynapple.query.all()
        pynapples_list = [pynapple.to_dict() for pynapple in pynapples]
        logger.info(f"Found {len(pynapples_list)} pynapples using: DB")
        self.cache_client.set('pynapples', json.dumps(pynapples_list), timeout=60)  # Refresh cache
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
        self.cache_client.delete('pynapples')

