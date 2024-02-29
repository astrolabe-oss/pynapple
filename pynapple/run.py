import os
from flask import Flask, jsonify, request, abort
from flask_sqlalchemy import SQLAlchemy

from pynapple.config import DevelopmentConfig


app = Flask(__name__)
app.config.from_object(DevelopmentConfig)
app.json.ensure_ascii = False

db = SQLAlchemy(app)


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
    pynapples = Pynapple.query.all()
    return jsonify([pynapple.to_dict() for pynapple in pynapples])


@app.route('/pynapples', methods=['POST'])
def add_pynapple():
    if request.remote_addr != '127.0.0.1':
        abort(403)
    data = request.get_json()
    ripeness = data.get('ripeness')
    selfie = data.get('selfie')
    if not ripeness or not isinstance(ripeness, int):
        return jsonify({'error': 'Ripeness is required and must be an integer'}), 400
    if not selfie:
        return jsonify({'error': 'Selfie is required'}), 400
    pynapple = Pynapple(ripeness=ripeness, selfie=selfie)
    db.session.add(pynapple)
    db.session.commit()
    return jsonify(pynapple.to_dict()), 201


@app.route('/pynapples/<int:id>', methods=['GET'])
def get_pynapple(id):
    pynapple = Pynapple.query.get_or_404(id)
    return jsonify(pynapple.to_dict())


if __name__ == '__main__':
    app.run(debug=True)
