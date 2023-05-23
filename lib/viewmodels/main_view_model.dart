import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nelson_lock_manager/constants.dart';
import 'package:nelson_lock_manager/services/axis/axis_detector.dart';
import 'package:nelson_lock_manager/services/types/credentials.dart';
import 'package:nelson_lock_manager/services/types/lock_controller.dart';
import 'package:nelson_lock_manager/services/types/lock_type.dart';
import 'package:nelson_lock_manager/utilities.dart';

import '../services/types/access_controller.dart';
import '../services/types/access_type.dart';

class MainViewModel {
  List<LockController> lockControllers = [];
  List<LockController> onlineLockControllers = [];
  bool loading = false;
  bool filterOnlineControllersOnly = false;

  AxisDetector axisDetector = AxisDetector();

  void scanNetwork(
      {void Function()? onSuccess, void Function(String)? onError}) {
    log('Scanning for axis locks on network...');
    axisDetector.scanNetwork(
        onSuccess: (locks) {
          onlineLockControllers.clear();
          onlineLockControllers.addAll(locks);
          if (locks.isEmpty) {
            log('No axis locks detected on network!');
          } else {
            log('Axis locks detected on network. Total count ${onlineLockControllers.length}');
            for (var lock in locks) {
              log('${lock.id} - ${lock.type.toString()} IP ${lock.ipAddress}${lock.linkLocalIpAddress.isNotEmpty ? ' | ${lock.linkLocalIpAddress}' : ''}');
              //Find the imported controller data and update local ip and
              if (lockControllers.isNotEmpty &&
                  lock.linkLocalIpAddress.isNotEmpty) {
                LockController? matchedController = lockControllers.any(
                        (controller) => controller.ipAddress == lock.ipAddress)
                    ? lockControllers.singleWhere(
                        (controller) => controller.ipAddress == lock.ipAddress)
                    : null;
                if (matchedController != null) {
                  matchedController.linkLocalIpAddress =
                      lock.linkLocalIpAddress;
                  matchedController.id = lock.id;
                }
              }
            }
          }
          if (onSuccess != null) {
            ///Start Mock Section
            // onlineLockControllers.add(
            //   LockController(
            //       type: LockType.axis_1601,
            //       id: 'ABCD',
            //       credentials: Credentials(username: 'root', password: 'pass'),
            //       maxSupportedAccessControllers: 2,
            //       ipAddress: '192.168.0.90',
            //       linkLocalIpAddress: '169.254.21.109',
            //       authType: AuthType.digest),
            // );

            ///End Mock Section
            onSuccess();
          }
        },
        onError: onError);
    loading = false;
  }

  void configureSelectedLockControllers(
      {void Function()? onSuccess, void Function(String)? onError}) {
    List<LockController> locksToConfigure = [];
    List<LockController> locksToUpdateTestCode = [];
    lockControllers
        .where((lockController) => lockController.selected)
        .forEach((lockController) {
      if (isControllerOnline(lockController, onlineLockControllers)) {
        locksToConfigure.add(lockController);
        axisDetector.configureLockController(
            lockController: lockController,
            onSuccess: () {
              locksToConfigure.remove(lockController);
              locksToUpdateTestCode.add(lockController);
              if (onSuccess != null && locksToConfigure.isEmpty) {
                log('Configuration complete for all selected online axis lock controllers');
              }
              axisDetector.setTestAccessCodes(
                  lockController: lockController,
                  onSuccess: () {
                    locksToUpdateTestCode.remove(lockController);
                    if (onSuccess != null && locksToUpdateTestCode.isEmpty) {
                      log('Test access codes added to selected online axis lock controllers');
                      onSuccess();
                    }
                  },
                  onError: onError);
            },
            onError: onError);
      } else {
        log('Controller at ${lockController.ipAddress} is offline. Skipping configuration');
        if (onSuccess != null) {
          onSuccess();
        }
      }
    });
  }

