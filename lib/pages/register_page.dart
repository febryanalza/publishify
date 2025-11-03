import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/pages/success_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ttlController = TextEditingController();
  final _jenisKelController = TextEditingController();
  final _penulisController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  // Dropdown options
  String? _selectedJenisKel;
  final List<String> _jenisKelOptions = ['Laki-laki', 'Perempuan'];
  
  String? _selectedPenulis;
  final List<String> _penulisOptions = ['Novel', 'Cerpen', 'Puisi', 'Esai', 'Artikel', 'Lainnya'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _ttlController.dispose();
    _jenisKelController.dispose();
    _penulisController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
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
              Text('Creating account...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Dummy registration - simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(
              userName: _fullNameController.text,
              message: 'Akun Writer berhasil dibuat!',
            ),
          ),
        );
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
                
                // Nama Field
                TextFormField(
                  controller: _fullNameController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Nama',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // TTL Field
                TextFormField(
                  controller: _ttlController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'TTL',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tempat tanggal lahir harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Jenis Kelamin Dropdown
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Jenis Kel',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _jenisKelOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJenisKel = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis kelamin harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Penulis Dropdown
                DropdownButtonFormField<String>(
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Penulis',
                  ).copyWith(
                    prefixIcon: null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _penulisOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPenulis = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis penulis harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Section Title "Masukkan"
                Center(
                  child: Text(
                    'Masukkan',
                    style: AppTheme.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Username',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppTheme.greyMedium,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username harus diisi';
                    }
                    if (value.length < 3) {
                      return 'Username minimal 3 karakter';
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
