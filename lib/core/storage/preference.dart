import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  static Future<SharedPreferences> getSharedPreference() async {
    return await SharedPreferences.getInstance();
  }
}
