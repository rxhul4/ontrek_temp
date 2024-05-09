import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';


class CommonWebViewWidget extends StatefulWidget {
  String? url;
  String? title;

  CommonWebViewWidget({Key? key,this.url,this.title}) : super(key: key,);

  @override
  State<CommonWebViewWidget> createState() => _CommonWebViewWidgetState();
}

class _CommonWebViewWidgetState extends State<CommonWebViewWidget> {

  late final PlatformWebViewController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = PlatformWebViewController(
      AndroidWebViewControllerCreationParams(),
    )
      ..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url ?? "")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: AppUtils.commonInkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppConstant.blackColor.withOpacity(0.7),
              size: 20,
            ),
          ),
        ),
        title: AppUtils.commonTextWidget(
          text: widget.title ?? "",
          textColor: AppConstant.blackColor.withOpacity(0.7),
          fontSize: 16,
        ),
        centerTitle: true,
      ),
      body: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: controller),
      ).build(context),

    );

  }
}
