import '../datasources/user_remote_data_source.dart';
import '../datasources/user_local_data_source.dart';
import '../models/user_model.dart';

class UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;

  UserRepository(this._remoteDataSource, this._localDataSource);

  Future<List<UserModel>> getUsers() async {
    try {
      final users = await _remoteDataSource.getUsers();
      await _localDataSource.cacheUsers(users);
      return users;
    } catch (e) {
      // If remote fails, try to get cached data
      final cachedUsers = await _localDataSource.getCachedUsers();
      if (cachedUsers.isNotEmpty) {
        return cachedUsers;
      }
      throw Exception('No users available');
    }
  }

  Future<UserModel> getUserById(int id) async {
    try {
      return await _remoteDataSource.getUserById(id);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
} 