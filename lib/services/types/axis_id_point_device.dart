class AxisIdPointDevice {
  String idPoint;
  String deviceUUID;

  AxisIdPointDevice({required this.idPoint, this.deviceUUID = ''});

  factory AxisIdPointDevice.fromJson(dynamic json) {
    return AxisIdPointDevice(
        idPoint: json['IdPoint'], deviceUUID: json['DeviceUUID'] ?? '');
  }

  Map<String, String> toJson() {
    return {'IdPoint': idPoint, 'DeviceUUID': deviceUUID};
  }
}
