import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class CommonWebViewWidget extends StatefulWidget {
  String? url;
  String? title;

  CommonWebViewWidget({Key? key, this.url, this.title})
      : super(
          key: key,
        );

  @override
  State<CommonWebViewWidget> createState() => _CommonWebViewWidgetState();
}

class _CommonWebViewWidgetState extends State<CommonWebViewWidget> {
  late final PlatformWebViewController controller;
  bool? isInternetAvailable;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkInternetConnectivity();
    controller = PlatformWebViewController(
      AndroidWebViewControllerCreationParams(),
    )..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url ?? "")));
  }

  checkInternetConnectivity() async {
    isInternetAvailable = await AppUtils.checkInternetConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.commonAppBar(
          context: context, title: widget.title, isBack: true, isBorder: true),
      body: isInternetAvailable == false
          ? AppUtils.commonNoDataFound(
              text: "Internet is not Available",
              onPressed: () {
                controller = PlatformWebViewController(
                  AndroidWebViewControllerCreationParams(),
                )..loadRequest(
                    LoadRequestParams(uri: Uri.parse(widget.url ?? "")));
              },
            )
          : PlatformWebViewWidget(
              PlatformWebViewWidgetCreationParams(controller: controller),
            ).build(context),
    );
  }
}
