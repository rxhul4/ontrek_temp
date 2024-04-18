import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {

  static const String IS_LOGIN = "isLogin";
  static const String ORG_ID = "orgId";
  static const String ORG_NAME = "orgName";

  static const String USER_NAME = "userName";
  static const String COUNTRY_CODE = "countryCode";
  static const String USER_ID = "userId";
  static const String EMAIL = "email";
  static const String PHONE_NO = "phoneNo";
  static const String PROFILE_PIC = "profilePic";
  static const String ROLE_NAME = "roleName";
  static const String ROLE_ID = "roleId";
  static const String REPORTING_MANAGER = "MANAGER";
  static const String DayStart = "dayStart";
  static const String checkIn = "checkIn";
  static const String isWaiting = 'is_waiting';
  static const String LAST_LAT = "LAST_LAT";
  static const String LAST_LONG = "LAST_LONG";
  static const String WAITING_START_TIME = "WAITING_START_TIME";
  static const String UNIVERSAL_LAST_SAVED_TIME = "UNIVERSAL_LAST_SAVED_TIME";



  static const String LAST_INTERNET_OFF_TIME = "LAST_INTERNET_OFF_TIME";
  static const String LAST_INTERNET_ON_TIME = "LAST_INTERNET_ON_TIME";


  static const String LAST_GPS_ON_TIME = "LAST_GPS_ON_TIME";
  static const String LAST_GPS_OFF_TIME = "LAST_GPS_OFF_TIME";
  static const String LAST_GPS_OFF_LAT = "LAST_GPS_OFF_LAT";
  static const String LAST_GPS_OFF_LONG = "LAST_GPS_OFF_LONG";

  static const String GPS_BOOL = "GPS_BOOL";
  static const String INTERNET_BOOL = "INTERNET_BOOL";
  static const String LAST_INTERNET_OFF_LAT = "LAST_INTERNET_OFF_LAT";
  static const String LAST_INTERNET_OFF_LONG = "LAST_INTERNET_OFF_LONG";


  static const String LOCATION_RESTRICTION = "allowLocationRestriction";
  static const String LOCATION_RESTRICTION_LAT = "LOCATION_RESTRICTION_LAT";
  static const String LOCATION_RESTRICTION_LONG = "LOCATION_RESTRICTION_LONG";
  static const String AllowCheckInCheckOut = "AllowCheckInCheckOut";

  static const String LIVE_LOCATION_TRACKING = "LIVE_LOCATION_TRACKING";
  static const String LIVE_LOCATION_INTERVAL = "LIVE_LOCATION_INTERVAL";
  static const String RESTRICTED_LOCATION_METER = "RESTRICTED_LOCATION_METER";


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
    return _prefs;
  }
}
