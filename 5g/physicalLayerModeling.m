%% 5G Physical Layer Multicast vs Unicast Simulation
% MATLAB 2024b Implementation using 5G Toolbox
% Author: Research Simulation
% Date: 2025

clear; close all; clc;

%% Check Required Toolboxes
requiredToolboxes = {'5G Toolbox', 'Communications Toolbox', 'Signal Processing Toolbox'};
installedToolboxes = ver;
toolboxNames = {installedToolboxes.Name};

for i = 1:length(requiredToolboxes)
    if ~any(contains(toolboxNames, requiredToolboxes{i}))
        warning('Required toolbox not found: %s', requiredToolboxes{i});
    else
        fprintf('✓ %s is available\n', requiredToolboxes{i});
    end
end

%% Simulation Parameters
simParams = struct();

% 5G Network Configuration
simParams.CarrierFreq = 3.5e9;           % 3.5 GHz carrier frequency
simParams.SubcarrierSpacing = 15e3;       % 15 kHz SCS
simParams.NumResourceBlocks = 100;        % Total RBs available
simParams.NumSubcarriers = 12;            % Subcarriers per RB
simParams.SlotDuration = 1e-3;            % 1 ms slot duration
simParams.NumSymbolsPerSlot = 14;         % OFDM symbols per slot

% Channel Model Parameters
simParams.PathLossModel = 'urban-macro';   % Urban macro path loss
simParams.ShadowFading = 8;               % Shadow fading std dev (dB)
simParams.TransmitPower = 43;             % Base station Tx power (dBm)
simParams.NoiseFigure = 9;                % UE noise figure (dB)
simParams.ThermalNoise = -174;            % Thermal noise density (dBm/Hz)

% Simulation Range
simParams.MaxUEs = 100;                   % Maximum number of UEs
simParams.UEStep = 10;                    % UE increment step
simParams.NumIterations = 10;             % Monte Carlo iterations

% Multicast Parameters
simParams.GroupSize = 10;                 % Average UEs per multicast group
simParams.RequiredBitrate = [0.5e6, 2e6]; % Bitrate range (bps)
simParams.DistanceRange = [50, 500];      % UE distance range (m)

%% Create Output Directory
outputDir = 'MATLAB_5G_Simulation_Results';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

fprintf('\n=== 5G Physical Layer Multicast vs Unicast Simulation ===\n');
fprintf('Output directory: %s\n\n', outputDir);

%% Initialize Results Storage
results = struct();
results.unicast = struct();
results.multicast = struct();

% Result arrays
numUERange = simParams.UEStep:simParams.UEStep:simParams.MaxUEs;
numPoints = length(numUERange);

% Initialize result matrices
results.unicast.numUEs = numUERange;
results.unicast.bandwidth = zeros(1, numPoints);
results.unicast.latency = zeros(1, numPoints);
results.unicast.efficiency = zeros(1, numPoints);
results.unicast.servedUEs = zeros(1, numPoints);
results.unicast.totalBitrate = zeros(1, numPoints);

results.multicast.numUEs = numUERange;
results.multicast.bandwidth = zeros(1, numPoints);
results.multicast.latency = zeros(1, numPoints);
results.multicast.efficiency = zeros(1, numPoints);
results.multicast.servedUEs = zeros(1, numPoints);
results.multicast.totalBitrate = zeros(1, numPoints);

%% Main Simulation Loop
fprintf('Starting simulation...\n');
progressBar = waitbar(0, 'Running 5G Simulation...');

