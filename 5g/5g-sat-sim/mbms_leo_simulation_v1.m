% MBMS over LEO Satellite Simulation with 5G Toolbox and DASH Streaming
% MATLAB R2024b, 5G Toolbox required
% Simulates TNAN architecture with Doppler effect, DASH video delivery via UPF
% Plots: Throughput vs. Latency, PER vs. Compensation, Packet Loss vs. Time

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
SIMULATION_DURATION_S = 1; % 1 second for packet loss tracking
TIME_STEP_MS = 10; % 10 ms time steps
UPF_LATENCY_MS = 5; % UPF forwarding latency
HTTP_LATENCY_MS = 10; % DASH server HTTP latency

% Calculate orbital speed and latency
orbital_radius_m = (EARTH_RADIUS_KM + LEO_ALTITUDE_KM) * 1000;
satellite_speed_ms = sqrt(GM / orbital_radius_m); % ~5266 m/s
propagation_latency_ms = (LEO_ALTITUDE_KM * 1000 / SPEED_OF_LIGHT) * 2 * 1000; % ~53.4 ms

% Doppler effect (static)
elevation_angle_deg = 30;
relative_velocity_ms = satellite_speed_ms * cosd(60); % ~2633 m/s
doppler_shift_hz = (relative_velocity_ms * CARRIER_FREQ_HZ) / SPEED_OF_LIGHT; % ~17553 Hz

% 5G NR Configuration (using 5G Toolbox)
carrier = nrCarrierConfig;
carrier.SubcarrierSpacing = 15; % 15 kHz
carrier.NSizeGrid = 52; % 10 MHz bandwidth
modulation = 'QPSK';
coding_rate = 0.5;
mbsConfig = struct('GroupID', 1);

% Initialize arrays for results
throughputs = zeros(SIMULATION_RUNS, 1);
latencies = zeros(SIMULATION_RUNS, 1);
compensation_levels = linspace(0, 1, SIMULATION_RUNS);
per_values = zeros(SIMULATION_RUNS, 1);
time_steps = (0:TIME_STEP_MS:SIMULATION_DURATION_S*1000)';
packet_loss = zeros(length(time_steps), SIMULATION_RUNS);

