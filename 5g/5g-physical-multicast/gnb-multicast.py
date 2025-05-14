import random
import time
from dataclasses import dataclass
from typing import List, Dict
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Data structures
@dataclass
class UE:
    ue_id: int
    rrc_state: str  # "IDLE", "CONNECTED"
    g_rnti: int  # Group RNTI for multicast
    last_ack: bool  # Last transmission ACK/NACK

@dataclass
class MulticastPacket:
    packet_id: int
    data: str
    size: int  # in bytes
    slot: int

# RRC Layer
class RRCLayer:
    def __init__(self):
        self.ues: Dict[int, UE] = {}
        self.group_g_rnti = 1000  # Fixed G-RNTI for multicast group
        self.multicast_configured = False

    def connect_ue(self, ue_id: int) -> bool:
        """Simulate RRC connection setup for a UE."""
        if ue_id not in self.ues:
            self.ues[ue_id] = UE(ue_id=ue_id, rrc_state="IDLE", g_rnti=0, last_ack=False)
        if self.ues[ue_id].rrc_state == "IDLE":
            logging.info(f"RRC: UE {ue_id} initiating connection setup")
            # Simulate RRC Connection Request, Setup, and Complete
            self.ues[ue_id].rrc_state = "CONNECTED"
            logging.info(f"RRC: UE {ue_id} moved to CONNECTED state")
            return True
        return False

    def configure_multicast_group(self, ue_ids: List[int]) -> bool:
        """Configure multicast session for a group of UEs."""
        if self.multicast_configured:
            logging.warning("RRC: Multicast group already configured")
            return False
        for ue_id in ue_ids:
            if ue_id in self.ues and self.ues[ue_id].rrc_state == "CONNECTED":
                self.ues[ue_id].g_rnti = self.group_g_rnti
                logging.info(f"RRC: UE {ue_id} assigned G-RNTI {self.group_g_rnti} for multicast")
            else:
                logging.error(f"RRC: UE {ue_id} not connected, cannot join multicast")
                return False
        self.multicast_configured = True
        logging.info("RRC: Multicast group configured successfully")
        return True

# MAC Layer
class MACLayer:
    def __init__(self):
        self.slot_number = 0
        self.resource_blocks = 100  # Available RBs per slot
        self.multicast_tb_size = 1000  # Transport block size in bytes

    def schedule_multicast(self, packet: MulticastPacket, g_rnti: int) -> bool:
        """Schedule a multicast packet for transmission."""
        if self.resource_blocks >= 20:  # Assume 20 RBs needed for multicast
            self.resource_blocks -= 20
            packet.slot = self.slot_number
            logging.info(f"MAC: Scheduled multicast packet {packet.packet_id} in slot {self.slot_number}, G-RNTI {g_rnti}")
            self.slot_number += 1
            self.resource_blocks = 100  # Reset for next slot
            return True
        logging.warning("MAC: Insufficient resources for multicast")
        return False

# PHY Layer
class PHYLayer:
    def __init__(self):
        self.channel_reliability = 0.9  # 90% chance of successful transmission

    def transmit_multicast(self, packet: MulticastPacket, ues: List[UE]) -> Dict[int, bool]:
        """Simulate multicast transmission to all UEs in the group."""
        results = {}
        logging.info(f"PHY: Transmitting multicast packet {packet.packet_id} in slot {packet.slot}")
        for ue in ues:
            # Simulate channel conditions
            success = random.random() < self.channel_reliability
            results[ue.ue_id] = success
            ue.last_ack = success
            status = "ACK" if success else "NACK"
            logging.info(f"PHY: UE {ue.ue_id} received packet {packet.packet_id} -> {status}")
        return results

# gNB Simulator
class GNBSimulator:
    def __init__(self):
        self.rrc = RRCLayer()
        self.mac = MACLayer()
        self.phy = PHYLayer()
        self.packet_counter = 0

    def setup_multicast_group(self, ue_ids: List[int]):
        """Set up the multicast group with RRC and connect UEs."""
        for ue_id in ue_ids:
            self.rrc.connect_ue(ue_id)
        self.rrc.configure_multicast_group(ue_ids)

    def send_multicast_packet(self, data: str, size: int) -> Dict[int, bool]:
        """Send a multicast packet to the group."""
        self.packet_counter += 1
        packet = MulticastPacket(packet_id=self.packet_counter, data=data, size=size, slot=0)
        
        # MAC scheduling
        if not self.mac.schedule_multicast(packet, self.rrc.group_g_rnti):
            logging.error("gNB: Failed to schedule multicast packet")
            return {}
        
        # PHY transmission
        multicast_ues = [ue for ue in self.rrc.ues.values() if ue.g_rnti == self.rrc.group_g_rnti]
        results = self.phy.transmit_multicast(packet, multicast_ues)
        return results

    def run_simulation(self, num_packets: int):
        """Run a simulation sending multiple multicast packets."""
        ue_ids = [1, 2, 3, 4, 5]  # Five UEs
        self.setup_multicast_group(ue_ids)
        
        for i in range(num_packets):
            logging.info(f"gNB: Preparing packet {i+1}")
            results = self.send_multicast_packet(data=f"Multicast data packet {i+1}", size=1000)
            if results:
                logging.info(f"gNB: Packet {i+1} transmission results: {results}")
            time.sleep(1)  # Simulate slot timing
            logging.info("-" * 50)

if __name__ == "__main__":
    gnb = GNBSimulator()
    gnb.run_simulation(num_packets=3)  # Send 3 multicast packets