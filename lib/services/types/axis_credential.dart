import 'package:nelson_lock_manager/services/types/axis_attribute.dart';
import 'package:nelson_lock_manager/services/types/axis_credential_access_profile.dart';
import 'package:nelson_lock_manager/services/types/axis_id_data.dart';

class AxisCredential {
  String token;
  String userToken;
  String description;
  String validFrom;
  String validTo;
  bool enabled;
  String status;
  List<AxisIdData> idData;
  List<AxisAttribute> attributes;
  dynamic authenticationProfile;
  List<AxisCredentialAccessProfile> credentialAccessProfile;

  AxisCredential({
    this.token = '',
    this.userToken = '',
    this.description = '',
    this.validFrom = '',
    this.validTo = '',
    this.enabled = false,
    this.status = 'Disabled',
    this.idData = const [],
    this.attributes = const [],
    this.authenticationProfile = const [],
    this.credentialAccessProfile = const [],
  });

  factory AxisCredential.fromJson(dynamic json) {
    AxisCredential credential = AxisCredential(
        token: json['token'],
        userToken: json['UserToken'],
        description: json['Description'],
        validFrom: json['ValidFrom'],
        validTo: json['ValidTo'],
        enabled: json['Enabled'],
        status: json['Status'],
        authenticationProfile: json['AuthenticationProfile']);

    if (json['Attribute'] != null) {
      List<dynamic> attributes = json['Attribute'];
      for (var attribute in attributes) {
        credential.attributes.add(AxisAttribute.fromJson(attribute));
      }
    }
    if (json['IdData'] != null) {
      List<dynamic> idData = json['IdData'];
      for (var id in idData) {
        credential.idData.add(AxisIdData.fromJson(id));
      }
    }
    if (json['CredentialAccessProfile'] != null) {
      List<dynamic> credentialAccessProfiles = json['CredentialAccessProfile'];
      for (var credentialAccessProfile in credentialAccessProfiles) {
        credential.credentialAccessProfile
            .add(AxisCredentialAccessProfile.fromJson(credentialAccessProfile));
      }
    }
    return credential;
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'UserToken': userToken,
      'Description': description,
      'ValidFrom': validFrom,
      'ValidTo': validTo,
      'Enabled': enabled,
      'Status': status,
      'IdData': idData.map((id) => id.toJson()).toList(),
      'Attribute': attributes.map((attribute) => attribute.toJson()).toList(),
      'AuthenticationProfile': authenticationProfile ?? [],
      'CredentialAccessProfile':
          credentialAccessProfile.map((cred) => cred.toJson()).toList(),
    };
  }
}
