class AxisIdPoint {
  String token;
  String name;
  String description;
  String location;
  String area;
  String action;
  int minPinSize;
  int maxPinSize;
  String endOfPin;
  String timeout;
  String heatrbeatInterval;

  AxisIdPoint({
    this.token = '',
    this.name = '',
    this.description = '',
    this.location = '',
    this.area = '',
    this.action = '',
    this.minPinSize = 4,
    this.maxPinSize = 4,
    this.endOfPin = '#',
    this.timeout = 'PT10S',
    this.heatrbeatInterval = '',
  });

  factory AxisIdPoint.fromJson(dynamic json) {
    return AxisIdPoint(
        token: json['token'] ?? '',
        name: json['Name'],
        description: json['Description'],
        location: json['Location'],
        area: json['Area'],
        action: json['Action'],
        minPinSize: json['MinPINSize'],
        maxPinSize: json['MaxPINSize'],
        endOfPin: json['EndOfPIN'],
        timeout: json['Timeout'],
        heatrbeatInterval: json['HeartbeatInterval']);
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'Name': name,
      'Description': description,
      'Location': location,
      'Area': area,
      'Action': action,
      'MinPINSize': minPinSize,
      'MaxPINSize': maxPinSize,
      'EndOfPIN': endOfPin,
      'Timeout': timeout,
      'HeartbeatInterval': heatrbeatInterval
    };
  }
}
