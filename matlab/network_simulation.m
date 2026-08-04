%% network_simulation.m
% Wireless network simulation, SINR/throughput/latency modeling,
% invisible coverage hole detection, and a 50-scenario before/after
% healing performance sweep.
%
% Part of: Self-Healing in Wireless Cellular Networks
% VIT Chennai - School of Electronics and Communication Engineering

clc;
clear;
close all;

rng('shuffle'); % Random topology every run

%% =====================================================
% STEP 1: NETWORK INITIALIZATION
% ======================================================

numberOfBaseStations = 3;
numberOfUsers = 30;
areaSize_m = 1000;

txPower_dBm = 46;
noisePower_dBm = -100;
baseLatency_ms = 20;
systemBandwidth_MHz = 10;

% Random positions
baseStationPosition_m = rand(numberOfBaseStations,2) * areaSize_m;
userPosition_m = rand(numberOfUsers,2) * areaSize_m;

% Nearest BS association
servingBaseStation = zeros(numberOfUsers,1);
distanceMatrix_m = zeros(numberOfUsers, numberOfBaseStations);

for user = 1:numberOfUsers
    for bs = 1:numberOfBaseStations
        distanceMatrix_m(user,bs) = ...
            norm(userPosition_m(user,:) - baseStationPosition_m(bs,:));
    end
    [~, servingBaseStation(user)] = min(distanceMatrix_m(user,:));
end

%% =====================================================
% STEP 2: SINR CALCULATION
% ======================================================

sinr_dB = zeros(numberOfUsers,1);

txPower_mW = 10^(txPower_dBm/10);
noisePower_mW = 10^(noisePower_dBm/10);

for user = 1:numberOfUsers

    distance_km = distanceMatrix_m(user, servingBaseStation(user)) / 1000;
    distance_km = max(distance_km,0.01);

    pathLoss_dB = 128.1 + 37.6*log10(distance_km);

    receivedSignal_mW = txPower_mW / (10^(pathLoss_dB/10));

    interference_dBm = -95 + randn*3;
    interference_mW = 10^(interference_dBm/10);

    sinr_linear = receivedSignal_mW / (interference_mW + noisePower_mW);
    sinr_dB(user) = 10*log10(sinr_linear);

    % ---- SCALE SINR BEFORE CLAMPING ----
    sinr_dB(user) = sinr_dB(user) - 15; % shift down

    % ---- ADD VARIATION ----
    sinr_dB(user) = sinr_dB(user) + randn*2;

    % ---- CLAMP ----
    sinr_dB(user) = max(5, min(25, sinr_dB(user)));
end

disp("SINR (dB) - First 30 Users:")
disp(sinr_dB(1:30))

%% =====================================================
% STEP 3: USER TRAFFIC DEMAND (CONTROLLED)
% ======================================================

userDemand_Mbps = 5 + 15*rand(numberOfUsers,1); % 5-20 Mbps

%% =====================================================
% STEP 4: CELL CAPACITY & LOAD
% ======================================================

cellCapacity_Mbps = 150; % Increased capacity

cellLoad_ratio = zeros(numberOfBaseStations,1);

for bs = 1:numberOfBaseStations
    usersInCell = find(servingBaseStation == bs);
    totalDemand = sum(userDemand_Mbps(usersInCell));
    cellLoad_ratio(bs) = totalDemand / cellCapacity_Mbps;
end

% ---- CLAMP LOAD (0.1 to 1.2) ----
cellLoad_ratio = max(0.1, min(1.2, cellLoad_ratio));

%% =====================================================
% STEP 5: QoE CALCULATION
% ======================================================

throughput_Mbps = zeros(numberOfUsers,1);
latency_ms = zeros(numberOfUsers,1);
packetLoss_ratio = zeros(numberOfUsers,1);

