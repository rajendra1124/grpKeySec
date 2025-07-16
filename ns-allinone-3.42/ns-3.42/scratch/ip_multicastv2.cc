#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/nr-module.h"
#include "ns3/nr-eps-bearer.h"
#include "ns3/eps-bearer.h"
#include "ns3/epc-tft.h"  // Added for EpcTft

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("5gNrMulticastExample");

// Packet receive callback
static void ReceivePacket (Ptr<Socket> socket)
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
static void SendMulticastPacket (Ptr<Socket> socket, uint32_t size)
{
  Ptr<Packet> packet = Create<Packet> (size);
  socket->Send (packet);
  NS_LOG_INFO ("At " << Simulator::Now ().GetSeconds () << "s: gNB sent " 
               << size << " bytes to multicast group");
}

// Create multicast receiver socket
static Ptr<Socket> CreateUdpMulticastReceiveSocket (Ptr<Node> node, Ipv4Address multicastGroup, uint16_t port)
{
  Ptr<Socket> socket = Socket::CreateSocket (node, UdpSocketFactory::GetTypeId ());
  InetSocketAddress local = InetSocketAddress (Ipv4Address::GetAny(), port);
  
  if (socket->Bind (local) == -1)
    NS_FATAL_ERROR ("Failed to bind socket");

  socket->SetRecvCallback (MakeCallback (&ReceivePacket));
  return socket;
}

