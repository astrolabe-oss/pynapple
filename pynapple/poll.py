import os
import threading
import time
import requests
from pynapple import config


def poll_downstream_pynapple():
    if config.Config.DOWNSTREAM_PYNAPPLE_HOST:
        threading.Thread(target=_poll_downstream_pynapple, daemon=True).start()


def _poll_downstream_pynapple():
    ds_host = config.Config.DOWNSTREAM_PYNAPPLE_HOST
    while True:
        try:
            response = requests.get(ds_host)
            print(f"Polled downstream pynapple (${ds_host}): {response.status_code}")
        except Exception as e:
            print(f"Error polling pynapple2: {e}")
        time.sleep(config.Config.DOWNSTREAM_PYNAPPLE_INTERVAL)