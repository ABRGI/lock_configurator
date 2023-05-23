import 'package:nelson_lock_manager/services/types/axis_attribute.dart';
import 'axis_access_policy.dart';

class AxisAccessProfile {
  String token;
  String name;
  String description;
  String validFrom;
  String validTo;
  List<String> schedules;
  dynamic authenticationProfile;
  List<AxisAttribute> attributes;
  List<AxisAccessPolicy> accessPolicies;
  bool enabled;

  AxisAccessProfile(
      {this.token = '',
      this.name = '',
      this.description = '',
      this.validFrom = '',
      this.validTo = '',
      this.schedules = const [],
      this.authenticationProfile,
      this.attributes = const [],
      this.accessPolicies = const [],
      this.enabled = false});

  factory AxisAccessProfile.fromJson(dynamic json) {
    AxisAccessProfile accessProfile = AxisAccessProfile(
        token: json['token'],
        name: json['Name'],
        description: json['Description'],
        validFrom: json['ValidFrom'],
        validTo: json['ValidTo'],
        authenticationProfile: json['Authenticationprofile'],
        attributes: [],
        accessPolicies: [],
        enabled: json['Enabled'] ?? false);

    if (json['Schedule'] != null) {
      List<dynamic> schedules = json['Schedule'];
      accessProfile.schedules =
          schedules.map((schedule) => schedule.toString()).toList();
    }
    if (json['Attribute'] != null) {
      List<dynamic> attributes = json['Attribute'];
      for (var attribute in attributes) {
        accessProfile.attributes.add(AxisAttribute.fromJson(attribute));
      }
    }
    if (json['AccessPolicy'] != null) {
      List<dynamic> accessPolicies = json['AccessPolicy'];
      for (var accessPolicy in accessPolicies) {
        accessProfile.accessPolicies
            .add(AxisAccessPolicy.fromJson(accessPolicy));
      }
    }
    return accessProfile;
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'Name': name,
      'Description': description,
      'ValidFrom': validFrom,
      'ValidTo': validTo,
      'Schedule': schedules,
      'AuthenticationProfile': authenticationProfile,
      'Attribute': attributes.map((attribute) => attribute.toJson()).toList(),
      'AccessPolicy':
          accessPolicies.map((accessPolicy) => accessPolicy.toJson()).toList(),
      'Enabled': enabled
    };
  }
}
