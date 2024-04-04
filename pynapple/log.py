import os
import logging


def setup_logging():
    # Get log level from environment variable or default to INFO
    log_level_name = os.getenv('LOG_LEVEL', 'INFO')
    log_level = getattr(logging, log_level_name.upper(), None)
    if not isinstance(log_level, int):
        raise ValueError(f'Invalid log level: {log_level_name}')

    logging.basicConfig(level=log_level)
