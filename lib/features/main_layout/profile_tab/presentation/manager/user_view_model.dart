import 'package:flutter/material.dart';
import '../../data/data_source/profile_data_source.dart';
import '../../data/models/user_info.dart';

class UserViewModel extends ChangeNotifier {
  final UserRemoteDataSource userRemoteDataSource;

  UserViewModel({required this.userRemoteDataSource});

  UserInfoModel? userInfo;
  bool isLoading = false;
  String? errorMessage;
  bool hasChanges = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> fetchUserInfo() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await userRemoteDataSource.getUserInfo();
      userInfo = result;

      usernameController.text = result.username ?? '';
      emailController.text = result.email ?? '';

      _setupListeners();
    } catch (e) {
      errorMessage = 'Failed to load user info';
    }

    isLoading = false;
    notifyListeners();
  }

  void _setupListeners() {
    usernameController.addListener(_onTextChanged);
    emailController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final currentUsername = usernameController.text;
    final currentEmail = emailController.text;
    if (currentUsername != (userInfo?.username ?? '') ||
        currentEmail != (userInfo?.email ?? '')) {
      hasChanges = true;
    } else {
      hasChanges = false;
    }
    notifyListeners();
  }

  Future<void> updateUserInfo({
    String? newUsername,
    String? newEmail,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await userRemoteDataSource.updateUserInfo(
        newUsername: newUsername,
        newEmail: newEmail,
      );
      userInfo = result;
      hasChanges = false;
    } catch (e) {
      errorMessage = 'Failed to update user info';
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
