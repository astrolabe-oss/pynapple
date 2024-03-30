from flask import jsonify, request, abort
from pynapple.flask_app import app
from pynapple.cache import cache_client
from pynapple.services import PynappleService
from pynapple.models import db


pynapple_service = PynappleService(db, cache_client)


@app.route('/')
def hello_world():
    return "Hello 🍍!\n"


@app.route('/pynapples', methods=['GET'])
def list_pynapples():
    pynapples_list, source = pynapple_service.get_pynapples()
    return _response(pynapples_list, source)


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
    new_pynapple = pynapple_service.add_pynapple(ripeness, selfie)
    return _response(new_pynapple, 201)


@app.route('/pynapples/<int:id>', methods=['GET'])
def get_pynapple(id: str):
    pynapple = pynapple_service.get_pynapple_by_id(id)
    return _response(pynapple)


def _response(pynapples, datasource: str = 'db'):
    return jsonify({'pynapples': pynapples, 'datasource': datasource})
