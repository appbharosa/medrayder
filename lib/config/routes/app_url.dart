class AppUrl {

  // production url  https://app.medrayder.in/api/

 // static const String baseUrl = "https://app.medrayder.in/api/";


   static const String baseUrl = "https://app.medconnect.org.in/api/";
  static const String imageBaseUrl = "https://medconnect.org.in/bharosa/";

  /// login

  static const String login = "auth/login";
  static const String otpVerify ="auth/otp-verification";
  static const String getProfile ="partner/profile";
  static const String updateProfile = "partner/update-profile";
  static const String bankDetails = "partner/bank-details";
  static const String addBankDetails = "partner/bank-details";
  static const String getAgents = "partner/agents";
  static const String postAgents = "partner/agents";
  static const String getUsers = "partner/users";
  static const String getBloodGroups = "partner/get-blood-groups";
  static const String getCategories = "partner/get-coverage-categories";
  static const String homeData ="partner/dashboard";
  static const String contactUs = "partner/submit-contact-us";
  static const String about = "partner/get-pages/about_us";
  static const String terms = "partner/get-pages/terms";
  static const String privacy = "partner/get-pages/privacy";
  static const String subscription ="partner/subscriptions-list";
  static const String tutorials ="partner/get-tutorials";
  static const String notification ="partner/read-notification";
  static const String getWallet ="partner/wallet/history";
  static const String walletWithDraw ="partner/wallet/debit";
  static const String updateApi = "version-control?version";
  static const String sendUserOtp ="partner/send-otp";
  static const String userOtpVerify ="partner/verify-otp";

}