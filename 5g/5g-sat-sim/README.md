#MBMS over LEO Satellite Simulation
Overview
This project simulates the delivery of Multimedia Broadcast Multicast Service (MBMS) over a Low Earth Orbit (LEO) satellite network integrated with a 5G core, based on the 3GPP-inspired Trusted Non-3GPP Access (TNAN) architecture. The simulation is implemented in MATLAB R2024b using the 5G Toolbox to model Radio Resource Control (RRC), Medium Access Control (MAC), and Physical (PHY) layers. It accounts for satellite-specific challenges, such as the Doppler effect due to the satellite’s high velocity, and evaluates the impact of Doppler compensation on throughput and latency.
The simulation models a LEO satellite at 8000 km altitude, calculates Doppler shift for a 2 GHz carrier frequency, and simulates MBMS broadcast and multicast to 100 User Equipments (UEs). It outputs a plot of throughput (Mbps) vs. latency (ms), demonstrating how Doppler compensation improves performance.
Objectives

#Simulate MBMS delivery (broadcast and multicast) over a LEO satellite network.
Model 5G NR protocols (RRC, MAC, PHY) using MATLAB’s 5G Toolbox.
Incorporate Doppler effect and compensation, calculating its impact on packet error rate (PER).
Simulate UE registration, MBMS session setup, and data transmission via a Satellite Gateway (TNAP) and Trusted Non-3GPP Gateway Function (TNGF).
Visualize throughput vs. latency for varying Doppler compensation levels (0% to 100%).

What We Did
We developed a MATLAB script (mbms_leo_simulation.m) that:
Modeled LEO Satellite Dynamics:
Altitude: 8000 km.
Orbital speed: ~5.27 km/s (calculated using orbital mechanics).
Propagation latency: ~53.4 ms round-trip.
Doppler shift: ~17.553 kHz for a 2 GHz carrier at 30° elevation angle.

#Simulated 5G NR Protocols:
RRC: Simulated NAS signaling over the N1 interface for UE registration and MBMS session setup using simplified structs.
MAC: Modeled resource allocation for MBMS broadcast/multicast.
PHY: Simulated satellite link transmission with Doppler-induced PER, using QPSK modulation and a 0.5 coding rate.


#Implemented MBMS:
Broadcast: Delivered data (e.g., TV content) to all 100 UEs.
Multicast: Delivered premium content to a subset of 10 UEs.
Packet size: 1500 bytes, with a 10 Mbps satellite bandwidth.


Handled Doppler Effect:

Calculated Doppler shift based on relative velocity (~2633 m/s at 30° elevation).
Modeled PER as proportional to residual Doppler shift after compensation.
Ran 10 iterations with Doppler compensation from 0% to 100%.


Generated Metrics and Visualization:

Calculated throughput (Mbps) and latency (~103.4 ms, including signaling overhead).
Plotted throughput vs. latency, saved as throughput_vs_latency.png.


Addressed Implementation Challenges:

Fixed syntax errors (e.g., incomplete Doppler shift calculation).
Resolved MATLAB R2024b-specific issues (e.g., cell array assignment errors, non-numeric field errors).
Adapted to missing 5G Toolbox functions (nrMCSConfig, nrMBSConfig) by using manual configurations.



How We Did It
Tools and Environment

MATLAB R2024b with 5G Toolbox for 5G NR protocol modeling.
MATLAB Script: mbms_leo_simulation.m (single-file implementation).
GitHub: Repository for version control and documentation.

Approach

System Design:

Modeled components: 5G Core, TNGF, Satellite Gateway (TNAP), and 100 UEs.
Used a structure array for UEs to store state (ID, registration, packets received, etc.).
Defined satellite parameters: 8000 km altitude, 10 MHz bandwidth, 2 GHz carrier.


Doppler Effect Modeling:

Calculated orbital speed: ( v = \sqrt{\frac{GM}{r}} \approx 5266 , \text{m/s} ).
Relative velocity: ( v_r = v \cdot \cos(60^\circ) \approx 2633 , \text{m/s} ) (30° elevation).
Doppler shift: ( f_d = \frac{v_r \cdot f_c}{c} \approx 17553 , \text{Hz} ).
PER: ( 0.1 \cdot \frac{|\text{residual_doppler}|}{f_c} ), reduced by compensation.


5G Protocol Simulation:

RRC: Simulated NAS messages (e.g., REGISTRATION_REQUEST, SESSION_REQUEST) with ~50 ms signaling overhead.
MAC/PHY: Modeled MBMS data transmission with Doppler-induced packet loss.
Used nrCarrierConfig for 5G NR setup (15 kHz subcarrier spacing, 10 MHz bandwidth).
Substituted missing nrMCSConfig and nrMBSConfig with manual QPSK and struct-based MBMS configuration.


Simulation Flow:

