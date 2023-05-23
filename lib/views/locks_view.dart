import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nelson_lock_manager/components/lock_grid.dart';
import 'package:nelson_lock_manager/components/main_section.dart';
import 'package:nelson_lock_manager/constants.dart';
import 'package:nelson_lock_manager/viewmodels/view_model_factory.dart';

import '../utilities.dart';

class LocksView extends StatefulWidget {
  const LocksView({super.key});

  @override
  State<LocksView> createState() => _LocksViewState();
}

class _LocksViewState extends State<LocksView> {
  bool scanning = false;
  bool configurationInProcess = false;
  bool onlineConfigurationInProcess = false;
  bool passwordInitializationInProcess = false;
  String firstPassword = '';
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Padding(
        padding: const EdgeInsets.only(
            bottom: LayoutConstants.mainSectionSmallTitleBottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
                onPressed: () {
                  if (scanning) {
                    log('Scan in process');
                    return;
                  }
                  setState(() {
                    scanning = true;
                  });
                  ViewModelFactory.mainViewModel.scanNetwork(onSuccess: () {
                    setState(() {
                      scanning = false;
                    });
                  }, onError: (error) {
                    setState(() {
                      //TODO: display a visual error note
                      scanning = false;
                    });
                  });
                },
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                child: Text(
                  scanning ? 'Scanning...' : 'Scan Network',
                  style: const TextStyle(color: Colors.white),
                )),
            TextButton(
              onPressed: () {
                ViewModelFactory.mainViewModel.importFromCsv(onSuccess: () {
                  log('Imported controller data from file. Total ${ViewModelFactory.mainViewModel.lockControllers.length} available');
                  setState(() {});
                });
              },
              style: TextButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0),
              ),
              child: Text(
                'Import Lock Data',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                ViewModelFactory.mainViewModel.exportConfigTemplate();
              },
              style: TextButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0),
              ),
              child: Text(
                'Export Data Template',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                ViewModelFactory.mainViewModel
                    .resetData(onSuccess: () => setState(() {}));
              },
              style: TextButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0),
              ),
              child: Text(
                'Clear Data',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ]
              .map<Widget>((action) => Padding(
                    padding: const EdgeInsets.only(
                        right: LayoutConstants.buttonEdgePadding),
                    child: action,
                  ))
              .toList(),
        ),
      ),
    ];
    if (ViewModelFactory.mainViewModel.lockControllers.isNotEmpty ||
        ViewModelFactory.mainViewModel.onlineLockControllers.isNotEmpty) {
      children.add(
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding:
                const EdgeInsets.only(right: LayoutConstants.buttonEdgePadding),
            child: TextButton(
                onPressed: () {
                  if (configurationInProcess) {
                    log('Lock controller configuration currently in progress. Try later.');
                    return;
                  }
                  log('Congifuration of lock controllers requested');
                  if (ViewModelFactory.mainViewModel.lockControllers.isEmpty) {
                    log('No lock controller imported');
                    setState(() {
                      configurationInProcess = false;
                    });
                  } else if (!ViewModelFactory.mainViewModel.lockControllers
                      .any((controller) => controller.selected)) {
                    log('No lock controller selected');
                    setState(() {
                      configurationInProcess = false;
                    });
                  } else {
                    setState(() {
                      configurationInProcess = true;
                    });
                    ViewModelFactory.mainViewModel
                        .configureSelectedLockControllers(onSuccess: () {
                      log('Lock controller configuration complete');
                      setState(() {
                        configurationInProcess = false;
                      });
                    }, onError: (error) {
                      setState(() {
                        //TODO: display a visual error note
                        configurationInProcess = false;
                      });
                    });
                  }
                },
                style: TextButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0),
                ),
                child: Text(configurationInProcess
                    ? 'Please wait...'
                    : 'Configure Selected Controllers')),
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: LayoutConstants.buttonEdgePadding),
            child: TextButton(
                onPressed: () {
                  log('Export of lock controllers configuration requested');
                  if (ViewModelFactory.mainViewModel.lockControllers.isEmpty) {
                    log('No lock controller imported');
                  } else if (!ViewModelFactory.mainViewModel.lockControllers
                      .any((controller) => controller.selected)) {
                    log('No lock controller selected');
                  } else {
                    ViewModelFactory.mainViewModel.exportConfigData(
                        onSuccess: () {
                      log('Lock controller configuration exported');
                    }, onError: (error) {
                      log('Lock controller configuration export failed',
                          error: {});
                    });
                  }
                },
                style: TextButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0),
                ),
                child: const Text('Export Controller Data')),
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: LayoutConstants.buttonEdgePadding),
            child: TextButton(
                onPressed: () {
                  if (onlineConfigurationInProcess) {
                    log('Online lock controller initialization currently in progress. Try later.');
                    return;
                  }
                  log('Congifuration of online lock controllers requested');
                  if (ViewModelFactory
                      .mainViewModel.onlineLockControllers.isEmpty) {
                    log('No lock controllers available online');
                    setState(() {
                      configurationInProcess = false;
                    });
                  } else if (!ViewModelFactory
                      .mainViewModel.onlineLockControllers
                      .any((controller) => controller.selected)) {
                    log('No online lock controller selected');
                    setState(() {
                      onlineConfigurationInProcess = false;
                    });
                  } else {
                    setState(() {
                      onlineConfigurationInProcess = true;
                    });
                    ViewModelFactory.mainViewModel
                        .initializeSelectedOnlineLockControllers(onSuccess: () {
                      log('Online lock controller initialization setup complete');
                      setState(() {
                        onlineConfigurationInProcess = false;
                      });
                    }, onError: (error) {
                      setState(() {
                        //TODO: display a visual error note
                        onlineConfigurationInProcess = false;
                      });
                    });
                  }
                },
                style: TextButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0),
                ),
                child: Text(onlineConfigurationInProcess
                    ? 'Please wait...'
                    : 'Initialize Selected Online Controllers')),
          ),
          TextButton(
              onPressed: () {
                if (passwordInitializationInProcess) {
                  log('Online lock controller password initialization currently in progress. Try later.');
                  return;
                }
                log('Initial password congifuration of online lock controllers requested');
                if (ViewModelFactory
                    .mainViewModel.onlineLockControllers.isEmpty) {
                  log('No lock controllers available online');
                  setState(() {
                    configurationInProcess = false;
                  });
                } else if (!ViewModelFactory.mainViewModel.onlineLockControllers
                    .any((controller) => controller.selected)) {
                  log('No online lock controller selected');
                  setState(() {
                    passwordInitializationInProcess = false;
                  });
                } else {
                  setState(() {
                    passwordInitializationInProcess = true;
                  });
                  ViewModelFactory.mainViewModel.setFirstTimePassword(
                      onSuccess: () {
                    log('Online lock controller password initialization setup complete');
                    setState(() {
                      passwordInitializationInProcess = false;
                    });
                  }, onError: (error) {
                    setState(() {
                      //TODO: display a visual error note
                      passwordInitializationInProcess = false;
                    });
                  });
                }
              },
              style: TextButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0),
              ),
              child: Text(passwordInitializationInProcess
                  ? 'Please wait...'
                  : 'Set Initial Password')),
        ]),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MainSection(
          title: 'Lock Configuration',
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getHorizontalEdgePadding(context),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LockGrid(
                  lockControllers:
                      ViewModelFactory.mainViewModel.lockControllers,
                  onlineLockControllers:
                      ViewModelFactory.mainViewModel.onlineLockControllers,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
