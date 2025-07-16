#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/nr-module.h"
#include "ns3/applications-module.h"
#include "ns3/point-to-point-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("Unicast5G");

static void RxTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Packet> packet)
{
  *stream->GetStream() << Simulator::Now().GetSeconds() << "\t" << packet->GetSize() << std::endl;
}

int main(int argc, char *argv[])
{
  double simTime = 1.0; // seconds
  uint16_t numUes = 10;
  uint16_t numerology = 0; // Subcarrier spacing
  double centralFrequency = 28e9; // FR2 (mmWave)
  double bandwidth = 100e6; // 100 MHz

  // Enable detailed logging
  LogComponentEnable("Unicast5G", LOG_LEVEL_INFO);
  LogComponentEnable("NrHelper", LOG_LEVEL_DEBUG);
  LogComponentEnable("NrMacSchedulerTdma", LOG_LEVEL_DEBUG);

  // Create nodes
  NodeContainer gnbNodes, ueNodes;
  gnbNodes.Create(1);
  ueNodes.Create(numUes);

  // Mobility
  MobilityHelper mobility;
  mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel");
  mobility.Install(gnbNodes);
  mobility.Install(ueNodes);
  Ptr<MobilityModel> gnbMob = gnbNodes.Get(0)->GetObject<MobilityModel>();
  gnbMob->SetPosition(Vector(0, 0, 10));
  for (uint16_t i = 0; i < numUes; ++i)
    {
      Ptr<MobilityModel> ueMob = ueNodes.Get(i)->GetObject<MobilityModel>();
      ueMob->SetPosition(Vector(10 + i * 5, 0, 1.5));
    }

  // NR helper
  Ptr<NrHelper> nrHelper = CreateObject<NrHelper>();
  Ptr<IdealBeamformingHelper> beamformingHelper = CreateObject<IdealBeamformingHelper>();
  nrHelper->SetBeamformingHelper(beamformingHelper);
  nrHelper->SetSchedulerTypeId(TypeId::LookupByName("ns3::NrMacSchedulerTdmaRR"));

  // Bandwidth part configuration using CcBwpCreator
  CcBwpCreator ccBwpCreator;
  CcBwpCreator::SimpleOperationBandConf bandConf(centralFrequency, bandwidth, 1);
  OperationBandInfo band = ccBwpCreator.CreateOperationBandContiguousCc(bandConf);
  nrHelper->InitializeOperationBand(&band);
  BandwidthPartInfoPtrVector allBwps = band.GetBwps();

  // Install NR devices
  NetDeviceContainer gnbDevs = nrHelper->InstallGnbDevice(gnbNodes, allBwps);
  NetDeviceContainer ueDevs = nrHelper->InstallUeDevice(ueNodes, allBwps);
  NS_ASSERT_MSG(gnbDevs.Get(0) != nullptr, "gNB device is null");
  NS_ASSERT_MSG(ueDevs.Get(0) != nullptr, "UE device is null");
  NS_LOG_INFO("gnbDevs size: " << gnbDevs.GetN());
  NS_LOG_INFO("ueDevs size: " << ueDevs.GetN());

  nrHelper->UpdateDeviceConfigs(gnbDevs);
  nrHelper->UpdateDeviceConfigs(ueDevs);

  nrHelper->AttachToClosestGnb(ueDevs, gnbDevs);

  // Internet stack
  InternetStackHelper internet;
  internet.Install(gnbNodes);
  internet.Install(ueNodes);

  // IP configuration
  Ipv4AddressHelper ipv4;
  ipv4.SetBase("10.1.1.0", "255.255.255.0");
  Ipv4InterfaceContainer ueIpIface = ipv4.Assign(ueDevs);

  // Application: UDP unicast
  ApplicationContainer clientApps;
  for (uint16_t i = 0; i < numUes; ++i)
    {
      UdpClientHelper client(ueIpIface.GetAddress(i), 1234);
      client.SetAttribute("MaxPackets", UintegerValue(1000));
      client.SetAttribute("PacketSize", UintegerValue(1024));
      client.SetAttribute("Interval", TimeValue(MilliSeconds(10)));
      clientApps.Add(client.Install(gnbNodes.Get(0)));
    }
  clientApps.Start(Seconds(0.1));
  clientApps.Stop(Seconds(simTime));

  UdpServerHelper server(1234);
  ApplicationContainer serverApps = server.Install(ueNodes);
  serverApps.Start(Seconds(0.05));
  serverApps.Stop(Seconds(simTime));

  // Enable tracing
  AsciiTraceHelper ascii;
  Ptr<OutputStreamWrapper> stream = ascii.CreateFileStream("unicast_5g.tr");
  for (uint16_t i = 0; i < numUes; ++i)
    {
      serverApps.Get(i)->TraceConnectWithoutContext("Rx", MakeBoundCallback(&RxTrace, stream));
    }

  // Run simulation
  Simulator::Stop(Seconds(simTime));
  Simulator::Run();
  Simulator::Destroy();

  return 0;
}