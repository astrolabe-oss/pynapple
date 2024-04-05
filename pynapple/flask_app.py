from flask import Flask
from pynapple.config import DevelopmentConfig
from pynapple.log import setup_logging
from pynapple.poll import poll_downstream_pynapples

setup_logging()
app = Flask(__name__)
app.config.from_object(DevelopmentConfig)
app.json.ensure_ascii = False


# run once on application launch
with app.app_context():
    poll_downstream_pynapples()
