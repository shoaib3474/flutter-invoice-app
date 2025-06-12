import '../storage/local_storage_service.dart';
import '../../models/user/user_model.dart';

class UserService {
  static const String _userKey = 'current_user';

  Future<User?> getCurrentUser() async {
    final userData = LocalStorageService.getJson(_userKey);
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    LocalStorageService.setJson(_userKey, user.toJson());
  }

  Future<void> clearUser() async {
    LocalStorageService.removeItem(_userKey);
  }

  Future<User> createUser({
    required String name,
    required String email,
    String? phone,
  }) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await saveUser(user);
    return user;
  }

  Future<User?> updateUser({
    String? name,
    String? email,
    String? phone,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    final updatedUser = currentUser.copyWith(
      name: name,
      email: email,
      phone: phone,
      updatedAt: DateTime.now(),
    );

    await saveUser(updatedUser);
    return updatedUser;
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}
