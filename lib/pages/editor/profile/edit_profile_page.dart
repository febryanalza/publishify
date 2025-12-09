import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/editor/profile_service.dart';
import 'package:publishify/models/writer/update_profile_models.dart';

class EditorEditProfilePage extends StatefulWidget {
  const EditorEditProfilePage({super.key});

  @override
  State<EditorEditProfilePage> createState() => _EditorEditProfilePageState();
}

class _EditorEditProfilePageState extends State<EditorEditProfilePage> {
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
      final profileResponse = await EditorProfileService.getProfile();

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
            if (profil.jenisKelamin == 'L' || profil.jenisKelamin == 'P') {
              _jenisKelamin = profil.jenisKelamin;
            } else {
              _jenisKelamin = null;
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
      final response = await EditorProfileService.updateProfile(request);

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
              _backendErrors.clear();
              for (var error in response.errors!) {
                _backendErrors[error.field] = error.message;
              }
            });

            _formKey.currentState!.validate();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.pesan),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.pesan),
                backgroundColor: AppTheme.errorRed,
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
                      // Nama Depan
                      TextFormField(
                        controller: _namaDepanController,
                        decoration: InputDecoration(
                          labelText: 'Nama Depan *',
                          hintText: 'Masukkan nama depan',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => _validateWithBackend(
                          'namaDepan',
                          (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama depan harus diisi';
                            }
                            return null;
                          },
                          value,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nama Belakang
                      TextFormField(
                        controller: _namaBelakangController,
                        decoration: InputDecoration(
                          labelText: 'Nama Belakang *',
                          hintText: 'Masukkan nama belakang',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => _validateWithBackend(
                          'namaBelakang',
                          (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama belakang harus diisi';
                            }
                            return null;
                          },
                          value,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nama Tampilan
                      TextFormField(
                        controller: _namaTampilanController,
                        decoration: InputDecoration(
                          labelText: 'Nama Tampilan *',
                          hintText: 'Nama yang akan ditampilkan',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => _validateWithBackend(
                          'namaTampilan',
                          (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama tampilan harus diisi';
                            }
                            return null;
                          },
                          value,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          hintText: 'Ceritakan tentang diri Anda',
                          prefixIcon: const Icon(Icons.description_outlined),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Telepon
                      TextFormField(
                        controller: _teleponController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Telepon',
                          hintText: 'Contoh: 08123456789',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tanggal Lahir
                      TextFormField(
                        controller: _tanggalLahirController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Lahir',
                          hintText: 'Pilih tanggal lahir',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),

                      // Jenis Kelamin
                      DropdownButtonFormField<String>(
                        initialValue: _jenisKelamin,
                        decoration: InputDecoration(
                          labelText: 'Jenis Kelamin',
                          prefixIcon: const Icon(Icons.wc_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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
                      ),
                      const SizedBox(height: 16),

                      // Alamat
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Alamat',
                          hintText: 'Masukkan alamat lengkap',
                          prefixIcon: const Icon(Icons.home_outlined),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kota
                      TextFormField(
                        controller: _kotaController,
                        decoration: InputDecoration(
                          labelText: 'Kota',
                          hintText: 'Contoh: Jakarta',
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Provinsi
                      TextFormField(
                        controller: _provinsiController,
                        decoration: InputDecoration(
                          labelText: 'Provinsi',
                          hintText: 'Contoh: DKI Jakarta',
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kode Pos
                      TextFormField(
                        controller: _kodePosController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kode Pos',
                          hintText: 'Contoh: 12345',
                          prefixIcon: const Icon(Icons.pin_drop_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Field dengan tanda * wajib diisi',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
