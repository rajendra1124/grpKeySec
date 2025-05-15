% MBMS over LEO Satellite Simulation with 5G Toolbox
% MATLAB R2024b, 5G Toolbox required
% Simulates TNAN architecture with Doppler effect and compensation
% Plots throughput vs. latency

clear all;
clc;

% Constants
LEO_ALTITUDE_KM = 8000;
EARTH_RADIUS_KM = 6371;
GM = 3.986e14; % Earth's gravitational constant (m^3/s^2)
SPEED_OF_LIGHT = 3e8; % m/s
CARRIER_FREQ_HZ = 2e9; % 2 GHz
SATELLITE_BANDWIDTH_MBPS = 10;
PACKET_SIZE_BYTES = 1500;
NAS_SIGNALING_OVERHEAD_MS = 50;
MBMS_BROADCAST_USERS = 100;
MBMS_MULTICAST_USERS = 10;
SIMULATION_RUNS = 10;

% Calculate orbital speed and latency
orbital_radius_m = (EARTH_RADIUS_KM + LEO_ALTITUDE_KM) * 1000;
satellite_speed_ms = sqrt(GM / orbital_radius_m); % ~5266 m/s
propagation_latency_ms = (LEO_ALTITUDE_KM * 1000 / SPEED_OF_LIGHT) * 2 * 1000; % ~53.4 ms

% Doppler effect
elevation_angle_deg = 30;
relative_velocity_ms = satellite_speed_ms * cosd(60); % ~2633 m/s
doppler_shift_hz = (relative_velocity_ms * CARRIER_FREQ_HZ) / SPEED_OF_LIGHT; % ~17553 Hz

% 5G NR Configuration (using 5G Toolbox)
carrier = nrCarrierConfig;
carrier.SubcarrierSpacing = 15; % 15 kHz
carrier.NSizeGrid = 52; % 10 MHz bandwidth
modulation = 'QPSK'; % Manual MCS configuration
coding_rate = 0.5; % Example coding rate
mbsConfig = struct('GroupID', 1); % Simplified MBMS configuration

% Initialize arrays for results
throughputs = zeros(SIMULATION_RUNS, 1);
latencies = zeros(SIMULATION_RUNS, 1);
compensation_levels = linspace(0, 1, SIMULATION_RUNS);

