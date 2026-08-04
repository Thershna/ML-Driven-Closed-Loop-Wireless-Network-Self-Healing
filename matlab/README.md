# MATLAB — Network Simulation & Rectification

Requires MATLAB (no extra toolboxes beyond base MATLAB — uses `rand`,
`randn`, `table`, `scatter`/`gscatter` for plotting).

## Files

- **`network_simulation.m`** — Builds a random 3-BS / 30-user topology in a
  1000 m × 1000 m area, computes path loss, SINR, throughput, and latency,
  flags invisible coverage holes, plots the topology and detection results,
  and then runs a 50-scenario before/after healing sweep to produce average
  throughput/latency/hole-count statistics.

- **`rectification.m`** — Takes one user's QoE sample plus a set of
  ML-predicted healing outputs (power boost, priority, handover, load
  weight, delay priority) and applies the healing transfer functions to
  compute the "after" SINR, throughput, latency, and load. Prints a
  before/after comparison and plots a grouped bar chart. In the full
  pipeline, the healing outputs come from the regressor/classifier trained
  in `../ml/train_new_dataset_model.py` and served by `../ml/app.py`.

## Running

```matlab
>> network_simulation
>> rectification
```

Both scripts are self-contained scripts (not functions) — run them
directly from the MATLAB command window or editor.

