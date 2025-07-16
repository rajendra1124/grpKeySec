#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/nr-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("Multicast5G");

int main(int argc, char *argv[])
{
  double simTime = 1.0;
  uint16_t numUes = 10;
  std::string mcastGroup = "224.1.1.1";
  uint16_t port = 1234;

  // Logging (optional)
  LogComponentEnable("Multicast5G", LOG_LEVEL_INFO);
  LogComponentEnable("UdpClient", LOG_LEVEL_INFO);
  LogComponentEnable("UdpServer", LOG_LEVEL_INFO);

  NodeContainer gnb, ues;
  gnb.Create(1);
  ues.Create(numUes);

  // Mobility setup
  MobilityHelper mobility;
  mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel");
  mobility.Install(gnb);
  mobility.Install(ues);

  gnb.Get(0)->GetObject<MobilityModel>()->SetPosition(Vector(0, 0, 10));
  for (uint16_t i = 0; i < numUes; ++i)
  {
    ues.Get(i)->GetObject<MobilityModel>()->SetPosition(Vector(10 + 5 * i, 0, 1.5));
  }

  // NR + Beamforming setup
  Ptr<NrHelper> nrHelper = CreateObject<NrHelper>();
  nrHelper->SetSchedulerTypeId(TypeId::LookupByName("ns3::NrMacSchedulerTdmaRR"));
  Ptr<IdealBeamformingHelper> bfHelper = CreateObject<IdealBeamformingHelper>();
  nrHelper->SetBeamformingHelper(bfHelper);

  // Frequency + Bandwidth setup
  CcBwpCreator bwpCreator;
  CcBwpCreator::SimpleOperationBandConf bandConf(28e9, 100e6, 1); // 28 GHz, 100 MHz
  OperationBandInfo band = bwpCreator.CreateOperationBandContiguousCc(bandConf);
  nrHelper->InitializeOperationBand(&band);
  auto allBwps = band.GetBwps();

  // Device installation
  NetDeviceContainer gnbDevs = nrHelper->InstallGnbDevice(gnb, allBwps);
  NetDeviceContainer ueDevs = nrHelper->InstallUeDevice(ues, allBwps);
  nrHelper->UpdateDeviceConfigs(gnbDevs);
  nrHelper->UpdateDeviceConfigs(ueDevs);
  nrHelper->AttachToClosestGnb(ueDevs, gnbDevs);

  // Internet stack
  InternetStackHelper internet;
  internet.Install(gnb);
  internet.Install(ues);

  // IP addressing
  Ipv4AddressHelper ipv4;
  ipv4.SetBase("10.1.1.0", "255.255.255.0");
  Ipv4InterfaceContainer gnbIface = ipv4.Assign(gnbDevs);
  Ipv4InterfaceContainer ueIfaces = ipv4.Assign(ueDevs);

  // Multicast group
  Ipv4Address multicastGroup(mcastGroup.c_str());
  Ipv4StaticRoutingHelper staticRouting;

  // gNB multicast route setup
  Ptr<Ipv4> gnbIpv4 = gnb.Get(0)->GetObject<Ipv4>();
  Ptr<Ipv4StaticRouting> gnbStatic = staticRouting.GetStaticRouting(gnbIpv4);
  gnbStatic->SetDefaultMulticastRoute(1);  // Interface 1 (NR)

  // UEs join multicast group
  for (uint16_t i = 0; i < numUes; ++i)
  {
    Ptr<Ipv4> ipv4ue = ues.Get(i)->GetObject<Ipv4>();
    const uint32_t interfaceIndex = 1; // NR interface
    ipv4ue->JoinMulticastGroup(interfaceIndex, multicastGroup);
  }

  // Application: UDP multicast sender on gNB
  UdpClientHelper client(multicastGroup, port);
  client.SetAttribute("MaxPackets", UintegerValue(1000));
  client.SetAttribute("Interval", TimeValue(MilliSeconds(10)));
  client.SetAttribute("PacketSize", UintegerValue(1024));
  ApplicationContainer senderApps = client.Install(gnb.Get(0));
  senderApps.Start(Seconds(0.1));
  senderApps.Stop(Seconds(simTime));

  // UDP receivers on UEs
  UdpServerHelper server(port);
  ApplicationContainer receiverApps = server.Install(ues);
  receiverApps.Start(Seconds(0.0));
  receiverApps.Stop(Seconds(simTime));

  // Tracing packets received at UEs
  AsciiTraceHelper ascii;
  Ptr<OutputStreamWrapper> stream = ascii.CreateFileStream("ip-multicast.tr");
  for (uint16_t i = 0; i < numUes; ++i)
  {
    receiverApps.Get(i)->TraceConnectWithoutContext("Rx", MakeBoundCallback(
      [stream, i](Ptr<const Packet> packet) {
        *stream->GetStream() << Simulator::Now().GetSeconds()
                             << "\tUE[" << i << "]\tReceived " << packet->GetSize() << " bytes" << std::endl;
      }));
  }

  Simulator::Stop(Seconds(simTime));
  Simulator::Run();
  Simulator::Destroy();
  return 0;
}
