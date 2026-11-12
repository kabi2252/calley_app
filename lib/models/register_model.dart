class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String mobile;
  final String countryCode;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
    this.countryCode = '+91',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'mobile': mobile,
      'countryCode': countryCode,
    };
  }
}

class RegisterResponse {
  final bool success;
  final String message;
  final String? token;
  final String? otpSessionId;

  RegisterResponse({
    required this.success,
    required this.message,
    this.token,
    this.otpSessionId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Registration successful',
      token: json['token'],
      otpSessionId: json['otpSessionId'] ?? json['sessionId'],
    );
  }
}
