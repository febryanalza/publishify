import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/pages/auth/register_page.dart';
import 'package:publishify/pages/auth/success_page.dart';
import 'package:publishify/services/writer/auth_service.dart';
import 'package:publishify/models/writer/auth_models.dart';
import 'package:publishify/controllers/role_navigation_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Validasi tambahan untuk mencegah pengiriman nilai null atau kosong
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email dan password tidak boleh kosong'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Logging in...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Call real API dengan nilai yang sudah divalidasi
      final response = await AuthService.login(
        LoginRequest(
          email: email,
          kataSandi: password,
        ),
      );

      if (mounted) {
        // Hide loading
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response.sukses) {
          // Use role-based navigation after successful login
          await RoleNavigationController.navigateAfterLogin(context, response);
          
          // Show welcome snackbar
          final userName = response.data?.pengguna.profilPengguna?.namaTampilan ?? 
                          '${response.data?.pengguna.profilPengguna?.namaDepan ?? ''} ${response.data?.pengguna.profilPengguna?.namaBelakang ?? ''}'.trim();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang kembali, $userName!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleGoogleLogin() async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Connecting to Google...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Dummy Google login
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigate to success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SuccessPage(
            message: 'Login dengan Google berhasil!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                
                // Create Account Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    style: AppTheme.primaryButtonStyle,
                    child: const Text(
                      'Create Publishify Account',
                      style: AppTheme.buttonText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Continue with Google Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _handleGoogleLogin,
                    style: AppTheme.googleButtonStyle,
                    icon: Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.g_mobiledata,
                          size: 24,
                          color: AppTheme.googleBlue,
                        );
                      },
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Divider with "or"
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.greyDisabled)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.greyDisabled)),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.greyMedium,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.greyMedium,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.greyMedium,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Forgot password coming soon'),
                        ),
                      );
                    },
                    child: Text(
                      'Lupa Password?',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: AppTheme.primaryButtonStyle,
                    child: const Text(
                      'Login',
                      style: AppTheme.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
