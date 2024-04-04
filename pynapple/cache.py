from pynapple.config import Config
import logging
logger = logging.getLogger(__name__)


class Cache:
    def get(self, key):
        raise NotImplementedError

    def set(self, key, value, timeout=None):
        raise NotImplementedError

    def delete(self, key):
        raise NotImplementedError


class RedisCache(Cache):
    def __init__(self, host):
        from redis import Redis
        self.redis = Redis(host=host)

    def get(self, key):
        return self.redis.get(key)

    def set(self, key, value, timeout=None):
        return self.redis.set(key, value, ex=timeout)

    def delete(self, key):
        return self.redis.delete(key)


class MemcachedCache(Cache):
    def __init__(self, host):
        import memcache
        self.memcached = memcache.Client([host], debug=0)

    def get(self, key):
        return self.memcached.get(key)

    def set(self, key, value, timeout=None):
        return self.memcached.set(key, value, time=timeout)

    def delete(self, key):
        return self.memcached.delete(key)


class NullCacheClient(Cache):
    def get(self, key):
        return None

    def set(self, key, value, timeout=None):
        pass

    def delete(self, key):
        pass


cache_client = NullCacheClient()
if Config.REDIS_HOST:
    logger.info('Using Redis for caching')
    cache_client = RedisCache(host=Config.REDIS_HOST)
elif Config.MEMCACHED_HOST:
    logger.info('Using Memcached for caching')
    cache_client = MemcachedCache(host=Config.MEMCACHED_HOST)
else:
    logger.info('Use NullCacheClient (no caching!)')
