%% rectification.m
% Applies ML-predicted healing actions to a single user sample using
% transfer functions, and compares before/after network performance.
%
% Part of: Self-Healing in Wireless Cellular Networks
% VIT Chennai - School of Electronics and Communication Engineering

clc;
clear;

%% INPUT (single sample)
sinr = 15;
throughput = 10;
latency = 60;
load_val = 0.6;
demand = 12;

%% ML OUTPUT
power_boost = 1.561;
priority = 1.158;
handover = 0;
load_weight = 0.699;
delay_priority = 0.858;

%% CONSTANTS
alpha = 0.8;
beta = 2;
gamma = 0.5;
delta = 1.5;
eta = 0.3;
kappa = 7;
lambda = 0.3;

%% -------- APPLY IMPROVEMENTS --------

sinr_new = sinr + alpha * power_boost + beta * handover;

delta_sinr = sinr_new - sinr;
throughput_new = throughput * (1 + gamma * (delta_sinr / sinr)) ...
    + delta * priority;

latency_new = latency * (1 - eta * delay_priority) ...
    - kappa * handover;

load_new = load_val * (1 - lambda * load_weight);

%% -------- PRINT RESULTS --------

fprintf('\n===== NETWORK PERFORMANCE COMPARISON =====\n');

% SINR
sinr_change = ((sinr_new - sinr) / sinr) *100;
fprintf('\nSINR:\nBefore = %.2f dB | After = %.2f dB | Change = +%.2f%%\n', ...
    sinr, sinr_new, sinr_change);

% Throughput
thr_change = ((throughput_new - throughput) / throughput) *100;
fprintf('\nThroughput:\nBefore = %.2f Mbps | After = %.2f Mbps | Change = +%.2f%%\n', ...
    throughput, throughput_new, thr_change);

% Latency (decrease is good)
lat_change = ((latency - latency_new) / latency) *100;
fprintf('\nLatency:\nBefore = %.2f ms | After = %.2f ms | Improvement = +%.2f%%\n', ...
    latency, latency_new, lat_change);

% Load (decrease is good)
load_change = ((load_val - load_new) / load_val) *100;
fprintf('\nLoad:\nBefore = %.2f | After = %.2f | Improvement = +%.2f%%\n', ...
    load_val, load_new, load_change);

fprintf('\n==========================================\n');

%% -------- GRAPH --------

before = [sinr, throughput, latency, load_val];
after = [sinr_new, throughput_new, latency_new, load_new];

labels = {'SINR','Throughput','Latency','Load'};

figure;
bar([before; after]');
legend('Before','After');
set(gca,'XTickLabel', labels);

title('Before vs After ML Optimization');
ylabel('Values');
grid on;

