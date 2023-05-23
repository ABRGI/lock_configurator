import 'package:flutter/material.dart';
import 'package:nelson_lock_manager/constants.dart';
import 'package:nelson_lock_manager/services/types/lock_controller.dart';

double getHorizontalEdgePadding(BuildContext context) {
  return MediaQuery.of(context).size.width < MediaSizes.mediaSmall
      ? LayoutConstants.edgePaddingSmall
      : LayoutConstants.edgePadding;
}

double getTitleTopPadding(BuildContext context) {
  return MediaQuery.of(context).size.width < MediaSizes.mediaSmall
      ? LayoutConstants.mainSectionSmallTitleTopPadding
      : LayoutConstants.mainSectionTitleTopPadding;
}

double getTitleBottomPadding(BuildContext context) {
  return MediaQuery.of(context).size.width < MediaSizes.mediaSmall
      ? LayoutConstants.mainSectionSmallTitleBottomPadding
      : LayoutConstants.mainSectionTitleBottomPadding;
}

double getTitleFontSize(BuildContext context) {
  return MediaQuery.of(context).size.width < MediaSizes.mediaSmall
      ? LayoutConstants.mainSectionSmallTitleFontSize
      : LayoutConstants.mainSectionTitleFontSize;
}

bool isControllerOnline(
    LockController lockController, List<LockController> onlineLockControllers) {
  return onlineLockControllers.isNotEmpty &&
      onlineLockControllers.any((onlineController) =>
          onlineController.ipAddress == lockController.ipAddress ||
          onlineController.linkLocalIpAddress == lockController.ipAddress);
}
