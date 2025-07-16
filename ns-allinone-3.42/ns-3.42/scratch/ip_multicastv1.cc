#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/nr-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("Multicast5G");

static void RxTrace(Ptr<OutputStreamWrapper> stream, uint32_t ueIndex, Ptr<const Packet> packet)
{
  *stream->GetStream() << Simulator::Now().GetSeconds()
                       << "\tUE[" << ueIndex << "]\tReceived "
                       << packet->GetSize() << " bytes" << std::endl;
}

int main(int argc, char *argv[])
{
  double simTime = 1.0;
  uint16_t numUes = 10;
  Ipv4Address multicastGroup("224.1.1.1");
  uint16_t port = 1234;

  NodeContainer gnb, ues;
  gnb.Create(1);
  ues.Create(numUes);

  MobilityHelper mob;
  mob.SetMobilityModel("ns3::ConstantPositionMobilityModel");
  mob.Install(gnb);
  mob.Install(ues);
  gnb.Get(0)->GetObject<MobilityModel>()->SetPosition(Vector(0.0, 0.0, 10.0));
  for (uint16_t i = 0; i < numUes; ++i)
  {
    ues.Get(i)->GetObject<MobilityModel>()->SetPosition(Vector(10 + i * 5.0, 0.0, 1.5));
  }

  Ptr<NrHelper> nr = CreateObject<NrHelper>();
  nr->SetSchedulerTypeId(TypeId::LookupByName("ns3::NrMacSchedulerTdmaRR"));
  nr->SetBeamformingHelper(CreateObject<IdealBeamformingHelper>());

  CcBwpCreator bwp;
  auto band = bwp.CreateOperationBandContiguousCc({28e9, 100e6, 1});
  nr->InitializeOperationBand(&band);
  auto bwps = band.GetBwps();

  auto gnbDevs = nr->InstallGnbDevice(gnb, bwps);
  auto ueDevs = nr->InstallUeDevice(ues, bwps);
  nr->UpdateDeviceConfigs(gnbDevs);
  nr->UpdateDeviceConfigs(ueDevs);
  nr->AttachToClosestGnb(ueDevs, gnbDevs);

  InternetStackHelper internet;
  internet.Install(gnb);
  internet.Install(ues);

  Ipv4AddressHelper ipv4;
  ipv4.SetBase("10.1.1.0", "255.255.255.0");
  ipv4.Assign(gnbDevs);
  ipv4.Assign(ueDevs);

  Ipv4StaticRoutingHelper mrt;
  Ptr<Ipv4StaticRouting> gnbRt = mrt.GetStaticRouting(gnb.Get(0)->GetObject<Ipv4>());
  gnbRt->SetDefaultMulticastRoute(1);

  for (uint16_t i = 0; i < numUes; ++i)
  {
    auto ipv4ue = ues.Get(i)->GetObject<Ipv4>();
    Ptr<Ipv4StaticRouting> ueRt = mrt.GetStaticRouting(ipv4ue);
    ueRt->AddMulticastRoute(Ipv4Address::GetAny(), multicastGroup, 1, {1});
  }

  UdpClientHelper client(multicastGroup, port);
  client.SetAttribute("MaxPackets", UintegerValue(1000));
  client.SetAttribute("Interval", TimeValue(MilliSeconds(10)));
  client.SetAttribute("PacketSize", UintegerValue(1024));
  ApplicationContainer senderApp = client.Install(gnb.Get(0));
  senderApp.Start(Seconds(1));
  senderApp.Stop(Seconds(simTime));

  UdpServerHelper server(port);
  ApplicationContainer receiverApps = server.Install(ues);
  receiverApps.Start(Seconds(0.0));
  receiverApps.Stop(Seconds(simTime));

  AsciiTraceHelper ascii;
  auto stream = ascii.CreateFileStream("ip-multicast.tr");
  for (uint16_t i = 0; i < numUes; ++i)
  {
    // receiverApps.Get(i)->TraceConnectWithoutContext(
    //     "Rx", MakeCallback(&RxTrace, stream, i));
    receiverApps.Get(i)->TraceConnectWithoutContext(
    "Rx", MakeBoundCallback(&RxTrace, stream, i));

  }

  Simulator::Stop(Seconds(simTime));
  Simulator::Run();
  Simulator::Destroy();

  return 0;
}