for user = 1:numberOfUsers

    bs = servingBaseStation(user);
    loadFactor = cellLoad_ratio(bs);

    sinr_linear = 10^(sinr_dB(user)/10);
    spectralEfficiency = log2(1 + sinr_linear);

    rfRate = systemBandwidth_MHz * spectralEfficiency;

    % Congestion-aware throughput
    throughput_Mbps(user) = ...
        min(rfRate/(1+loadFactor), userDemand_Mbps(user));
    % ---- ADD RANDOM QoE DISTURBANCE ----
    throughput_Mbps(user) = throughput_Mbps(user) * (0.8 + 0.4*rand);
    % ---- CLAMP THROUGHPUT (0 to 20 Mbps) ----
    throughput_Mbps(user) = max(0, min(20, throughput_Mbps(user)));

    % Latency components
    queueDelay = 40 * loadFactor;
    distanceDelay = 0.01 * distanceMatrix_m(user, bs);
    randomJitter = rand*5;

    latency_ms(user) = ...
        baseLatency_ms + queueDelay + distanceDelay + randomJitter;

    % ---- ADD RANDOM DELAY VARIATION ----
    latency_ms(user) = latency_ms(user) * (0.9 + 0.3*rand);

    % ---- CLAMP LATENCY ----
    latency_ms(user) = max(20, min(200, latency_ms(user)));

    packetLoss_ratio(user) = ...
        min(0.02 + 0.25*loadFactor + 0.01*randn, 1);
end

sampleTable = table( ...
    sinr_dB(1:30), ...
    throughput_Mbps(1:30), ...
    latency_ms(1:30), ...
    packetLoss_ratio(1:30), ...
    'VariableNames', {'SINR_dB','Throughput_Mbps', ...
    'Latency_ms','PacketLoss_ratio'});

disp("Sample QoE Metrics (First 30 Users):")
disp(sampleTable)

%% =====================================================
% STEP 6: INVISIBLE COVERAGE HOLE DETECTION (RANDOMIZED)
% ======================================================

invisibleHoleFlag = zeros(numberOfUsers,1);

% -------- RANDOMIZED THRESHOLDS --------

throughputThresholds = (0.7 + 0.2*rand(numberOfUsers,1)) .* userDemand_Mbps;
latencyThresholds = 60 + 40*rand(numberOfUsers,1);

% -------- PREPARE TABLE VALUES (FIXED) --------