% Simulation loop
for run = 1:SIMULATION_RUNS
    doppler_compensation = compensation_levels(run);
    fprintf('Run %d: Doppler compensation = %.1f%%\n', run, doppler_compensation*100);

    % Initialize components
    core = struct('id', '5G_Core', 'registered_ues', containers.Map, 'mbms_sessions', containers.Map);
    tngf = struct('id', 'TNGF_1', 'core', core);
    
    % Initialize gateway with structure array for UEs
    gateway = struct('id', 'Satellite_GW', ...
                     'ues', repmat(struct('id', '', 'registered', false, 'session_active', false, ...
                                         'received_packets', 0, 'total_bytes', 0), ...
                                   MBMS_BROADCAST_USERS, 1));
    
    % Populate UE fields
    for i = 1:MBMS_BROADCAST_USERS
        gateway.ues(i).id = sprintf('UE_%d', i);
    end

    % Step 1: UE Registration (RRC)
    for i = 1:MBMS_BROADCAST_USERS
        ue = gateway.ues(i);
        % Simulate RRC Connection Setup (NAS over N1)
        rrcMsg = struct('type', 'REGISTRATION_REQUEST', ...
                        'source', ue.id, ...
                        'destination', core.id, ...
                        'payload', struct('ue_id', ue.id));
        % Forward through TNGF and Gateway
        pause(NAS_SIGNALING_OVERHEAD_MS/1000); % Simulate signaling delay
        response = simulate_core_processing(core, rrcMsg);
        response = simulate_gateway_transmit(response, doppler_compensation, propagation_latency_ms, doppler_shift_hz, CARRIER_FREQ_HZ);
        if ~isempty(response)
            gateway.ues(i).registered = true;
            fprintf('UE %s: Registered with core network\n', ue.id);
            core.registered_ues(ue.id) = true;
        end
    end

    % Step 2: MBMS Session Setup (RRC)
    sessionMsg = struct('type', 'SESSION_REQUEST', ...
                        'source', gateway.ues(1).id, ...
                        'destination', core.id, ...
                        'payload', struct('session_id', sprintf('MBMS_Session_%d', run)));
    pause(NAS_SIGNALING_OVERHEAD_MS/1000);
    response = simulate_core_processing(core, sessionMsg);
    response = simulate_gateway_transmit(response, doppler_compensation, propagation_latency_ms, doppler_shift_hz, CARRIER_FREQ_HZ);
    if ~isempty(response)
        for i = 1:MBMS_BROADCAST_USERS
            gateway.ues(i).session_active = true;
            fprintf('UE %s: MBMS session active\n', gateway.ues(i).id);
        end
        core.mbms_sessions(sessionMsg.payload.session_id) = true;
    end

    % Step 3: MBMS Broadcast (MAC/PHY)
    mbmsBroadcast = struct('type', 'MBMS_DATA', ...
                           'source', gateway.id, ...
                           'destination', 'ALL_UES', ...
                           'payload', struct('size', PACKET_SIZE_BYTES, 'content', 'Broadcast TV data'));
    fprintf('Run %d: Starting MBMS broadcast...\n', run);
    for i = 1:MBMS_BROADCAST_USERS
        % Simulate PHY transmission with Doppler
        transmitted = simulate_gateway_transmit(mbmsBroadcast, doppler_compensation, propagation_latency_ms, doppler_shift_hz, CARRIER_FREQ_HZ);
        if ~isempty(transmitted)
            gateway.ues(i).received_packets = gateway.ues(i).received_packets + 1;
            gateway.ues(i).total_bytes = gateway.ues(i).total_bytes + transmitted.payload.size;
            fprintf('UE %s: Received MBMS packet %d\n', gateway.ues(i).id, gateway.ues(i).received_packets);
        end
    end

    % Step 4: MBMS Multicast (MAC/PHY)
    mbmsMulticast = struct('type', 'MBMS_DATA', ...
                           'source', gateway.id, ...
                           'destination', 'SELECTED_UES', ...
                           'payload', struct('size', PACKET_SIZE_BYTES, 'content', 'Multicast premium content'));
    fprintf('Run %d: Starting MBMS multicast...\n', run);
    selected_ues = randsample(1:MBMS_BROADCAST_USERS, min(MBMS_MULTICAST_USERS, MBMS_BROADCAST_USERS))';
    for idx = 1:length(selected_ues)
        i = selected_ues(idx);
        transmitted = simulate_gateway_transmit(mbmsMulticast, doppler_compensation, propagation_latency_ms, doppler_shift_hz, CARRIER_FREQ_HZ);
        if ~isempty(transmitted)
            if ~isnumeric(gateway.ues(i).received_packets)
                error('Non-numeric received_packets for UE %d', i);
            end
            gateway.ues(i).received_packets = gateway.ues(i).received_packets + 1;
            gateway.ues(i).total_bytes = gateway.ues(i).total_bytes + transmitted.payload.size;
            fprintf('UE %s: Received MBMS packet %d\n', gateway.ues(i).id, gateway.ues(i).received_packets);
        end
    end

    % Calculate metrics
    total_packets = sum(arrayfun(@(x) x.received_packets, gateway.ues(1:MBMS_BROADCAST_USERS)));
    total_bytes = sum(arrayfun(@(x) x.total_bytes, gateway.ues(1:MBMS_BROADCAST_USERS)));
    latency = propagation_latency_ms + NAS_SIGNALING_OVERHEAD_MS;
    throughput_mbps = (total_bytes * 8 / 1e6) / (latency / 1000);
    throughputs(run) = throughput_mbps;
    latencies(run) = latency;
    fprintf('Run %d: Throughput = %.2f Mbps, Latency = %.2f ms\n', run, throughput_mbps, latency);
end

% Plot throughput vs latency
figure;
plot(latencies, throughputs, 'b--', 'DisplayName', 'Simulation Runs');
hold on;
scatter(latencies, throughputs, 'b', 'filled', 'DisplayName', 'Data Points');
title('Throughput vs Latency for MBMS over LEO Satellite');
xlabel('Latency (ms)');
ylabel('Throughput (Mbps)');
grid on;
legend;
saveas(gcf, 'throughput_vs_latency.png');

% Helper functions
function response = simulate_core_processing(core, msg)
    if strcmp(msg.type, 'REGISTRATION_REQUEST')
        response = struct('type', 'REGISTRATION_ACCEPT', ...
                          'source', core.id, ...
                          'destination', msg.source, ...
                          'payload', struct('status', 'registered'));
    elseif strcmp(msg.type, 'SESSION_REQUEST')
        response = struct('type', 'SESSION_ACCEPT', ...
                          'source', core.id, ...
                          'destination', msg.source, ...
                          'payload', struct('session_id', msg.payload.session_id, 'status', 'active'));
    else
        response = [];
    end
end

function transmitted = simulate_gateway_transmit(msg, doppler_compensation, latency_ms, doppler_shift_hz, carrier_freq_hz)
    % Simulate satellite transmission with Doppler effect
    pause(latency_ms / 1000);
    residual_doppler = doppler_shift_hz * (1 - doppler_compensation);
    per = 0.1 * abs(residual_doppler) / carrier_freq_hz;
    if rand() > per
        transmitted = msg;
    else
        transmitted = [];
    end
end