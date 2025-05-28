% 5G NR Simulation: Compare Unicast, Broadcast, and Multicast
% This script simulates a single-cell 5G NR network and compares
% unicast, broadcast, and multicast transmission modes for group communication.

clear all; close all; clc;

% Simulation Parameters
numUEs = [5, 20, 60]; % Low, medium, high user densities
cellRadius = 500; % Cell radius in meters
bandwidth = 20e6; % 20 MHz bandwidth
numRBs = 100; % Number of resource blocks per slot
txPower = 40; % Transmit power in dBm
noisePower = -90; % Noise power in dBm
dataRate = 4e6; % 4 Mbps CBR traffic
numSlots = 100; % Number of slots to simulate
mcsTable = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]; % Simplified MCS (bits/symbol)
sinrThresholds = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]; % SINR thresholds (dB)

% Initialize results
resourceUsage = zeros(length(numUEs), 3); % [Unicast, Broadcast, Multicast]
reliability = zeros(length(numUEs), 3);
throughput = zeros(length(numUEs), 3);

for n = 1:length(numUEs)
    numUE = numUEs(n);
    
    % Generate random UE positions
    theta = 2 * pi * rand(numUE, 1);
    r = cellRadius * sqrt(rand(numUE, 1));
    uePositions = [r .* cos(theta), r .* sin(theta)];
    distances = sqrt(sum(uePositions.^2, 2));
    
    % Calculate SINR (simplified free-space path loss)
    pathLoss = 32.45 + 20 * log10(distances / 1000) + 20 * log10(3.5e9 / 1e6);
    receivedPower = txPower - pathLoss;
    sinr = receivedPower - noisePower;
    
    % Unicast Simulation
    rbsPerUE = ceil(dataRate / (bandwidth / numRBs * mean(mcsTable))); % RBs per UE
    resourceUsage(n, 1) = min(rbsPerUE * numUE, numRBs); % Cap at available RBs
    success = zeros(numUE, numSlots);
    for slot = 1:numSlots
        for ue = 1:numUE
            mcsIdx = find(sinr(ue) >= sinrThresholds, 1, 'last');
            if ~isempty(mcsIdx)
                success(ue, slot) = 1; % Successful reception
            end
        end
    end
    reliability(n, 1) = mean(mean(success)) * 100; % Percentage
    throughput(n, 1) = sum(success(:)) * dataRate / numSlots;
    
    % Broadcast Simulation
    fixedMCS = 4; % Fixed MCS for 95% coverage
    resourceUsage(n, 2) = ceil(dataRate / (bandwidth / numRBs * mcsTable(fixedMCS)));
    success = zeros(numUE, numSlots);
    for slot = 1:numSlots
        for ue = 1:numUE
            if sinr(ue) >= sinrThresholds(fixedMCS)
                success(ue, slot) = 1;
            end
        end
    end
    reliability(n, 2) = mean(mean(success)) * 100;
    throughput(n, 2) = sum(success(:)) * dataRate / numSlots;
    
    % Multicast Simulation
    resourceUsage(n, 3) = resourceUsage(n, 2); % Same RBs as broadcast
    success = zeros(numUE, numSlots);
    for slot = 1:numSlots
        minSINR = min(sinr); % Worst-case UE
        mcsIdx = find(minSINR >= sinrThresholds, 1, 'last');
        if ~isempty(mcsIdx)
            for ue = 1:numUE
                if sinr(ue) >= sinrThresholds(mcsIdx)
                    success(ue, slot) = 1;
                end
            end
        end
    end
    reliability(n, 3) = mean(mean(success)) * 100;
    throughput(n, 3) = sum(success(:)) * dataRate / numSlots;
end

% Plot and Save Results
% Resource Usage
figure;
plot(numUEs, resourceUsage(:, 1), 'b-o', 'LineWidth', 2, 'DisplayName', 'Unicast');
hold on;
plot(numUEs, resourceUsage(:, 2), 'r-s', 'LineWidth', 2, 'DisplayName', 'Broadcast');
plot(numUEs, resourceUsage(:, 3), 'g-^', 'LineWidth', 2, 'DisplayName', 'Multicast');
title('Resource Usage vs. Number of UEs');
xlabel('Number of UEs');
ylabel('Resource Blocks Used');
legend('show');
grid on;
saveas(gcf, 'resource_usage.png');

% Reliability
figure;
plot(numUEs, reliability(:, 1), 'b-o', 'LineWidth', 2, 'DisplayName', 'Unicast');
hold on;
plot(numUEs, reliability(:, 2), 'r-s', 'LineWidth', 2, 'DisplayName', 'Broadcast');
plot(numUEs, reliability(:, 3), 'g-^', 'LineWidth', 2, 'DisplayName', 'Multicast');
title('Reliability vs. Number of UEs');
xlabel('Number of UEs');
ylabel('Reliability (%)');
legend('show');
grid on;
saveas(gcf, 'reliability.png');

% Throughput
figure;
plot(numUEs, throughput(:, 1) / 1e6, 'b-o', 'LineWidth', 2, 'DisplayName', 'Unicast');
hold on;
plot(numUEs, throughput(:, 2) / 1e6, 'r-s', 'LineWidth', 2, 'DisplayName', 'Broadcast');
plot(numUEs, throughput(:, 3) / 1e6, 'g-^', 'LineWidth', 2, 'DisplayName', 'Multicast');
title('Throughput vs. Number of UEs');
xlabel('Number of UEs');
ylabel('Throughput (Mbps)');
legend('show');
grid on;
saveas(gcf, 'throughput.png');

% Comparison Plot
figure;
subplot(3, 1, 1);
plot(numUEs, resourceUsage(:, 1), 'b-o', 'LineWidth', 2, 'DisplayName', 'Unicast');
hold on;
plot(numUEs, resourceUsage(:, 2), 'r-s', 'LineWidth', 2, 'DisplayName', 'Broadcast');
plot(numUEs, resourceUsage(:, 3), 'g-^', 'LineWidth', 2, 'DisplayName', 'Multicast');
title('Comparison of Transmission Modes');
ylabel('Resource Blocks');
legend('show');
grid on;

subplot(3, 1, 2);
plot(numUEs, reliability(:, 1), 'b-o', 'LineWidth', 2, 'DisplayName', 'Unicast');
hold on;
plot(numUEs, reliability(:, 2), 'r-s', 'LineWidth', 2, 'DisplayName', 'Broadcast');
plot(numUEs, reliability(:, 3), 'g-^', 'LineWidth', 2, 'DisplayName', 'Multicast');
ylabel('Reliability (%)');
grid on;

subplot(3, 1, 3);
plot(numUEs, throughput(:, 1) / 1e6, 'b-o', 'LineWidth', 2, 'DisplayName', 'Unicast');
hold on;
plot(numUEs, throughput(:, 2) / 1e6, 'r-s', 'LineWidth', 2, 'DisplayName', 'Broadcast');
plot(numUEs, throughput(:, 3) / 1e6, 'g-^', 'LineWidth', 2, 'DisplayName', 'Multicast');
xlabel('Number of UEs');
ylabel('Throughput (Mbps)');
grid on;
saveas(gcf, 'comparison.png');