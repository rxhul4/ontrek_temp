import 'dart:async';
import 'dart:convert';


import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:ontrek/core/storage/preference_helper.dart';
AndroidDeviceInfo? myDeviceInfo;

final userName = PreferenceHelper.getString(PreferenceHelper.FULL_NAME);
final authToken = PreferenceHelper.getString(PreferenceHelper.AUTH_TOKEN);


Map<String, String> header = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'current-User' : userName ?? "",
  'time-zone' : DateTime.now().timeZoneOffset.inMinutes.toString()
  // 'token' : "Bariar ${}"
};
Map<String, String> headerWithToken = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'current-User' : userName ?? "",
  'time-zone' : DateTime.now().timeZoneOffset.inMinutes.toString(),
  'token' : "Bariar $authToken"
};

Future callPostMethod(String url, Map<String, dynamic> params) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  myDeviceInfo = await deviceInfo.androidInfo;

  // print("deviceId_DTAAAAAAAAAAAAA${myDeviceInfo?.id ?? ""}");
  // print("deviceversion${myDeviceInfo?.version.release ?? ""}");
  // print("devicemodel${myDeviceInfo?.model ?? ""}");

  if (kDebugMode) {
    print("baseUrl--$url");
    print("params--${jsonEncode(params)}");
    print("header----${header}");
  }
  return await http
      .post(
    Uri.parse(url),
    body: utf8.encode(json.encode(params)),
    headers: authToken != null ? headerWithToken : header,
  )
      .then((http.Response response) {
    return getResponse(response);
  });
}

Future callGetMethod(String url) async {
  if (kDebugMode) {
    print("baseUrl--$url");
  }
  var requestUrl = url;
  return await http
      .get(
    Uri.parse(requestUrl),
    headers: header,
  )
      .then((http.Response response) {
    return getResponse(response);
  });
}

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
  } else if (statusCode < 200 || statusCode > 404) {
    String error = response.headers['message'].toString();
    printWrapped("response--$error");
    return "{\"status\":\"0\",\"message\":\"$error\"}";
  }
  return response.body;
}
