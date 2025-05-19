import '../models/user_model.dart';
import 'mock/mock_user_data.dart';
// import '../../core/network/dio_client.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  // final DioClient _dioClient;

  UserRemoteDataSourceImpl(
    // this._dioClient
    );

  @override
  Future<List<UserModel>> getUsers() async {
    // TODO: Implement real API call when ready
    // try {
    //   final response = await _dioClient.dio.get('/users');
    //   final List<dynamic> data = response.data;
    //   return data.map((json) => UserModel.fromJson(json)).toList();
    // } on DioException catch (e) {
    //   throw Exception('Failed to fetch users: ${e.message}');
    // }

    // Using mock data for now
    await Future.delayed(const Duration(seconds: 1));
    return MockUserData.getMockUsers();
  }

  @override
  Future<UserModel> getUserById(int id) async {
    // TODO: Implement real API call when ready
    // try {
    //   final response = await _dioClient.dio.get('/users/$id');
    //   return UserModel.fromJson(response.data);
    // } on DioException catch (e) {
    //   throw Exception('Failed to fetch user: ${e.message}');
    // }

    // Using mock data for now
    await Future.delayed(const Duration(milliseconds: 500));
    final users = MockUserData.getMockUsers();
    final user = users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
    return user;
  }
} 