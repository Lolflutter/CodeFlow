class UserInfoModel {
  final String dateTime;
  final int statusCode;
  final String? username;
  final String? email;
  final String? errorMessage;

  UserInfoModel({
    required this.dateTime,
    required this.statusCode,
    this.username,
    this.email,
    this.errorMessage,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      dateTime: json['dateTime'],
      statusCode: json['statusCode'],
      username: json['username'],
      email: json['email'],
      errorMessage: json['errorMessage'],
    );
  }
}
