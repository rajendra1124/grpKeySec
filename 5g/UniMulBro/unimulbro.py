import matplotlib.pyplot as plt
import numpy as np

# Simulation Parameters
numUEs = [5, 10,15, 20, 25,30,35, 40, 45,50,55, 60, 65, 70, 75,80, 85, 90, 95, 100, 110, 120, 130, 140, 150]  # Low, medium, high user densities
cellRadius = 500  # Cell radius in meters
bandwidth = 20e6  # 20 MHz bandwidth
numRBs = 100  # Number of resource blocks per slot
txPower = 40  # Transmit power in dBm
noisePower = -90  # Noise power in dBm
dataRate = 4e6  # 4 Mbps CBR traffic
numSlots = 100  # Number of slots to simulate
mcsTable = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]  # Simplified MCS (bits/symbol)
sinrThresholds = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]  # SINR thresholds (dB)
blerTarget = 0.1  # Target BLER of 10%

# Initialize results
perUEDataRate = np.zeros((len(numUEs), 2))  # [Unicast, Multicast]
reliability = np.zeros((len(numUEs), 2))
rbUsage = np.zeros((len(numUEs), 2))
throughput = np.zeros((len(numUEs), 2))
bler = np.zeros((len(numUEs), 2))

for n in range(len(numUEs)):
    numUE = numUEs[n]
    
    # Generate random UE positions
    theta = 2 * np.pi * np.random.rand(numUE)
    r = cellRadius * np.sqrt(np.random.rand(numUE))
    distances = np.sqrt(r**2)
    
    # Calculate SINR (simplified free-space path loss)
    pathLoss = 32.45 + 20 * np.log10(distances / 1000) + 20 * np.log10(3.5e9 / 1e6)
    receivedPower = txPower - pathLoss
    sinr = receivedPower - noisePower
    
    # Unicast Simulation
    rbsPerUE = np.ceil(dataRate / (bandwidth / numRBs * np.mean(mcsTable)))  # RBs per UE
    rbUsage[n, 0] = min(rbsPerUE * numUE, numRBs)  # Cap at available RBs
    success = np.zeros((numUE, numSlots))
    ueDataRates = np.zeros(numUE)
    ueBLER = np.zeros(numUE)
    for ue in range(numUE):
        mcsIdx = np.searchsorted(sinrThresholds, sinr[ue], side='right') - 1
        if mcsIdx >= 0:
            ueDataRates[ue] = mcsTable[mcsIdx] * (bandwidth / numRBs) * rbsPerUE
            success[ue, :] = np.random.rand(numSlots) > blerTarget  # Simplified BLER model
            ueBLER[ue] = 1 - np.mean(success[ue, :])
    perUEDataRate[n, 0] = np.mean(ueDataRates) / 1e6  # Mbps
    reliability[n, 0] = np.mean(np.mean(success, axis=1)) * 100  # Percentage
    throughput[n, 0] = np.sum(success) * dataRate / numSlots / 1e6  # Mbps
    bler[n, 0] = np.mean(ueBLER) * 100  # Percentage
    
    # Multicast Simulation
    rbUsage[n, 1] = rbsPerUE  # Fixed RBs for group
    minSINR = np.min(sinr)
    mcsIdx = np.searchsorted(sinrThresholds, minSINR, side='right') - 1
    groupDataRate = 0
    if mcsIdx >= 0:
        groupDataRate = mcsTable[mcsIdx] * (bandwidth / numRBs) * rbsPerUE
    success = np.zeros((numUE, numSlots))
    ueBLER = np.zeros(numUE)
    for ue in range(numUE):
        if sinr[ue] >= sinrThresholds[mcsIdx] and mcsIdx >= 0:
            success[ue, :] = np.random.rand(numSlots) > blerTarget
            ueBLER[ue] = 1 - np.mean(success[ue, :])
    perUEDataRate[n, 1] = groupDataRate / 1e6  # Same for all UEs
    reliability[n, 1] = np.mean(np.mean(success, axis=1)) * 100
    throughput[n, 1] = np.sum(success) * dataRate / numSlots / 1e6
    bler[n, 1] = np.mean(ueBLER) * 100

# Plot and Save Graphs
# Per UE Data Rate
plt.figure(figsize=(8, 6))
plt.plot(numUEs, perUEDataRate[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, perUEDataRate[:, 1], 'g-^', label='Multicast')
plt.title('Per UE Data Rate vs. Number of UEs')
plt.xlabel('Number of UEs')
plt.ylabel('Data Rate (Mbps)')
plt.legend()
plt.grid(True)
plt.savefig('per_ue_data_rate.png')
plt.close()

# Reliability
plt.figure(figsize=(8, 6))
plt.plot(numUEs, reliability[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, reliability[:, 1], 'g-^', label='Multicast')
plt.title('Reliability vs. Number of UEs')
plt.xlabel('Number of UEs')
plt.ylabel('Reliability (%)')
plt.legend()
plt.grid(True)
plt.savefig('reliability.png')
plt.close()

# RB Usage
plt.figure(figsize=(8, 6))
plt.plot(numUEs, rbUsage[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, rbUsage[:, 1], 'g-^', label='Multicast')
plt.title('Resource Block Usage vs. Number of UEs')
plt.xlabel('Number of UEs')
plt.ylabel('Resource Blocks Used')
plt.legend()
plt.grid(True)
plt.savefig('rb_usage.png')
plt.close()

# Throughput
plt.figure(figsize=(8, 6))
plt.plot(numUEs, throughput[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, throughput[:, 1], 'g-^', label='Multicast')
plt.title('Total Throughput vs. Number of UEs')
plt.xlabel('Number of UEs')
plt.ylabel('Throughput (Mbps)')
plt.legend()
plt.grid(True)
plt.savefig('throughput.png')
plt.close()

# BLER
plt.figure(figsize=(8, 6))
plt.plot(numUEs, bler[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, bler[:, 1], 'g-^', label='Multicast')
plt.title('Block Error Rate vs. Number of UEs')
plt.xlabel('Number of UEs')
plt.ylabel('BLER (%)')
plt.legend()
plt.grid(True)
plt.savefig('bler.png')
plt.close()

# Comparison Plot
plt.figure(figsize=(10, 15))
plt.subplot(5, 1, 1)
plt.plot(numUEs, perUEDataRate[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, perUEDataRate[:, 1], 'g-^', label='Multicast')
plt.title('Comparison of Unicast and Multicast Metrics')
plt.ylabel('Data Rate (Mbps)')
plt.legend()
plt.grid(True)

plt.subplot(5, 1, 2)
plt.plot(numUEs, reliability[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, reliability[:, 1], 'g-^', label='Multicast')
plt.ylabel('Reliability (%)')
plt.legend()
plt.grid(True)

plt.subplot(5, 1, 3)
plt.plot(numUEs, rbUsage[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, rbUsage[:, 1], 'g-^', label='Multicast')
plt.ylabel('Resource Blocks')
plt.legend()
plt.grid(True)

plt.subplot(5, 1, 4)
plt.plot(numUEs, throughput[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, throughput[:, 1], 'g-^', label='Multicast')
plt.ylabel('Throughput (Mbps)')
plt.legend()
plt.grid(True)

plt.subplot(5, 1, 5)
plt.plot(numUEs, bler[:, 0], 'b-o', label='Unicast')
plt.plot(numUEs, bler[:, 1], 'g-^', label='Multicast')
plt.xlabel('Number of UEs')
plt.ylabel('BLER (%)')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('comparison.png')
plt.close()