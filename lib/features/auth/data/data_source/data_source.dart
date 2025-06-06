import 'package:dio/dio.dart';

import '../models/password_reset_model.dart';

abstract class AuthDataSource {
  Future<Response> login({required String username, required String password});
  Future<Response> register({
    required String username,
    required String password,
    required String email,
  });
  Future<PasswordResetModel> requestPasswordReset({required String username});
  Future<Response> resetPassword({
    required String code,
    required String username,
    required String newPassword,
  });
}
