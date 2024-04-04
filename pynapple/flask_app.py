from flask import Flask
from pynapple.config import DevelopmentConfig
from pynapple.log import setup_logging

setup_logging()
app = Flask(__name__)
app.config.from_object(DevelopmentConfig)
app.json.ensure_ascii = False