  void initializeSelectedOnlineLockControllers(
      {void Function()? onSuccess, void Function(String)? onError}) {
    List<LockController> locksToConfigure = [];
    //First set the password
    onlineLockControllers
        .where((lockController) => lockController.selected)
        .forEach((lockController) {
      locksToConfigure.add(lockController);
      //Update the ipAddress and NTP
      axisDetector.updateNetworkConfiguration(
          lockController: lockController,
          onSuccess: () {
            axisDetector.updateNTPConfiguration(
                lockController: lockController,
                onSuccess: () {
                  //Then update the room configuration
                  lockControllers.remove(lockController);
                  if (lockControllers.isEmpty && onSuccess != null) {
                    onSuccess();
                  }
                },
                onError: onError);
          },
          onError: onError);
    });
  }

  void setFirstTimePassword(
      {void Function()? onSuccess, void Function(String)? onError}) {
    List<LockController> locksToConfigure = [];
    onlineLockControllers
        .where((lockController) => lockController.selected)
        .forEach((lockController) {
      locksToConfigure.add(lockController);
      axisDetector.setFirstTimeBootPassword(
          lockController: lockController,
          onSuccess: () {
            lockControllers.remove(lockController);
            if (lockControllers.isEmpty && onSuccess != null) {
              onSuccess();
            }
          },
          onError: onError);
    });
  }

