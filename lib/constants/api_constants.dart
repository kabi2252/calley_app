class ApiConstants {
  static const String baseUrl = 'https://mock-api.calleyacd.com/api';

  // Auth endpoints
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String sendOtpEndpoint = '$baseUrl/auth/send-otp';
  static const String verifyOtpEndpoint = '$baseUrl/auth/verify-otp';

  // List endpoints
  static const String defaultUserId = '68626f9497757cb741f449b0';
  static const String defaultListId = '68626fb697757cb741f449b9';
  static const String listEndpoint = '$baseUrl/list?userId=$defaultUserId';
  static const String listDetailEndpoint = '$baseUrl/list/$defaultListId';

  // Calley External links & Media
  static const String calleyWebPanelUrl = 'https://app.getcalley.com';
  static const String youtubeVideoId = 'bP4U-L4EHcg';
  static const String youtubeVideoUrl =
      'https://youtu.be/bP4U-L4EHcg?si=sxbwLJOFWSIdiXvN';
}
