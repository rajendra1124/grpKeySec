# Install script for directory: /home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "default")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.42-nr-default.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.42-nr-default.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.42-nr-default.so"
         RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib:/usr/local/lib64:$ORIGIN/:$ORIGIN/../lib64")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/build/lib/libns3.42-nr-default.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.42-nr-default.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.42-nr-default.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.42-nr-default.so"
         OLD_RPATH "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/build/lib::::::::::::::::::::::::::::"
         NEW_RPATH "/usr/local/lib:$ORIGIN/:$ORIGIN/../lib:/usr/local/lib64:$ORIGIN/:$ORIGIN/../lib64")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libns3.42-nr-default.so")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/ns3" TYPE FILE FILES
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/beamforming-helper-base.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/cc-bwp-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/file-scenario-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/grid-scenario-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/hexagonal-grid-scenario-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/ideal-beamforming-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/node-distribution-scenario-interface.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-bearer-stats-calculator.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-bearer-stats-connector.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-bearer-stats-simple.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-epc-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-mac-rx-trace.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-mac-scheduling-stats.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-no-backhaul-epc-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-phy-rx-trace.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-point-to-point-epc-helper-base.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-point-to-point-epc-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-radio-environment-map-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-spectrum-value-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/nr-stats-calculator.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/realistic-beamforming-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/scenario-parameters.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/helper/three-gpp-ftp-m1-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/bandwidth-part-gnb.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/bandwidth-part-ue.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/beam-id.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/beam-manager.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/beamforming-vector.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/bwp-manager-algorithm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/bwp-manager-gnb.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/bwp-manager-ue.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/ideal-beamforming-algorithm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/lena-error-model.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-a2-a4-rsrq-handover-algorithm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-a3-rsrp-handover-algorithm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-amc.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-anr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-anr-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-as-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-asn1-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-cb-two-port.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-cb-type-one-sp.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-cb-type-one.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ccm-mac-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ccm-rrc-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ch-access-manager.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-chunk-processor.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-common.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-component-carrier.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-control-messages.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-cc-t1.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-cc-t2.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-cc.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-error-model.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-ir-t1.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-ir-t2.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-ir.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-t1.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eesm-t2.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-gnb-application.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-gnb-s1-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-gtpc-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-gtpu-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-mme-application.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-pgw-application.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-s11-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-s1ap-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-sgw-application.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-tft-classifier.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-tft.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-ue-nas.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-x2-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-x2-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-epc-x2.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eps-bearer-tag.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-eps-bearer.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-error-model.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-fh-control.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-fh-sched-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-fh-phy-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-gnb-cmac-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-gnb-component-carrier-manager.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-gnb-cphy-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-gnb-mac.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-gnb-net-device.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-gnb-phy.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-gnb-rrc.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-handover-algorithm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-handover-management-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-harq-phy.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-interference-base.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-interference.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-lte-amc.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-lte-mi-error-model.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-csched-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-harq-process.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-harq-vector.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-header-fs-dl.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-header-fs-ul.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-header-fs.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-header-vs-dl.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-header-vs-ul.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-header-vs.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-pdu-info.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-sched-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-cqi-management.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-harq-rr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-lc-alg.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-lc-qos.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-lc-rr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-lcg.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ns3.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ofdma-mr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ofdma-pf.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ofdma-qos.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ofdma-rr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ofdma.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-srs-default.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-srs.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-tdma-mr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-tdma-pf.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-tdma-qos.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-tdma-rr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-tdma.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ue-info-mr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ue-info-pf.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ue-info-qos.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ue-info-rr.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler-ue-info.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-scheduler.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mac-short-bsr-ce.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mimo-chunk-processor.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mimo-matrices.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-mimo-signal.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-net-device.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-no-op-component-carrier-manager.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-no-op-handover-algorithm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-pdcp-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-pdcp-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-pdcp-tag.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-pdcp.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-phy-mac-common.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-phy-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-phy-tag.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-phy.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-pm-search-full.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-pm-search.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-radio-bearer-info.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-radio-bearer-tag.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-am-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-am.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-sdu-status-tag.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-sequence-number.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-tag.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-tm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc-um.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rlc.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rrc-header.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rrc-protocol-ideal.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rrc-protocol-real.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-rrc-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-simple-ue-component-carrier-manager.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-spectrum-phy.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-spectrum-signal-parameters.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-ccm-rrc-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-cmac-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-component-carrier-manager.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-cphy-sap.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-mac.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-net-device.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-phy.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-power-control.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-ue-rrc.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/nr-vendor-specific-parameters.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/realistic-beamforming-algorithm.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/realistic-bf-manager.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/model/sfnsf.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/distance-based-three-gpp-spectrum-propagation-loss-model.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/helper/traffic-generator-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/helper/xr-traffic-mixer-helper.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-3gpp-audio-data.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-3gpp-generic-video.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-3gpp-pose-control.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-ftp-single.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-ngmn-ftp-multi.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-ngmn-gaming.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-ngmn-video.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator-ngmn-voip.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/src/nr/utils/traffic-generators/model/traffic-generator.h"
    "/home/dwijesek/git/ns-allinone-3.42/ns-3.42/build/include/ns3/nr-module.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/dwijesek/git/ns-allinone-3.42/ns-3.42/cmake-cache/src/nr/examples/cmake_install.cmake")

endif()

