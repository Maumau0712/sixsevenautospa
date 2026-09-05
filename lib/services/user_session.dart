import '../models/user_model.dart';

class UserSession {
  static UserModel? currentUser;

  static void login(
      UserModel user,
      ) {
    currentUser = user;
  }

  static void logout() {
    currentUser = null;
  }
}