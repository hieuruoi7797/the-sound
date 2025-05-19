import '../../models/user_model.dart';

class MockUserData {
  static List<UserModel> getMockUsers() {
    return [
      UserModel(
        id: 1,
        name: 'John Doe',
        email: 'john.doe@example.com',
      ),
      UserModel(
        id: 2,
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
      ),
      UserModel(
        id: 3,
        name: 'Robert Johnson',
        email: 'robert.j@example.com',
      ),
      UserModel(
        id: 4,
        name: 'Emily Brown',
        email: 'emily.b@example.com',
      ),
      UserModel(
        id: 5,
        name: 'Michael Wilson',
        email: 'michael.w@example.com',
      ),
    ];
  }
} 