% Distance values
distVals = distanceMatrix_m(sub2ind(size(distanceMatrix_m), ...
    (1:numberOfUsers)', servingBaseStation));
distVals = max(50, min(300, distVals));

% Load values
loadVals = cellLoad_ratio(servingBaseStation);
loadVals = loadVals(:); % ensure column

% Ensure all are column vectors (important)
sinr_dB = sinr_dB(:);
throughput_Mbps = throughput_Mbps(:);
latency_ms = latency_ms(:);
throughputThresholds = throughputThresholds(:);
latencyThresholds = latencyThresholds(:);

% -------- FINAL TABLE --------

finalTable = table( ...
    (1:numberOfUsers)', ...
    sinr_dB, ...
    throughput_Mbps, ...
    latency_ms, ...
    loadVals, ...
    distVals, ...
    throughputThresholds, ...
    latencyThresholds, ...
    'VariableNames', {'user_no','sinr','throughput','latency', ...
    'load','distance','thrpt_threshold','latency_threshold'});

disp('================ USER DATA WITH RANDOM THRESHOLDS ================')
disp(finalTable)
disp('======================================')

% -------- DETECTION --------

for user = 1:numberOfUsers

    highRF = sinr_dB(user) > 12;

    poorThroughput = throughput_Mbps(user) < throughputThresholds(user);

    highLatency = latency_ms(user) > latencyThresholds(user);

    if highRF && (poorThroughput || highLatency)
        invisibleHoleFlag(user) = 1;
    end
end

totalHoles = sum(invisibleHoleFlag);

disp(['Total Invisible Holes Detected: ', num2str(totalHoles)])

holeUsers = find(invisibleHoleFlag == 1);

disp('Invisible Hole User IDs:')
disp(holeUsers')

%% =====================================================
% PLOTS
% =====================================================

% --------- NETWORK TOPOLOGY ---------
figure;
scatter(userPosition_m(:,1), userPosition_m(:,2),50,'b','filled');
hold on;
scatter(baseStationPosition_m(:,1), baseStationPosition_m(:,2),150, 'r','filled');

for bs = 1:numberOfBaseStations
    text(baseStationPosition_m(bs,1)+10, baseStationPosition_m(bs,2)+10, ...
        ['BS', num2str(bs)], ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', 'r');
end

for user = 1:numberOfUsers
    text(userPosition_m(user,1)+10, userPosition_m(user,2)+10, ...
        ['U', num2str(user), ' BS', num2str(servingBaseStation(user))], ...
        'FontSize', 8);
end

title('Network Topology');
xlabel('X Distance (m)');
ylabel('Y Distance (m)');
legend('Users','Base Stations');
grid on;
axis([0 areaSize_m 0 areaSize_m]);

drawnow;


% --------- INVISIBLE HOLE PLOT ---------
figure;
gscatter(userPosition_m(:,1), userPosition_m(:,2), invisibleHoleFlag,'gb','ox');
hold on;
scatter(baseStationPosition_m(:,1), baseStationPosition_m(:,2),150, 'r','filled');

for bs = 1:numberOfBaseStations
    text(baseStationPosition_m(bs,1)+10, baseStationPosition_m(bs,2)+10, ...
        ['BS', num2str(bs)], ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', 'r');
end

title('Invisible Coverage Hole Detection');
xlabel('X Distance (m)');
ylabel('Y Distance (m)');
legend('Normal User','Invisible Hole User','Base Station');
grid on;
axis([0 areaSize_m 0 areaSize_m]);

drawnow;


%% =====================================================
% STEP 7: NETWORK HEALING - 50 RANDOM SCENARIOS
% ======================================================

numScenarios = 50;

avgThroughput_before = zeros(numScenarios,1);
avgLatency_before = zeros(numScenarios,1);
avgHoles_before = zeros(numScenarios,1);

avgThroughput_after = zeros(numScenarios,1);
avgLatency_after = zeros(numScenarios,1);
avgHoles_after = zeros(numScenarios,1);

for scenario = 1:numScenarios

    rng('shuffle');

    %% RANDOM TOPOLOGY
    baseStationPosition_m = rand(numberOfBaseStations,2) * areaSize_m;
    userPosition_m = rand(numberOfUsers,2) * areaSize_m;

    servingBaseStation = zeros(numberOfUsers,1);
    distanceMatrix_m = zeros(numberOfUsers, numberOfBaseStations);

    for user = 1:numberOfUsers
        for bs = 1:numberOfBaseStations
            distanceMatrix_m(user,bs) = ...
                norm(userPosition_m(user,:) - baseStationPosition_m(bs,:));
        end
        [~, servingBaseStation(user)] = ...
            min(distanceMatrix_m(user,:));
    end

    %% SINR CALCULATION
    sinr_dB = zeros(numberOfUsers,1);

    for user = 1:numberOfUsers

        distance_km = ...
            distanceMatrix_m(user, servingBaseStation(user)) / 1000;
        distance_km = max(distance_km,0.01);

        pathLoss_dB = 128.1 + 37.6*log10(distance_km);
        receivedSignal_mW = txPower_mW / (10^(pathLoss_dB/10));

        interference_dBm = -95 + randn*3;
        interference_mW = 10^(interference_dBm/10);

        sinr_linear = ...
            receivedSignal_mW / (interference_mW + noisePower_mW);
        sinr_dB(user) = 10*log10(sinr_linear);
    end

    %% TRAFFIC
    userDemand_Mbps = 5 + 15*rand(numberOfUsers,1);

    %% CELL LOAD (BEFORE HEALING)
    cellLoad_ratio = zeros(numberOfBaseStations,1);

    for bs = 1:numberOfBaseStations
        usersInCell = find(servingBaseStation == bs);
        totalDemand = sum(userDemand_Mbps(usersInCell));
        cellLoad_ratio(bs) = totalDemand / cellCapacity_Mbps;
    end

    %% QoE BEFORE HEALING
    throughput = zeros(numberOfUsers,1);
    latency = zeros(numberOfUsers,1);
    invisibleHoleFlag = zeros(numberOfUsers,1);

    for user = 1:numberOfUsers

        bs = servingBaseStation(user);
        loadFactor = cellLoad_ratio(bs);

        sinr_linear = 10^(sinr_dB(user)/10);
        spectralEfficiency = log2(1 + sinr_linear);
        rfRate = systemBandwidth_MHz * spectralEfficiency;

        throughput(user) = ...
            min(rfRate/(1+loadFactor), userDemand_Mbps(user));

        queueDelay = 40 * loadFactor;
        distanceDelay = 0.01 * distanceMatrix_m(user, bs);
        latency(user) = ...
            baseLatency_ms + queueDelay + distanceDelay + rand*5;
    end

    % Invisible Hole Detection (Before Healing)
    avgLat = mean(latency);
    stdLat = std(latency);

    for user = 1:numberOfUsers
        highRF = sinr_dB(user) > 15;
        poorThroughput = ...
            throughput(user) < 0.6 * userDemand_Mbps(user);
        highLatency = latency(user) > (avgLat + 0.8*stdLat);

        if highRF && (poorThroughput || highLatency)
            invisibleHoleFlag(user) = 1;
        end
    end

    avgHoles_before(scenario) = sum(invisibleHoleFlag);
    avgThroughput_before(scenario) = mean(throughput);
    avgLatency_before(scenario) = mean(latency);

    %% =====================================================
    % NETWORK HEALING
    % ======================================================

    healedCapacity = cellCapacity_Mbps * 1.3;
    healedLoad_ratio = zeros(numberOfBaseStations,1);

    for bs = 1:numberOfBaseStations
        usersInCell = find(servingBaseStation == bs);
        totalDemand = sum(userDemand_Mbps(usersInCell));
        healedLoad_ratio(bs) = totalDemand / healedCapacity;
    end

    throughput_healed = zeros(numberOfUsers,1);
    latency_healed = zeros(numberOfUsers,1);
    invisibleHoleFlag_healed = zeros(numberOfUsers,1);

    for user = 1:numberOfUsers

        bs = servingBaseStation(user);
        loadFactor = healedLoad_ratio(bs);

        improvedSINR_dB = sinr_dB(user) + 2;
        sinr_linear = 10^(improvedSINR_dB/10);

        spectralEfficiency = log2(1 + sinr_linear);
        rfRate = systemBandwidth_MHz * spectralEfficiency;

        throughput_healed(user) = ...
            min(rfRate/(1+0.6*loadFactor), userDemand_Mbps(user));

        queueDelay = 25 * loadFactor;
        distanceDelay = 0.01 * distanceMatrix_m(user, bs);
        latency_healed(user) = ...
            baseLatency_ms + queueDelay + distanceDelay + rand*3;
    end

    % Invisible Hole Detection (After Healing)
    avgLatH = mean(latency_healed);
    stdLatH = std(latency_healed);

    for user = 1:numberOfUsers
        highRF = (sinr_dB(user)+2) > 15;
        poorThroughput = ...
            throughput_healed(user) < 0.6 * userDemand_Mbps(user);
        highLatency = latency_healed(user) > (avgLatH + 0.8*stdLatH);

        if highRF && (poorThroughput || highLatency)
            invisibleHoleFlag_healed(user) = 1;
        end
    end

    avgHoles_after(scenario) = sum(invisibleHoleFlag_healed);
    avgThroughput_after(scenario) = mean(throughput_healed);
    avgLatency_after(scenario) = mean(latency_healed);
end
