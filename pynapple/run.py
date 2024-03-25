from flask import Flask, jsonify, request, abort
from flask_sqlalchemy import SQLAlchemy
from redis import Redis
import json

from pynapple.config import DevelopmentConfig

app = Flask(__name__)
app.config.from_object(DevelopmentConfig)
app.json.ensure_ascii = False

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


@app.route('/')
def hello_world():
    return "Hello 🍍!\n"


@app.route('/pynapples', methods=['GET'])
def list_pynapples():
    # check cache
    cached_pynapples = redis.get('pynapples')
    if cached_pynapples:
        return _response(json.loads(cached_pynapples), 'cache')

    # check db
    pynapples = Pynapple.query.all()
    pynapples_list = [pynapple.to_dict() for pynapple in pynapples]

    # update cache
    redis.set('pynapples', json.dumps(pynapples_list), ex=60)  # Cache for 60 seconds
    return _response(pynapples_list)


@app.route('/pynapples', methods=['POST'])
def add_pynapple():
    # block remote POSTs
    client_addr = request.headers.get('X-Forwarded-For', request.remote_addr)
    if '127.0.0.1' != client_addr:
        abort(403)

    # get pynapple from request data
    data = request.get_json()
    ripeness = data.get('ripeness')
    selfie = data.get('selfie')
    if not ripeness or not isinstance(ripeness, int):
        return jsonify({'error': 'Ripeness is required and must be an integer'}), 400
    if not selfie:
        return jsonify({'error': 'Selfie is required'}), 400

    # instantiate and store pynapple
    pynapple = Pynapple(ripeness=ripeness, selfie=selfie)
    db.session.add(pynapple)
    db.session.commit()

    # invalidate cache
    redis.delete('pynapples')  # Invalidate cache after adding a new pynapple

    # return pynapple for view
    return _response(pynapple.to_dict()), 201


@app.route('/pynapples/<int:id>', methods=['GET'])
def get_pynapple(id):
    pynapple = Pynapple.query.get_or_404(id)
    return _response(pynapple.to_dict())


def _response(pynapples, datasource: str = 'db'):
    return jsonify({'pynapples': pynapples, 'datasource': datasource})


if __name__ == '__main__':
    app.run(debug=True)
