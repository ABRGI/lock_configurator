/*
  Media size constants
  Each value determines the max size allowed for that media dimension
  Greater than mediaXLarge is xxl
*/
import 'package:flutter/material.dart';

class MediaSizes {
  static const int mediaXSmall = 576;
  static const int mediaSmall = 768;
  static const int mediaMedium = 992;
  static const int mediaLarge = 1200;
  static const int mediaXLarge = 1400;
}

class LayoutConstants {
//constants (for larger devices)
  static const double toolbarHeight = 150;
  static const double edgePadding = 124;
  static const double mainSectionTitleTopPadding = 48;
  static const double mainSectionTitleBottomPadding = 32;
  static const double mainSectionTitleFontSize = 40;
  static const double buttonEdgePadding = 10;
  static const double tableCellPadding = 10;
  static const double defaultTableColumnWidth = 150;
  static const double insetPadding = 50;

//constants (for smaller devices)
  static const double toolbarSmallHeight = kToolbarHeight;
  static const double edgePaddingSmall = 10;
  static const double mainSectionSmallTitleTopPadding = 5;
  static const double mainSectionSmallTitleBottomPadding = 5;
  static const double mainSectionSmallTitleFontSize = 25;
}

class NelsonLockConfigTemplate {
  static const int ipAddressIndex = 0;
  static const int portIndex = 1;
  static const int controllerTypeIndex = 2;
  static const int controllerIdIndex = 3;
  static const int controllerNumberIndex = 4;
  static const int usernameIndex = 5;
  static const int passwordIndex = 6;
  static const int propertyNameIndex = 7;
  static const int buildingIndex = 8;
  static const int floorIndex = 9;
  static const int entranceTypeIndex = 10;
  static const int roomLabelIndex = 11;
  static const int roomOrderIndex = 12;

  static const List<String> nelsonLockConfigHeaders = [
    'IpAddress',
    'Port',
    'ControllerType',
    'ControllerId',
    'ControllerNumber',
    'Username',
    'Password',
    'PropertyName',
    'Building',
    'Floor',
    'EntranceType',
    'RoomLabel',
    'RoomOrder'
  ];

  static const List<List<String>> nelsonLockConfigTemplateData = [
    nelsonLockConfigHeaders,
    [
      '192.168.0.90',
      '80',
      'Axis A1601',
      'AXIS000',
      '1',
      'root',
      'pass',
      'HKI2',
      'A',
      '1',
      'Room',
      '101',
      '14'
    ]
  ];

  static const Map<int, TableColumnWidth> controllerTableColumnWidths = {
    0: FixedColumnWidth(40),
    1: FixedColumnWidth(100),
    2: FixedColumnWidth(140),
    3: FixedColumnWidth(70),
    4: FixedColumnWidth(100),
    5: FixedColumnWidth(100),
    6: FixedColumnWidth(150),
    7: FixedColumnWidth(160),
    8: FixedColumnWidth(200),
    9: FixedColumnWidth(90),
  };

  static const Map<int, TableColumnWidth> onlineControllerTableColumnWidths = {
    0: FixedColumnWidth(40),
    1: FixedColumnWidth(150),
    2: FixedColumnWidth(140),
    3: FixedColumnWidth(140),
    4: FixedColumnWidth(70),
    5: FixedColumnWidth(150),
  };
}
