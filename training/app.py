"""
app.py

Flask-based inference interface for the network self-healing models.
Loads the trained handover classifier and healing-action regressor and
serves a simple web form for real-time predictions.

Part of: Self-Healing in Wireless Cellular Networks
VIT Chennai - School of Electronics and Communication Engineering
"""

from pathlib import Path

import joblib
import pandas as pd
from flask import Flask, render_template, request


FEATURE_ORDER = ["sinr", "throughput", "latency", "demand", "load", "distance"]

BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "model_artifacts_new_80_20"

classifier = joblib.load(MODEL_DIR / "handover_classifier_new.joblib")
regressor = joblib.load(MODEL_DIR / "action_regressor_new.joblib")

app = Flask(__name__)


def to_float(value: str, default: float) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


@app.route("/", methods=["GET", "POST"])
def index():
    defaults = {
        "sinr": 15.0,
        "throughput": 10.0,
        "latency": 60.0,
        "demand": 12.0,
        "load": 0.6,
        "distance": 150.0,
    }

    values = defaults.copy()
    prediction = None
    error = None

    if request.method == "POST":
        for key in FEATURE_ORDER:
            values[key] = to_float(request.form.get(key), defaults[key])

        try:
            features = pd.DataFrame(
                [[values[key] for key in FEATURE_ORDER]],
                columns=FEATURE_ORDER,
            )

            handover = int(classifier.predict(features)[0])
            reg_out = regressor.predict(features)[0]

            prediction = {
                "power_boost": round(float(reg_out[0]), 3),
                "priority": round(float(reg_out[1]), 3),
                "handover": handover,
                "load_weight": round(float(reg_out[2]), 3),
                "delay_priority": round(float(reg_out[3]), 3),
            }
        except Exception as exc:
            error = f"Prediction failed: {exc}"

    return render_template(
        "index.html",
        values=values,
        prediction=prediction,
        error=error,
    )


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=False)
