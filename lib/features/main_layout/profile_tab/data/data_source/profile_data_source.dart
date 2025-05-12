
import '../models/user_info.dart';

abstract class UserRemoteDataSource {
  Future<UserInfoModel> getUserInfo();

  Future<UserInfoModel> updateUserInfo({
    String? newUsername,
    String? newEmail,
  });
}
