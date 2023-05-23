class AxisCredentialAccessProfile {
  String validFrom;
  String validTo;
  String accessProfile;

  AxisCredentialAccessProfile(
      {this.validFrom = '', this.validTo = '', this.accessProfile = ''});

  factory AxisCredentialAccessProfile.fromJson(dynamic json) {
    return AxisCredentialAccessProfile(
        validFrom: json['ValidFrom'],
        validTo: json['ValidTo'],
        accessProfile: json['AccessProfile']);
  }

  Map<String, dynamic> toJson() {
    return {
      'ValidFrom': validFrom,
      'ValidTo': validTo,
      'AccessProfile': accessProfile
    };
  }
}
