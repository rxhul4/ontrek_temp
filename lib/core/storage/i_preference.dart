abstract class IPreference {
  Future<void> setToken(String token);

  Future<String> getToken();

  Future<void> setUserId(String userId);

  Future<String> getUserId();

  Future<void> clearPreference();
}
