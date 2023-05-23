import 'package:nelson_lock_manager/services/types/access_controller.dart';
import 'package:nelson_lock_manager/services/types/auth_type.dart';
import 'package:nelson_lock_manager/services/types/credentials.dart';
import 'package:nelson_lock_manager/services/types/lock_type.dart';

class LockController {
  LockType type;
  String id;
  String ipAddress;
  int controllerNumber;
  String linkLocalIpAddress;
  int port;
  String mdnsRecordName;
  Credentials credentials;
  AuthType authType;
  int maxSupportedAccessControllers;
  List<AccessController> accessControllers;
  int propertyId;
  String propertyName;
  bool selected;
  String updatedIp = '';
  String ntp;

  LockController(
      {required this.type,
      required this.id,
      required this.credentials,
      this.controllerNumber = 0,
      this.propertyId = 0,
      this.propertyName = '',
      this.ipAddress = '',
      this.linkLocalIpAddress = '',
      this.port = 80,
      this.mdnsRecordName = '',
      this.authType = AuthType.noauth,
      this.maxSupportedAccessControllers = 1,
      this.accessControllers = const [],
      this.selected = false,
      this.ntp = ''});

  String get defaultRouterIp {
    return '${updatedIp.substring(0, updatedIp.lastIndexOf('.'))}.1';
  }

  String get networkBroadcast {
    return '${updatedIp.substring(0, updatedIp.lastIndexOf('.'))}.255';
  }
}
