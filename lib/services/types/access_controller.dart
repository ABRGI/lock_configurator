import 'package:nelson_lock_manager/services/types/access_type.dart';

class AccessController {
  String name;
  AccessType accessType;
  String label;
  int floor;
  String buildingLabel;
  int roomOrder;

  AccessController(
      {required this.name,
      required this.accessType,
      required this.label,
      required this.floor,
      this.buildingLabel = '',
      required this.roomOrder});
}
