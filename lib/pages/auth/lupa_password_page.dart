import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/general/auth_models.dart';
import 'package:publishify/pages/auth/reset_password_page.dart';

/// Halaman Lupa Password
/// Memungkinkan pengguna meminta link reset password via email
class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleLupaPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email tidak boleh kosong'),
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
              Text('Mengirim permintaan reset password...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Call API
      final response = await AuthService.lupaPassword(
        LupaPasswordRequest(email: email),
      );

      if (mounted) {
        // Hide loading
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        setState(() {
          _isLoading = false;
        });

        if (response.sukses) {
          setState(() {
            _emailSent = true;
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

  void _navigateToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResetPasswordPage(),
      ),
    );
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
          'Lupa Password',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Icon Section
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                      size: 60,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  _emailSent ? 'Email Terkirim!' : 'Lupa Password?',
                  style: AppTheme.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  _emailSent
                      ? 'Kami telah mengirimkan link reset password ke email Anda. Silakan cek inbox atau folder spam Anda.'
                      : 'Masukkan email yang terdaftar. Kami akan mengirimkan link untuk mereset password Anda.',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                if (!_emailSent) ...[
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
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLupaPassword,
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
                              'Kirim Link Reset',
                              style: AppTheme.buttonText,
                            ),
                    ),
                  ),
                ] else ...[
                  // Success State - Show options

                  // Kirim Ulang Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _emailSent = false;
                              });
                            },
                      style: AppTheme.secondaryButtonStyle,
                      child: const Text(
                        'Kirim Ulang Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sudah Punya Token Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _navigateToResetPassword,
                      style: AppTheme.primaryButtonStyle,
                      child: const Text(
                        'Masukkan Kode Reset',
                        style: AppTheme.buttonText,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Kembali ke Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Kembali ke Login',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Info tambahan jika email sudah dikirim
                if (_emailSent) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Cek folder spam/junk jika email tidak masuk inbox\n'
                          '• Link reset password berlaku selama 1 jam\n'
                          '• Hubungi support jika masih mengalami masalah',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
