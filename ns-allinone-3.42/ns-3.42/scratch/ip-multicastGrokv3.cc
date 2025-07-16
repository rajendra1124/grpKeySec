#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/nr-module.h"
#include "ns3/config-store-module.h"
#include "ns3/antenna-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("5gNrMulticastExample");

// Packet receive callback
void ReceivePacket (Ptr<Socket> socket)
{
  Address from;
  Ptr<Packet> packet;
  while ((packet = socket->RecvFrom (from)))
    {
      InetSocketAddress address = InetSocketAddress::ConvertFrom (from);
      NS_LOG_INFO ("At " << Simulator::Now ().GetSeconds () << "s: UE received "
                   << packet->GetSize () << " bytes from "
                   << address.GetIpv4 ());
    }
}

// Multicast packet sender
void SendMulticastPacket (Ptr<Socket> socket, uint32_t size)
{
  Ptr<Packet> packet = Create<Packet> (size);
  socket->Send (packet);
  NS_LOG_INFO ("At " << Simulator::Now ().GetSeconds () << "s: gNB sent " 
               << size << " bytes to multicast group");
}

// Create multicast receiver socket
Ptr<Socket> CreateUdpMulticastReceiveSocket (Ptr<Node> node, Ipv4Address multicastGroup, uint16_t port)
{
  Ptr<Socket> socket = Socket::CreateSocket (node, UdpSocketFactory::GetTypeId ());
  InetSocketAddress local = InetSocketAddress (Ipv4Address::GetAny(), port);
  
  if (socket->Bind (local) == -1)
    {
      NS_FATAL_ERROR ("Failed to bind socket for node " << node->GetId());
    }

  Ptr<Ipv4> ipv4 = node->GetObject<Ipv4>();
  Ptr<NetDevice> dev = node->GetDevice(0);
  int32_t interface = ipv4->GetInterfaceForDevice(dev);
  
  if (interface == -1)
    {
      NS_FATAL_ERROR("Failed to find interface for device on node " << node->GetId());
    }
  
  socket->SetRecvCallback (MakeCallback (&ReceivePacket));
  ipv4->AddMulticastAddress(multicastGroup, interface);
  
  return socket;
}

// Create multicast sender socket
Ptr<Socket> CreateUdpMulticastSendSocket (Ptr<Node> node, Ipv4Address multicastGroup, uint16_t port)
{
  Ptr<Socket> socket = Socket::CreateSocket (node, UdpSocketFactory::GetTypeId ());
  InetSocketAddress remote = InetSocketAddress (multicastGroup, port);
  socket->SetAllowBroadcast (true);
  socket->Connect (remote);
  return socket;
}

int main (int argc, char *argv[])
{
  Time::SetResolution (Time::NS);
  LogComponentEnable ("5gNrMulticastExample", LOG_LEVEL_INFO);

  // Command line arguments
  uint16_t numUes = 3;
  uint16_t multicastPort = 12345;
  Ipv4Address multicastGroup ("239.255.0.1");
  double frequency = 28e9; // 28 GHz mmWave
  double bandwidth = 100e6; // 100 MHz
  uint16_t numerology = 2; // μ = 2
  std::string tracePrefix = "5g-multicast-ue"; // Prefix for trace files

  CommandLine cmd;
  cmd.AddValue ("numUes", "Number of UEs", numUes);
  cmd.AddValue ("frequency", "Carrier frequency", frequency);
  cmd.AddValue ("bandwidth", "Bandwidth", bandwidth);
  cmd.AddValue ("numerology", "Numerology index", numerology);
  cmd.Parse (argc, argv);

  // Create nodes
  NodeContainer remoteHostContainer;
  remoteHostContainer.Create (1);
  Ptr<Node> remoteHost = remoteHostContainer.Get (0);

  NodeContainer ueNodes;
  ueNodes.Create (numUes);

  NodeContainer gnbNodes;
  gnbNodes.Create (1);

  // Install internet stack
  InternetStackHelper internet;
  internet.Install (remoteHostContainer);
  internet.Install (ueNodes);
  internet.Install (gnbNodes);

  // Setup mobility
  MobilityHelper mobility;
  Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator>();
  positionAlloc->Add(Vector(0, 0, 0));  // gNB position
  for (uint16_t i = 0; i < numUes; i++)
    {
      positionAlloc->Add(Vector(30.0 * (i + 1), 0, 0));  // UEs spread out
    }
  mobility.SetPositionAllocator(positionAlloc);
  mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel");
  mobility.Install(gnbNodes);
  mobility.Install(ueNodes);

  // Create 5G NR helpers
  Ptr<NrPointToPointEpcHelper> epcHelper = CreateObject<NrPointToPointEpcHelper> ();
  Ptr<NrHelper> nrHelper = CreateObject<NrHelper> ();
  nrHelper->SetEpcHelper (epcHelper);

  // Configure 5G NR spectrum
  BandwidthPartInfoPtrVector allBwps;
  CcBwpCreator ccBwpCreator;
  const uint8_t numCcPerBand = 1;
  
  CcBwpCreator::SimpleOperationBandConf bandConf (frequency, bandwidth, numCcPerBand, BandwidthPartInfo::UMi_StreetCanyon);
  OperationBandInfo band = ccBwpCreator.CreateOperationBandContiguousCc (bandConf);
  nrHelper->InitializeOperationBand (&band);
  allBwps = CcBwpCreator::GetAllBwps ({band});

  // Antenna configuration
  nrHelper->SetSchedulerTypeId (TypeId::LookupByName("ns3::NrMacSchedulerTdmaRR"));
  nrHelper->Set
