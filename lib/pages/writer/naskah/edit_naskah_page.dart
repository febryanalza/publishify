import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:publishify/models/writer/kategori_models.dart';
import 'package:publishify/models/writer/genre_models.dart';
import 'package:publishify/services/writer/naskah_service.dart';
import 'package:publishify/services/writer/kategori_service.dart';
import 'package:publishify/services/writer/genre_service.dart';
import 'package:publishify/services/writer/upload_service.dart';
import 'package:publishify/utils/theme.dart';

/// Halaman untuk mengedit/update data naskah
class EditNaskahPage extends StatefulWidget {
  final NaskahDetail naskah;

  const EditNaskahPage({
    super.key,
    required this.naskah,
  });

  @override
  State<EditNaskahPage> createState() => _EditNaskahPageState();
}

class _EditNaskahPageState extends State<EditNaskahPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form controllers
  late TextEditingController _judulController;
  late TextEditingController _subJudulController;
  late TextEditingController _sinopsisController;
  late TextEditingController _jumlahHalamanController;
  late TextEditingController _jumlahKataController;
  late TextEditingController _urlSampulController;
  late TextEditingController _isbnController;

  // Dropdown values
  String? _selectedKategoriId;
  String? _selectedGenreId;
  String? _selectedFormatBuku;
  bool _publik = false;

  // Data untuk dropdown
  List<Kategori> _kategoriList = [];
  List<Genre> _genreList = [];
  bool _isLoadingOptions = true;

  // File picker untuk sampul
  File? _sampulFile;
  bool _isUploadingSampul = false;
  String? _sampulUrl;

  // File picker untuk naskah
  File? _naskahFile;
  bool _isUploadingNaskah = false;
  String? _naskahUrl;
  String? _naskahFileName;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadOptions();
    
    // Check if naskah can be edited based on status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEditPermission();
    });
  }

  void _checkEditPermission() {
    final status = widget.naskah.status.toLowerCase();
    
    // Status yang tidak boleh diedit
    // Naskah terkunci setelah siap terbit atau diterbitkan
    final lockedStatuses = ['siap_terbit', 'ditolak', 'diterbitkan'];
    
    if (lockedStatuses.contains(status)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.errorRed),
              const SizedBox(width: 8),
              const Text('Naskah Terkunci'),
            ],
          ),
          content: Text(
            'Naskah dengan status "$status" tidak dapat diubah. '
            'Naskah hanya dapat diedit sampai status "dalam review".',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close edit page
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      );
    }
  }

  void _initializeControllers() {
    _judulController = TextEditingController(text: widget.naskah.judul);
    _subJudulController = TextEditingController(text: widget.naskah.subJudul ?? '');
    _sinopsisController = TextEditingController(text: widget.naskah.sinopsis);
    _jumlahHalamanController = TextEditingController(
      text: widget.naskah.jumlahHalaman?.toString() ?? '',
    );
    _jumlahKataController = TextEditingController(
      text: widget.naskah.jumlahKata?.toString() ?? '',
    );
    _urlSampulController = TextEditingController(text: widget.naskah.urlSampul ?? '');
    _isbnController = TextEditingController(text: widget.naskah.isbn ?? '');

    _selectedKategoriId = widget.naskah.kategori.id;
    _selectedGenreId = widget.naskah.genre.id;
    _selectedFormatBuku = widget.naskah.formatBuku;
    _publik = widget.naskah.publik;
    _sampulUrl = widget.naskah.urlSampul;
    _naskahUrl = widget.naskah.urlFile;
    
    // Ekstrak nama file dari URL
    if (_naskahUrl != null) {
      _naskahFileName = _naskahUrl!.split('/').last;
    }
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });

    try {
      final kategoriResponse = await KategoriService.getActiveKategori();
      final genreResponse = await GenreService.getActiveGenres();

      setState(() {
        if (kategoriResponse.sukses && kategoriResponse.data != null) {
          _kategoriList = kategoriResponse.data!;
        }
        if (genreResponse.sukses && genreResponse.data != null) {
          _genreList = genreResponse.data!;
        }
        _isLoadingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOptions = false;
      });
      if (mounted) {
        _showSnackBar('Gagal memuat data kategori dan genre', isError: true);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _sampulFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memilih gambar: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _uploadSampul() async {
    if (_sampulFile == null) {
      _showSnackBar('Pilih gambar terlebih dahulu', isError: true);
      return;
    }

    setState(() {
      _isUploadingSampul = true;
    });

    try {
      final response = await UploadService.uploadSampul(
        file: _sampulFile!,
        deskripsi: 'Sampul untuk ${_judulController.text}',
        idReferensi: widget.naskah.id,
      );

      setState(() {
        _isUploadingSampul = false;
      });

      if (response.sukses && response.data != null) {
        setState(() {
          _sampulUrl = response.data!.url;
          _urlSampulController.text = response.data!.url;
        });
        _showSnackBar('Sampul berhasil diupload');
      } else {
        _showSnackBar(response.pesan, isError: true);
      }
    } catch (e) {
      setState(() {
        _isUploadingSampul = false;
      });
      _showSnackBar('Gagal upload sampul: ${e.toString()}', isError: true);
    }
  }

  void _removeSampul() {
    setState(() {
      _sampulFile = null;
      _sampulUrl = null;
      _urlSampulController.clear();
    });
  }

  @override
  void dispose() {
    _judulController.dispose();
    _subJudulController.dispose();
    _sinopsisController.dispose();
    _jumlahHalamanController.dispose();
    _jumlahKataController.dispose();
    _urlSampulController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi: jika ada file sampul yang dipilih tapi belum diupload
    if (_sampulFile != null && _sampulUrl == null) {
      _showSnackBar('Mohon upload sampul terlebih dahulu dengan menekan tombol "Upload"', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await NaskahService.perbaruiNaskah(
      id: widget.naskah.id,
      judul: _judulController.text.trim(),
      subJudul: _subJudulController.text.isNotEmpty 
        ? _subJudulController.text.trim() 
        : null,
      sinopsis: _sinopsisController.text.trim(),
      idKategori: _selectedKategoriId,
      idGenre: _selectedGenreId,
      formatBuku: _selectedFormatBuku,
      jumlahHalaman: _jumlahHalamanController.text.isNotEmpty
        ? int.tryParse(_jumlahHalamanController.text)
        : null,
      jumlahKata: _jumlahKataController.text.isNotEmpty
        ? int.tryParse(_jumlahKataController.text)
        : null,
      urlSampul: _urlSampulController.text.isNotEmpty
        ? _urlSampulController.text.trim()
        : null,
      urlFile: _naskahUrl, // Gunakan URL yang sudah diupload atau URL lama
      publik: _publik,
      isbn: _isbnController.text.isNotEmpty
        ? _isbnController.text.trim()
        : null,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (response.sukses) {
      _showSnackBar('Naskah berhasil diperbarui');
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } else {
      _showSnackBar(response.pesan, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Naskah',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.white),
        ),
      ),
      body: _isLoadingOptions
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.googleBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.googleBlue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.googleBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Edit data naskah Anda. Field yang wajib diisi ditandai dengan *',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.googleBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status saat ini: ${_formatStatus(widget.naskah.status)} • '
                        'Dapat diedit sampai status "Dalam Review"',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Judul *
          _buildSectionTitle('Judul Naskah *'),
          TextFormField(
            controller: _judulController,
            decoration: AppTheme.inputDecoration(
              hintText: 'Masukkan judul naskah',
              prefixIcon: const Icon(Icons.title, color: AppTheme.primaryGreen),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Judul wajib diisi';
              }
              if (value.trim().length < 3) {
                return 'Judul minimal 3 karakter';
              }
              if (value.trim().length > 200) {
                return 'Judul maksimal 200 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Sub Judul
          _buildSectionTitle('Sub Judul (Opsional)'),
          TextFormField(
            controller: _subJudulController,
            decoration: AppTheme.inputDecoration(
              hintText: 'Masukkan sub judul',
              prefixIcon: const Icon(Icons.subtitles, color: AppTheme.primaryGreen),
            ),
            validator: (value) {
              if (value != null && value.trim().length > 200) {
                return 'Sub judul maksimal 200 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Sinopsis *
          _buildSectionTitle('Sinopsis *'),
          TextFormField(
            controller: _sinopsisController,
            maxLines: 5,
            maxLength: 2000,
            decoration: AppTheme.inputDecoration(
              hintText: 'Tulis sinopsis naskah Anda (minimal 50 karakter)',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Sinopsis wajib diisi';
              }
              if (value.trim().length < 50) {
                return 'Sinopsis minimal 50 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Kategori *
          _buildSectionTitle('Kategori *'),
          DropdownButtonFormField<String>(
            initialValue: _selectedKategoriId,
            decoration: AppTheme.inputDecoration(
              hintText: 'Pilih kategori',
              prefixIcon: const Icon(Icons.category, color: AppTheme.primaryGreen),
            ),
            items: _kategoriList.map((kategori) {
              return DropdownMenuItem(
                value: kategori.id,
                child: Text(kategori.nama),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedKategoriId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kategori wajib dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Genre *
          _buildSectionTitle('Genre *'),
          DropdownButtonFormField<String>(
            initialValue: _selectedGenreId,
            decoration: AppTheme.inputDecoration(
              hintText: 'Pilih genre',
              prefixIcon: const Icon(Icons.style, color: AppTheme.primaryGreen),
            ),
            items: _genreList.map((genre) {
              return DropdownMenuItem(
                value: genre.id,
                child: Text(genre.nama),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGenreId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Genre wajib dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Format Buku
          _buildSectionTitle('Format Buku (Opsional)'),
          DropdownButtonFormField<String>(
            value: _selectedFormatBuku,
            decoration: AppTheme.inputDecoration(
              hintText: 'Pilih format buku',
              prefixIcon: const Icon(Icons.aspect_ratio, color: AppTheme.primaryGreen),
            ),
            items: const [
              DropdownMenuItem(value: 'A4', child: Text('A4 (210 x 297 mm)')),
              DropdownMenuItem(value: 'A5', child: Text('A5 (148 x 210 mm)')),
              DropdownMenuItem(value: 'B5', child: Text('B5 (176 x 250 mm)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFormatBuku = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // ISBN
          _buildSectionTitle('ISBN (Opsional)'),
          TextFormField(
            controller: _isbnController,
            decoration: AppTheme.inputDecoration(
              hintText: 'Masukkan ISBN (jika ada)',
              prefixIcon: const Icon(Icons.qr_code, color: AppTheme.primaryGreen),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length < 10 || value.length > 17) {
                  return 'ISBN harus 10-17 karakter';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Jumlah Halaman
          _buildSectionTitle('Jumlah Halaman (Opsional)'),
          TextFormField(
            controller: _jumlahHalamanController,
            keyboardType: TextInputType.number,
            decoration: AppTheme.inputDecoration(
              hintText: 'Masukkan jumlah halaman',
              prefixIcon: const Icon(Icons.book, color: AppTheme.primaryGreen),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final num = int.tryParse(value);
                if (num == null || num < 1) {
                  return 'Jumlah halaman harus angka minimal 1';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Jumlah Kata
          _buildSectionTitle('Jumlah Kata (Opsional)'),
          TextFormField(
            controller: _jumlahKataController,
            keyboardType: TextInputType.number,
            decoration: AppTheme.inputDecoration(
              hintText: 'Masukkan jumlah kata',
              prefixIcon: const Icon(Icons.text_fields, color: AppTheme.primaryGreen),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final num = int.tryParse(value);
                if (num == null || num < 100) {
                  return 'Jumlah kata harus angka minimal 100';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Upload Sampul Cover
          _buildSectionTitle('Sampul Cover Buku'),
          _buildSampulPicker(),
          const SizedBox(height: 24),

          // Upload File Naskah
          _buildSectionTitle('File Naskah'),
          _buildNaskahFilePicker(),
          const SizedBox(height: 24),

          // Publik Switch
          SwitchListTile(
            title: Text(
              'Tampilkan ke Publik',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
            subtitle: Text(
              'Naskah dapat dilihat oleh pengguna lain',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.greyText),
            ),
            value: _publik,
            onChanged: (value) {
              setState(() {
                _publik = value;
              });
            },
            activeThumbColor: AppTheme.primaryGreen,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.greyDisabled),
            ),
            tileColor: AppTheme.white,
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitUpdate,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : const Icon(Icons.save, color: AppTheme.white),
              label: Text(
                _isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: AppTheme.primaryButtonStyle,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }

  Widget _buildSampulPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyDisabled),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview sampul jika ada
          if (_sampulFile != null || _sampulUrl != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.greyDisabled.withValues(alpha: 0.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _sampulFile != null
                    ? Image.file(
                        _sampulFile!,
                        fit: BoxFit.cover,
                      )
                    : _sampulUrl != null
                        ? Image.network(
                            _sampulUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, 
                                      color: AppTheme.errorRed, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gagal memuat gambar',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryGreen,
                                  ),
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Informasi file yang dipilih
          if (_sampulFile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, 
                    color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sampulFile!.path.split('/').last,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Tombol aksi
          Row(
            children: [
              // Tombol pilih gambar
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, size: 18),
                  label: Text(
                    _sampulFile != null || _sampulUrl != null
                        ? 'Ganti Gambar'
                        : 'Pilih Gambar',
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.googleBlue,
                    side: const BorderSide(color: AppTheme.googleBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Tombol upload (hanya muncul jika ada file yang dipilih)
              if (_sampulFile != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploadingSampul ? null : _uploadSampul,
                    icon: _isUploadingSampul
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.cloud_upload, size: 18),
                    label: Text(
                      _isUploadingSampul ? 'Uploading...' : 'Upload',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],

              // Tombol hapus (hanya muncul jika ada sampul)
              if (_sampulFile != null || _sampulUrl != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _removeSampul,
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.errorRed,
                  tooltip: 'Hapus sampul',
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Info tambahan
          Text(
            'Format: JPG, JPEG, PNG • Max: 5MB',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNaskahFilePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyDisabled),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info file saat ini
          if (_naskahFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File Naskah Saat Ini:',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _naskahFileName!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Info file yang baru dipilih
          if (_naskahFile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.googleBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.googleBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.file_upload,
                    color: AppTheme.googleBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File Baru Dipilih:',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _naskahFile!.path.split('/').last,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Tombol aksi
          Row(
            children: [
              // Tombol pilih file
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickNaskahFile,
                  icon: const Icon(Icons.file_upload, size: 18),
                  label: Text(
                    _naskahFile != null
                        ? 'Ganti File'
                        : _naskahFileName != null
                            ? 'Upload File Baru'
                            : 'Pilih File',
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.googleBlue,
                    side: const BorderSide(color: AppTheme.googleBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Tombol upload (hanya muncul jika ada file yang dipilih)
              if (_naskahFile != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploadingNaskah ? null : _uploadNaskahFile,
                    icon: _isUploadingNaskah
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.cloud_upload, size: 18),
                    label: Text(
                      _isUploadingNaskah ? 'Uploading...' : 'Upload',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Info tambahan
          Text(
            'Format: DOC, DOCX • Max: 50MB',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyText,
              fontSize: 12,
            ),
          ),
          
          if (_naskahFileName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Untuk mengganti file naskah, upload file baru',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryGreen,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickNaskahFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Check file size (max 50MB)
        const maxSize = 50 * 1024 * 1024; // 50MB
        if (fileSize > maxSize) {
          if (!mounted) return;
          _showSnackBar(
            'Ukuran file terlalu besar! Maksimal 50MB',
            isError: true,
          );
          return;
        }

        setState(() {
          _naskahFile = file;
        });

        if (!mounted) return;
        _showSnackBar('File dipilih: ${result.files.single.name}');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error memilih file: ${e.toString()}', isError: true);
    }
  }

  Future<void> _uploadNaskahFile() async {
    if (_naskahFile == null) {
      _showSnackBar('Tidak ada file yang dipilih', isError: true);
      return;
    }

    setState(() {
      _isUploadingNaskah = true;
    });

    try {
      final response = await UploadService.uploadNaskah(
        file: _naskahFile!,
        deskripsi: 'Naskah: ${_judulController.text}',
      );

      setState(() {
        _isUploadingNaskah = false;
      });

      if (response.sukses && response.data != null) {
        // Ekstrak path relatif dari URL
        final uploadUrl = response.data!.url;
        final fileUrl = _extractRelativePath(uploadUrl);
        
        setState(() {
          _naskahUrl = fileUrl;
          _naskahFileName = _naskahFile!.path.split('/').last;
          _naskahFile = null; // Clear selected file setelah upload
        });

        _showSnackBar('File naskah berhasil diupload');
      } else {
        _showSnackBar(response.pesan, isError: true);
      }
    } catch (e) {
      setState(() {
        _isUploadingNaskah = false;
      });
      _showSnackBar('Error upload file: ${e.toString()}', isError: true);
    }
  }

  String _extractRelativePath(String url) {
    // Jika sudah dalam format yang diinginkan (/naskah/...)
    if (url.startsWith('/naskah/') || url.startsWith('/sampul/')) {
      return url;
    }
    
    // Ekstrak path setelah /uploads
    final uploadsIndex = url.indexOf('/uploads/');
    if (uploadsIndex != -1) {
      // Ambil bagian setelah /uploads
      final afterUploads = url.substring(uploadsIndex + '/uploads'.length);
      return afterUploads; // Returns: /naskah/filename.docx
    }
    
    // Jika format tidak dikenali, kembalikan apa adanya
    return url;
  }

  String _formatStatus(String status) {
    final statusMap = {
      'draft': 'Draft',
      'diajukan': 'Diajukan',
      'dalam_review': 'Dalam Review',
      'dalam_editing': 'Dalam Editing',
      'siap_terbit': 'Siap Terbit',
      'ditolak': 'Ditolak',
      'diterbitkan': 'Diterbitkan',
    };
    
    return statusMap[status.toLowerCase()] ?? status;
  }
}
