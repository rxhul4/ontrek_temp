import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  // static const String LOGIN_DATA = "LOGIN_DATA";
  // static const String IS_SIGN_IN = "IS_SIGN_IN";
  static const String AUTH_TOKEN = "AUTH_TOKEN";
  // static const String FCM_TOKEN = "FCM_TOKEN";

  // static const String DEVICE_ID = "DEVICE_ID";
  static const String IS_LOGIN = "isLogin";
  static const String USER_DATA = "userData";

  static const String FULL_NAME = "employeeName";
  static const String EMAIL = "email";
  static const String PHONE_NO = "phoneNo";
  static const String PROFILE_PIC = "profilePic";
  static const String ROLE_NAME = "roleName";

  static const String USER_UID = "userUid";
  static const String ROLE_ID = "roleId";

  static const String LocationPrefKey = "locationPrefKey";
  static const String DateAndTime = "dateAndTime";
  static const String DayStart = "dayStart";
  // static const String DayEnd = "dayEnd";
  static const String checkIn = "checkIn";
  // static const String checkOut = "checkOut";
  // static const String TASK_ID = "TaskId";
  static const String LAST_LAT = "LAST_LAT";
  static const String LAST_LONG = "LAST_LONG";
  static const String LAST_ADD_ROUTE_DATETIME = "LAST_ADD_ROUTE_DATETIME";
  static const String CHECK_END_TIME = "CHECK_END_TIME";
  static const String WAITING_LAST_TIME = "WAITING_LAST_TIME";



  static const String DAY_START_DAY_END_ID = "DAY_START_DAY_END_ID";
  static const String LAST_DAY_START_DATETIME = "LAST_DAY_START_DATETIME";

  static const String LAST_INTERNET_OFF_TIME = "LAST_INTERNET_OFF_TIME";
  static const String LAST_INTERNET_ON_TIME = "LAST_INTERNET_ON_TIME";
  static const String LAST_GPS_ON_TIME = "LAST_GPS_ON_TIME";
  static const String LAST_GPS_OFF_TIME = "LAST_GPS_OFF_TIME";

  static const String GPS_BOOL = "GPS_BOOL";
  static const String INTERNET_BOOL = "INTERNET_BOOL";

  static const String LAST_GPS_OFF_LAT = "LAST_GPS_OFF_LAT";
  static const String LAST_GPS_OFF_LONG = "LAST_GPS_OFF_LONG";

  static const String LAST_INTERNET_OFF_LAT = "LAST_INTERNET_OFF_LAT";
  static const String LAST_INTERNET_OFF_LONG = "LAST_INTERNET_OFF_LONG";


  static SharedPreferences? _prefs;
  static Map<String, dynamic> _memoryPrefs = Map<String, dynamic>();

  static Future<SharedPreferences?> load() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs;
  }

  static void setString(String key, String value) {
    _prefs?.setString(key, value);
    _memoryPrefs[key] = value;
  }

  static void remove(String? key) {
    if (key != null) {
      _prefs?.remove(key);
      _memoryPrefs[key] = null;
    }
  }

  static bool containsKey(String? key) {
    bool doesContain = false;
    if (key != null) {
      doesContain = _prefs?.containsKey(key) ?? false;
    }
    return doesContain;
  }

  static void setObject<T>(String key, dynamic value) {
    JsonEncoder encoder = const JsonEncoder();
    _prefs?.setString(key, encoder.convert(value));
    _memoryPrefs[key] = encoder.convert(value);
  }

  static void setInt(String key, int value) {
    _prefs?.setInt(key, value);
    _memoryPrefs[key] = value;
  }

  static void setDouble(String key, double value) {
    _prefs?.setDouble(key, value);
    _memoryPrefs[key] = value;
  }

  static void setBool(String key, bool value) {
    _prefs?.setBool(key, value);
    _memoryPrefs[key] = value;
  }

  static String? getString(String key, {String? def}) {
    String? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs?.getString(key);
    }
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val;
  }

  static int? getInt(String key, {int? def}) {
    int? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs?.getInt(key);
    }
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val;
  }

  static double? getDouble(String key, {double? def}) {
    double? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs?.getDouble(key);
    }
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val;
  }

  static bool getBool(String key, {bool def = false}) {
    bool? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs?.getBool(key);
    }
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val;
  }

  static dynamic getObject(String key) {
    String? val = getString(key, def: "");

    if (val != null) {
      JsonDecoder decoder = const JsonDecoder();
      return decoder.convert(val);
    }
    return "";
  }

  static void clear() {
    _memoryPrefs.clear();
    _prefs?.clear();
  }
  static Future<SharedPreferences?> reload() async{
    await _prefs?.reload();
  }
}
