import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/datasources/user_remote_data_source.dart';
import '../../../data/datasources/user_local_data_source.dart';
import '../../../core/network/dio_client.dart';

final userViewModelProvider = StateNotifierProvider<UserViewModel, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserViewModel(repository);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepository(remoteDataSource, localDataSource);
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  // final dioClient = ref.watch(dioClientProvider);
  return UserRemoteDataSourceImpl(
    // dioClient
    );
});

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserLocalDataSourceImpl(prefs);
});

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main.dart');
});

class UserViewModel extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;

  UserViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.getUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
} 