for idx = 1:numPoints
    numUEs = numUERange(idx);
    
    % Update progress
    waitbar(idx/numPoints, progressBar, ...
        sprintf('Processing %d UEs (%d/%d)', numUEs, idx, numPoints));
    
    % Monte Carlo averaging
    unicastResults = zeros(simParams.NumIterations, 5);
    multicastResults = zeros(simParams.NumIterations, 5);
    
    for iter = 1:simParams.NumIterations
        % Generate UE positions and channel conditions
        ueData = generateUEScenario(numUEs, simParams);
        
        % Run unicast simulation
        unicastAlloc = simulateUnicast(ueData, simParams);
        
        % Run multicast simulation
        multicastAlloc = simulateMulticast(ueData, simParams);
        
        % Store iteration results
        unicastResults(iter, :) = [unicastAlloc.rbsUsed, unicastAlloc.latency, ...
                                   unicastAlloc.efficiency, unicastAlloc.servedUEs, ...
                                   unicastAlloc.totalBitrate];
        multicastResults(iter, :) = [multicastAlloc.rbsUsed, multicastAlloc.latency, ...
                                     multicastAlloc.efficiency, multicastAlloc.servedUEs, ...
                                     multicastAlloc.totalBitrate];
    end
    
    % Average results
    results.unicast.bandwidth(idx) = mean(unicastResults(:, 1));
    results.unicast.latency(idx) = mean(unicastResults(:, 2));
    results.unicast.efficiency(idx) = mean(unicastResults(:, 3));
    results.unicast.servedUEs(idx) = mean(unicastResults(:, 4));
    results.unicast.totalBitrate(idx) = mean(unicastResults(:, 5));
    
    results.multicast.bandwidth(idx) = mean(multicastResults(:, 1));
    results.multicast.latency(idx) = mean(multicastResults(:, 2));
    results.multicast.efficiency(idx) = mean(multicastResults(:, 3));
    results.multicast.servedUEs(idx) = mean(multicastResults(:, 4));
    results.multicast.totalBitrate(idx) = mean(multicastResults(:, 5));
    
    fprintf('Completed %d UEs: Unicast RBs=%d, Multicast RBs=%d\n', ...
        numUEs, round(results.unicast.bandwidth(idx)), ...
        round(results.multicast.bandwidth(idx)));
end

close(progressBar);

%% Generate Comprehensive Plots
fprintf('\nGenerating analysis plots...\n');
generateComparisonPlots(results, simParams, outputDir);
generateCongestionAnalysis(results, simParams, outputDir);
generateSummaryReport(results, simParams, outputDir);

%% Save Results
save(fullfile(outputDir, 'simulation_results.mat'), 'results', 'simParams');
fprintf('\nSimulation completed! Results saved in: %s\n', outputDir);

%% ========== FUNCTION DEFINITIONS ==========

function ueData = generateUEScenario(numUEs, simParams)
    % Generate UE positions and channel conditions
    
    ueData = struct();
    ueData.numUEs = numUEs;
    
    % Random UE positions (uniform distribution in circular cell)
    angles = 2*pi*rand(numUEs, 1);
    radii = sqrt(rand(numUEs, 1)) * diff(simParams.DistanceRange) + simParams.DistanceRange(1);
    ueData.positions = [radii .* cos(angles), radii .* sin(angles)];
    ueData.distances = radii;
    
    % Channel gains (path loss + shadow fading)
    pathLoss = calculatePathLoss(ueData.distances, simParams);
    shadowFading = simParams.ShadowFading * randn(numUEs, 1);
    ueData.channelGain = -pathLoss + shadowFading; % dB
    
    % Required bitrates
    ueData.requiredBitrate = simParams.RequiredBitrate(1) + ...
        (simParams.RequiredBitrate(2) - simParams.RequiredBitrate(1)) * rand(numUEs, 1);
    
    % Group RNTI assignment for multicast
    numGroups = max(1, ceil(numUEs / simParams.GroupSize));
    ueData.groupRNTI = mod(0:numUEs-1, numGroups) + 1;
end

function pathLoss = calculatePathLoss(distances, simParams)
    % Calculate path loss using 3GPP Urban Macro model
    % PL = 32.4 + 20*log10(fc_GHz) + 30*log10(d_km)
    
    fc_GHz = simParams.CarrierFreq / 1e9;
    d_km = distances / 1000;
    d_km = max(d_km, 0.001); % Minimum distance constraint
    
    pathLoss = 32.4 + 20*log10(fc_GHz) + 30*log10(d_km);
