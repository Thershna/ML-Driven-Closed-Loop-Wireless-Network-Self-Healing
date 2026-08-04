# ML-Driven Closed-Loop Wireless Network Self-Healing

An intelligent Machine Learning-based framework for detecting **Invisible Coverage Holes** and automatically optimizing wireless cellular network performance using **MATLAB**, **Python**, **Random Forest**, and **Flask**.

---

## Overview

Modern wireless cellular networks often experience poor **Quality of Experience (QoE)** even when signal strength is sufficient. These hidden performance issues, known as **Invisible Coverage Holes**, occur due to congestion, interference, and inefficient resource allocation.

This project presents a **closed-loop self-healing framework** that intelligently detects such network problems and predicts optimal healing actions using Machine Learning. The framework combines **MATLAB-based wireless network simulation**, **Python-based Random Forest models**, and a **Flask web application** to automatically improve network performance.

The proposed system continuously analyzes network Quality of Experience (QoE) metrics, predicts corrective actions, and applies network optimization strategies to improve **SINR**, **Throughput**, **Latency**, and **Load Balancing**.

---

## Objectives

- Simulate a realistic wireless cellular network.
- Detect Invisible Coverage Holes using QoE metrics.
- Predict intelligent network healing actions using Machine Learning.
- Improve overall network performance through closed-loop optimization.
- Demonstrate autonomous network optimization using Artificial Intelligence.

---

## Features

- Wireless Network Simulation using MATLAB
- Random Base Station and User Deployment
- Invisible Coverage Hole Detection
- QoE Analysis using SINR, Throughput, Latency, Load, and Distance
- Random Forest Classifier for Handover Prediction
- Multi-Output Random Forest Regressor for Healing Action Prediction
- Flask-based Web Interface for Real-Time Predictions
- Network Performance Validation Before and After Healing

---

## System Workflow

```
Wireless Network Simulation
            │
            ▼
Generate QoE Metrics
(SINR, Throughput, Latency,
Demand, Load, Distance)
            │
            ▼
Invisible Coverage Hole Detection
            │
            ▼
Machine Learning Prediction
(Random Forest Models)
            │
            ▼
Healing Action Prediction
            │
            ▼
Network Optimization
            │
            ▼
Improved Network Performance
```

---

## Technologies Used

| Category | Technologies |
|----------|--------------|
| Programming Language | Python |
| Network Simulation | MATLAB |
| Machine Learning | Scikit-Learn |
| ML Algorithms | Random Forest Classifier & Regressor |
| Backend | Flask |
| Data Processing | Pandas, NumPy |
| Model Storage | Joblib |
| Frontend | HTML, CSS |
| Version Control | Git, GitHub |

---

## Machine Learning Models

### Random Forest Classifier

The classifier predicts whether a network user should be handed over to another base station based on the current network conditions.

**Output**

- Handover Decision

---

### Random Forest Regressor

The regressor predicts multiple healing parameters required to improve network Quality of Experience.

**Predicted Parameters**

- Power Boost
- Priority Scheduling
- Load Weight
- Delay Priority

These predicted values are applied to optimize wireless network performance.

---

## Dataset

The Machine Learning models are trained using a dataset generated from the MATLAB simulation environment.

### Input Features

- SINR
- Throughput
- Latency
- Demand
- Load
- Distance

### Output Targets

**Classification**

- Handover Decision

**Regression**

- Power Boost
- Priority
- Load Weight
- Delay Priority

---

## Model Performance

| Metric | Value |
|---------|-------|
| Total Samples | 5000 |
| Training Samples | 4000 |
| Testing Samples | 1000 |
| Train-Test Split | 80 : 20 |
| Classification Accuracy | **99.9%** |



---

## Installation

Clone the repository:

```bash
git clone https://github.com/Thershna/ml-wireless-network-self-healing.git
```

Move into the project directory:

```bash
cd ml-wireless-network-self-healing
```

Install the required Python packages:

```bash
pip install -r requirements.txt
```

---

## Usage

### Train the Machine Learning Models

```bash
python train_model.py
```

### Start the Flask Application

```bash
python app.py
```

Open your browser and visit:

```
http://127.0.0.1:5000
```

Enter the required network parameters to receive real-time network healing predictions.

---

## Results

The proposed framework successfully detects Invisible Coverage Holes and predicts intelligent healing actions that significantly improve network performance.

The optimized network demonstrates:

- Improved SINR
- Increased Throughput
- Reduced Latency
- Better Load Distribution
- Intelligent Handover Decisions
- Enhanced User Quality of Experience (QoE)

---

## Screenshots

Add the following screenshots here:

- Network Topology
- Invisible Coverage Hole Detection
- Flask Prediction Interface
- Network Performance Comparison
- Before vs After Healing Results

---

## Future Scope

- Deep Reinforcement Learning for Adaptive Optimization
- Integration with 5G and 6G Networks
- Edge AI Deployment
- Real-Time Network Monitoring
- Digital Twin-Based Network Simulation
- Cloud-Based Network Management

---

## Contributors

- Kamalesh Kumar
- Muhamed Ibrahim
- Roshan Mathew
- Thershna TK

---

## License

This project is developed for academic and research purposes.
