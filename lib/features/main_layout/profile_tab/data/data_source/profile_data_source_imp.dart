import 'package:graduation_project/features/main_layout/profile_tab/data/data_source/profile_data_source.dart';

import '../../../../../core/services/network_services.dart';
import '../models/user_info.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final NetworkServices networkServices;

  UserRemoteDataSourceImpl(this.networkServices);

  @override
  Future<UserInfoModel> getUserInfo() async {
    final response = await networkServices.dio.get(
      'user/info',
      data: {},
    );
    return UserInfoModel.fromJson(response.data);
  }

  @override
  Future<UserInfoModel> updateUserInfo({
    String? newUsername,
    String? newEmail,
  }) async {
    final requestData = {
      "newUsername": newUsername,
      "newEmail": newEmail,
    };
    final response = await networkServices.dio.post(
      'user/update',
      data: requestData,
    );
    return UserInfoModel.fromJson(response.data);
  }
}
