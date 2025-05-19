import 'dart:convert';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUsers(List<UserModel> users);
  Future<List<UserModel>> getCachedUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences _prefs;
  static const String CACHED_USERS_KEY = 'CACHED_USERS';

  UserLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    final usersJson = users.map((user) => user.toJson()).toList();
    await _prefs.setString(CACHED_USERS_KEY, json.encode(usersJson));
  }

  @override
  Future<List<UserModel>> getCachedUsers() async {
    final jsonString = _prefs.getString(CACHED_USERS_KEY);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => UserModel.fromJson(json)).toList();
  }
} 