enum AccessType {
  room,
  entrance,
  mainEntrance,
  innerEntrance,
  stairwell,
  broomCloset,
  supplyCloset,
  customerCloset,
  electricalRoom,
  serverRoom,
  cafeteria,
  office,
  elevatorLargeRelay,
  elevatorLarge,
  elevatorSmallRelay,
  elevatorSmall,
  elevator,
  technicalRoom,
  other;

  static const _room = 'Room';
  static const _entrance = 'Entrance';
  static const _mainEntrance = 'Main Entrance';
  static const _innerEntrance = 'Inner Entrance';
  static const _stairwell = 'Stairwell';
  static const _broomCloset = 'Broom Closet';
  static const _supplyCloset = 'Supply Closet';
  static const _customerCloset = 'Customer Closet';
  static const _electricalRoom = 'Electrical Room';
  static const _serverRoom = 'Server Room';
  static const _cafeteria = 'Cafeteria';
  static const _office = 'Office';
  static const _elevatorLargeRelay = 'Elevator Large Relay';
  static const _elevatorLarge = 'Elevator Large';
  static const _elevatorSmallRelay = 'Elevator Small Relay';
  static const _elevatorSmall = 'Elevator Small';
  static const _elevator = 'Elevator';
  static const _technicalRoom = 'Technical Room';
  static const _other = 'Other';

  @override
  String toString() {
    switch (this) {
      case AccessType.room:
        return _room;
      case AccessType.entrance:
        return _entrance;
      case AccessType.mainEntrance:
        return _mainEntrance;
      case AccessType.innerEntrance:
        return _innerEntrance;
      case AccessType.stairwell:
        return _stairwell;
      case AccessType.broomCloset:
        return _broomCloset;
      case AccessType.supplyCloset:
        return _supplyCloset;
      case AccessType.customerCloset:
        return _customerCloset;
      case AccessType.electricalRoom:
        return _electricalRoom;
      case AccessType.serverRoom:
        return _serverRoom;
      case AccessType.cafeteria:
        return _cafeteria;
      case AccessType.office:
        return _office;
      case AccessType.elevatorLargeRelay:
        return _elevatorLargeRelay;
      case AccessType.elevatorLarge:
        return _elevatorLarge;
      case AccessType.elevatorSmallRelay:
        return _elevatorSmallRelay;
      case AccessType.elevatorSmall:
        return _elevatorSmall;
      case AccessType.elevator:
        return _elevator;
      case AccessType.technicalRoom:
        return _technicalRoom;
      case other:
        return _other;
    }
  }

  factory AccessType.fromString(String value) {
    switch (value) {
      case _room:
        return AccessType.room;
      case _entrance:
        return AccessType.entrance;
      case _mainEntrance:
        return AccessType.mainEntrance;
      case _innerEntrance:
        return AccessType.innerEntrance;
      case _stairwell:
        return AccessType.stairwell;
      case _broomCloset:
        return AccessType.broomCloset;
      case _supplyCloset:
        return AccessType.supplyCloset;
      case _customerCloset:
        return AccessType.customerCloset;
      case _electricalRoom:
        return AccessType.electricalRoom;
      case _serverRoom:
        return AccessType.serverRoom;
      case _cafeteria:
        return AccessType.cafeteria;
      case _office:
        return AccessType.office;
      case _elevatorLargeRelay:
        return AccessType.elevatorLargeRelay;
      case _elevatorLarge:
        return AccessType.elevatorLarge;
      case _elevatorSmallRelay:
        return AccessType.elevatorSmallRelay;
      case _elevatorSmall:
        return AccessType.elevatorSmall;
      case _elevator:
        return AccessType.elevator;
      case _technicalRoom:
        return AccessType.technicalRoom;
      default:
        return AccessType.other;
    }
  }

  String toTokenString() {
    switch (this) {
      case AccessType.room:
        return 'room';
      case AccessType.entrance:
        return 'entrance';
      case AccessType.mainEntrance:
        return 'main_entrance';
      case AccessType.innerEntrance:
        return 'inner_entrance';
      case AccessType.stairwell:
        return 'stairwell';
      case AccessType.broomCloset:
        return 'broom_closet';
      case AccessType.supplyCloset:
        return 'supply_closet';
      case AccessType.customerCloset:
        return 'customer_closet';
      case AccessType.electricalRoom:
        return 'electrical_room';
      case AccessType.serverRoom:
        return 'server_room';
      case AccessType.cafeteria:
        return 'cafeteria';
      case AccessType.office:
        return 'office';
      case AccessType.elevatorLargeRelay:
        return 'elevator_large_relay';
      case AccessType.elevatorLarge:
        return 'elevator_large';
      case AccessType.elevatorSmallRelay:
        return 'elevator_small_relay';
      case AccessType.elevatorSmall:
        return 'elevator_small';
      case AccessType.elevator:
        return 'elevator';
      case AccessType.technicalRoom:
        return 'technical_room';
      case other:
        return 'other';
    }
  }
}