  void importFromCsv(
      {void Function()? onSuccess, void Function(String)? onError}) {
    FilePicker.platform.pickFiles(
        allowedExtensions: ['xls', 'xslx', 'csv'],
        withReadStream: true).then((result) {
      if (result != null) {
        PlatformFile file = result.files.single;
        log('User selected ${file.extension != 'csv' ? 'invalid ' : ''}file - ${file.path}');
        if (file.extension == 'csv' && file.readStream != null) {
          log('reading stream');
          file.readStream!
              .transform(utf8.decoder)
              .transform(const CsvToListConverter())
              .toList()
              .then((csvData) => _parseCsvData(csvData, onSuccess: onSuccess))
              .onError((error, stackTrace) {
            log('Error transforming csv file!',
                error: error, stackTrace: stackTrace);
            if (onError != null) {
              onError(error.toString());
            }
          });
        }
      }
    }).onError((error, stackTrace) {
      log('Error picking file!', error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void exportConfigTemplate(
      {void Function()? onSuccess, void Function(String)? onError}) {
    FilePicker.platform.saveFile(
        fileName: 'NelsonLockTemplate.csv',
        type: FileType.custom,
        allowedExtensions: ['csv']).then((savePath) {
      if (savePath != null) {
        log('Exporting config template to $savePath');
        String csv = const ListToCsvConverter()
            .convert(NelsonLockConfigTemplate.nelsonLockConfigTemplateData);
        File file = File(savePath);
        file.writeAsString(csv).then((value) {
          log('Successfully exported config template');
          if (onSuccess != null) {
            onSuccess();
          }
        }).onError((error, stackTrace) {
          log('Error exporting csv template!',
              error: error, stackTrace: stackTrace);
          if (onError != null) {
            onError(error.toString());
          }
        });
      }
    }).onError((error, stackTrace) {
      log('Error exporting csv template!',
          error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void exportConfigData(
      {void Function()? onSuccess, void Function(String)? onError}) {
    FilePicker.platform.saveFile(
        fileName: 'NelsonDataExport.csv',
        type: FileType.custom,
        allowedExtensions: ['csv']).then((savePath) {
      if (savePath != null) {
        log('Exporting config data to $savePath');
        List<List<String>> exportData = [
          [
            ...NelsonLockConfigTemplate.nelsonLockConfigHeaders,
            'Access Token',
            'Access Profile'
          ]
        ];
        for (var lockController in lockControllers
            .where((lockController) => lockController.selected)) {
          for (var accessController in lockController.accessControllers) {
            exportData.add([
              lockController.ipAddress,
              lockController.port.toString(),
              lockController.type.toString(),
              lockController.id,
              lockController.controllerNumber.toString(),
              lockController.credentials.username,
              lockController.credentials.password,
              lockController.propertyName,
              accessController.buildingLabel,
              accessController.floor.toString(),
              accessController.accessType.toString(),
              accessController.label,
              accessController.roomOrder.toString(),
              axisDetector.getAccessProfileToken(
                  lockController, accessController),
              axisDetector.getAccessProfileName(accessController)
            ]);
          }
        }
        String csv = const ListToCsvConverter().convert(exportData);
        File file = File(savePath);
        file.writeAsString(csv).then((value) {
          log('Successfully exported data template');
          if (onSuccess != null) {
            onSuccess();
          }
        }).onError((error, stackTrace) {
          log('Error exporting csv data!',
              error: error, stackTrace: stackTrace);
          if (onError != null) {
            onError(error.toString());
          }
        });
      }
    }).onError((error, stackTrace) {
      log('Error exporting csv data!', error: error, stackTrace: stackTrace);
      if (onError != null) {
        onError(error.toString());
      }
    });
  }

  void _parseCsvData(List<List<dynamic>> csvData,
      {void Function()? onSuccess}) {
    for (var csvRow in csvData) {
      if (csvData.indexOf(csvRow) > 0) {
        LockController lockController;
        lockController = lockControllers.firstWhere(
          (lock) =>
              (csvRow[NelsonLockConfigTemplate.ipAddressIndex]
                      .toString()
                      .isNotEmpty &&
                  lock.ipAddress ==
                      csvRow[NelsonLockConfigTemplate.ipAddressIndex]
                          .toString()) ||
              (csvRow[NelsonLockConfigTemplate.controllerNumberIndex]
                      .toString()
                      .isNotEmpty &&
                  lock.controllerNumber ==
                      csvRow[NelsonLockConfigTemplate.controllerNumberIndex]) ||
              (csvRow[NelsonLockConfigTemplate.controllerIdIndex]
                      .toString()
                      .isNotEmpty &&
                  lock.id ==
                      csvRow[NelsonLockConfigTemplate.controllerIdIndex]),
          orElse: () => _createLockControllerFromCsvRow(csvRow),
        );
        if (!lockControllers.contains(lockController)) {
          lockControllers.add(lockController);
        }
        AccessController accessController =
            _createAccessControllerFromCsvRow(csvRow);
        if (lockController.accessControllers.isEmpty) {
          lockController.accessControllers = [];
        }
        if (!lockController.accessControllers.any((access) =>
            (access.label == accessController.label &&
                access.accessType == accessController.accessType))) {
          lockController.accessControllers.add(accessController);
        } else {}
      }
    }
    if (onSuccess != null) {
      onSuccess();
    }
  }

  LockController _createLockControllerFromCsvRow(List<dynamic> csvRow) {
    LockController lockController = LockController(
        type: LockType.fromString(
            csvRow[NelsonLockConfigTemplate.controllerTypeIndex]),
        id: csvRow[NelsonLockConfigTemplate.controllerIdIndex],
        credentials: Credentials(
            username: csvRow[NelsonLockConfigTemplate.usernameIndex],
            password: csvRow[NelsonLockConfigTemplate.passwordIndex]),
        ipAddress: csvRow[NelsonLockConfigTemplate.ipAddressIndex],
        port: csvRow[NelsonLockConfigTemplate.portIndex],
        controllerNumber:
            csvRow[NelsonLockConfigTemplate.controllerNumberIndex],
        propertyName: csvRow[NelsonLockConfigTemplate.propertyNameIndex]);
    if (onlineLockControllers.isNotEmpty) {
      LockController? matchedController = onlineLockControllers.any(
              (onlineController) =>
                  onlineController.ipAddress == lockController.ipAddress)
          ? onlineLockControllers.singleWhere((onlineController) =>
              onlineController.ipAddress == lockController.ipAddress)
          : null;
      if (matchedController != null) {
        lockController.linkLocalIpAddress =
            matchedController.linkLocalIpAddress;
        lockController.id = matchedController.id;
      }
    }
    return lockController;
  }

  AccessController _createAccessControllerFromCsvRow(List<dynamic> csvRow) {
    return AccessController(
        name: '',
        accessType: AccessType.fromString(
            csvRow[NelsonLockConfigTemplate.entranceTypeIndex]),
        label: csvRow[NelsonLockConfigTemplate.roomLabelIndex].toString(),
        floor: csvRow[NelsonLockConfigTemplate.floorIndex],
        buildingLabel: csvRow[NelsonLockConfigTemplate.buildingIndex],
        roomOrder: csvRow[NelsonLockConfigTemplate.roomOrderIndex]);
  }

  void resetData({void Function()? onSuccess}) {
    lockControllers.clear();
    onlineLockControllers.clear();
    if (onSuccess != null) {
      onSuccess();
    }
  }
}
