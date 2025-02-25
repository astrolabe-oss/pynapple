import requests
import threading
import time
from pynapple import config
import logging
logger = logging.getLogger(__name__)


def poll_downstream_pynapples():
    dph = config.Config.DOWNSTREAM_PYNAPPLE_HOST
    if dph:
        hosts = [host.strip() for host in dph.split(',')]
        logger.info(f"Pynapple configured to poll {len(hosts)} downstream pynapple(s): {hosts}")
        for host in hosts:
            logger.info(f"Starting polling thread for downstream pynapple: `{host}`")
            threading.Thread(target=_poll_downstream_pynapples, args=(host,), daemon=True).start()
    else:
        logger.info("Pynapple not configured to poll any downstream pynapples... womp womp :(")


def _poll_downstream_pynapples(host):
    ds_uri = f"http://{host}/pynapples"
    while True:
        try:
            logger.info(f"Polling {ds_uri}...")
            headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'}
            response = requests.get(ds_uri, proxies={'no': 'pass'}, headers=headers)
            if response.status_code == 200:
                # Assuming the endpoint returns a list of pynapples in JSON format
                pynapples = response.json()
                logger.info(f"Polled {len(pynapples['pynapples'])} downstream pynapples successfully.")
            else:
                logger.warning(f"Failed to poll downstream pynapple: HTTP {response.status_code}")
        except Exception as e:
            logger.error(f"Error polling downstream pynapple: {e}")
        time.sleep(config.Config.DOWNSTREAM_PYNAPPLE_INTERVAL)
