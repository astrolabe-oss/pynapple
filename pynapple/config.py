import os


class Config:
    SQLALCHEMY_DATABASE_URI = os.environ.get('PYNAPPLE_DATABASE_URI', 'sqlite:///:memory:')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    REDIS_HOST = os.environ.get('PYNAPPLE_REDIS_HOST', 'localhost')


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
