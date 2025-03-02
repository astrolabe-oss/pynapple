import os


# For PostgreSQL: postgresql+psycopg2://user:password@hostname/database_name
# For MySQL: mysql+pymysql://user:password@hostname/database_name
class Config:
    SQLALCHEMY_DATABASE_URI = os.environ.get('SANDBOX_DATABASE_URI', 'sqlite:///:memory:')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    REDIS_HOST = os.environ.get('SANDBOX_REDIS_HOST')
    MEMCACHED_HOST = os.environ.get('SANDBOX_MEMCACHED_HOST')
    DOWNSTREAM_PYNAPPLE_HOST = os.environ.get('DOWNSTREAM_PYNAPPLE_HOST', '')
    DOWNSTREAM_PYNAPPLE_INTERVAL = os.environ.get('DOWNSTREAM_PYNAPPLE_INTERVAL', 1)
    CACHE_REFRESH_THRESHOLD = os.environ.get('PYNAPPLE_CACHE_REFRESH_THRESHOLD', 10)

class DevelopmentConfig(Config):
    DEBUG = True
    # Development-specific configurations


class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'  # Override for tests
    # Testing-specific configurations


# class ProductionConfig(Config):
#     DEBUG = False
#     # Production-specific configurations
