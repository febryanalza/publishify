// Application Constants

class AppConstants {
  // App Information
  static const String appName = 'Publishify';
  static const String appTagline = 'Connect Writers & Editors';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String roleWriter = 'writer';
  static const String roleEditor = 'editor';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';

  // API Endpoints (dummy for now)
  static const String baseUrl = 'https://api.publishify.com';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String googleAuthEndpoint = '/auth/google';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // Validation
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;

  // Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String loginErrorMessage = 'Invalid username or password';
  static const String registerSuccessMessage = 'Registration successful!';
  static const String registerErrorMessage = 'Registration failed. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your connection.';
}
