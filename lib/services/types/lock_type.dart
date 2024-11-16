enum LockType {
  axis_1001,
  axis_1601,
  axis_1610,
  vanderbilt,
  axbase,
  salto,
  other;

  static const String _axisA1001 = 'AXIS A1001';
  static const String _axisA1601 = 'AXIS A1601';
  static const String _axisA1610 = 'AXIS A1610';
  static const String _other = 'OTHER';

  @override
  String toString() {
    switch (this) {
      case LockType.axis_1001:
        return _axisA1001;
      case LockType.axis_1601:
        return _axisA1601;
      case LockType.axis_1610:
        return _axisA1610;
      default:
        return _other;
    }
  }

  factory LockType.fromString(String value) {
    switch (value) {
      case _axisA1001:
        return LockType.axis_1001;
      case _axisA1601:
        return LockType.axis_1601;
      case _axisA1610:
        return LockType.axis_1610;
      default:
        return LockType.other;
    }
  }
}
