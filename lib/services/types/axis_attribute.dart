class AxisAttribute {
  String type;
  String name;
  String value;

  AxisAttribute({this.type = '', required this.name, required this.value});

  factory AxisAttribute.fromJson(dynamic json) {
    return AxisAttribute(
        type: json['type'] ?? '', name: json['Name'], value: json['Value']);
  }

  Map<String, String> toJson() {
    return {'type': type, 'Name': name, 'Value': value};
  }
}
