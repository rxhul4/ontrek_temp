import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static Future<void> launchToBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  static getBatteryLevel() async {
    var battery = Battery();
    int batteryLevel = 0; // Default value

    try {
      final value = await battery.batteryLevel;
      batteryLevel = value; // If value is null, assign 0
    } catch (e) {
      print("Error getting battery level: $e");
    }

    return batteryLevel;
  }

  static PreferredSizeWidget? commonAppBar(
      {required BuildContext context,
      String? title,
      Color? textColor,
      bool? isBack,
      bool? isBorder}) {
    return AppBar(
      surfaceTintColor: AppConstant.transparentColor,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: isBack == true
          ? AppUtils.commonSizedBox()
          : InkWell(
              onTap: () {
                Navigator.pop(context!);
              },
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppConstant.blackColor.withOpacity(0.7),
                size: 24,
              )),
      title: AppUtils.commonTextWidget(
          text: title ?? "",
          textColor: textColor ?? AppConstant.blackColor.withOpacity(0.7),
          fontSize: 16,
          fontWeight: FontWeight.w500),
      centerTitle: true,
      bottom: isBorder == true
          ? PreferredSize(
              preferredSize: Size.zero,
              child: AppUtils.commonContainer(
                  decoration: AppUtils.commonBoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AppConstant.blackColor.withOpacity(0.4),
                              width: 0.3)))),
            )
          : PreferredSize(
              preferredSize: Size.zero,
              child: AppUtils.commonContainer(
                decoration: AppUtils.commonBoxDecoration(
                  border: Border(
                      bottom: BorderSide.none),
                ),
              ),
            ),
    );
  }

  // static getAddress(double lat ,double long) async {
  //   const String googelApiKey = 'AIzaSyBtIPj5XDL4wiGpUaiXrYfTyWLDLlyvgbs';
  //   final bool isDebugMode = true;
  //   final api = GoogleGeocodingApi(googelApiKey, isLogged: isDebugMode);
  //   final reversedSearchResults = await api.reverse(
  //     '${lat},${long}',
  //     language: 'en',
  //   );
  //   print("address please111   \n${reversedSearchResults.results.first.formattedAddress}");
  //   return reversedSearchResults;
  // }

  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    return regex.hasMatch(value);
  }

  static Widget commonNetworkImageWidget(
      {String? path,
      double? width,
      double? height,
      Alignment? alignment,
      Color? iconColor,
      Color? loaderBackgroundColor,
      Color? loaderColor,
      // BaseCacheManager? cacheManager,
      BoxFit? boxFit}) {
    // DefaultCacheManager cm = DefaultCacheManager();
    // cm.emptyCache();
    return /*CachedNetworkImage(
      // cacheManager: cacheManager ?? CacheManager(Config(
      //   "fluttercampus",
      //   stalePeriod: const Duration(seconds: 2),
      //   //one week cache period
      // )),
      cacheManager: CacheManager(Config(
        "fluttercampus",
        stalePeriod: const Duration(seconds: 30),
        maxNrOfCacheObjects: 0,

        //one week cache period
      )),
      imageUrl: path.toString(),
      width: width,
      height: height,
      placeholder: (context, url) => showLoaderList(
          loaderBackgroundColor: loaderBackgroundColor,
          loaderColor: loaderColor),
      errorWidget: (context, url, error) => Image.asset(
        icNoImage,
        height: AppConstants.fifty,
        width: AppConstants.fifty,
      ),
      color: iconColor,
      fit: boxFit ?? BoxFit.cover,
    ) */
        Image.asset(
      path ?? "",

      width: width,
      // frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      //   if (wasSynchronouslyLoaded == true) return child;
      //   return Container(
      //       // padding: EdgeInsets.all(AppConstants.twenty),
      //       decoration: AppUtils.containerDecoration(
      //         // radius: 14,
      //         borderWidth: 0,
      //         borderColor: Colors.transparent,
      //         color: loaderBackgroundColor ??
      //             AppConstant.whiteColor.withOpacity(0.70),
      //       ),
      //       child: Center(
      //         child: CircularProgressIndicator(
      //           color: loaderColor ?? AppConstant.appPrimaryColor,
      //           strokeWidth: 1.0,
      //         ),
      //       ));
      // },
      // loadingBuilder: ((context, child, loadingProgress) {
      //   if (loadingProgress == null) return child;
      //   return Container(
      //     // padding: EdgeInsets.all(AppConstants.twenty),
      //       decoration: AppUtils.containerDecoration(
      //         // radius: 14,
      //         borderWidth: 0,
      //         borderColor: Colors.transparent,
      //         color: loaderBackgroundColor ??
      //             AppConstant.whiteColor.withOpacity(0.70),
      //       ),
      //       child: Center(
      //         child: CircularProgressIndicator(
      //           color: loaderColor ?? AppConstant.appPrimaryColor,
      //           strokeWidth: 1.0,
      //         ),
      //       ));
      // }),
      errorBuilder: (context, error, stackTrace) =>
          Center(child: Icon(Icons.person)),
      height: height,
      // alignment: alignment ?? Alignment.center,
      color: iconColor,
      fit: boxFit ?? BoxFit.cover,
    );
  }

  static Widget taskTile({String? titleText, String? username, String? date}) {
    return AppUtils.commonContainer(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
      decoration: BoxDecoration(
          color: AppConstant.whiteColor,
          borderRadius: AppUtils.borderRadiusAll(raduis: 10),
          boxShadow: [
            BoxShadow(
                color: AppConstant.greyColor.withOpacity(0.3),
                blurRadius: 8,
                blurStyle: BlurStyle.solid,
                spreadRadius: 0.8),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppConstant.appPrimaryColor,
                size: 18,
              ),
              AppUtils.commonSizedBox(width: 5),
              AppUtils.commonTextWidget(
                  text: titleText ?? "",
                  fontSize: 12,
                  textColor: AppConstant.blackColor.withOpacity(0.9),
                  fontWeight: FontWeight.w500),
            ],
          ),
          AppUtils.commonSizedBox(height: 5),
          Divider(
            color: AppConstant.greyColor.withOpacity(0.3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                // padding: EdgeInsets.all(18),
                padding: EdgeInsets.all(10),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.3),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.7), width: 1),
                ),
                child: Center(
                  child: AppUtils.commonNetworkImageWidget(
                      path: profileImage,
                      boxFit: BoxFit.cover,
                      iconColor: AppConstant.appPrimaryColor,
                      height: 25,
                      width: 25),
                ),
              ),
              AppUtils.commonSizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppUtils.commonTextWidget(
                    text: username ?? "",
                    fontWeight: FontWeight.w500,
                    textColor: Colors.black,
                    letterSpacing: 0.3,
                    fontSize: 12,
                  ),
                  AppUtils.commonTextWidget(
                    text: AppUtils.getDate(
                        date: date ?? "", format: "dd MMM yyyy hh:mm a"),
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black.withOpacity(0.7),
                    letterSpacing: 0.0,
                    fontSize: 10,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildHeader(
      {height,
      width,
      List<Widget>? actionWidget,
      String? title,
      String? subTitle,
      Color? loaderColor,
      String? leadingImage,
      Color? backgroundColor,
      Color? borderColor,
      Color? iconColor}) {
    return Container(
      alignment: Alignment.centerLeft,
      height: height * 0.09,
      width: width,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 5),
                        // padding: EdgeInsets.all(18),
                        padding: EdgeInsets.all(10),
                        height: double.infinity,
                        width: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              backgroundColor ?? Colors.grey.withOpacity(0.5),
                          border: Border.all(
                              color:
                                  borderColor ?? Colors.grey.withOpacity(0.7),
                              width: 2),
                        ),
                        child: Center(
                          child: AppUtils.commonNetworkImageWidget(
                              path: leadingImage ?? "",
                              boxFit: BoxFit.cover,
                              iconColor:
                                  iconColor ?? AppConstant.appPrimaryColor,
                              height: 25,
                              width: 25),
                        ),
                      ),
                      // AppUtils.commonSizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppUtils.commonTextWidget(
                            text: title ?? "",
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black,
                            letterSpacing: 0.3,
                            fontSize: 14,
                          ),
                          AppUtils.commonTextWidget(
                            text: subTitle ?? "",
                            fontWeight: FontWeight.w400,
                            textColor: Colors.grey.withOpacity(0.7),
                            letterSpacing: 0.0,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(children: actionWidget ?? []),
                ],
              ),
            ),
          ),
          // LinearProgressIndicator(color: loaderColor ?? Colors.blue )
        ],
      ),
    );
  }

  static Widget commonSlidePanel({
    double? maxHeight,
    double? minHeight,
    bool? isDraggable,
    bool? panelSnapping,
    PanelController? controller,
    Widget? panel,
    double? snapPoint,
    Widget Function(ScrollController)? panelBuilder,
    Function()? onPanelClosed,
    Function()? onPanelOpened,
    Function(double)? onPanelSlide,
    Widget? body,
  }) {
    return Animate(
      effects: const [
        SlideEffect(
            end: Offset(0, 0),
            curve: Curves.decelerate,
            begin: Offset(0, 1),
            duration: Duration(milliseconds: 700)),
      ],
      child: SlidingUpPanel(
        body: body,
        onPanelSlide: onPanelSlide,
        maxHeight: maxHeight ?? 1.0,
        minHeight: minHeight ?? 0.08,
        panelSnapping: panelSnapping ?? true,
        panelBuilder: panelBuilder,
        defaultPanelState: PanelState.OPEN,
        isDraggable: isDraggable ?? true,
        onPanelClosed: onPanelClosed,
        onPanelOpened: onPanelOpened,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        panel: panel,
        controller: controller,
        snapPoint: snapPoint,
      ),
    );
  }

  static BoxDecoration containerDecoration({
    double radius = 13,
    double radiusTopLeft = 0,
    double radiusBottomLeft = 0,
    double radiusTopRight = 0,
    double radiusBottomRight = 0,
    Color? color,
    bool isBoxShadow = false,
    bool isShowBorder = false,
    bool isTopLeftRight = false,
    Color? borderColor,
    // BoxShape boxShape = BoxShape.circle,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      borderRadius: isTopLeftRight
          ? circularTopLeftRightBorderRadius(
              radiusTopLeft,
              radiusBottomLeft,
              radiusTopRight,
              radiusBottomRight,
            )
          : circularBorderRadius(
              radius,
            ),
      // shape: boxShape,
      border: Border.all(
        width: isShowBorder ? borderWidth : 0,
        color: isShowBorder
            ? borderColor ?? AppConstant.transparentColor
            : AppConstant.transparentColor,
      ),
      color: color,
      boxShadow: isBoxShadow
          ? [
              BoxShadow(
                color: borderColor ?? AppConstant.transparentColor,
                offset: Offset(0, 2),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ]
          : [],
    );
  }

  static circularBorderRadius(double radius) {
    return BorderRadius.circular(
      radius,
    );
  }

  static appTextStyle() {
    return TextStyle(
      fontSize: 14,
      color: AppConstant.appPrimaryColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w500,
    );
  }

  static circularTopLeftRightBorderRadius(
    double radiusTopLeft,
    double radiusBottomLeft,
    double radiusTopRight,
    double radiusBottomRight,
  ) {
    return BorderRadius.only(
      topLeft: circularRadius(
        radiusTopLeft,
      ),
      bottomLeft: circularRadius(
        radiusBottomLeft,
      ),
      topRight: circularRadius(
        radiusTopRight,
      ),
      bottomRight: circularRadius(
        radiusBottomRight,
      ),
    );
  }

  static circularRadius(double radius) {
    return Radius.circular(
      radius,
    );
  }

  static Widget commonTextWidget(
      {required String text,
      Color? textColor,
      double? fontSize,
      double? letterSpacing,
      FontWeight? fontWeight,
      double? height,
      String? fontFamily,
      TextAlign? textAlign,
      EdgeInsets? margin,
      TextDecoration? decoration,
      TextOverflow? overflow}) {
    return Text(
      textAlign: textAlign,
      text,
      style: TextStyle(
        overflow: overflow,
        decoration: decoration,
        color: textColor ?? Colors.white,
        fontSize: fontSize ?? 14,
        letterSpacing: letterSpacing ?? 0.2,
        fontWeight: fontWeight,
        height: height,
        fontFamily: "Poppins",
      ),
    );
  }

  // static dialogWidget(String text, BuildContext? context) {
  //   return showDialog(
  //     context: context ?? navigatorKey.currentState!.context,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(10))),
  //         // Remove border radius
  //         insetPadding: const EdgeInsets.all(40),
  //         titlePadding: const EdgeInsets.all(0),
  //         contentPadding:
  //             const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // Text(text, textAlign: TextAlign.center,),
  //             AppUtils.commonTextWidget(
  //                 text: text,
  //                 textAlign: TextAlign.center,
  //                 textColor: AppConstant.blackColor,
  //                 fontWeight: FontWeight.w400),
  //             const SizedBox(height: 10),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 TextButton(
  //                   style: TextButton.styleFrom(
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10))),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: AppUtils.commonTextWidget(
  //                       text: "OK",
  //                       textColor: AppConstant.appPrimaryColor,
  //                       letterSpacing: 1,
  //                       fontWeight: FontWeight.w600),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  static loaderWidget({Color? color, double? radius}) {
    return Center(
        child: CupertinoActivityIndicator(
      animating: true,
      radius: radius ?? 15,
      color: color,
    ));
  }

  static Widget commonSizedBox({
    double? height,
    double? width,
    Widget? child,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: child,
    );
  }

  static Future<bool> checkInternetConnectivity() async {
    bool isInternetAvailable = false;

    final connectivityResult = await Connectivity().checkConnectivity();
    isInternetAvailable = connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;

    return isInternetAvailable;
  }

  static Future<bool> checkLocationServiceAvailability() async {
    bool isLocationServiceAvailable = false;
    isLocationServiceAvailable = await Geolocator.isLocationServiceEnabled();
    return isLocationServiceAvailable;
  }

  static dateFormat({
    DateTime? date,
    String? dateFormat,
  }) {
    return DateFormat(dateFormat ?? AppConstant.dateFormat)
        .format(date ?? DateTime.now());
  }

  static EdgeInsets edgeInsetsOnly({
    double? bottom,
    double? top,
    double? right,
    double? left,
  }) {
    return EdgeInsets.only(
        bottom: bottom ?? 0, top: top ?? 0, right: right ?? 0, left: left ?? 0);
  }

  static double getMediaHeight(BuildContext uiContext) {
    return MediaQuery.of(uiContext).size.height;
  }

  static double getMediaWidth(BuildContext uiContext) {
    return MediaQuery.of(uiContext).size.width;
  }

  static EdgeInsets edgeInsetsAll({
    double? allPadding,
  }) {
    return EdgeInsets.all(allPadding ?? 0);
  }

  static String getImagePathFromApi(trackingStatus) {
    String imagePath = "";
    if (trackingStatus != null) {
      print("Tracking Status: $trackingStatus");

      switch (trackingStatus) {
        case 'tracking_event_day_start':
          imagePath = loginIcon;
          break;
        case 'tracking_event_check_in':
          imagePath = checkInIcon;
          break;
        case 'tracking_event_check_out':
          imagePath = checkOutIcon;
          break;
        case 'tracking_event_waiting_start':
        case 'tracking_event_waiting_end':
          imagePath = waitingIcon;
          break;
        default:
          imagePath = logoutIcon;
      }
    } else {
      // Handling null case
      print("Tracking status is null");
      imagePath = logoutIcon; // or provide a default image path
    }
    return imagePath;
  }

  static Color getStatusColor(trackingStatus) {
    Color statusColor;
    if (trackingStatus != null) {
      print("Tracking Status: $trackingStatus");

      switch (trackingStatus) {
        case 'tracking_event_day_start':
          statusColor = Colors.lightGreen;
          break;
        case 'tracking_event_check_in':
          statusColor = AppConstant.appPrimaryColor;
          break;
        case 'tracking_event_check_out':
          statusColor = AppConstant.appPrimaryColor;
          break;
        case 'tracking_event_waiting_start':
        case 'tracking_event_waiting_end':
          statusColor = Colors.orangeAccent;
          break;
        default:
          statusColor = Colors.red;
      }
    } else {
      // Handling null case
      print("Tracking status is null");
      statusColor = Colors.red; // or provide a default image path
    }
    return statusColor;
  }

  static String switchCaseForTotType(int param) {
    String value = "";
    switch (param) {
      case 1:
        value = "visit_type_1";
        break;
      case 2:
        value = "visit_type_2";
        break;
      case 3:
        value = "visit_type_3";
        break;
      case 4:
        value = "visit_type_4";
        break;
      case 5:
        value = "visit_type_5";
        break;
      default:
        value = "";
        break;
    }
    return value;
  }

  static Color switchCaseForTaskStatus(String param) {
    Color color;
    switch (param) {
      case "Assigned":
        color = Colors.blue;
        break;
      case "Pending":
        color = Colors.grey;
        break;
      case "InProgress":
        color = Colors.orange;
        break;
      case "Overdue":
        color = Colors.red;
        break;
      default:
        color = Colors.green;
        break;
    }
    return color;
  }

  static Widget commonNoDataFound({String? text, VoidCallback? onPressed}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppUtils.commonTextWidget(
            text: text ?? "No Data Found", textColor: AppConstant.blackColor),
        AppUtils.commonSizedBox(height: 10),
        AppUtils.commonElevatedBtn(
          height: 45,
          text: "Refresh",
          bgColor: AppConstant.appPrimaryColor,
          textColor: AppConstant.whiteColor,
          borderRadiusAll: 10,
          leftMargin: 0,
          rightMargin: 0,
          bottomMargin: 0,
          topMargin: 0,
          onPressed: onPressed,
        )
      ],
    );
  }

  static String getDate({required String date, required String format}) {
    // print("uuuuuuuuu $date");
    String parseDate = '';
    if (date != '') {
      try {
        parseDate = DateFormat(format).format(DateTime.parse(date));
      } catch (e) {
        return parseDate;
      }
    }
    return parseDate;
  }

  static String removeMilliseconds(String durationString) {
    // Parse the duration string into a DateTime object
    DateTime dateTime = DateTime.parse("1970-01-01T$durationString");

    // Format the DateTime object without milliseconds
    String formattedDuration =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";

    return formattedDuration;
  }

  static showDialogBoxWithTwoButton(
      {BuildContext? context,
      String? text,
        String? titleText,
      String? onSuccessString,
      required Function() onSuccess,
      String? onCancelString,
      required Function() onCancel}) {
    return showDialog(
      context: context ?? navigatorKey.currentState!.context,
      builder: (context) {
        return CupertinoAlertDialog(
          title:  AppUtils.commonTextWidget(
              text: titleText ?? "",
              textColor: AppConstant.blackColor,
              fontSize: 14,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
          actions: [
            CupertinoDialogAction(
              child: AppUtils.commonTextWidget(
                  text: onCancelString ?? "Cancel",
                  textColor: AppConstant.appPrimaryColor,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5),
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
            ),
            CupertinoDialogAction(
              child: AppUtils.commonTextWidget(
                  text: onSuccessString ?? "OK",
                  textColor: AppConstant.appPrimaryColor,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5),
              onPressed: () {
                Navigator.pop(context);
                onSuccess();
              },
            ),

          ],
          content: AppUtils.commonTextWidget(
              text: text ?? "",
              textColor: AppConstant.blackColor,
              fontSize: 12,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5),
        );
      },
    );
  }

  static showDialogBoxWithOneButton({BuildContext? context, String? text}) {
    return showDialog(
      context: context ?? navigatorKey.currentState!.context,
      builder: (context) {
        return CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              child: AppUtils.commonTextWidget(
                  text: "OK",
                  textColor: AppConstant.appPrimaryColor,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: AppUtils.commonTextWidget(
              text: text ?? "",
              textColor: AppConstant.blackColor,
              fontSize: 12,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5),
        );
      },
    );
  }

  static Widget commonContainer({
    double? height,
    double? width,
    Alignment? alignment,
    BoxDecoration? decoration,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Widget? child,
    Color? color,
  }) {
    return Container(
      height: height,
      width: width,
      alignment: alignment,
      decoration: decoration,
      margin: margin,
      padding: padding,
      color: color,
      child: child,
    );
  }

  static BorderRadius borderRadiousonly({
    double? topleft,
    double? topright,
    double? bottomleft,
    double? bottomright,
  }) {
    return BorderRadius.only(
        topLeft: Radius.circular(topleft ?? 0),
        topRight: Radius.circular(topright ?? 0),
        bottomLeft: Radius.circular(bottomleft ?? 0),
        bottomRight: Radius.circular(bottomright ?? 0));
  }

  static Widget commonInkWell({
    Widget? child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
  }) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }

  static BoxDecoration commonBoxDecoration(
      {Color? color,
      BoxBorder? border,
      Gradient? gradient,
      BoxShape? shape,
      List<BoxShadow>? boxShadow,
      DecorationImage? image,
      BorderRadiusGeometry? borderRadius}) {
    return BoxDecoration(
      image: image,
      shape: shape ?? BoxShape.rectangle,
      color: color,
      boxShadow: boxShadow,
      border: border,
      gradient: gradient,
      borderRadius: borderRadius,
    );
  }

  static Widget imageAsset(
      {required String imagePath,
      Color? imageColor,
      double? width,
      double? height,
      BoxFit? fit}) {
    return Image.asset(
      imagePath,
      color: imageColor,
      height: height,
      fit: fit,
      width: width,
    );
  }

  static BorderRadiusGeometry borderRadiusAll({double? raduis}) {
    return BorderRadius.all(Radius.circular(raduis ?? 12));
  }

  static Widget commonElevatedBtn(
      {double? width,
      Color? bgColor,
      double? borderRadiusAll,
      double? bottomMargin,
      double? topMargin,
      double? rightMargin,
      double? leftMargin,
      VoidCallback? onPressed,
      String? text,
      String? fontFamily,
      double? fontSize,
      double? letterSpacing,
      double? height,
      Gradient? gradient,
      Color? backgroundColor,
      double? radius,
      Color? textColor,
      bool? isLoading = false}) {
    return commonContainer(
      height: height,
      width: width,
      decoration: commonBoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadiusAll ?? 5),
      ),
      margin: edgeInsetsOnly(
          bottom: bottomMargin ?? 0,
          top: topMargin ?? 0,
          right: rightMargin ?? 0,
          left: leftMargin ?? 0),
      child: ElevatedButton(
        onPressed: isLoading ?? false ? () {} : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusAll ?? 10),
          ),
        ),
        child: isLoading ?? false
            ? AppUtils.loaderWidget(color: Colors.white, radius: radius ?? 12)
            : commonTextWidget(
                text: text ?? '',
                fontFamily: fontFamily,
                textColor: textColor,
                fontSize: fontSize ?? 14,
                letterSpacing: letterSpacing,
              ),
      ),
    );
  }

  static showSnackBarWithColor(
      {BuildContext? context, required String message, Color? giveColor,Color? fontColor}) {
    return ScaffoldMessenger.of(context ?? navigatorKey.currentState!.context)
        .showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 800),
        content: AppUtils.commonTextWidget(
            text: message, textColor: fontColor ?? AppConstant.whiteColor),
        backgroundColor: giveColor ?? Colors.blue,
      ),
    );
  }
// static loaderWidget({Color? color}){
//   return Center(
//     child: SpinKitCubeGrid(
//       color: color ?? AppConstants.colorPurple,
//     ),
//   );
// }
}