% Simulation loop
for run = 1:SIMULATION_RUNS
    doppler_compensation = compensation_levels(run);
    fprintf('Run %d: Doppler compensation = %.1f%%\n', run, doppler_compensation*100);

    % Initialize components
    core = struct('id', '5G_Core', 'registered_ues', containers.Map, 'mbms_sessions', containers.Map);
    upf = struct('id', 'UPF_1', 'core', core);
    tngf = struct('id', 'TNGF_1', 'core', core, 'upf', upf);
    gateway = struct('id', 'Satellite_GW', ...
                     'ues', repmat(struct('id', '', 'registered', false, 'session_active', false, ...
                                         'received_packets', 0, 'total_bytes', 0, ...
                                         'received_segments', {}), ...
                                   MBMS_BROADCAST_USERS, 1));
    
    % Populate UE fields
    for i = 1:MBMS_BROADCAST_USERS
        gateway.ues(i).id = sprintf('UE_%d', i);
        gateway.ues(i).received_segments = {}; % Initialize empty cell array for segments
    end

    % Step 1: UE Registration (RRC)
    for i = 1:MBMS_BROADCAST_USERS
        ue = gateway.ues(i);
        rrcMsg = struct('type', 'REGISTRATION_REQUEST', ...
                        'source', ue.id, ...
                        'destination', core.id, ...
                        'payload', struct('ue_id', ue.id));
        pause(NAS_SIGNALING_OVERHEAD_MS/1000);
        response = simulate_core_processing(core, rrcMsg);
        [response, ~] = simulate_gateway_transmit(response, doppler_compensation, doppler_shift_hz, CARRIER_FREQ_HZ, propagation_latency_ms);
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
    [response, ~] = simulate_gateway_transmit(response, doppler_compensation, doppler_shift_hz, CARRIER_FREQ_HZ, propagation_latency_ms);
    if ~isempty(response)
        for i = 1:MBMS_BROADCAST_USERS
            gateway.ues(i).session_active = true;
            fprintf('UE %s: MBMS session active\n', gateway.ues(i).id);
        end
        core.mbms_sessions(sessionMsg.payload.session_id) = true;
    end

    % Step 3: DASH Video Streaming via MBMS Broadcast
    fprintf('Run %d: Starting DASH video broadcast...\n', run);
    % Initialize DASH server and get video segments
    dash = dash_server();
    video_segments = dash.segments; % Get all segments
    total_video_bytes = sum([video_segments.size]); % Total bytes for playback check

    % Broadcast all segments to all UEs
    for seg_idx = 1:length(video_segments)
        segment = video_segments(seg_idx);
        num_packets = ceil(segment.size / PACKET_SIZE_BYTES); % Number of packets for segment
        mbmsBroadcast = struct('type', 'MBMS_DATA', ...
                               'source', gateway.id, ...
                               'destination', 'ALL_UES', ...
                               'payload', struct('size', PACKET_SIZE_BYTES, ...
                                                 'content', sprintf('DASH segment %d', seg_idx), ...
                                                 'segment_id', segment.id, ...
                                                 'segment_size', segment.size));
        for t_idx = 1:length(time_steps)
            for i = 1:MBMS_BROADCAST_USERS
                % Simulate transmission through UPF and satellite
                [packet, per] = simulate_upf_forward(mbmsBroadcast, upf, doppler_compensation, doppler_shift_hz, CARRIER_FREQ_HZ, propagation_latency_ms, UPF_LATENCY_MS);
                if ~isempty(packet)
                    gateway.ues(i).received_packets = gateway.ues(i).received_packets + 1;
                    gateway.ues(i).total_bytes = gateway.ues(i).total_bytes + packet.payload.size;
                    % Track unique segments
                    if ~ismember(packet.payload.segment_id, gateway.ues(i).received_segments)
                        gateway.ues(i).received_segments = [gateway.ues(i).received_segments, packet.payload.segment_id];
                    end
                    if t_idx == 1 % Log first attempt
                        fprintf('UE %s: Received DASH packet %d for segment %d\n', gateway.ues(i).id, gateway.ues(i).received_packets, seg_idx);
                    end
                else
                    packet_loss(t_idx, run) = packet_loss(t_idx, run) + 1;
                end
                if i == 1 && t_idx == 1 % Store PER for first UE, first attempt
                    per_values(run) = per;
                end
            end
        end
    end

    % Step 4: DASH Video Multicast (Premium Segment)
    fprintf('Run %d: Starting DASH video multicast...\n', run);
    premium_segment = video_segments(end); % Last segment as premium
    num_packets = ceil(premium_segment.size / PACKET_SIZE_BYTES);
    mbmsMulticast = struct('type', 'MBMS_DATA', ...
                           'source', gateway.id, ...
                           'destination', 'SELECTED_UES', ...
                           'payload', struct('size', PACKET_SIZE_BYTES, ...
                                             'content', sprintf('DASH premium segment %d', length(video_segments)), ...
                                             'segment_id', premium_segment.id, ...
                                             'segment_size', premium_segment.size));
    selected_ues = randsample(1:MBMS_BROADCAST_USERS, min(MBMS_MULTICAST_USERS, MBMS_BROADCAST_USERS))';
    for idx = 1:length(selected_ues)
        i = selected_ues(idx);
        for t_idx = 1:length(time_steps)
            [packet, ~] = simulate_upf_forward(mbmsMulticast, upf, doppler_compensation, doppler_shift_hz, CARRIER_FREQ_HZ, propagation_latency_ms, UPF_LATENCY_MS);
            if ~isempty(packet)
                if ~isnumeric(gateway.ues(i).received_packets)
                    error('Non-numeric received_packets for UE %d', i);
                end
                gateway.ues(i).received_packets = gateway.ues(i).received_packets + 1;
                gateway.ues(i).total_bytes = gateway.ues(i).total_bytes + packet.payload.size;
                if ~ismember(packet.payload.segment_id, gateway.ues(i).received_segments)
                    gateway.ues(i).received_segments = [gateway.ues(i).received_segments, packet.payload.segment_id];
                end
                if t_idx == 1
                    fprintf('UE %s: Received DASH multicast packet %d for premium segment\n', gateway.ues(i).id, gateway.ues(i).received_packets);
                end
            else
                packet_loss(t_idx, run) = packet_loss(t_idx, run) + 1;
            end
        end
    end

    % Step 5: Check Video Playback
    fprintf('Run %d: Checking video playback...\n', run);
    for i = 1:MBMS_BROADCAST_USERS
        received_bytes = gateway.ues(i).total_bytes;
        % Check if UE has enough data to play the video (4 Mbps * 10 s = 5 MB)
        if received_bytes >= total_video_bytes
            fprintf('UE %s: Playing video (received %.2f MB, required %.2f MB)\n', ...
                    gateway.ues(i).id, received_bytes/1e6, total_video_bytes/1e6);
        else
            fprintf('UE %s: Insufficient data for playback (received %.2f MB, required %.2f MB)\n', ...
                    gateway.ues(i).id, received_bytes/1e6, total_video_bytes/1e6);
        end
    end

    % Calculate metrics
    total_packets = sum(arrayfun(@(x) x.received_packets, gateway.ues(1:MBMS_BROADCAST_USERS)));
    total_bytes = sum(arrayfun(@(x) x.total_bytes, gateway.ues(1:MBMS_BROADCAST_USERS)));
    latency = propagation_latency_ms + NAS_SIGNALING_OVERHEAD_MS + UPF_LATENCY_MS + HTTP_LATENCY_MS;
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
title('Throughput vs Latency for DASH over LEO Satellite');
xlabel('Latency (ms)');
ylabel('Throughput (Mbps)');
grid on;
legend;
saveas(gcf, 'throughput_vs_latency.png');