Initialization: Set up core, TNGF, gateway, and UEs.
Registration: Each UE registers with the 5G core via TNGF and gateway.
Session Setup: One UE initiates an MBMS session, activated for all UEs.
Broadcast: Transmitted data to all UEs, affected by Doppler PER.
Multicast: Transmitted data to 10 randomly selected UEs.
Metrics: Calculated throughput and latency over 10 runs.


Error Handling:

Fixed cell array assignment errors by switching to a structure array for UEs.
Corrected syntax errors in Doppler shift calculation.
Resolved non-numeric field errors in multicast loop by validating indices and field types.
Adapted to MATLAB R2024b limitations by avoiding unavailable 5G Toolbox functions.


Visualization:

Used MATLAB’s plotting functions to create a throughput vs. latency scatter plot.
Saved the plot as throughput_vs_latency.png.



Key Calculations

Latency: Propagation (53.4 ms) + signaling (50 ms) = ~103.4 ms.
Throughput: ( \frac{\text{total_bytes} \cdot 8}{10^6 \cdot \text{latency}/1000} ), affected by Doppler PER.
Doppler Shift: ~17.553 kHz, reduced by compensation (0% to 100%).
PER: Proportional to residual Doppler, impacting packet reception.

Repository Structure
├── mbms_leo_simulation.m  # Main MATLAB script for the simulation
├── README.md              # Project documentation (this file)
└── throughput_vs_latency.png  # Output plot (generated after running the script)

Prerequisites

MATLAB R2024b with 5G Toolbox installed and licensed.
A system with sufficient memory and processing power to run MATLAB simulations.

How to Run

Clone the Repository:
git clone https://github.com/your-username/mbms-leo-simulation.git
cd mbms-leo-simulation


Verify MATLAB Setup:

Ensure MATLAB R2024b is installed.
Confirm 5G Toolbox is available by running ver in MATLAB.
If missing, install via MATLAB’s Add-Ons menu or contact your license administrator.


#Run the Simulation:
Open MATLAB and navigate to the repository folder.
Execute the script:mbms_leo_simulation

Monitor the command window for simulation progress (e.g., UE registration, packet reception, metrics).
Check the output plot throughput_vs_latency.png in the working directory.


#Expected Output:
Console output showing simulation steps (e.g., "Run 1: Doppler compensation = 0.0%", "UE UE_0: Received MBMS packet 1").
Final metrics (e.g., "Run 1: Throughput = 1.89 Mbps, Latency = 103.40 ms").
A plot (throughput_vs_latency.png) showing throughput vs. latency for 10 runs.


#Troubleshooting
Error: "Unrecognized function or variable 'nrCarrierConfig'":
Ensure 5G Toolbox is installed (ver should list it).
Reinstall via MATLAB’s Add-Ons if needed.


Non-numeric field errors:
Run clear all; close all; clc; to reset the workspace.
Verify gateway.ues initialization in the script.


Other MATLAB errors:
Check MATLAB R2024b compatibility and toolbox licensing.
Share error messages for debugging assistance.



Results

Throughput: Ranges from ~1.89 Mbps (0% Doppler compensation) to ~2.12 Mbps (100% compensation) due to reduced PER.
Latency: Constant at ~103.4 ms (propagation + signaling).
Plot: throughput_vs_latency.png shows throughput increasing with Doppler compensation, validating the impact of compensation on MBMS performance.

Limitations

Simplified MBMS/MCS: Uses manual QPSK and coding rate (0.5) due to unavailable nrMCSConfig and nrMBSConfig in R2024b.
Doppler Model: Assumes fixed 30° elevation angle; dynamic angles would improve realism.
PHY Layer: Doppler affects PER; a full nrChannel model would be more accurate.
Single Satellite: No handovers or constellation modeling.
MATLAB R2024b: Version-specific quirks required workarounds (e.g., structure array instead of cell array).

Future Improvements

Detailed 5G Protocols: Integrate nrDLSCH or nrPDSCH for MBMS (per 3GPP TS 23.247).
Dynamic Doppler: Model varying elevation angles over time.
Advanced PHY: Use nrChannel with Doppler frequency offsets.
Multi-Satellite: Simulate handovers and constellations.
Additional Metrics: Plot PER vs. compensation, packet loss vs. time.
Satellite Toolbox: Use MATLAB’s Satellite Communications Toolbox for precise orbital dynamics.

Contributing
Contributions are welcome! To contribute:

Fork the repository.
Create a feature branch (git checkout -b feature/YourFeature).
Commit changes (git commit -m "Add YourFeature").
Push to the branch (git push origin feature/YourFeature).
Open a pull request.

Please include tests and documentation for new features.
License
This project is licensed under the MIT License. See the LICENSE file for details.
Acknowledgments

Built with MATLAB R2024b and 5G Toolbox.
Inspired by 3GPP TNAN architecture and MBMS specifications.
Developed to address real-world satellite communication challenges, including Doppler effect compensation.

