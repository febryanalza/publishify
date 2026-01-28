import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/general/auth_models.dart';

/// Halaman Reset Password
/// Memungkinkan pengguna mereset password dengan token yang diterima via email
class ResetPasswordPage extends StatefulWidget {
  final String? initialToken;

  const ResetPasswordPage({
    super.key,
    this.initialToken,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _resetSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null) {
      _tokenController.text = widget.initialToken!;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validasi password sesuai dengan requirement backend:
  /// - Minimal 8 karakter
  /// - Harus mengandung huruf besar
  /// - Harus mengandung huruf kecil
  /// - Harus mengandung angka
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password baru harus diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf besar';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password harus mengandung huruf kecil';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final token = _tokenController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token reset password harus diisi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validasi konfirmasi password
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi password tidak cocok'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

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
              Text('Mereset password...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Call API
      final response = await AuthService.resetPassword(
        ResetPasswordRequest(
          token: token,
          kataSandiBaru: password,
          konfirmasiKataSandiBaru: confirmPassword,
        ),
      );

      if (mounted) {
        // Hide loading
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        setState(() {
          _isLoading = false;
        });

        if (response.sukses) {
          setState(() {
            _resetSuccess = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
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

  void _navigateToLogin() {
    // Pop semua halaman auth dan kembali ke login
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _resetSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),

        // Success Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Success Title
        const Text(
          'Password Berhasil Direset!',
          style: AppTheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'Password Anda telah berhasil diubah. Silakan login dengan password baru Anda.',
          style: AppTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Login Button
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _navigateToLogin,
            style: AppTheme.primaryButtonStyle,
            child: const Text(
              'Kembali ke Login',
              style: AppTheme.buttonText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Icon Section
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.vpn_key,
                size: 50,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Buat Password Baru',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'Masukkan kode reset yang dikirim ke email Anda dan buat password baru.',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Token Field
          TextFormField(
            controller: _tokenController,
            decoration: AppTheme.inputDecoration(
              hintText: 'Kode Reset Password',
              prefixIcon: const Icon(
                Icons.confirmation_number_outlined,
                color: AppTheme.greyMedium,
              ),
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kode reset harus diisi';
              }
              return null;
            },
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: AppTheme.inputDecoration(
              hintText: 'Password Baru',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppTheme.greyMedium,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.greyMedium,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: _validatePassword,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: AppTheme.inputDecoration(
              hintText: 'Konfirmasi Password Baru',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppTheme.greyMedium,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppTheme.greyMedium,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password harus diisi';
              }
              if (value != _passwordController.text) {
                return 'Konfirmasi password tidak cocok';
              }
              return null;
            },
            enabled: !_isLoading,
          ),
          const SizedBox(height: 24),

          // Password Requirements Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.greyDisabled,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryDark,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Syarat Password:',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRequirementItem('Minimal 8 karakter'),
                _buildRequirementItem('Mengandung huruf besar (A-Z)'),
                _buildRequirementItem('Mengandung huruf kecil (a-z)'),
                _buildRequirementItem('Mengandung angka (0-9)'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: _isLoading
                  ? AppTheme.primaryButtonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        AppTheme.greyDisabled,
                      ),
                    )
                  : AppTheme.primaryButtonStyle,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : const Text(
                      'Reset Password',
                      style: AppTheme.buttonText,
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Kembali ke Login
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kembali',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 14,
            color: AppTheme.greyMedium,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