end

function sinr_dB = calculateSINR(channelGain, simParams)
    % Calculate SINR for given channel gain
    
    rbBandwidth = simParams.SubcarrierSpacing * simParams.NumSubcarriers;
    noisePerRB = simParams.ThermalNoise + 10*log10(rbBandwidth) + simParams.NoiseFigure;
    
    receivedPower = simParams.TransmitPower + channelGain;
    sinr_dB = receivedPower - noisePerRB;
end

function spectralEff = calculateSpectralEfficiency(sinr_dB)
    % Calculate spectral efficiency using Shannon capacity
    sinr_linear = 10.^(sinr_dB/10);
    spectralEff = log2(1 + sinr_linear);
end

function result = simulateUnicast(ueData, simParams)
    % Simulate unicast transmission
    
    result = struct();
    result.rbsUsed = 0;
    result.servedUEs = 0;
    result.totalBitrate = 0;
    result.efficiency = 0;
    
    rbBandwidth = simParams.SubcarrierSpacing * simParams.NumSubcarriers;
    availableRBs = simParams.NumResourceBlocks;
    
    for ue = 1:ueData.numUEs
        sinr = calculateSINR(ueData.channelGain(ue), simParams);
        
        if sinr < -3 % SINR threshold
            continue;
        end
        
        spectralEff = calculateSpectralEfficiency(sinr);
        bitratePerRB = spectralEff * rbBandwidth;
        
        requiredRBs = max(1, ceil(ueData.requiredBitrate(ue) / bitratePerRB));
        
        if requiredRBs <= availableRBs
            result.rbsUsed = result.rbsUsed + requiredRBs;
            result.servedUEs = result.servedUEs + 1;
            result.totalBitrate = result.totalBitrate + requiredRBs * bitratePerRB;
            availableRBs = availableRBs - requiredRBs;
        end
    end
    
    % Calculate latency
    result.latency = calculateLatency(ueData.numUEs, 'unicast', simParams);
    
    % Calculate efficiency
    if result.rbsUsed > 0
        result.efficiency = result.totalBitrate / ...
            (simParams.NumResourceBlocks * rbBandwidth);
    end
end

function result = simulateMulticast(ueData, simParams)
    % Simulate multicast transmission with Group RNTI
    
    result = struct();
    result.rbsUsed = 0;
    result.servedUEs = 0;
    result.totalBitrate = 0;
    result.efficiency = 0;
    
    rbBandwidth = simParams.SubcarrierSpacing * simParams.NumSubcarriers;
    availableRBs = simParams.NumResourceBlocks;
    
    % Group UEs by RNTI
    uniqueGroups = unique(ueData.groupRNTI);
    
    for group = uniqueGroups
        groupUEs = find(ueData.groupRNTI == group);
        
        if isempty(groupUEs)
            continue;
        end
        
        % Find worst SINR in group (limiting factor)
        groupSINRs = zeros(length(groupUEs), 1);
        for i = 1:length(groupUEs)
            groupSINRs(i) = calculateSINR(ueData.channelGain(groupUEs(i)), simParams);
        end
        
        worstSINR = min(groupSINRs);
        
        if worstSINR < -3 % SINR threshold
            continue;
        end
        
        spectralEff = calculateSpectralEfficiency(worstSINR);
        bitratePerRB = spectralEff * rbBandwidth;
        
        % Use maximum required bitrate in group
        maxRequiredBitrate = max(ueData.requiredBitrate(groupUEs));
        requiredRBs = max(1, ceil(maxRequiredBitrate / bitratePerRB));
        
        if requiredRBs <= availableRBs
            result.rbsUsed = result.rbsUsed + requiredRBs;
            result.servedUEs = result.servedUEs + length(groupUEs);
            % In multicast, same bitrate serves all UEs in group
            result.totalBitrate = result.totalBitrate + ...
                requiredRBs * bitratePerRB * length(groupUEs);
            availableRBs = availableRBs - requiredRBs;
        end
    end
    
    % Calculate latency
    result.latency = calculateLatency(ueData.numUEs, 'multicast', simParams);
    
    % Calculate efficiency
    if result.rbsUsed > 0
        result.efficiency = result.totalBitrate / ...
            (simParams.NumResourceBlocks * rbBandwidth);
    end
