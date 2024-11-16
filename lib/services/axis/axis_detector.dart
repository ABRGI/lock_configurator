import 'dart:async';
import 'dart:developer';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:nelson_lock_manager/services/digest_auth_client.dart';
import 'package:nelson_lock_manager/services/service_constants.dart';
import 'package:nelson_lock_manager/services/types/access_controller.dart';
import 'package:nelson_lock_manager/services/types/auth_type.dart';
import 'package:nelson_lock_manager/services/types/axis_access_point.dart';
import 'package:nelson_lock_manager/services/types/axis_access_policy.dart';
import 'package:nelson_lock_manager/services/types/axis_access_profile.dart';
import 'package:nelson_lock_manager/services/types/axis_credential.dart';
import 'package:nelson_lock_manager/services/types/axis_credential_access_profile.dart';
import 'package:nelson_lock_manager/services/types/axis_id_data.dart';
import 'package:nelson_lock_manager/services/types/axis_id_point.dart';
import 'package:nelson_lock_manager/services/types/axis_lock_controller_configuration_status.dart';
import 'package:nelson_lock_manager/services/types/credentials.dart';
import 'package:nelson_lock_manager/services/types/lock_controller.dart';
import 'package:nelson_lock_manager/services/types/lock_type.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import '../types/access_type.dart';

class AxisDetector {
  static const String _castType = "_http._tcp";
  static const String _lockSearchFilter = "AXIS"; //case sensitive string
  static const String _axisA1001Identifier = 'A1001';
  static const String _axisA1601Identifier = 'A1601';
  static const String _axisA1610Identifier = 'A1610';

  late MDnsClient _mdnsClient;

  AxisDetector() {
    _mdnsClient = MDnsClient();
  }

