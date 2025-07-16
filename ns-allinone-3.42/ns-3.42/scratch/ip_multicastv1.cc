#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/nr-module.h"
#include "ns3/applications-module.h"
#include "ns3/mobility-module.h"

using namespace ns3;

int main(int argc, char *argv[])
{
  double simTime = 1.0;
  uint16_t numUes = 10;
  std::string mcastGroup = "224.1.1.1";
  uint16_t port = 1234;

  NodeContainer gnb, ues;
  gnb.Create(1);
  ues.Create(numUes);

  // Mobility setup (optional)
  MobilityHelper mob;
  mob.SetMobilityModel("ns3::ConstantPositionMobilityModel");
  mob.Install(gnb);
  mob.Install(ues);
  gnb.Get(0)->GetObject<MobilityModel>()->SetPosition(Vector(0,0,10));
  for (uint16_t i = 0; i < numUes; ++i)
    ues.Get(i)->GetObject<MobilityModel>()->SetPosition(Vector(10 + 5*i,0,1.5));

  // NR setup
  Ptr<NrHelper> nr = CreateObject<NrHelper>();
  nr->SetSchedulerTypeId(TypeId::LookupByName("ns3::NrMacSchedulerTdmaRR"));
  Ptr<IdealBeamformingHelper> bf = CreateObject<IdealBeamformingHelper>();
  nr->SetBeamformingHelper(bf);

  CcBwpCreator bwpCreator;
  CcBwpCreator::SimpleOperationBandConf bandConf(28e9, 100e6, 1);
  OperationBandInfo band = bwpCreator.CreateOperationBandContiguousCc(bandConf);
  nr->InitializeOperationBand(&band);
  auto bwps = band.GetBwps();

  auto gnbDevs = nr->InstallGnbDevice(gnb, bwps);
  auto ueDevs = nr->InstallUeDevice(ues, bwps);
  nr->UpdateDeviceConfigs(gnbDevs);
  nr->UpdateDeviceConfigs(ueDevs);
  nr->AttachToClosestGnb(ueDevs, gnbDevs);

  // IP stack
  InternetStackHelper ipstack;
  ipstack.Install(gnb);
  ipstack.Install(ues);

  Ipv4AddressHelper ipv4;
  ipv4.SetBase("10.1.1.0", "255.255.255.0");
  auto gnbIface = ipv4.Assign(gnbDevs);
  auto ueIfaces = ipv4.Assign(ueDevs);

  // Enable multicast routing on gNB
  Ipv4StaticRoutingHelper mrt;
  Ptr<Ipv4> gnbIpv4 = gnb.Get(0)->GetObject<Ipv4>();
  Ptr<Ipv4StaticRouting> gnbStatic = mrt.GetStaticRouting(gnbIpv4);
  gnbStatic->SetDefaultMulticastRoute(1); // send multicast via NR interface

  // UEs join the multicast group
  Ipv4Address mGroupAddr(mcastGroup.c_str());
  for (uint16_t i = 0; i < numUes; ++i)
  {
    Ptr<Ipv4> ipv4ue = ues.Get(i)->GetObject<Ipv4>();
    Ptr<Ipv4StaticRouting> staticRoute = mrt.GetStaticRouting(ipv4ue);
    staticRoute->AddMulticastRoute(mGroupAddr, 1, ipv4ue->GetInterfaceForAddress(mGroupAddr)); 
    // Alternatively use interface index directly (e.g., 1 for NR)
  }

  // Multicast sender on gNB
  UdpClientHelper client(mGroupAddr, port);
  client.SetAttribute("MaxPackets", UintegerValue(1000));
  client.SetAttribute("Interval", TimeValue(MilliSeconds(10)));
  client.SetAttribute("PacketSize", UintegerValue(1024));

  ApplicationContainer sendApp = client.Install(gnb.Get(0));
  sendApp.Start(Seconds(0.1));
  sendApp.Stop(Seconds(simTime));

  // Multicast receivers on UEs
  UdpServerHelper server(port);
  ApplicationContainer recvApps = server.Install(ues);
  recvApps.Start(Seconds(0.0));
  recvApps.Stop(Seconds(simTime));

  // Tracing receive events
  AsciiTraceHelper ascii;
  auto traceStream = ascii.CreateFileStream("mcast_5g.tr");
  for (uint16_t i = 0; i < numUes; ++i)
  {
    recvApps.Get(i)->TraceConnectWithoutContext("Rx", MakeBoundCallback(
      [traceStream,i](Ptr<const Packet> pkt) {
        *traceStream->GetStream() << Simulator::Now().GetSeconds()
              << "\tUE[" << i << "]\t" << pkt->GetSize() << std::endl;
      }));
  }

  Simulator::Stop(Seconds(simTime));
  Simulator::Run();
  Simulator::Destroy();
  return 0;
}
