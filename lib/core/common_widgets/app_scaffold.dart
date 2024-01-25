import 'package:flutter/material.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final Widget? drawer;
  final Key? scaffoldKey;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final Function? getKey;
  Widget? bottomSheet;

  AppScaffold(
      {Key? key,
        required this.body,
        this.bottomNavigationBar,
        this.appBar,
        this.drawer,
        this.backgroundColor,
        this.scaffoldKey,
        this.getKey,
        this.bottomSheet})
      : super(key: key);

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();




  @override
  Widget build(BuildContext context) {
    if (widget.getKey != null) {
      widget.getKey!(scaffoldKey);
    }
    return Stack(children: [
      // WidgetUtils.commonContainer(
      //     child: Image.asset(
      //   icAppBg2,
      //   fit: BoxFit.fill,
      //   height: double.infinity,
      //   width: double.infinity,
      // )),
      Scaffold(
          key: scaffoldKey,
          extendBody: false,
          backgroundColor: widget.backgroundColor,
          bottomNavigationBar: widget.bottomNavigationBar,
          appBar: widget.appBar,
          drawer: widget.drawer,
          // bottomSheet: widget.bottomSheet,
          body: widget.body),
    ]);
  }
}