// Create multicast sender socket
static Ptr<Socket> CreateUdpMulticastSendSocket (Ptr<Node> node, Ipv4Address multicastGroup, uint16_t port)
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

  // 5G NR parameters
  uint16_t numUes = 3;
  uint16_t multicastPort = 12345;
  Ipv4Address multicastGroup ("239.255.0.1");
  double frequency = 28e9; // 28 GHz mmWave
  double bandwidth = 100e6; // 100 MHz
  uint16_t numerology = 2; // μ = 2

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
      positionAlloc->Add(Vector(30, 0, 0));  // UEs at 30m from gNB
  mobility.SetPositionAllocator(positionAlloc);
  mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel");
  mobility.Install(gnbNodes);
  mobility.Install(ueNodes);

  // Create 5G NR helpers
  Ptr<NrHelper> nrHelper = CreateObject<NrHelper> ();
  Ptr<NrPointToPointEpcHelper> epcHelper = CreateObject<NrPointToPointEpcHelper> ();
  nrHelper->SetEpcHelper (epcHelper);

  // Configure 5G NR spectrum
  BandwidthPartInfoPtrVector allBwps;
  CcBwpCreator ccBwpCreator;
  const uint8_t numCcPerBand = 1; // Single component carrier
  
  CcBwpCreator::SimpleOperationBandConf bandConf (frequency, bandwidth, numCcPerBand, BandwidthPartInfo::UMi_StreetCanyon);
  OperationBandInfo band = ccBwpCreator.CreateOperationBandContiguousCc (bandConf);
  nrHelper->InitializeOperationBand (&band);
  allBwps = CcBwpCreator::GetAllBwps ({band});

  // Antenna configuration
  nrHelper->SetSchedulerTypeId (TypeId::LookupByName ("ns3::NrMacSchedulerTdmaRR"));
  nrHelper->SetGnbPhyAttribute ("Numerology", UintegerValue (numerology));
  nrHelper->SetGnbAntennaAttribute ("NumRows", UintegerValue (4));
  nrHelper->SetGnbAntennaAttribute ("NumColumns", UintegerValue (8));

  // Install 5G NR devices
  NetDeviceContainer gnbDevs = nrHelper->InstallGnbDevice (gnbNodes, allBwps);
  NetDeviceContainer ueDevs = nrHelper->InstallUeDevice (ueNodes, allBwps);

  // Assign IP addresses to UEs
  Ipv4InterfaceContainer ueIpIfaces = epcHelper->AssignUeIpv4Address (ueDevs);

  // Attach UEs to gNB - using the correct method for ns-3.42
  for (uint32_t i = 0; i < ueNodes.GetN (); ++i)
  {
      // Register UE with EPC
      epcHelper->AddUe (ueDevs.Get(i), ueNodes.Get(i)->GetId());
      
      // Create default EPS bearer
      GbrQosInformation qos;
      qos.gbrDl = 1e6; // Downlink GBR
      qos.gbrUl = 1e6; // Uplink GBR
      qos.mbrDl = 1e6; // Downlink MBR
      qos.mbrUl = 1e6; // Uplink MBR
      
      EpsBearer bearer (EpsBearer::NGBR_VIDEO_TCP_DEFAULT, qos);
      Ptr<EpcTft> tft = Create<EpcTft> ();
      epcHelper->ActivateEpsBearer (ueDevs.Get(i), bearer, tft);
      
      // Attach UE to the closest gNB
      nrHelper->AttachToClosestGnb (ueDevs.Get(i), gnbDevs);
  }

  // Connect remote host to 5G core (SGW)
  PointToPointHelper p2ph;
  p2ph.SetDeviceAttribute ("DataRate", DataRateValue (DataRate ("100Gb/s")));
  p2ph.SetDeviceAttribute ("Mtu", UintegerValue (1500));
  p2ph.SetChannelAttribute ("Delay", TimeValue (Seconds (0.010)));
  
  NetDeviceContainer internetDevices = p2ph.Install (epcHelper->GetSgwNode (), remoteHost);
  
  // Assign IP addresses
  Ipv4AddressHelper ipv4h;
  ipv4h.SetBase ("1.0.0.0", "255.0.0.0");
  Ipv4InterfaceContainer internetIpIfaces = ipv4h.Assign (internetDevices);
  
  // Set up routing
  Ipv4StaticRoutingHelper ipv4RoutingHelper;
  
  // Configure remote host routing
  Ptr<Ipv4StaticRouting> remoteHostStaticRouting = ipv4RoutingHelper.GetStaticRouting (remoteHost->GetObject<Ipv4> ());
  remoteHostStaticRouting->AddNetworkRouteTo (epcHelper->GetUeDefaultGatewayAddress(), Ipv4Mask ("255.0.0.0"), 1);
  
  // Configure SGW routing
  Ptr<Ipv4> sgwIpv4 = epcHelper->GetSgwNode ()->GetObject<Ipv4> ();
  Ptr<Ipv4StaticRouting> sgwStaticRouting = ipv4RoutingHelper.GetStaticRouting (sgwIpv4);
  
  // Add multicast route on SGW
  std::vector<uint32_t> outputInterfaces;
  outputInterfaces.push_back(internetDevices.Get(0)->GetIfIndex());
  sgwStaticRouting->AddMulticastRoute (Ipv4Address::GetAny(), multicastGroup, 1, outputInterfaces);
  
  // Configure UEs for multicast
  for (uint32_t i = 0; i < ueNodes.GetN(); ++i)
  {
      Ptr<Node> ue = ueNodes.Get(i);
      Ptr<Ipv4> ueIpv4 = ue->GetObject<Ipv4> ();
      Ptr<Ipv4StaticRouting> ueStaticRouting = ipv4RoutingHelper.GetStaticRouting (ueIpv4);
      ueStaticRouting->SetDefaultRoute (epcHelper->GetUeDefaultGatewayAddress(), 1);
  }

  // Create multicast receive sockets on UEs
  for (uint16_t i = 0; i < numUes; i++)
      CreateUdpMulticastReceiveSocket (ueNodes.Get(i), multicastGroup, multicastPort);

  // Create multicast send socket on remote host
  Ptr<Socket> senderSocket = CreateUdpMulticastSendSocket (remoteHost, multicastGroup, multicastPort);

  // Schedule multicast packets
  for (uint32_t i = 1; i <= 5; i++)
      Simulator::Schedule (Seconds (i), &SendMulticastPacket, senderSocket, 1024);

  // Enable tracing
  p2ph.EnablePcapAll ("5g-nr-multicast");
  AsciiTraceHelper ascii;
  p2ph.EnableAsciiAll (ascii.CreateFileStream ("5g-nr-multicast.tr"));

  // Enable NR PHY/MAC tracing
  nrHelper->EnableTraces();
  
  // Enable RLC and PDCP traces
  Config::SetDefault("ns3::NrHelper::EnableRlcTraces", BooleanValue(true));
  Config::SetDefault("ns3::NrHelper::EnablePdcpTraces", BooleanValue(true));

  Simulator::Stop (Seconds (10.0));
  Simulator::Run ();
  Simulator::Destroy ();

  return 0;
}
