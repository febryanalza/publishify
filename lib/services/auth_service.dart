// Dummy Authentication Service
// Untuk development purpose only

class AuthService {
  // Dummy user data storage
  static final Map<String, Map<String, dynamic>> _dummyUsers = {
    'admin': {
      'username': 'admin',
      'password': 'admin123',
      'name': 'Admin User',
      'role': 'writer',
    },
    'writer1': {
      'username': 'writer1',
      'password': 'password123',
      'name': 'John Doe',
      'role': 'writer',
    },
  };

  // Dummy login function
  static Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user exists
    if (_dummyUsers.containsKey(username)) {
      final user = _dummyUsers[username]!;
      if (user['password'] == password) {
        return {
          'success': true,
          'user': {
            'username': user['username'],
            'name': user['name'],
            'role': user['role'],
          },
          'token': 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
        };
      }
    }

    return {
      'success': false,
      'message': 'Username atau password salah',
    };
  }

  // Dummy register function
  static Future<Map<String, dynamic>> register({
    required String name,
    required String ttl,
    required String jenisKelamin,
    required String jenisPenulis,
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if username already exists
    if (_dummyUsers.containsKey(username)) {
      return {
        'success': false,
        'message': 'Username sudah digunakan',
      };
    }

    // Add new user to dummy storage
    _dummyUsers[username] = {
      'username': username,
      'password': password,
      'name': name,
      'ttl': ttl,
      'jenisKelamin': jenisKelamin,
      'jenisPenulis': jenisPenulis,
      'role': 'writer',
    };

    return {
      'success': true,
      'message': 'Registrasi berhasil',
      'user': {
        'username': username,
        'name': name,
        'role': 'writer',
      },
    };
  }

  // Dummy Google Sign-In function
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    return {
      'success': true,
      'user': {
        'username': 'google_user',
        'name': 'Google User',
        'email': 'user@gmail.com',
        'role': 'writer',
      },
      'token': 'dummy_google_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Dummy logout function
  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Clear any stored data
  }

  // Check if user is logged in (dummy)
  static Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return false; // Always return false for now
  }
}
