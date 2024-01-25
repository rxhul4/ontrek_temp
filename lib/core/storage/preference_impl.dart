
import 'package:ontrek/core/storage/i_preference.dart';
import 'package:ontrek/core/storage/preference.dart';
import 'package:ontrek/core/storage/preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceImpl implements IPreference {
  @override
  Future<String> getToken() async {
    final SharedPreferences prefs = await Preference.getSharedPreference();
    return prefs.getString(PreferenceKey.token) ?? '';
  }

  @override
  Future<void> setToken(String token) async {
    final SharedPreferences prefs = await Preference.getSharedPreference();
    prefs.setString(PreferenceKey.token, token);
  }

  @override
  Future<String> getUserId() async {
    final SharedPreferences prefs = await Preference.getSharedPreference();
    return prefs.getString(PreferenceKey.userId) ?? '';
  }

  @override
  Future<void> setUserId(String userId) async {
    final SharedPreferences prefs = await Preference.getSharedPreference();
    prefs.setString(PreferenceKey.userId, userId);
  }

  @override
  Future<void> clearPreference() async {
    final SharedPreferences prefs = await Preference.getSharedPreference();
    prefs.clear();
  }
}
