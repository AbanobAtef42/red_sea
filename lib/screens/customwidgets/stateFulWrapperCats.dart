import 'package:flutter/material.dart';

class StatefulWrapper2 extends StatefulWidget {
  final Function? onInit;
  final Widget child;


  const StatefulWrapper2({required this.onInit, required this.child});
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();

  static _StatefulWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<_StatefulWrapperState>()!;
  }
}
class _StatefulWrapperState extends State<StatefulWrapper2> {
  @override
  void initState() {
    if(widget.onInit != null) {
      widget.onInit!();
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return widget.child;
  }
  void rebuild() {
    setState(() {});
  }

}