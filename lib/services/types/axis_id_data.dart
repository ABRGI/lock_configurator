class AxisIdData {
  String name;
  String value;

  AxisIdData({required this.name, required this.value});

  factory AxisIdData.fromJson(dynamic json) {
    return AxisIdData(name: json['Name'], value: json['Value']);
  }

  Map<String, dynamic> toJson() {
    return {'Name': name, 'Value': value};
  }
}
