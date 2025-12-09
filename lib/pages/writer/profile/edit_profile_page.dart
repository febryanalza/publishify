import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/writer/profile_service.dart';
import 'package:publishify/models/writer/update_profile_models.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Form controllers
  final _namaDepanController = TextEditingController();
  final _namaBelakangController = TextEditingController();
  final _namaTampilanController = TextEditingController();
  final _bioController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kotaController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kodePosController = TextEditingController();

  String? _jenisKelamin;
  DateTime? _selectedDate;
  
  // Map to store backend validation errors
  final Map<String, String> _backendErrors = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  // Helper method to check backend validation error
  String? _getBackendError(String fieldName) {
    return _backendErrors[fieldName];
  }

  // Helper method to validate with backend error
  String? _validateWithBackend(
    String fieldName,
    String? Function(String?)? frontendValidator,
    String? value,
  ) {
    // Check frontend validation first
    final frontendError = frontendValidator?.call(value);
    if (frontendError != null) {
      return frontendError;
    }
    
    // Then check backend validation error
    return _getBackendError(fieldName);
  }

  @override
  void dispose() {
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    _namaTampilanController.dispose();
    _bioController.dispose();
    _tanggalLahirController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Load profile from API (has complete data including telepon)
      final profileResponse = await ProfileService.getProfile();

      if (profileResponse.sukses && profileResponse.data != null) {
        final profil = profileResponse.data!.profilPengguna;
        final pengguna = profileResponse.data!;

        setState(() {
          if (profil != null) {
            _namaDepanController.text = profil.namaDepan ?? '';
            _namaBelakangController.text = profil.namaBelakang ?? '';
            _namaTampilanController.text = profil.namaTampilan ?? '';
            _bioController.text = profil.bio ?? '';
            _alamatController.text = profil.alamat ?? '';
            _kotaController.text = profil.kota ?? '';
            _provinsiController.text = profil.provinsi ?? '';
            _kodePosController.text = profil.kodePos ?? '';
            
            // Fixed: Validate jenisKelamin value before assigning
            // Only accept 'L', 'P', or null (not empty string or other values)
            if (profil.jenisKelamin == 'L' || profil.jenisKelamin == 'P') {
              _jenisKelamin = profil.jenisKelamin;
            } else {
              _jenisKelamin = null; // Set to null if invalid value
            }

            if (profil.tanggalLahir != null) {
              try {
                _selectedDate = DateTime.parse(profil.tanggalLahir!);
                _tanggalLahirController.text =
                    '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
              } catch (e) {
                _tanggalLahirController.text = '';
              }
            }
          }

          // Load telepon from user data
          _teleponController.text = pengguna.telepon ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data profil: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format untuk display (DD/MM/YYYY)
        _tanggalLahirController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request data
      final request = UpdateProfileRequest(
        namaDepan: _namaDepanController.text.trim(),
        namaBelakang: _namaBelakangController.text.trim(),
        namaTampilan: _namaTampilanController.text.trim(),
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        tanggalLahir: _selectedDate?.toIso8601String(),
        jenisKelamin: _jenisKelamin,
        alamat: _alamatController.text.trim().isEmpty 
            ? null 
            : _alamatController.text.trim(),
        kota: _kotaController.text.trim().isEmpty 
            ? null 
            : _kotaController.text.trim(),
        provinsi: _provinsiController.text.trim().isEmpty 
            ? null 
            : _provinsiController.text.trim(),
        kodePos: _kodePosController.text.trim().isEmpty 
            ? null 
            : _kodePosController.text.trim(),
        telepon: _teleponController.text.trim().isEmpty 
            ? null 
            : _teleponController.text.trim(),
      );

      // Call API
      final response = await ProfileService.updateProfile(request);

      if (mounted) {
        if (response.sukses) {
          // Clear any previous backend errors
          setState(() {
            _backendErrors.clear();
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(response.pesan)),
                ],
              ),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Go back and trigger refresh
          Navigator.pop(context, true);
        } else {
          // Handle validation errors from backend
          if (response.errors != null && response.errors!.isNotEmpty) {
            setState(() {
              // Clear previous errors
              _backendErrors.clear();
              
              // Map backend errors to field names
              for (var error in response.errors!) {
                _backendErrors[error.field] = error.message;
              }
            });

            // Trigger form validation to show backend errors
            _formKey.currentState!.validate();

            // Show summary error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            response.pesan,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...response.errors!.take(3).map((error) => Padding(
                          padding: const EdgeInsets.only(left: 36, top: 4),
                          child: Text(
                            '• ${error.message}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        )),
                    if (response.errors!.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(left: 36, top: 4),
                        child: Text(
                          '• dan ${response.errors!.length - 3} error lainnya',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                backgroundColor: AppTheme.errorRed,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else {
            // Show generic error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(response.pesan)),
                  ],
                ),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _handleSubmit,
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informasi Dasar Section
                      _buildSectionTitle('Informasi Dasar'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _namaDepanController,
                        label: 'Nama Depan',
                        hint: 'Masukkan nama depan',
                        icon: Icons.person_outline,
                        validator: (value) {
                          return _validateWithBackend('namaDepan', (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama depan wajib diisi';
                            }
                            if (val.trim().length < 2) {
                              return 'Nama depan minimal 2 karakter';
                            }
                            if (val.trim().length > 50) {
                              return 'Nama depan maksimal 50 karakter';
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _namaBelakangController,
                        label: 'Nama Belakang',
                        hint: 'Masukkan nama belakang',
                        icon: Icons.person_outline,
                        validator: (value) {
                          return _validateWithBackend('namaBelakang', (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama belakang wajib diisi';
                            }
                            if (val.trim().length > 50) {
                              return 'Nama belakang maksimal 50 karakter';
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _namaTampilanController,
                        label: 'Nama Tampilan',
                        hint: 'Nama yang akan ditampilkan',
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          return _validateWithBackend('namaTampilan', (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama tampilan wajib diisi';
                            }
                            if (val.trim().length > 100) {
                              return 'Nama tampilan maksimal 100 karakter';
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _bioController,
                        label: 'Biografi Singkat',
                        hint: 'Ceritakan sedikit tentang diri Anda',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        maxLength: 500,
                        validator: (value) {
                          return _validateWithBackend('bio', (val) {
                            if (val != null && val.trim().length > 500) {
                              return 'Biografi maksimal 500 karakter';
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Informasi Personal Section
                      _buildSectionTitle('Informasi Personal'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _tanggalLahirController,
                        label: 'Tanggal Lahir',
                        hint: 'Pilih tanggal lahir',
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),

                      const SizedBox(height: 16),

                      _buildGenderDropdown(),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _teleponController,
                        label: 'Nomor Telepon',
                        hint: 'Contoh: 081234567890 atau +6281234567890',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          return _validateWithBackend('telepon', (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              // Remove spaces and dashes
                              final phone = val.trim().replaceAll(RegExp(r'[\s-]'), '');
                              
                              // Regex for Indonesian phone number
                              // Accepts: +62xxx, 62xxx, 0xxx with 9-12 digits after prefix
                              final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
                              
                              if (!phoneRegex.hasMatch(phone)) {
                                return 'Format nomor telepon tidak valid';
                              }
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Alamat Section
                      _buildSectionTitle('Alamat'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _alamatController,
                        label: 'Alamat Lengkap',
                        hint: 'Jl. Contoh No. 123 (maks 200 karakter)',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                        validator: (value) {
                          return _validateWithBackend('alamat', (val) {
                            if (val != null && val.trim().length > 200) {
                              return 'Alamat maksimal 200 karakter';
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _kotaController,
                        label: 'Kota',
                        hint: 'Contoh: Jakarta Selatan',
                        icon: Icons.location_city_outlined,
                        validator: (value) {
                          return _validateWithBackend('kota', (val) {
                            if (val != null && val.trim().length > 100) {
                              return 'Kota maksimal 100 karakter';
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _provinsiController,
                        label: 'Provinsi',
                        hint: 'Contoh: DKI Jakarta',
                        icon: Icons.map_outlined,
                        validator: (value) {
                          return _validateWithBackend('provinsi', (val) {
                            if (val != null && val.trim().length > 100) {
                              return 'Provinsi maksimal 100 karakter';
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _kodePosController,
                        label: 'Kode Pos',
                        hint: 'Contoh: 12345 (5 digit)',
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return _validateWithBackend('kodePos', (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final kodePos = val.trim();
                              
                              // Must be exactly 5 digits
                              if (!RegExp(r'^[0-9]{5}$').hasMatch(kodePos)) {
                                return 'Kode pos harus 5 digit angka';
                              }
                            }
                            return null;
                          }, value);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headingSmall.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppTheme.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
            ),
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterStyle: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _jenisKelamin, // Will be null, 'L', or 'P'
          decoration: InputDecoration(
            hintText: 'Pilih jenis kelamin',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
            ),
            prefixIcon: const Icon(Icons.wc_outlined, color: AppTheme.primaryGreen),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
          ],
          onChanged: (value) {
            setState(() {
              _jenisKelamin = value;
            });
          },
          validator: (value) {
            // Optional field - no validation needed
            // Backend accepts: 'L', 'P', or null
            return null;
          },
        ),
      ],
    );
  }
}
