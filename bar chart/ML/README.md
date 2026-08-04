# ML — Training & Inference

Random Forest models for network self-healing decisions, plus a Flask
web UI for live predictions.

## Setup

```bash
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## 1. Train the models

Needs a CSV dataset with columns:
`sinr, throughput, latency, demand, load, distance, handover, power_boost,
priority, load_weight, delay_priority` (the project report describes a
5,000-row dataset generated from the MATLAB simulation, split 80/20).

```bash
python train_new_dataset_model.py --data "per_user_dataset (1).csv" --output-dir model_artifacts_new_80_20
```

This writes to `model_artifacts_new_80_20/`:
- `handover_classifier_new.joblib` — Random Forest Classifier (400 trees)
- `action_regressor_new.joblib` — Random Forest Regressor (450 trees, 4 outputs)
- `training_summary.json` — split sizes, classification accuracy, and
  per-target MAE / RMSE / R² for the regressor

Reference results from the report: 99.9% handover-classification accuracy;
regression R² ranging from 0.552 (load weight) to 0.928 (delay priority).

## 2. Run the prediction interface

```bash
python app.py
```

Serves at `http://127.0.0.1:5000`. Enter SINR, throughput, latency, demand,
load, and distance to get predicted power boost, priority, handover
decision, load weight, and delay priority in real time.

> `templates/index.html` here is a minimal reconstruction of the UI shown
> in `../docs/images/ml_prediction_interface.png` (the report only
> documents `app.py` itself, not the template source) — restyle freely.

