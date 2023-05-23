//Main section defines the user input place for any MUI page
import 'package:flutter/material.dart';
import 'package:nelson_lock_manager/constants.dart';
import 'package:nelson_lock_manager/theme_styles.dart';
import 'package:nelson_lock_manager/utilities.dart';

class MainSection extends StatefulWidget {
  final String title;
  final TextButton? primaryAction;
  final List<TextButton> secondaryAction;
  final Widget? child;
  const MainSection(
      {super.key,
      required this.title,
      this.primaryAction,
      this.secondaryAction = const [],
      this.child});
  @override
  State<MainSection> createState() => _MainSectionState();
}

class _MainSectionState extends State<MainSection> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      //Title
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: LayoutConstants.mainSectionTitleBottomPadding),
            child:
                Text(widget.title, style: ThemeStyles.getTitleStyle(context)),
          )
        ],
      ),
      const Spacer(),
    ];

    List<TextButton> actions = [];
    actions.addAll(widget.secondaryAction);
    if (widget.primaryAction != null) {
      actions.insert(0, widget.primaryAction!);
      children.addAll(actions.reversed.map((action) => Padding(
            padding:
                const EdgeInsets.only(left: LayoutConstants.buttonEdgePadding),
            child: action,
          )));
    }

    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            getHorizontalEdgePadding(context),
            getTitleTopPadding(context),
            getHorizontalEdgePadding(context),
            getTitleBottomPadding(context)),
        child: Column(
          children: [
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: children),
            widget.child != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [widget.child!])
                : const Row(),
          ],
        ),
      ),
    );
  }
}