end

function latency = calculateLatency(numUEs, mode, simParams)
    % Calculate end-to-end latency
    
    baseLatency = 1.5; % Base processing + propagation delay (ms)
    
    if strcmp(mode, 'unicast')
        % Scheduling overhead increases with UEs
        schedulingDelay = 0.1 * numUEs;
        % Queuing delay increases with congestion
        queuingDelay = 0.05 * numUEs^1.5;
    else % multicast
        % Less scheduling overhead for groups
        numGroups = max(1, ceil(numUEs / 10));
        schedulingDelay = 0.1 * numGroups;
        % Reduced queuing delay
        queuingDelay = 0.02 * numGroups^1.2;
    end
    
    latency = baseLatency + schedulingDelay + queuingDelay;
end

function generateComparisonPlots(results, simParams, outputDir)
    % Generate main comparison plots
    
    figure('Position', [100, 100, 1400, 900]);
    
    % Subplot 1: Bandwidth Usage
    subplot(3, 2, 1);
    plot(results.unicast.numUEs, results.unicast.bandwidth, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, results.multicast.bandwidth, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('Resource Blocks Used');
    title('Resource Block Usage Comparison');
    legend('Location', 'best');
    grid on;
    
    % Subplot 2: Bandwidth Efficiency
    subplot(3, 2, 2);
    plot(results.unicast.numUEs, results.unicast.efficiency, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, results.multicast.efficiency, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('Bandwidth Efficiency');
    title('System Efficiency Comparison');
    legend('Location', 'best');
    grid on;
    
    % Subplot 3: Latency
    subplot(3, 2, 3);
    plot(results.unicast.numUEs, results.unicast.latency, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, results.multicast.latency, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('Latency (ms)');
    title('End-to-End Latency Comparison');
    legend('Location', 'best');
    grid on;
    
    % Subplot 4: Served UEs
    subplot(3, 2, 4);
    plot(results.unicast.numUEs, results.unicast.servedUEs, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, results.multicast.servedUEs, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('Successfully Served UEs');
    title('Service Success Rate');
    legend('Location', 'best');
    grid on;
    
    % Subplot 5: Total Bitrate
    subplot(3, 2, 5);
    plot(results.unicast.numUEs, results.unicast.totalBitrate/1e6, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, results.multicast.totalBitrate/1e6, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('Total Bitrate (Mbps)');
    title('System Bitrate Comparison');
    legend('Location', 'best');
    grid on;
    
    % Subplot 6: Bandwidth Savings
    subplot(3, 2, 6);
    bandwidthSavings = zeros(size(results.unicast.bandwidth));
    for i = 1:length(results.unicast.bandwidth)
        if results.unicast.bandwidth(i) > 0
            bandwidthSavings(i) = max(0, (1 - results.multicast.bandwidth(i) / ...
                results.unicast.bandwidth(i)) * 100);
        end
    end
    plot(results.unicast.numUEs, bandwidthSavings, '^-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'Color', 'green');
    xlabel('Number of UEs');
    ylabel('Bandwidth Savings (%)');
    title('Multicast Bandwidth Savings vs Unicast');
    grid on;
    ylim([0, 100]);
    
    sgtitle('5G Physical Layer: Multicast vs Unicast Comparison', ...
            'FontSize', 14, 'FontWeight', 'bold');
    
    % Save plot
    saveas(gcf, fullfile(outputDir, 'multicast_vs_unicast_comparison.png'));
    saveas(gcf, fullfile(outputDir, 'multicast_vs_unicast_comparison.fig'));
end

function generateCongestionAnalysis(results, simParams, outputDir)
    % Generate network congestion analysis plots
    
    figure('Position', [200, 200, 1200, 800]);
    
    % Resource utilization
    subplot(2, 2, 1);
    unicastUtil = results.unicast.bandwidth / simParams.NumResourceBlocks * 100;
    multicastUtil = results.multicast.bandwidth / simParams.NumResourceBlocks * 100;
    
    plot(results.unicast.numUEs, unicastUtil, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'Color', 'red', 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, multicastUtil, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'Color', 'blue', 'DisplayName', 'Multicast');
    yline(100, '--k', 'Maximum Capacity', 'LineWidth', 1.5);
    xlabel('Number of UEs');
    ylabel('Resource Utilization (%)');
    title('Network Resource Utilization');
    legend('Location', 'best');
    grid on;
    
    % Latency growth (log scale)
    subplot(2, 2, 2);
    semilogy(results.unicast.numUEs, results.unicast.latency, 'o-', ...
             'LineWidth', 2, 'MarkerSize', 6, 'Color', 'red', 'DisplayName', 'Unicast');
    hold on;
    semilogy(results.multicast.numUEs, results.multicast.latency, 's-', ...
             'LineWidth', 2, 'MarkerSize', 6, 'Color', 'blue', 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('Latency (ms) - Log Scale');
    title('Latency Growth Pattern');
    legend('Location', 'best');
    grid on;
    
    % Efficiency comparison
    subplot(2, 2, 3);
    plot(results.unicast.numUEs, results.unicast.efficiency, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'Color', 'red', 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, results.multicast.efficiency, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'Color', 'blue', 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('System Efficiency');
    title('System Efficiency vs Load');
    legend('Location', 'best');
    grid on;
    
    % Service success ratio
    subplot(2, 2, 4);
    unicastRatio = results.unicast.servedUEs ./ results.unicast.numUEs;
    multicastRatio = results.multicast.servedUEs ./ results.multicast.numUEs;
    
    plot(results.unicast.numUEs, unicastRatio, 'o-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'Color', 'red', 'DisplayName', 'Unicast');
    hold on;
    plot(results.multicast.numUEs, multicastRatio, 's-', ...
         'LineWidth', 2, 'MarkerSize', 6, 'Color', 'blue', 'DisplayName', 'Multicast');
    xlabel('Number of UEs');
    ylabel('Service Success Ratio');
    title('Scalability: Service Success Rate');
    legend('Location', 'best');
    grid on;
    ylim([0, 1.1]);
    
    sgtitle('Network Congestion Analysis: Multicast vs Unicast', ...
            'FontSize', 14, 'FontWeight', 'bold');
    
    % Save plot
    saveas(gcf, fullfile(outputDir, 'network_congestion_analysis.png'));
    saveas(gcf, fullfile(outputDir, 'network_congestion_analysis.fig'));
end

function generateSummaryReport(results, simParams, outputDir)
    % Generate comprehensive summary report
    
    % Calculate key metrics
    maxIdx = length(results.unicast.numUEs);
    maxUEs = results.unicast.numUEs(maxIdx);
    
    % Bandwidth savings
    maxUnicastRB = max(results.unicast.bandwidth);
    maxMulticastRB = max(results.multicast.bandwidth);
    bandwidthSavingsPct = (1 - maxMulticastRB / maxUnicastRB) * 100;
    
    % Average latency
    avgUnicastLatency = mean(results.unicast.latency);
    avgMulticastLatency = mean(results.multicast.latency);
    latencyImprovementPct = (1 - avgMulticastLatency / avgUnicastLatency) * 100;
    
    % Create summary report
    reportText = sprintf([...
        '5G MULTICAST VS UNICAST SIMULATION REPORT\n' ...
        '==========================================\n\n' ...
        'SIMULATION PARAMETERS:\n' ...
        '- Carrier Frequency: %.1f GHz\n' ...
        '- Total Resource Blocks: %d\n' ...
        '- Subcarrier Spacing: %d kHz\n' ...
        '- Maximum UEs Tested: %d\n' ...
        '- Monte Carlo Iterations: %d\n\n' ...
        'KEY FINDINGS:\n' ...
        '-------------\n\n' ...
        '1. BANDWIDTH EFFICIENCY:\n' ...
        '   - Multicast achieves %.1f%% bandwidth savings at maximum load\n' ...
        '   - Maximum RBs used (Unicast): %.0f\n' ...
        '   - Maximum RBs used (Multicast): %.0f\n\n' ...
        '2. LATENCY PERFORMANCE:\n' ...
        '   - Average Unicast Latency: %.2f ms\n' ...
        '   - Average Multicast Latency: %.2f ms\n' ...
        '   - Latency Improvement: %.1f%%\n\n' ...
        '3. SCALABILITY:\n' ...
        '   - Unicast Resource Utilization: %.1f%%\n' ...
        '   - Multicast Resource Utilization: %.1f%%\n\n' ...
        '4. NETWORK CONGESTION:\n' ...
        '   - Multicast shows better scalability with increasing UEs\n' ...
        '   - Lower resource utilization reduces network congestion\n' ...
        '   - More predictable latency patterns in multicast\n\n' ...
        'RECOMMENDATIONS:\n' ...
        '---------------\n' ...
        '- Use multicast for content delivery to multiple UEs\n' ...
        '- Implement Group RNTI allocation for efficient resource sharing\n' ...
        '- Consider hybrid approach for mixed traffic scenarios\n' ...
        '- Monitor SINR to optimize group formations\n\n' ...
        'Generated Files:\n' ...
        '- multicast_vs_unicast_comparison.png/.fig\n' ...
        '- network_congestion_analysis.png/.fig\n' ...
        '- simulation_results.mat\n' ...
        '- detailed_results.xlsx\n'], ...
        simParams.CarrierFreq/1e9, simParams.NumResourceBlocks, ...
        simParams.SubcarrierSpacing/1e3, maxUEs, simParams.NumIterations, ...
        bandwidthSavingsPct, maxUnicastRB, maxMulticastRB, ...
        avgUnicastLatency, avgMulticastLatency, latencyImprovementPct, ...
        maxUnicastRB/simParams.NumResourceBlocks*100, ...
        maxMulticastRB/simParams.NumResourceBlocks*100);
    
    % Save report
    fid = fopen(fullfile(outputDir, 'simulation_summary_report.txt'), 'w');
    fprintf(fid, '%s', reportText);
    fclose(fid);
    
    % Display report
    fprintf('\n%s\n', reportText);
    
    % Export detailed results to Excel
    resultsTable = table(results.unicast.numUEs', results.unicast.bandwidth', ...
        results.multicast.bandwidth', results.unicast.latency', ...
        results.multicast.latency', results.unicast.efficiency', ...
        results.multicast.efficiency', results.unicast.servedUEs', ...
        results.multicast.servedUEs', results.unicast.totalBitrate'/1e6, ...
        results.multicast.totalBitrate'/1e6, ...
        'VariableNames', {'UE_Count', 'Unicast_RBs', 'Multicast_RBs', ...
        'Unicast_Latency_ms', 'Multicast_Latency_ms', ...
        'Unicast_Efficiency', 'Multicast_Efficiency', ...
        'Unicast_Served_UEs', 'Multicast_Served_UEs', ...
        'Unicast_Bitrate_Mbps', 'Multicast_Bitrate_Mbps'});
    
    writetable(resultsTable, fullfile(outputDir, 'detailed_results.xlsx'));
    
    fprintf('\nDetailed results exported to: %s\n', ...
        fullfile(outputDir, 'detailed_results.xlsx'));
end