  void scanNetwork(
      {required void Function(List<LockController>) onSuccess,
      void Function(String error)? onError}) {
    List<LockController> lockList = [];
    _mdnsClient.start().then((value) {
      _mdnsClient
          .lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(_castType))
          .forEach((ptrRecord) {
        _mdnsClient
            .lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptrRecord.domainName))
            .where((srvRecord) => srvRecord.name.startsWith(_lockSearchFilter))
            .forEach((srvRecord) {
          LockType lockType =
              LockType.axis_1001; //Assign a default axis lock type
          if (srvRecord.name.contains(_axisA1001Identifier)) {
            lockType = LockType.axis_1001;
          } else if (srvRecord.name.contains(_axisA1601Identifier)) {
            lockType = LockType.axis_1601;
          } else if (srvRecord.name.contains(_axisA1610Identifier)) {
            lockType = LockType.axis_1610;
          }

          LockController lock = LockController(
              type: lockType,
              id: _getLockControllerId(srvRecord.name, lockType),
              credentials: Credentials(
                  username: 'root',
                  password: 'pass'), //Default Axis controller credentials
              port: srvRecord.port,
              mdnsRecordName: srvRecord.target,
              authType: AuthType.digest,
              maxSupportedAccessControllers:
                  2 //Default support by Axis A1001 and A1601
              );
          _mdnsClient
              .lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv4(srvRecord.target))
              .forEach((ipRecord) {
            if (ipRecord.address.isLinkLocal) {
              lock.linkLocalIpAddress = ipRecord.address.host;
            } else {
              lock.ipAddress = ipRecord.address.host;
            }
            if (!lockList.any((lc) =>
                lc.id == _getLockControllerId(srvRecord.name, lockType) ||
                lc.linkLocalIpAddress == lock.linkLocalIpAddress)) {
              lockList.add(lock);
            }
          }).onError((error, stackTrace) {
            _mdnsClient.stop();
            log('Error scanning for locks!',
                error: error, stackTrace: stackTrace);
            if (onError != null) {
              onError(error.toString());
            }
          });
        });
      });
    });
    Timer(mdnsTimeout, () {
      _mdnsClient.stop();
      onSuccess(lockList);
    });
  }

  void configureLockController(
      {required LockController lockController,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Configuring controller ${lockController.ipAddress} of type ${lockController.type}');
    AxisLockControllerConfigurationStatus configurationStaus =
        AxisLockControllerConfigurationStatus();
    //Step 1: Get the access point list with direction "in".
    _getControllerAccessPointList(
        lockController: lockController,
        onSuccess: (accessPointList) {
          configurationStaus.getAccessPoints = true;
          //Step 1.1 Update the access point list configuration
          for (var accessPoint in accessPointList) {
            accessPoint.authenticationProfiles = ['CardOnly', 'PINOnly'];
          }
          _setAccessPointList(
              lockController: lockController,
              accessPointList: accessPointList,
              onSuccess: () {
                configurationStaus.setAccessPoints = true;
                if (configurationStaus.isConfigComplete && onSuccess != null) {
                  onSuccess();
                }
              },
              onError: onError);
          //Step 1.2 or 3 Update the access profile list configuration
          List<AxisAccessProfile> accessProfileList = _buildAccessProfiles(
              lockController: lockController, accessPoints: accessPointList);
          _setAccessProfiles(
              lockController: lockController,
              accessProfleList: accessProfileList,
              onSuccess: () {
                configurationStaus.setAccessProfiles = true;
                if (configurationStaus.isConfigComplete && onSuccess != null) {
                  onSuccess();
                }
              },
              onError: onError);
        },
        onError: onError);
    //Step 2: Get the id point list
    _getIdPointList(
        lockController: lockController,
        onSuccess: (idPointList) {
          configurationStaus.getIdPoints = true;
          //Step 2.1 Update the id point list configuration
          for (var idPoint in idPointList) {
            idPoint.maxPinSize = 5;
            idPoint.minPinSize = 5;
            idPoint.endOfPin = '#';
          }
          _setIdPointList(
              lockController: lockController,
              idPointList: idPointList,
              onSuccess: () {
                configurationStaus.setIdPoints = true;
                if (configurationStaus.isConfigComplete && onSuccess != null) {
                  onSuccess();
                }
              });
        },
        onError: onError);
  }

  void setTestAccessCodes(
      {required LockController lockController,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Setting test access codes for controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}');
    var url = Uri.http(lockController.linkLocalIpAddress, 'vapix/pacs');
    List<AxisCredential> credentials =
        _buildTestCredentials(lockController: lockController);
    DigestAuthClient(lockController.credentials.username,
            lockController.credentials.password)
        .post(
      url,
      headers: {'Host': lockController.linkLocalIpAddress},
      body:
          '{"pacsaxis:SetCredential":{"Credential": ${convert.jsonEncode(credentials)}}}',
    )
        .then((response) {
      if (convert.jsonDecode(response.body)['FaultMsg'] != null) {
        log('Error setting test access codes for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: convert.jsonDecode(response.body)['FaultMsg']);
        if (onError != null) {
          onError(convert.jsonDecode(response.body)['FaultMsg']);
        }
      } else {
        List<dynamic> credentialResponseTokens =
            convert.jsonDecode(response.body)['Token'];
        log('Set ${credentialResponseTokens.length.toString()} test access code${credentialResponseTokens.length > 1 ? 's' : ''} on controller ${lockController.id}');
        if (onSuccess != null) {
          onSuccess();
        }
      }
    }).onError((error, stackTrace) {
      log('Error setting test access codes for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void setFirstTimeBootPassword(
      {required LockController lockController,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Setting inital password for root user for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
    var controllerUri = lockController.type == LockType.axis_1610
        ? Uri.http(
            '${lockController.linkLocalIpAddress}:${lockController.port}',
            'axis-cgi/pwdgrp.cgi', {
            'action': 'add',
            'user': 'root',
            'pwd': lockController.credentials.password,
            'grp': 'root',
            'sgrp': 'admin:operator:viewer:ptz',
          })
        : Uri.http(
            '${lockController.linkLocalIpAddress}:${lockController.port}',
            'axis-cgi/pwdroot/pwdroot.cgi', {
            'action': 'update',
            'user':
                'root', //Make sure that the initial username is 'root' for axis controllers.
            'pwd': lockController.credentials.password,
          });
    http.get(controllerUri).timeout(
      passwordSetTimeout,
      onTimeout: () {
        log('Timeout on update root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        if (onError != null) {
          onError(
              'Timeout on update root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        }
        return http.Response(
            'Timeout on update root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}',
            400);
      },
    ).then((response) {
      if (response.statusCode == 200 &&
          response.body.toString().contains('Created account root')) {
        log('Updated root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        log('Failed to update root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        if (onError != null) {
          onError(
              'Failed to update root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        }
      }
    }).onError((error, stackTrace) {
      log('Failed to update root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void updateControllerPassword(
      {required LockController lockController,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Updating password for root user for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
    var controllerUri = Uri.http(
        '${lockController.linkLocalIpAddress}:${lockController.port}',
        'axis-cgi/admin/pwdgrp.cgi', {
      'action': 'update',
      'user':
          'root', //Make sure that the initial username is 'root' for axis controllers.
      'pwd': lockController.newCredentials!.password,
    });
    DigestAuthClient(lockController.credentials.username,
            lockController.credentials.password)
        .get(controllerUri,
            headers: {'Host': lockController.linkLocalIpAddress}).timeout(
      passwordSetTimeout,
      onTimeout: () {
        log('Timeout on update ${lockController.credentials.username} password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        if (onError != null) {
          onError(
              'Timeout on update ${lockController.credentials.username} password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        }
        return http.Response(
            'Timeout on update ${lockController.credentials.username} password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}',
            400);
      },
    ).then((response) {
      if (response.statusCode == 200 &&
          response.body.toString().contains(
              'Modified account ${lockController.credentials.username}.')) {
        log('Updated root password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        log('Failed to update ${lockController.credentials.username} password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        if (onError != null) {
          onError(
              'Failed to update ${lockController.credentials.username} password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
        }
      }
    }).onError((error, stackTrace) {
      log('Failed to update ${lockController.credentials.username} password for controller ${lockController.id} at ${lockController.linkLocalIpAddress}',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void updateNetworkConfiguration(
      {required LockController lockController,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Updating ip address for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
    if (lockController.updatedIp == lockController.ipAddress) {
      log('Requested ip update is same as current ip. Skipping ip address chang for controller ${lockController.id}');
      if (onSuccess != null) {
        onSuccess();
      }
    } else if (lockController.updatedIp.isEmpty) {
      log('New ip not provided. Skipping ip address change for controller ${lockController.id}');
      if (onSuccess != null) {
        onSuccess();
      }
    } else {
      Uri networkUri = Uri.http(lockController.linkLocalIpAddress, 'sm/sm.srv');
      DigestAuthClient(lockController.credentials.username,
              lockController.credentials.password)
          .post(
        networkUri,
        headers: {
          'Host': lockController.linkLocalIpAddress,
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Accept-Encoding': 'gzip, deflate',
        },
        body:
            'root_Network_ZeroConf_Enabled=yes&root_Network_Broadcast=${lockController.networkBroadcast}&root_Network_Enabled=yes&root_Network_IPv6_Enabled=no&Network_Enabled=on&root_Network_BootProto=none&root_Network_IPAddress=${lockController.updatedIp}&root_Network_SubnetMask=255.255.255.0&root_Network_DefaultRouter=${lockController.defaultRouterIp}&root_Network_ARPPingIPAddress_Enabled=&root_RemoteService_Enabled=oneclick&RemoteService_Enabled=on&RemoteService_Enabled_value=oneclick&root_RemoteService_ProxyServer=&root_RemoteService_ProxyPort=3128&root_RemoteService_ProxyLogin=&root_RemoteService_ProxyPassword=&RemoteService_ProxyAuth_value=basic&root_RemoteService_ProxyAuth=basic&action=modify&replyfirst=yes',
      )
          .then((response) {
        if (onSuccess != null) {
          lockController.ipAddress = lockController.updatedIp;
          onSuccess();
        }
      }).onError((error, stackTrace) {
        log('Error setting network configuration for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: error, stackTrace: stackTrace);
        if (onError != null) {
          onError(error.toString());
        }
      });
    }
    if (onSuccess != null) {
      onSuccess();
    }
  }

  void updateNTPConfiguration(
      {required LockController lockController,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Updating NTP for controller ${lockController.id} at ${lockController.linkLocalIpAddress}');
    if (lockController.ntp.isEmpty) {
      log('New NTP not provided. Skipping NTP change for controller ${lockController.id}');
      if (onSuccess != null) {
        onSuccess();
      }
    } else {
      Uri networkUri = Uri.http(lockController.linkLocalIpAddress, 'sm/sm.srv');
      DigestAuthClient(lockController.credentials.username,
              lockController.credentials.password)
          .post(
        networkUri,
        headers: {
          'Host': lockController.linkLocalIpAddress,
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Accept-Encoding': 'gzip, deflate',
        },
        body:
            'root_Network_ZeroConf_Enabled=yes&root_Network_Broadcast=192.168.0.255&root_Network_Resolver_ObtainFromDHCP=no&root_Network_DomainName=&root_Network_DNSServer1=0.0.0.0&root_Network_DNSServer2=0.0.0.0&root_Time_ObtainFromDHCP=no&root_Time_NTP_Server=${lockController.ntp}&root_Network_VolatileHostName_ObtainFromDHCP=no&hostName=no&root_Network_HostName=axis-b8a44f68167a&OldEnabled=no&OldDNSName=&OldTTL=30&root_Network_DNSUpdate_Enabled=no&Network_ZeroConf_Enabled=yes&root_System_BoaPort=80&root_HTTPS_Port=443&root_Network_UPnP_NATTraversal_Router=&root_System_AlternateBoaPort=0&root_Network_FTP_Enabled=no&Network_RTSP_Enabled=on&root_Network_RTSP_Port=554&root_Network_RTSP_Enabled=yes&action=modify&replyfirst=no',
      )
          .then((response) {
        if (onSuccess != null) {
          onSuccess();
        }
      }).onError((error, stackTrace) {
        log('Error setting NTP for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: error, stackTrace: stackTrace);
        if (onError != null) {
          onError(error.toString());
        }
      });
    }
    if (onSuccess != null) {
      onSuccess();
    }
  }

  String _getLockControllerId(String srvName, LockType type) {
    return srvName.replaceAll(
        RegExp('(${type.toString()} - )|(.$_castType.local)'), '');
  }

  // Use the link local ip for the lock controller and work with that.
  // This is done because the locks are not expected to be on a router during configuration.
  // They can be on a P2P connection as well but still expose default or configured ipAddress which is not available on network
  void _getControllerAccessPointList(
      {required LockController lockController,
      void Function(List<AxisAccessPoint> accessPointList)? onSuccess,
      void Function(String error)? onError}) {
    log('Requesting access point list for controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}');
    var url = Uri.http(lockController.linkLocalIpAddress, 'vapix/pacs');
    DigestAuthClient(lockController.credentials.username,
            lockController.credentials.password)
        .post(
      url,
      headers: {'Host': lockController.linkLocalIpAddress},
      body: '{"pacsaxis:GetAccessPointList":{}}',
    )
        .then((response) {
      if (convert.jsonDecode(response.body)['FaultMsg'] != null) {
        log('Error getting access point list for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: convert.jsonDecode(response.body)['FaultMsg']);
        if (onError != null) {
          onError(convert.jsonDecode(response.body)['FaultMsg']);
        }
      } else {
        List<dynamic> apl = convert.jsonDecode(response.body)['AccessPoint'];
        List<AxisAccessPoint> accessPointList = apl
            .map<AxisAccessPoint>((ap) => AxisAccessPoint.fromJson(ap))
            .where((ap) => ap.attributes.any((attribute) =>
                attribute.name == 'Direction' && attribute.value == 'in'))
            .toList();
        log('Found ${accessPointList.length.toString()} access points with inward direction on controller ${lockController.id}');
        if (onSuccess != null) {
          onSuccess(accessPointList);
        }
      }
    }).onError((error, stackTrace) {
      log('Error getting access point list for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void _setAccessPointList(
      {required LockController lockController,
      required List<AxisAccessPoint> accessPointList,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Updating access point list for controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}');
    var url = Uri.http(lockController.linkLocalIpAddress, 'vapix/pacs');
    DigestAuthClient(lockController.credentials.username,
            lockController.credentials.password)
        .post(
      url,
      headers: {'Host': lockController.linkLocalIpAddress},
      body:
          '{"pacsaxis:SetAccessPoint":{"AccessPoint": ${convert.jsonEncode(accessPointList)}}}',
    )
        .then((response) {
      if (convert.jsonDecode(response.body)['FaultMsg'] != null) {
        log('Error updating access points for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: convert.jsonDecode(response.body)['FaultMsg']);
        if (onError != null) {
          onError(convert.jsonDecode(response.body)['FaultMsg']);
        }
      } else {
        List<dynamic> accessPointResponseTokens =
            convert.jsonDecode(response.body)['Token'];
        log('Updated ${accessPointResponseTokens.length.toString()} access points on controller ${lockController.id}');
        if (onSuccess != null) {
          onSuccess();
        }
      }
    }).onError((error, stackTrace) {
      log('Error updating access points for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void _getIdPointList(
      {required LockController lockController,
      void Function(List<AxisIdPoint> idPointList)? onSuccess,
      void Function(String error)? onError}) {
    log('Requesting id point list for controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}');
    var url = Uri.http(lockController.linkLocalIpAddress, 'vapix/idpoint');
    DigestAuthClient(lockController.credentials.username,
            lockController.credentials.password)
        .post(
      url,
      headers: {'Host': lockController.linkLocalIpAddress},
      body: '{"axtid:GetIdPointList":{}}',
    )
        .then((response) {
      if (response.reasonPhrase == 'unauthorized') {
        log('Unauthorized id point request for ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!');
        return;
      }
      if (convert.jsonDecode(response.body)['FaultMsg'] != null) {
        log('Error getting id points for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: convert.jsonDecode(response.body)['FaultMsg']);
        if (onError != null) {
          onError(convert.jsonDecode(response.body)['FaultMsg']);
        }
      } else {
        List<dynamic> idl = convert.jsonDecode(response.body)['IdPoint'];
        List<AxisIdPoint> idPointList = idl
            .map<AxisIdPoint>((id) => AxisIdPoint.fromJson(id))
            .where(
                (id) => id.name == 'Reader Entrance' || id.name == 'Elevator')
            .toList();
        log('Found ${idPointList.length.toString()} reader entrance id points on controller ${lockController.id}');
        if (onSuccess != null) {
          onSuccess(idPointList);
        }
      }
    }).onError((error, stackTrace) {
      log('Error getting id points for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void _setIdPointList(
      {required LockController lockController,
      required List<AxisIdPoint> idPointList,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Updating id point list for controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}');
    var url = Uri.http(lockController.linkLocalIpAddress, 'vapix/idpoint');
    DigestAuthClient(lockController.credentials.username,
            lockController.credentials.password)
        .post(
      url,
      headers: {'Host': lockController.linkLocalIpAddress},
      body:
          '{"axtid:SetIdPoint":{"IdPoint": ${convert.jsonEncode(idPointList)}}}',
    )
        .then((response) {
      if (convert.jsonDecode(response.body)['FaultMsg'] != null) {
        log('Error updating id point list for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: convert.jsonDecode(response.body)['FaultMsg']);
        if (onError != null) {
          onError(convert.jsonDecode(response.body)['FaultMsg']);
        }
      } else {
        List<dynamic> idPointResponseTokens =
            convert.jsonDecode(response.body)['Token'];
        log('Updated ${idPointResponseTokens.length.toString()} reader entrance id points on controller ${lockController.id}');
        if (onSuccess != null) {
          onSuccess();
        }
      }
    }).onError((error, stackTrace) {
      log('Error updating id point list for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void _setAccessProfiles(
      {required LockController lockController,
      required List<AxisAccessProfile> accessProfleList,
      void Function()? onSuccess,
      void Function(String error)? onError}) {
    log('Updating access profile list for controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}');
    var url = Uri.http(lockController.linkLocalIpAddress, 'vapix/pacs');
    DigestAuthClient(lockController.credentials.username,
            lockController.credentials.password)
        .post(
      url,
      headers: {'Host': lockController.linkLocalIpAddress},
      body:
          '{"pacsaxis:SetAccessProfile":{"AccessProfile": ${convert.jsonEncode(accessProfleList)}}}',
    )
        .then((response) {
      if (convert.jsonDecode(response.body)['FaultMsg'] != null) {
        log('Error updating access profile list for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
            error: convert.jsonDecode(response.body)['FaultMsg']);
        if (onError != null) {
          onError(convert.jsonDecode(response.body)['FaultMsg']);
        }
      } else {
        List<dynamic> idPointResponseTokens =
            convert.jsonDecode(response.body)['Token'];
        log('Updated ${idPointResponseTokens.length.toString()} access profiles on controller ${lockController.id}');
        if (onSuccess != null) {
          onSuccess();
        }
      }
    }).onError((error, stackTrace) {
      log('Error updating access profile list for lock controller ${lockController.ipAddress} | ${lockController.linkLocalIpAddress}!',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  List<AxisAccessProfile> _buildAccessProfiles(
      {required LockController lockController,
      required List<AxisAccessPoint> accessPoints}) {
    List<AxisAccessProfile> accessProfiles =
        lockController.accessControllers.map((accessController) {
      return AxisAccessProfile(
          token: getAccessProfileToken(lockController, accessController),
          name: getAccessProfileName(accessController),
          description: accessController.roomOrder.toString(),
          schedules: ['standard_always'],
          authenticationProfile: [],
          accessPolicies: [
            AxisAccessPolicy(
                authorizationProfile: [],
                schedules: ['standard_always'],
                accessPoint: accessPoints[lockController.accessControllers
                        .indexOf(accessController)]
                    .token)
          ],
          enabled: true);
    }).toList();
    return accessProfiles;
  }

  String getAccessProfileToken(
      LockController lockController, AccessController accessController) {
    String token = '${lockController.propertyName}_';
    switch (accessController.accessType) {
      case AccessType.room:
        token += 'room_1_${accessController.label}';
      case AccessType.entrance:
      case AccessType.stairwell:
      case AccessType.broomCloset:
      case AccessType.supplyCloset:
      case AccessType.customerCloset:
      case AccessType.electricalRoom:
      case AccessType.serverRoom:
      case AccessType.cafeteria:
      case AccessType.office:
      case AccessType.elevatorLargeRelay:
      case AccessType.elevatorLarge:
      case AccessType.elevatorSmallRelay:
      case AccessType.elevatorSmall:
      case AccessType.technicalRoom:
      case AccessType.elevator:
        token +=
            'floor_${accessController.floor.toString()}_1_${accessController.accessType.toTokenString()}${accessController.label.isNotEmpty ? '_${accessController.label.toLowerCase()}' : ''}';
      case AccessType.mainEntrance:
      case AccessType.innerEntrance:
        token +=
            '${accessController.accessType.toTokenString()}${accessController.label.isNotEmpty ? '_${accessController.label}' : ''}';
      case AccessType.other:
        token += AccessType.other.toTokenString();
    }
    return token;
  }

  String getAccessProfileName(AccessController accessController) {
    switch (accessController.accessType) {
      case AccessType.room:
        return 'Room ${accessController.label}';
      case AccessType.entrance:
      case AccessType.stairwell:
      case AccessType.broomCloset:
      case AccessType.supplyCloset:
      case AccessType.customerCloset:
      case AccessType.electricalRoom:
      case AccessType.serverRoom:
      case AccessType.cafeteria:
      case AccessType.office:
      case AccessType.technicalRoom:
      case AccessType.other:
        return 'Floor ${accessController.floor} ${accessController.accessType.toString().toLowerCase()}${accessController.label.isNotEmpty ? ' ${accessController.label}' : ''}';
      case AccessType.mainEntrance:
        return 'Main entrance${accessController.label.isNotEmpty ? ' ${accessController.label}' : ''}';
      case AccessType.innerEntrance:
        return 'Inner entrance${accessController.label.isNotEmpty ? ' ${accessController.label}' : ''}';
      case AccessType.elevatorLargeRelay:
      case AccessType.elevatorLarge:
      case AccessType.elevatorSmallRelay:
      case AccessType.elevatorSmall:
      case AccessType.elevator:
        return '${accessController.accessType.toString()} ${accessController.label.isNotEmpty ? '${accessController.label} ' : ''}for floor ${accessController.floor.toString()}';
    }
  }

  List<AxisCredential> _buildTestCredentials(
      {required LockController lockController}) {
    return lockController.accessControllers
        .map<AxisCredential>((accessController) {
      DateTime now = DateTime.now();
      String vf = '${now.year}-${now.month}-${now.day}T00:00:00Z';
      String vt = '2025-01-01T00:00:00Z'; //For fixed date
      // String vt =
      //     '${(now.day < 28 && now.month < 12) ? now.year : now.year + 1}-${now.day < 28 ? now.month : (now.month < 12 ? now.month + 1 : 1)}-${now.day < 28 ? now.day + 1 : 1}T00:00:00Z'; // For 24 hour access
      return AxisCredential(
          description: 'Test credential for Nelson',
          validFrom: vf,
          validTo: vt,
          enabled: true,
          status: 'Enabled',
          idData: [
            AxisIdData(
                name: 'PIN',
                value:
                    '0${accessController.floor}${accessController.accessType == AccessType.room ? accessController.label : '${accessController.floor}00'}')
          ],
          credentialAccessProfile: [
            AxisCredentialAccessProfile(
                validFrom: vf,
                validTo: vt,
                accessProfile:
                    getAccessProfileToken(lockController, accessController))
          ]);
    }).toList();
  }
}
