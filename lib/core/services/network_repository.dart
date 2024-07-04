import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/main.dart';

AndroidDeviceInfo? myDeviceInfo;

String? userName = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
Map<String, String> iosHeader = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'current-User': userName ?? "",
  'time-zone': DateTime.now().timeZoneOffset.inMinutes.toString(),
  'app-version': AppConstant.appVersionIos,
  'app-os': "Ios"
};
Map<String, String> androidHeader = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'current-User': userName ?? "",
  'time-zone': DateTime.now().timeZoneOffset.inMinutes.toString(),
  'app-version': AppConstant.appVersionAndroid,
  'app-os': "android"
};

Future callPostMethod(String url, Map<String, dynamic> params) async {
//   if (Platform.isAndroid) {
//     bool developerMode = await FlutterJailbreakDetection.developerMode;
//     if (developerMode) {
//       AppUtils.showDialogBoxWithOneButton(
//         context: navigatorKey.currentState!.context,
//         text: "Please disable Developer Options to run the smoothly.",
//         titleText: "Developer Option",
//         btnColor: Colors.red,
//         btnText: "Open Settings",
//         onTap: () {
//           AppSettings.openAppSettings(type: AppSettingsType.developer);
//         },
//       );
//     } else {
//       if (kDebugMode) {
//         print("baseUrl--$url");
//         print("params--${jsonEncode(params)}");
//         print("header----${androidHeader}");
//       }
//
//       return await http
//           .post(
//         Uri.parse(url),
//         body: utf8.encode(json.encode(params)),
//         headers: androidHeader,
//       )
//           .then((http.Response response) {
//         return getResponse(response);
//       });
//     }
//   } else {
//     if (kDebugMode) {
//       print("baseUrl--$url");
//       print("params--${jsonEncode(params)}");
//       print("header----${iosHeader}");
//     }
//
//     return await http
//         .post(
//       Uri.parse(url),
//       body: utf8.encode(json.encode(params)),
//       headers: iosHeader,
//     )
//         .then((http.Response response) {
//       return getResponse(response);
//     });
//   }
// }

  if (kDebugMode) {
    print("baseUrl--$url");
    print("params--${jsonEncode(params)}");
    print("header----${androidHeader}");
  }

  return await http
      .post(
    Uri.parse(url),
    body: utf8.encode(json.encode(params)),
    headers: androidHeader,
  )
      .then((http.Response response) {
    return getResponse(response);
  });
}

Future callPostMethodForDevmode(String url, Map<String, dynamic> params) async {
  if (kDebugMode) {
    print("baseUrl--$url");
    print("params--${jsonEncode(params)}");
    print("header----${androidHeader}");
  }
  var requestUrl = url;
  return await http
      .post(
    Uri.parse(requestUrl),
    body:  utf8.encode(json.encode(params)),
    headers: androidHeader,
  )
      .then((http.Response response) {
    return getResponse(response);
  });
}


// Future callGetMethod(String url) async {
//   if (kDebugMode) {
//     print("baseUrl--$url");
//   }
//   var requestUrl = url;
//   return await http
//       .get(
//     Uri.parse(requestUrl),
//     headers: header,
//   )
//       .then((http.Response response) {
//     return getResponse(response);
//   });
// }

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

Future getResponse(Response response) async {
  final int statusCode = response.statusCode;
  printWrapped("response--statusCode--${response.statusCode}");
  printWrapped("response--${response.body}");
  if (statusCode == 500 || statusCode == 502) {
    return "{\"status\":\"false\",\"message\":\"Internal server issue\"}";
  } else if (statusCode == 401) {
    // MyAppState.navKey.currentContext;
    final parsedJson = jsonDecode(response.body.toString());
    final message = parsedJson['message'].toString();
    //WidgetUtils.errorMessage='Unauthorised user';
    return "{\"status\":\"false\",\"message\":\"$message\"}";
  } else if (statusCode == 403) {
    //  Unauthorised streams = Unauthorised.fromJson(json.decode(response.body));
    // return "{\"status\":\"0\",\"message\":\"${streams.message}\"}";
    return "{\"status\":\"false\",\"message\":\"Internal server issue\"}";
  } else if (statusCode == 405) {
    String error = "This Method not allowed.";
    printWrapped("response--$error");
    return "{\"status\":\"0\",\"message\":\"$error\"}";
  } else if (statusCode == 400) {
    // Unauthorised streams = Unauthorised.fromJson(json.decode(response.body));
    // return "{\"status\":\"0\",\"message\":\"${streams.message}\"}";
    return "{\"status\":\"0\",\"message\":\"Bad Request response\"}";
  } else if (statusCode == 422) {
    // Map<String, dynamic> data = jsonDecode(response.body);
    final parsedJson = jsonDecode(response.body.toString());
    final message = parsedJson['message'].toString();
    printWrapped("---sa-Add${message.replaceAll(RegExp(r'[^\w\s]+'), '')}");
    printWrapped("---sa-Add${message.replaceAll(RegExp(r'[^\w\s]+'), '')}");
    String error1 = message.replaceAll(RegExp(r'[^\w\s]+'), '');
    return "{\"status\":\"false\",\"message\":\"$error1\"}";
  } else if (statusCode == 426) {
    final parsedJson = jsonDecode(response.body.toString());
    final message = parsedJson['message'].toString();
    AppUtils.showDialogBoxWithOneButton(
      context: navigatorKey.currentState!.context,
      titleText: "App Update",
      text: message,
      btnColor: Colors.red,
      btnText: "Update now",
      onTap: () {
        if (Platform.isAndroid) {
          AppUtils.launchToBrowser(Uri.parse(AppConstant.androidAppLink));
        }
        if (Platform.isIOS) {
          AppUtils.launchToBrowser(Uri.parse(AppConstant.iosAppLink));
        }
      },
    );
  } else if (statusCode < 200 || statusCode > 404) {
    String error = response.headers['message'].toString();
    printWrapped("response--$error");
    return "{\"status\":\"0\",\"message\":\"$error\"}";
  }
  return response.body;
}
