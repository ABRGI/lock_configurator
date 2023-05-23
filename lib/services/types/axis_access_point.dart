import 'package:nelson_lock_manager/services/types/axis_attribute.dart';
import 'package:nelson_lock_manager/services/types/axis_id_point_device.dart';

class AxisAccessPoint {
  String token;
  String name;
  String description;
  String areaFrom;
  String areaTo;
  String entityType;
  String entity;
  bool enabled;
  String doorDeviceUUID;
  List<AxisIdPointDevice> idPointDevices;
  List<String> authenticationProfiles;
  List<AxisAttribute> attributes;
  List<dynamic> actionArguments;
  String action;

  AxisAccessPoint(
      {this.token = '',
      this.name = '',
      this.description = '',
      this.areaFrom = '',
      this.areaTo = '',
      this.entityType = '',
      this.entity = '',
      this.enabled = false,
      this.doorDeviceUUID = '',
      this.idPointDevices = const [],
      this.authenticationProfiles = const [],
      this.attributes = const [],
      this.actionArguments = const [],
      this.action = ''});

  factory AxisAccessPoint.fromJson(dynamic json) {
    AxisAccessPoint accessPoint = AxisAccessPoint(
      token: json['token'] ?? '',
      name: json['Name'],
      description: json['Description'],
      areaFrom: json['AreaFrom'],
      areaTo: json['AreaTo'],
      entityType: json['EntityType'],
      entity: json['Entity'],
      enabled: json['Enabled'],
      doorDeviceUUID: json['DoorDeviceUUID'],
      action: json['Action'],
      idPointDevices: [],
      authenticationProfiles: [],
      attributes: [],
      actionArguments: json['ActionArgument'] ?? [],
    );
    if (json['IdPointDevice'] != null) {
      List<dynamic> idPointDevices = json['IdPointDevice'];
      for (var idpointdevice in idPointDevices) {
        accessPoint.idPointDevices
            .add(AxisIdPointDevice.fromJson(idpointdevice));
      }
    }
    if (json['AuthenticationProfile'] != null) {
      List<dynamic> aps = json['AuthenticationProfile'];
      accessPoint.authenticationProfiles =
          aps.map((ap) => ap.toString()).toList();
    }
    if (json['Attribute'] != null) {
      List<dynamic> attributes = json['Attribute'];
      for (var attribute in attributes) {
        accessPoint.attributes.add(AxisAttribute.fromJson(attribute));
      }
    }
    return accessPoint;
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'Name': name,
      'Description': description,
      'AreaFrom': areaFrom,
      'AreaTo': areaTo,
      'EntityType': entityType,
      'Entity': entity,
      'Enabled': enabled,
      'DoorDeviceUUID': doorDeviceUUID,
      'Action': action,
      'IdPointDevice': idPointDevices
          .map((idPointDevice) => idPointDevice.toJson())
          .toList(),
      'AuthenticationProfile': authenticationProfiles,
      'Attribute': attributes.map((attribute) => attribute.toJson()).toList(),
      'ActionArgument': actionArguments
    };
  }
}
