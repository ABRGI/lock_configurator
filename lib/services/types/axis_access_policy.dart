import 'axis_attribute.dart';

class AxisAccessPolicy {
  dynamic authorizationProfile;
  List<AxisAttribute> attributes;
  List<String> schedules;
  String accessPoint;

  AxisAccessPolicy(
      {this.authorizationProfile,
      this.attributes = const [],
      this.schedules = const [],
      required this.accessPoint});

  factory AxisAccessPolicy.fromJson(dynamic json) {
    AxisAccessPolicy accessPolicy = AxisAccessPolicy(
        authorizationProfile: json['AuthorizationProfile'],
        accessPoint: json['AccessPoint']);
    if (json['Attribute'] != null) {
      List<dynamic> attributes = json['Attribute'];
      for (var attribute in attributes) {
        accessPolicy.attributes.add(AxisAttribute.fromJson(attribute));
      }
    }
    if (json['Schedule'] != null) {
      List<dynamic> schedules = json['Schedule'];
      accessPolicy.schedules =
          schedules.map((schedule) => schedule.toString()).toList();
    }
    return accessPolicy;
  }

  Map<String, dynamic> toJson() {
    return {
      'AuthorizationProfile': authorizationProfile,
      'Attribute': attributes.map((attribute) => attribute.toJson()).toList(),
      'Schedule': schedules,
      'AccessPoint': accessPoint
    };
  }
}
