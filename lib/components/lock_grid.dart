import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nelson_lock_manager/constants.dart';
import 'package:nelson_lock_manager/services/types/credentials.dart';
import 'package:nelson_lock_manager/theme_styles.dart';
import 'package:nelson_lock_manager/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/types/lock_controller.dart';

class LockGrid extends StatefulWidget {
  final List<LockController> lockControllers;
  final List<LockController> onlineLockControllers;

  const LockGrid(
      {Key? key,
      this.lockControllers = const [],
      this.onlineLockControllers = const []})
      : super(key: key);

  @override
  State<LockGrid> createState() => _LockGridState();
}

class _LockGridState extends State<LockGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.lockControllers.isEmpty &&
        widget.onlineLockControllers.isEmpty) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: LayoutConstants.tableCellPadding),
            child: Text("Scan or import data to see grid"),
          ),
        ],
      );
    } else {
      List<Widget> children = [];
      if (widget.lockControllers.isNotEmpty) {
        children.addAll([
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: LayoutConstants.tableCellPadding),
                child: Text(
                  "Imported Data",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          _createLockControllerHeaderRow(),
        ]);
        for (var lockController in widget.lockControllers) {
          children
              .add(_createLockControllerRow(lockController: lockController));
        }
      }
      if (widget.onlineLockControllers.isNotEmpty) {
        children.addAll([
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: LayoutConstants.tableCellPadding),
                child: Text(
                  "Online lock controllers",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          _createOnlineLockControllersTable(),
        ]);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
  }

  TableCell _createTableCell({required Widget child, bool noPadding = false}) {
    return TableCell(
      child: Padding(
        padding:
            EdgeInsets.all(noPadding ? 0 : LayoutConstants.tableCellPadding),
        child: child,
      ),
    );
  }

  Row _createLockControllerHeaderRow() {
    return Row(
      children: [
        Table(
          border: TableBorder.all(
              color: ThemeStyles.tableContentBorder,
              width: ThemeStyles.tableBorderWidth),
          defaultColumnWidth:
              const FixedColumnWidth(LayoutConstants.defaultTableColumnWidth),
          columnWidths: NelsonLockConfigTemplate.controllerTableColumnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration:
                  const BoxDecoration(color: ThemeStyles.tableHeaderBackground),
              children: [
                _createTableCell(
                    child: Align(
                  alignment: Alignment.centerLeft,
                  child: Checkbox(
                      value: !widget.lockControllers
                          .any((controller) => !controller.selected),
                      onChanged: (changed) {
                        log('All controllers selected/unselected');
                        setState(() {
                          bool allSelected =
                              widget.lockControllers.any((c) => !c.selected);
                          for (var controller in widget.lockControllers) {
                            controller.selected = allSelected;
                          }
                        });
                      }),
                )),
                _createTableCell(
                    child: Text(
                  'Status',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Ip Address',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Port',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Controller Type',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Controller Id',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Controller Number',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Username',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Password',
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                _createTableCell(
                    child: Text(
                  'Propery',
                  style: Theme.of(context).textTheme.bodyLarge,
                ))
              ],
            ),
          ],
        ),
      ],
    );
  }

  Row _createLockControllerRow({required LockController lockController}) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(
                  color: ThemeStyles.tableContentBorder,
                  width: ThemeStyles.tableBorderWidth),
              defaultColumnWidth: const FixedColumnWidth(
                  LayoutConstants.defaultTableColumnWidth),
              columnWidths:
                  NelsonLockConfigTemplate.controllerTableColumnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    _createTableCell(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: Checkbox(
                          value: lockController.selected,
                          onChanged: (changed) {
                            log('Controller ${lockController.id} ${!(changed ?? false) ? 'un' : ''}selected');
                            setState(() {
                              lockController.selected = changed ?? false;
                            });
                          }),
                    )),
                    _createTableCell(
                        child: Text(
                      isControllerOnline(
                              lockController, widget.onlineLockControllers)
                          ? 'Online'
                          : 'Offline',
                      style: TextStyle(
                          color: isControllerOnline(
                                  lockController, widget.onlineLockControllers)
                              ? ThemeStyles.successColor
                              : ThemeStyles.errorColor),
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.ipAddress.toString(),
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.port.toString(),
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.type.toString(),
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.id,
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.controllerNumber.toString(),
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.credentials.username,
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.credentials.password,
                    )),
                    _createTableCell(
                        child: Text(
                      lockController.propertyName,
                    )),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: LayoutConstants.tableCellPadding,
                  bottom: LayoutConstants.tableCellPadding,
                  left: LayoutConstants.insetPadding),
              child: Text(
                'Controller accesses',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: LayoutConstants.tableCellPadding,
                  bottom: LayoutConstants.tableCellPadding,
                  left: LayoutConstants.insetPadding),
              child: _createEntrancesTable(lockController),
            )
          ],
        ),
      ],
    );
  }

  Table _createEntrancesTable(LockController lockController) {
    List<TableRow> children = [
      TableRow(
          decoration:
              const BoxDecoration(color: ThemeStyles.tableHeaderBackground),
          children: [
            _createTableCell(
                child: Text(
              'Building',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Floor',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Entrance Type',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Room Label',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Room Order',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
          ])
    ];
    for (var controller in lockController.accessControllers) {
      children.add(TableRow(children: [
        _createTableCell(
            child: Text(
          controller.buildingLabel,
        )),
        _createTableCell(
            child: Text(
          controller.floor.toString(),
        )),
        _createTableCell(
            child: Text(
          controller.accessType.toString(),
        )),
        _createTableCell(
            child: Text(
          controller.label,
        )),
        _createTableCell(
            child: Text(
          controller.roomOrder.toString(),
        )),
      ]));
    }
    return Table(
        border: TableBorder.all(
            color: ThemeStyles.tableContentBorder,
            width: ThemeStyles.tableBorderWidth),
        defaultColumnWidth:
            const FixedColumnWidth(LayoutConstants.defaultTableColumnWidth),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: children);
  }

  Row _createOnlineLockControllersTable() {
    List<TableRow> children = [
      TableRow(
          decoration:
              const BoxDecoration(color: ThemeStyles.tableHeaderBackground),
          children: [
            _createTableCell(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Checkbox(
                  value: !widget.onlineLockControllers
                      .any((controller) => !controller.selected),
                  onChanged: (changed) {
                    log('All controllers selected/unselected');
                    setState(() {
                      bool allSelected =
                          widget.onlineLockControllers.any((c) => !c.selected);
                      for (var controller in widget.onlineLockControllers) {
                        controller.selected = allSelected;
                      }
                    });
                  }),
            )),
            _createTableCell(
                child: Text(
              'Controller Id',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Ip Address',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Link-Local Address',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Port',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Controller Type',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Update Ip',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Update NTP',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'Initial Password',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            _createTableCell(
                child: Text(
              'New Password',
              style: Theme.of(context).textTheme.bodyLarge,
            )),
          ])
    ];
    for (var controller in widget.onlineLockControllers) {
      children.add(TableRow(children: [
        _createTableCell(
            child: Align(
          alignment: Alignment.centerLeft,
          child: Checkbox(
              value: controller.selected,
              onChanged: (changed) {
                log('Online controller ${controller.id} ${!(changed ?? false) ? 'un' : ''}selected');
                setState(() {
                  controller.selected = changed ?? false;
                });
              }),
        )),
        _createTableCell(
            child: SelectableText(
          controller.id,
        )),
        _createTableCell(
            child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            text: controller.ipAddress,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                Uri uri = Uri.http(controller.linkLocalIpAddress,
                    'webapp/pacs/index.shtml#hardware-installation');
                log(uri.toString());
                if (await canLaunchUrl(uri)) {
                  await launch(
                      'http://${controller.linkLocalIpAddress}/webapp/pacs/index.shtml#hardware-installation',
                      forceWebView: true);
                }
              },
          ),
        )),
        _createTableCell(
            child: SelectableText(
          controller.linkLocalIpAddress,
        )),
        _createTableCell(
            child: Text(
          controller.port.toString(),
        )),
        _createTableCell(
            child: Text(
          controller.type.toString(),
        )),
        _createTableCell(
            child: TextField(
          onChanged: (value) => controller.updatedIp = value,
        )),
        _createTableCell(
            child: TextField(
          onChanged: (value) => controller.ntp = value,
        )),
        _createTableCell(
            child: TextField(
          onChanged: (value) => controller.credentials.password = value,
        )),
        _createTableCell(child: TextField(
          onChanged: (value) {
            controller.newCredentials ??= Credentials(
                username: controller.credentials.username, password: value);
            controller.newCredentials!.password = value;
          },
        )),
      ]));
    }
    return Row(children: [
      Table(
          border: TableBorder.all(
              color: ThemeStyles.tableContentBorder,
              width: ThemeStyles.tableBorderWidth),
          defaultColumnWidth:
              const FixedColumnWidth(LayoutConstants.defaultTableColumnWidth),
          columnWidths:
              NelsonLockConfigTemplate.onlineControllerTableColumnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: children)
    ]);
  }
}
