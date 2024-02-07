import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class AppUtils {
  static Widget commonTextWidget({
    required String text,
    Color? textColor,
    double? fontSize,
    double? letterSpacing,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    TextAlign? textAlign,
    EdgeInsets? margin,
    TextDecoration? decoration,
  }) {
    return Text(
      textAlign: textAlign,
      text,
      style: TextStyle(
        decoration: decoration,
        color: textColor ?? Colors.white,
        fontSize: fontSize ?? 14,
        letterSpacing: letterSpacing ??0.2 ,
        fontWeight: fontWeight,
        height: height,
        fontFamily: "Poppins",
      ),
    );
  }


  static loaderWidget({Color? color, double? size}) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? AppConstant.blueColor,
      ),
    );
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
    isInternetAvailable = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;

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
  }){
    return DateFormat(dateFormat ?? AppConstant.dateFormat).format(date ?? DateTime.now());
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


  static Widget commonNoDataFound({String? text,VoidCallback? onPressed}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppUtils.commonTextWidget(
            text: text ?? "No Data Found",textColor: AppConstant.blackColor),
        AppUtils.commonSizedBox(height: 10),
        AppUtils.commonElevatedBtn(
          height: 50,
          text: "Refresh",
          bgColor: AppConstant.blueColor,
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
    return  BorderRadius.only(topLeft: Radius.circular(topleft ?? 0),topRight: Radius.circular(topright ?? 0),bottomLeft: Radius.circular(bottomleft ?? 0),bottomRight:  Radius.circular(bottomright ?? 0));
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

  static Widget commonElevatedBtn({
    double? width,
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
    Color? textColor
  }) {
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusAll ?? 10),
          ),
        ),
        child: commonTextWidget(
          text: text ?? '',
          fontFamily: fontFamily,
          textColor:  textColor,
          fontSize: fontSize ?? 14,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }

  static showSnackBarWithColor(
      {required BuildContext context,
      required String message,
      Color? giveColor}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 800),
        content: AppUtils.commonTextWidget(text: message,textColor: AppConstant.whiteColor),
        backgroundColor: Colors.blue ?? giveColor,
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
