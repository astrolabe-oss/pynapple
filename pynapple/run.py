from pynapple.flask_app import app
from pynapple import routes  # imports only so that routes are added


if __name__ == '__main__':
    app.run(debug=True)
