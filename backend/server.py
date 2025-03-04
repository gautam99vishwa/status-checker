from flask import Flask, jsonify, request
from flask_cors import CORS
import requests
import logging

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def check_service_status(url):
    """Checks if the service is online and returns status & HTTP code properly."""
    try:
        response = requests.get(url, timeout=2)  # Short timeout to avoid delays
        is_online = 200 <= response.status_code < 300  # True if status is 2xx
        return {"url": url, "status": is_online, "code": response.status_code}

    except requests.exceptions.Timeout:
        logger.error(f"Timeout checking service {url}")
        return {"url": url, "status": False, "code": 408}  # 408 = Request Timeout

    except requests.exceptions.ConnectionError:
        logger.error(f"Connection error for {url}")
        return {"url": url, "status": False, "code": 503}  # 503 = Service Unavailable

    except requests.exceptions.RequestException as e:
        logger.error(f"Unknown error checking {url}: {e}")
        return {
            "url": url,
            "status": False,
            "code": 503,
        }  # Default to 503 for all failures


@app.route("/status/<path:urlValue>", methods=["GET"])
def get_status_by_url(urlValue):
    """Checks the status of the given URL from the URL parameter."""
    url = (
        f"https://{urlValue}"
        if not urlValue.startswith(("http://", "https://"))
        else urlValue
    )
    result = check_service_status(url)
    return jsonify(result)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
