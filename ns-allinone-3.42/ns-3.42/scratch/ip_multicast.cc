#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/nr-module.h"
#include "ns3/applications-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/mobility-module.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("IpMulticast5G");

static void RxTrace(Ptr<OutputStreamWrapper> stream, Ptr<const Packet> packet)
{
    *stream->GetStream() << Simulator::Now().GetSeconds() << "\t" << packet->GetSize() << std::endl;
}

int main(int argc, char* argv[])
{
    // Set default scheduler type
    

    double simTime = 1.0;
    uint16_t numUes = 10;
    double centralFrequency = 28e9;
    double bandwidth = 100e6;

    // Enable logging
    LogComponentEnable("IpMulticast5G", LOG_LEVEL_INFO);
    LogComponentEnable("NrHelper", LOG_LEVEL_DEBUG);
    LogComponentEnable("ThreeGppPropagationLossModel", LOG_LEVEL_DEBUG);
    LogComponentEnable("ThreeGppSpectrumPropagationLossModel", LOG_LEVEL_DEBUG);

    // Create nodes
    NodeContainer gnbNodes, ueNodes;
    gnbNodes.Create(1);
    ueNodes.Create(numUes);

    // Mobility
    MobilityHelper mobility;
    mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel");
    mobility.Install(gnbNodes);
    Ptr<MobilityModel> gnbMob = gnbNodes.Get(0)->GetObject<MobilityModel>();
    gnbMob->SetPosition(Vector(0, 0, 10));

    // UE placement
    mobility.Install(ueNodes);
    for (uint16_t i = 0; i < numUes; ++i)
    {
        Ptr<MobilityModel> ueMob = ueNodes.Get(i)->GetObject<MobilityModel>();
        ueMob->SetPosition(Vector(10 + i * 5, 0, 1.5));
    }

    // NR helper
    Ptr<NrHelper> nrHelper = CreateObject<NrHelper>();
    NS_ASSERT_MSG(nrHelper, "NrHelper is null");
    nrHelper->SetEpcHelper(CreateObject<NrPointToPointEpcHelper>());
    Ptr<IdealBeamformingHelper> beamformingHelper = CreateObject<IdealBeamformingHelper>();
    beamformingHelper->SetAttribute("BeamformingPeriodicity", TimeValue(MilliSeconds(10)));
    NS_ASSERT_MSG(beamformingHelper, "BeamformingHelper is null");
    nrHelper->SetBeamformingHelper(beamformingHelper);
    ObjectFactory schedulerFactory;
    schedulerFactory.SetTypeId("ns3::NrMacSchedulerTdmaRR");
    nrHelper->SetSchedulerTypeId(schedulerFactory.GetTypeId());
    
    // Set up antenna parameters
    NrHelper::AntennaParams gnbAntennaParams;
    gnbAntennaParams.antennaElem = "ns3::IsotropicAntennaModel";
    gnbAntennaParams.nAntCols = 4;
    gnbAntennaParams.nAntRows = 4;
    nrHelper->SetupGnbAntennas(gnbAntennaParams);

    NrHelper::AntennaParams ueAntennaParams;
    ueAntennaParams.antennaElem = "ns3::IsotropicAntennaModel";
    ueAntennaParams.nAntCols = 1;
    ueAntennaParams.nAntRows = 1;
    nrHelper->SetupUeAntennas(ueAntennaParams);

    // Bandwidth part configuration
    CcBwpCreator ccBwpCreator;
    CcBwpCreator::SimpleOperationBandConf bandConf(centralFrequency, bandwidth, 1);
    OperationBandInfo band = ccBwpCreator.CreateOperationBandContiguousCc(bandConf);
    NS_LOG_DEBUG("Operation band: centralFrequency=" << band.m_centralFrequency << ", bandwidth=" << band.m_channelBandwidth);
    nrHelper->InitializeOperationBand(&band);
    BandwidthPartInfoPtrVector allBwps = band.GetBwps();
    NS_LOG_DEBUG("Number of BWPs: " << allBwps.size());
    NS_ASSERT_MSG(allBwps.size() == 1, "Expected exactly one BWP");

    // Install NR devices
    NetDeviceContainer gnbDevs = nrHelper->InstallGnbDevice(gnbNodes, allBwps);
    NS_ASSERT_MSG(gnbDevs.Get(0), "gNB device is null");
    NetDeviceContainer ueDevs = nrHelper->InstallUeDevice(ueNodes, allBwps);
    for (uint16_t i = 0; i < numUes; i++)
    {
        NS_ASSERT_MSG(ueDevs.Get(i), "UE device " << i << " is null");
    }

    // Log node positions and device information
    NS_LOG_INFO("gNB Node Position: " << gnbNodes.Get(0)->GetObject<MobilityModel>()->GetPosition());
    for (uint16_t i = 0; i < numUes; i++)
    {
        NS_LOG_INFO("UE " << i << " Node Position: " << ueNodes.Get(i)->GetObject<MobilityModel>()->GetPosition());
    }
    NS_LOG_INFO("gnbDevs size: " << gnbDevs.GetN());
    NS_LOG_INFO("ueDevs size: " << ueDevs.GetN());

    // Internet stack
    InternetStackHelper internet;
    internet.Install(gnbNodes);
    internet.Install(ueNodes);

    // IP configuration
    Ipv4AddressHelper ipv4;
    ipv4.SetBase("10.1.1.0", "255.255.255.0");
    Ipv4InterfaceContainer ueIpIface = ipv4.Assign(ueDevs);

    nrHelper->UpdateDeviceConfigs(gnbDevs);
    nrHelper->UpdateDeviceConfigs(ueDevs);

    nrHelper->AttachToClosestGnb(ueDevs, gnbDevs);

    // Multicast group
    Ipv4Address multicastGroup("225.1.2.3");

    // Application: UDP multicast
    OnOffHelper onoff("ns3::UdpSocketFactory", Address(InetSocketAddress(multicastGroup, 1234)));
    onoff.SetAttribute("DataRate", StringValue("1Mbps"));
    onoff.SetAttribute("PacketSize", UintegerValue(1024));
    onoff.SetAttribute("OnTime", StringValue("ns3::ConstantRandomVariable[Constant=1.0]"));
    onoff.SetAttribute("OffTime", StringValue("ns3::ConstantRandomVariable[Constant=0.0]"));
    ApplicationContainer onoffApps = onoff.Install(gnbNodes.Get(0));
    onoffApps.Start(Seconds(0.1));
    onoffApps.Stop(Seconds(simTime));

    PacketSinkHelper sink("ns3::UdpSocketFactory", Address(InetSocketAddress(Ipv4Address::GetAny(), 1234)));
    ApplicationContainer sinkApps;
    for (uint16_t i = 0; i < numUes; i++)
    {
        sinkApps.Add(sink.Install(ueNodes.Get(i)));
    }
    sinkApps.Start(Seconds(0.05));
    sinkApps.Stop(Seconds(simTime));

    for (uint16_t i = 0; i < numUes; i++)
    {
        Ptr<Ipv4> ipv4Ue = ueNodes.Get(i)->GetObject<Ipv4>();
        NS_ASSERT_MSG(ipv4Ue, "IPv4 object is null for UE " << i);
        Ptr<NetDevice> ueDevice = ueDevs.Get(i);
        int32_t interfaceIndex = ipv4Ue->GetInterfaceForDevice(ueDevice);
        Ptr<UdpSocket> sinkSocket = DynamicCast<UdpSocket>(sinkApps.Get(i)->GetObject<PacketSink>()->GetListeningSocket());
        sinkSocket->MulticastJoinGroup(interfaceIndex, multicastGroup);
    }

    // Enable tracing
    AsciiTraceHelper ascii;
    Ptr<OutputStreamWrapper> stream = ascii.CreateFileStream("ip_multicast_5g.tr");
    for (uint16_t i = 0; i < numUes; i++)
    {
        sinkApps.Get(i)->TraceConnectWithoutContext("Rx", MakeBoundCallback(&RxTrace, stream));
    }

    // Run simulation
    Simulator::Stop(Seconds(simTime));
    Simulator::Run();
    Simulator::Destroy();

    return 0;
}