% Plot PER vs Doppler Compensation
figure;
plot(compensation_levels * 100, per_values, 'r-', 'DisplayName', 'PER vs Compensation');
title('Packet Error Rate vs Doppler Compensation');
xlabel('Doppler Compensation (%)');
ylabel('Packet Error Rate');
grid on;
legend;
saveas(gcf, 'per_vs_compensation.png');

% Plot Packet Loss vs Time
figure;
hold on;
for run = 1:SIMULATION_RUNS
    plot(time_steps, cumsum(packet_loss(:, run)), 'DisplayName', sprintf('Run %d (%.1f%%)', run, compensation_levels(run)*100));
end
title('Cumulative Packet Loss vs Time');
xlabel('Time (ms)');
ylabel('Cumulative Packet Loss');
grid on;
legend;
saveas(gcf, 'packet_loss_vs_time.png');

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

function [transmitted, per] = simulate_gateway_transmit(msg, doppler_compensation, doppler_shift_hz, carrier_freq_hz, latency_ms)
    % Simulate satellite transmission with static Doppler effect
    pause(latency_ms / 1000);
    residual_doppler = doppler_shift_hz * (1 - doppler_compensation);
    per = 0.1 * abs(residual_doppler) / carrier_freq_hz;
    if rand() > per
        transmitted = msg;
    else
        transmitted = [];
    end
end

function [packet, per] = simulate_upf_forward(msg, upf, doppler_compensation, doppler_shift_hz, carrier_freq_hz, satellite_latency_ms, upf_latency_ms)
    % Simulate UPF forwarding to satellite
    pause(upf_latency_ms / 1000);
    [packet, per] = simulate_gateway_transmit(msg, doppler_compensation, doppler_shift_hz, carrier_freq_hz, satellite_latency_ms);
end