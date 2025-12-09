import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/pages/auth/success_page.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/general/auth_models.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaDepanController = TextEditingController();
  final _namaBelakangController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Dropdown options
  String? _selectedJenisPeran;
  final List<Map<String, String>> _jenisPeranOptions = [
    {'value': 'penulis', 'label': 'Penulis'},
    {'value': 'editor', 'label': 'Editor'},
    {'value': 'percetakan', 'label': 'Percetakan'},
  ];

  @override
  void dispose() {
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Validate password match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password dan konfirmasi password tidak cocok!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate role selection
      if (_selectedJenisPeran == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih jenis peran terlebih dahulu!'),
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
              Text('Membuat akun...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Call real API
      final response = await AuthService.register(
        RegisterRequest(
          email: _emailController.text,
          kataSandi: _passwordController.text,
          konfirmasiKataSandi: _confirmPasswordController.text,
          namaDepan: _namaDepanController.text,
          namaBelakang: _namaBelakangController.text,
          telepon: _teleponController.text,
          jenisPeran: _selectedJenisPeran!,
        ),
      );

      if (mounted) {
        // Hide loading
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response.sukses) {
          // Navigate to success page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessPage(
                userName: '${_namaDepanController.text} ${_namaBelakangController.text}',
                message: 'Akun berhasil dibuat! Silakan cek email Anda untuk verifikasi.',
              ),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Publishify Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Icon Profile
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Nama Depan Field
                TextFormField(
                  controller: _namaDepanController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Nama Depan',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama depan harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Nama Belakang Field
                TextFormField(
                  controller: _namaBelakangController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Nama Belakang',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama belakang harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Telepon Field
                TextFormField(
                  controller: _teleponController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Nomor Telepon',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Jenis Peran Dropdown
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Pilih Peran',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  initialValue: _selectedJenisPeran,
                  items: _jenisPeranOptions.map((Map<String, String> option) {
                    return DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(option['label']!),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJenisPeran = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis peran harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Section Title "Masukkan"
                Center(
                  child: Text(
                    'Akun Login',
                    style: AppTheme.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
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
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Konfirmasi Password',
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
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Create Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: AppTheme.primaryButtonStyle,
                    child: const Text(
                      'Create',
                      style: AppTheme.buttonText,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
