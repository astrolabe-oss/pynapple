from flask import Flask
from pynapple.config import DevelopmentConfig


app = Flask(__name__)
app.config.from_object(DevelopmentConfig)
app.json.ensure_ascii = False
