"""
train_new_dataset_model.py

Trains a Random Forest Classifier (handover decision) and a Random
Forest Regressor (healing parameters: power_boost, priority,
load_weight, delay_priority) on per-user QoE telemetry, using an
80/20 train-test split.

Part of: Self-Healing in Wireless Cellular Networks
VIT Chennai - School of Electronics and Communication Engineering
"""

import argparse
import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.metrics import (
    accuracy_score,
    mean_absolute_error,
    mean_squared_error,
    r2_score,
)
from sklearn.model_selection import train_test_split


INPUT_FEATURES = ["sinr", "throughput", "latency", "demand", "load", "distance"]
OUTPUT_CLASS = "handover"
OUTPUT_REG = ["power_boost", "priority", "load_weight", "delay_priority"]


def validate_schema(df: pd.DataFrame) -> None:
    required = set(INPUT_FEATURES + [OUTPUT_CLASS] + OUTPUT_REG)
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")


def regression_metrics(y_true: pd.DataFrame, y_pred: np.ndarray) -> dict:
    out = {}
    for i, target in enumerate(OUTPUT_REG):
        yt = y_true[target].values
        yp = y_pred[:, i]
        out[target] = {
            "mae": float(mean_absolute_error(yt, yp)),
            "rmse": float(np.sqrt(mean_squared_error(yt, yp))),
            "r2": float(r2_score(yt, yp)),
        }
    return out


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Train a new ML model on per_user_dataset (1).csv with 80/20 split."
    )
    parser.add_argument(
        "--data",
        type=str,
        default="per_user_dataset (1).csv",
        help="Path to new dataset CSV",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default="model_artifacts_new_80_20",
        help="Directory to save new model artifacts",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed",
    )
    args = parser.parse_args()

    data_path = Path(args.data)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(data_path)
    validate_schema(df)

    X = df[INPUT_FEATURES]
    y_cls = df[OUTPUT_CLASS].astype(int)
    y_reg = df[OUTPUT_REG]

    # 80/20 split as requested.
    X_train, X_test, y_cls_train, y_cls_test, y_reg_train, y_reg_test = train_test_split(
        X,
        y_cls,
        y_reg,
        test_size=0.2,
        random_state=args.seed,
        stratify=y_cls,
    )

    cls_model = RandomForestClassifier(
        n_estimators=400,
        max_depth=14,
        min_samples_leaf=2,
        random_state=args.seed,
        n_jobs=-1,
    )
    cls_model.fit(X_train, y_cls_train)

    reg_model = RandomForestRegressor(
        n_estimators=450,
        max_depth=16,
        min_samples_leaf=2,
        random_state=args.seed,
        n_jobs=-1,
    )
    reg_model.fit(X_train, y_reg_train)

    cls_pred = cls_model.predict(X_test)
    reg_pred = reg_model.predict(X_test)

    summary = {
        "dataset": str(data_path),
        "rows": int(len(df)),
        "input_features": INPUT_FEATURES,
        "output_parameters": {
            "classification": OUTPUT_CLASS,
            "regression": OUTPUT_REG,
        },
        "split": {
            "train_percent": 80,
            "test_percent": 20,
            "train_rows": int(len(X_train)),
            "test_rows": int(len(X_test)),
            "seed": args.seed,
        },
        "classification": {
            "accuracy": float(accuracy_score(y_cls_test, cls_pred)),
        },
        "regression": regression_metrics(y_reg_test, reg_pred),
    }

    joblib.dump(cls_model, output_dir / "handover_classifier_new.joblib")
    joblib.dump(reg_model, output_dir / "action_regressor_new.joblib")
    with open(output_dir / "training_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)

    print("New model training complete.")
    print(f"Saved folder: {output_dir}")
    print(f"- {output_dir / 'handover_classifier_new.joblib'}")
    print(f"- {output_dir / 'action_regressor_new.joblib'}")
    print(f"- {output_dir / 'training_summary.json'}")
    print(f"Accuracy: {summary['classification']['accuracy']:.4f}")


if __name__ == "__main__":
    main()

