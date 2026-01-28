import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/general/auth_models.dart';

/// Halaman Verifikasi Email
/// Memungkinkan pengguna memverifikasi email dengan token yang diterima setelah registrasi
class VerifikasiEmailPage extends StatefulWidget {
  final String? initialToken;
  final String? email;

  const VerifikasiEmailPage({
    super.key,
    this.initialToken,
    this.email,
  });

  @override
  State<VerifikasiEmailPage> createState() => _VerifikasiEmailPageState();
}

class _VerifikasiEmailPageState extends State<VerifikasiEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _verificationSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null) {
      _tokenController.text = widget.initialToken!;
      // Auto-verify jika token sudah ada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleVerifikasi();
      });
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _handleVerifikasi() async {
    if (_tokenController.text.isEmpty) {
      if (_formKey.currentState?.validate() != true) {
        return;
      }
    }

    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token verifikasi harus diisi'),
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
            Text('Memverifikasi email...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    // Call API
    final response = await AuthService.verifikasiEmail(
      VerifikasiEmailRequest(token: token),
    );

    if (mounted) {
      // Hide loading
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      setState(() {
        _isLoading = false;
      });

      if (response.sukses) {
        setState(() {
          _verificationSuccess = true;
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
          'Verifikasi Email',
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
          child: _verificationSuccess ? _buildSuccessView() : _buildFormView(),
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
              Icons.verified,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Success Title
        const Text(
          'Email Terverifikasi!',
          style: AppTheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'Selamat! Email Anda telah berhasil diverifikasi. Anda sekarang dapat login dan menggunakan semua fitur Publishify.',
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
              'Login Sekarang',
              style: AppTheme.buttonText,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Info Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.celebration,
                color: AppTheme.primaryGreen,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Akun Anda aktif!',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mulai jelajahi dunia penerbitan bersama Publishify',
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
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
              child: const Icon(
                Icons.mark_email_unread,
                size: 60,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          const Text(
            'Verifikasi Email Anda',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            widget.email != null
                ? 'Kami telah mengirimkan kode verifikasi ke ${widget.email}. Masukkan kode tersebut di bawah ini.'
                : 'Masukkan kode verifikasi yang dikirim ke email Anda saat registrasi.',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Token Field
          TextFormField(
            controller: _tokenController,
            decoration: AppTheme.inputDecoration(
              hintText: 'Kode Verifikasi',
              prefixIcon: const Icon(
                Icons.confirmation_number_outlined,
                color: AppTheme.greyMedium,
              ),
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kode verifikasi harus diisi';
              }
              return null;
            },
            enabled: !_isLoading,
          ),
          const SizedBox(height: 32),

          // Verify Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerifikasi,
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
                      'Verifikasi Email',
                      style: AppTheme.buttonText,
                    ),
            ),
          ),
          const SizedBox(height: 24),

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

          const SizedBox(height: 32),

          // Info Box
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
                      'Tidak menerima email?',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Cek folder spam/junk email Anda\n'
                  '• Pastikan email yang didaftarkan benar\n'
                  '• Tunggu beberapa menit dan coba lagi\n'
                  '• Hubungi support jika masih bermasalah',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
