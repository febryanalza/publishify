import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/book_submission.dart';
import 'package:publishify/services/writer/upload_service.dart';
import 'package:publishify/services/writer/naskah_service.dart';

/// Model untuk menyimpan informasi file yang dipilih
class SelectedFile {
  final File file;
  final String name;
  final int size;
  
  SelectedFile({required this.file, required this.name, required this.size});
}

class UploadFilePage extends StatefulWidget {
  final BookSubmission submission;

  const UploadFilePage({
    super.key,
    required this.submission,
  });

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  // State untuk file naskah (WAJIB)
  SelectedFile? _naskahFile;
  
  // State untuk file sampul/cover (OPSIONAL)
  SelectedFile? _sampulFile;
  
  // State untuk dokumen pendukung (OPSIONAL)
  SelectedFile? _suratPerjanjianFile;
  SelectedFile? _suratKeaslianFile;
  SelectedFile? _proposalFile;
  
  bool _isUploading = false;
  String _uploadStatus = '';
  int _uploadProgress = 0;
  int _totalUploads = 0;

  /// Pick file naskah (DOC/DOCX)
  Future<void> _pickNaskah() async {
    final result = await _pickDocument(
      extensions: ['doc', 'docx'],
      maxSizeMB: 50,
      label: 'naskah',
    );
    if (result != null) {
      setState(() => _naskahFile = result);
    }
  }

  /// Pick file sampul (Image)
  Future<void> _pickSampul() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        
        const maxSize = 5 * 1024 * 1024; // 5MB
        if (fileSize > maxSize) {
          _showError('Ukuran gambar sampul terlalu besar! Maksimal 5MB');
          return;
        }

        setState(() {
          _sampulFile = SelectedFile(
            file: file,
            name: result.files.single.name,
            size: fileSize,
          );
        });
        _showSuccess('Sampul dipilih: ${result.files.single.name}');
      }
    } catch (e) {
      _showError('Error memilih sampul: ${e.toString()}');
    }
  }

  /// Pick dokumen pendukung (PDF/DOC/DOCX)
  Future<void> _pickDokumenPendukung(String jenis) async {
    final result = await _pickDocument(
      extensions: ['pdf', 'doc', 'docx'],
      maxSizeMB: 10,
      label: jenis,
    );
    
    if (result != null) {
      setState(() {
        switch (jenis) {
          case 'surat_perjanjian':
            _suratPerjanjianFile = result;
            break;
          case 'surat_keaslian':
            _suratKeaslianFile = result;
            break;
          case 'proposal':
            _proposalFile = result;
            break;
        }
      });
    }
  }

  /// Generic document picker
  Future<SelectedFile?> _pickDocument({
    required List<String> extensions,
    required int maxSizeMB,
    required String label,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        
        final maxSize = maxSizeMB * 1024 * 1024;
        if (fileSize > maxSize) {
          _showError('Ukuran file $label terlalu besar! Maksimal ${maxSizeMB}MB');
          return null;
        }

        _showSuccess('File $label dipilih: ${result.files.single.name}');
        return SelectedFile(
          file: file,
          name: result.files.single.name,
          size: fileSize,
        );
      }
    } catch (e) {
      _showError('Error memilih file $label: ${e.toString()}');
    }
    return null;
  }

  /// Hapus file yang dipilih
  void _removeFile(String jenis) {
    setState(() {
      switch (jenis) {
        case 'naskah':
          _naskahFile = null;
          break;
        case 'sampul':
          _sampulFile = null;
          break;
        case 'surat_perjanjian':
          _suratPerjanjianFile = null;
          break;
        case 'surat_keaslian':
          _suratKeaslianFile = null;
          break;
        case 'proposal':
          _proposalFile = null;
          break;
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Ekstrak path relatif dari URL upload
  String _extractRelativePath(String url) {
    if (url.startsWith('/naskah/') || 
        url.startsWith('/sampul/') || 
        url.startsWith('/dokumen/')) {
      return url;
    }
    
    final uploadsIndex = url.indexOf('/uploads/');
    if (uploadsIndex != -1) {
      final afterUploads = url.substring(uploadsIndex + '/uploads'.length);
      return afterUploads;
    }
    
    return url;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateProgress(String status, int current) {
    setState(() {
      _uploadStatus = status;
      _uploadProgress = current;
    });
  }

  Future<void> _handleSubmit() async {
    if (_naskahFile == null) {
      _showError('Mohon pilih file naskah terlebih dahulu');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      
      // Hitung total upload
      _totalUploads = 1; // Naskah wajib
      if (_sampulFile != null) _totalUploads++;
      if (_suratPerjanjianFile != null) _totalUploads++;
      if (_suratKeaslianFile != null) _totalUploads++;
      if (_proposalFile != null) _totalUploads++;
    });

    try {
      int currentUpload = 0;
      
      // Step 1: Upload file naskah (WAJIB)
      _updateProgress('Mengupload naskah...', ++currentUpload);
      final naskahResponse = await UploadService.uploadNaskah(
        file: _naskahFile!.file,
        deskripsi: 'Naskah: ${widget.submission.title}',
      );

      if (!naskahResponse.sukses || naskahResponse.data == null) {
        _showError(naskahResponse.pesan);
        setState(() => _isUploading = false);
        return;
      }

      final naskahUrl = _extractRelativePath(naskahResponse.data!.url);

      // Step 2: Upload sampul jika ada
      String? sampulUrl;
      if (_sampulFile != null) {
        _updateProgress('Mengupload sampul...', ++currentUpload);
        final sampulResponse = await UploadService.uploadSampul(
          file: _sampulFile!.file,
          deskripsi: 'Sampul: ${widget.submission.title}',
        );
        if (sampulResponse.sukses && sampulResponse.data != null) {
          sampulUrl = _extractRelativePath(sampulResponse.data!.url);
        }
      }

      // Step 3: Upload dokumen pendukung jika ada
      String? suratPerjanjianUrl;
      String? suratKeaslianUrl;
      String? proposalUrl;

      if (_suratPerjanjianFile != null) {
        _updateProgress('Mengupload surat perjanjian...', ++currentUpload);
        final response = await UploadService.uploadDokumen(
          file: _suratPerjanjianFile!.file,
          deskripsi: 'Surat Perjanjian: ${widget.submission.title}',
        );
        if (response.sukses && response.data != null) {
          suratPerjanjianUrl = _extractRelativePath(response.data!.url);
        }
      }

      if (_suratKeaslianFile != null) {
        _updateProgress('Mengupload surat keaslian...', ++currentUpload);
        final response = await UploadService.uploadDokumen(
          file: _suratKeaslianFile!.file,
          deskripsi: 'Surat Keaslian: ${widget.submission.title}',
        );
        if (response.sukses && response.data != null) {
          suratKeaslianUrl = _extractRelativePath(response.data!.url);
        }
      }

      if (_proposalFile != null) {
        _updateProgress('Mengupload proposal naskah...', ++currentUpload);
        final response = await UploadService.uploadDokumen(
          file: _proposalFile!.file,
          deskripsi: 'Proposal: ${widget.submission.title}',
        );
        if (response.sukses && response.data != null) {
          proposalUrl = _extractRelativePath(response.data!.url);
        }
      }

      // Step 4: Create naskah
      _updateProgress('Menyimpan data naskah...', _totalUploads);
      final createResponse = await NaskahService.createNaskah(
        judul: widget.submission.title,
        subJudul: widget.submission.subTitle,
        sinopsis: widget.submission.synopsis,
        idKategori: widget.submission.category,
        idGenre: widget.submission.genre,
        isbn: widget.submission.isbn,
        formatBuku: widget.submission.formatBuku,
        bahasaTulis: widget.submission.bahasaTulis,
        urlFile: naskahUrl,
        urlSampul: sampulUrl,
        publik: false,
      );

      if (!createResponse.sukses || createResponse.data == null) {
        _showError(createResponse.pesan);
        setState(() => _isUploading = false);
        return;
      }

      // Step 5: Update naskah dengan dokumen pendukung jika ada
      final hasDokumenPendukung = suratPerjanjianUrl != null || 
                                   suratKeaslianUrl != null || 
                                   proposalUrl != null;
      
      if (hasDokumenPendukung) {
        _updateProgress('Menyimpan dokumen pendukung...', _totalUploads);
        await NaskahService.perbaruiNaskah(
          id: createResponse.data!.id,
          urlSuratPerjanjian: suratPerjanjianUrl,
          urlSuratKeaslian: suratKeaslianUrl,
          urlProposalNaskah: proposalUrl,
        );
      }

      if (!mounted) return;

      setState(() => _isUploading = false);

      // Show success message
      _showSuccess('Naskah berhasil diupload!');

      // Navigate back to home
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      _showError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: File Naskah (WAJIB)
                        _buildSectionTitle(
                          icon: Icons.menu_book,
                          title: 'File Naskah',
                          subtitle: 'Format DOC/DOCX, maks 50MB',
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _buildUploadCard(
                          file: _naskahFile,
                          icon: Icons.description,
                          hint: 'Pilih file naskah',
                          formats: 'DOC, DOCX',
                          onPick: _pickNaskah,
                          onRemove: () => _removeFile('naskah'),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Section 2: Sampul (OPSIONAL)
                        _buildSectionTitle(
                          icon: Icons.image,
                          title: 'Sampul Buku',
                          subtitle: 'Format JPG/PNG/WebP, maks 5MB',
                          isRequired: false,
                        ),
                        const SizedBox(height: 12),
                        _buildUploadCard(
                          file: _sampulFile,
                          icon: Icons.photo_library,
                          hint: 'Pilih gambar sampul',
                          formats: 'JPG, PNG, WebP',
                          onPick: _pickSampul,
                          onRemove: () => _removeFile('sampul'),
                          isImage: true,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Section 3: Dokumen Pendukung
                        _buildSectionTitle(
                          icon: Icons.folder_copy,
                          title: 'Dokumen Pendukung',
                          subtitle: 'Surat-surat kelengkapan (opsional)',
                          isRequired: false,
                        ),
                        const SizedBox(height: 12),
                        
                        // Surat Perjanjian
                        _buildCompactUploadCard(
                          label: 'Surat Perjanjian Terbit',
                          file: _suratPerjanjianFile,
                          onPick: () => _pickDokumenPendukung('surat_perjanjian'),
                          onRemove: () => _removeFile('surat_perjanjian'),
                        ),
                        const SizedBox(height: 12),
                        
                        // Surat Keaslian
                        _buildCompactUploadCard(
                          label: 'Surat Pernyataan Keaslian',
                          file: _suratKeaslianFile,
                          onPick: () => _pickDokumenPendukung('surat_keaslian'),
                          onRemove: () => _removeFile('surat_keaslian'),
                        ),
                        const SizedBox(height: 12),
                        
                        // Proposal
                        _buildCompactUploadCard(
                          label: 'Proposal Naskah',
                          file: _proposalFile,
                          onPick: () => _pickDokumenPendukung('proposal'),
                          onRemove: () => _removeFile('proposal'),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        _buildSubmitButton(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Loading overlay
            if (_isUploading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload File',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.submission.title,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isRequired,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTheme.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Wajib',
                        style: TextStyle(
                          color: AppTheme.errorRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required SelectedFile? file,
    required IconData icon,
    required String hint,
    required String formats,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    bool isImage = false,
  }) {
    return GestureDetector(
      onTap: _isUploading ? null : onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? AppTheme.primaryGreen : AppTheme.greyDisabled,
            width: 2,
          ),
        ),
        child: file == null
            ? _buildEmptyUploadCard(icon, hint, formats)
            : _buildSelectedFileCard(file, onRemove, isImage: isImage),
      ),
    );
  }

  Widget _buildEmptyUploadCard(IconData icon, String hint, String formats) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.greyDisabled, width: 2),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          hint,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.greyMedium,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formats,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.greyMedium,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFileCard(SelectedFile file, VoidCallback onRemove, {bool isImage = false}) {
    return Row(
      children: [
        if (isImage && _sampulFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file.file,
              width: 60,
              height: 75,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatFileSize(file.size),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (!_isUploading)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: AppTheme.errorRed, size: 20),
            tooltip: 'Hapus',
          ),
      ],
    );
  }

  Widget _buildCompactUploadCard({
    required String label,
    required SelectedFile? file,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return GestureDetector(
      onTap: _isUploading ? null : onPick,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppTheme.primaryGreen : AppTheme.greyLight,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: file != null
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                file != null ? Icons.check_circle : Icons.add,
                color: file != null ? AppTheme.primaryGreen : AppTheme.greyMedium,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: file != null ? AppTheme.primaryDark : AppTheme.greyMedium,
                    ),
                  ),
                  if (file != null)
                    Text(
                      '${file.name} (${_formatFileSize(file.size)})',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'PDF, DOC, DOCX (maks 10MB)',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (file != null && !_isUploading)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: AppTheme.errorRed, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Hapus',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          disabledBackgroundColor: AppTheme.greyDisabled,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload, color: AppTheme.white),
                  const SizedBox(width: 8),
                  Text(
                    'Submit Naskah',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppTheme.primaryGreen),
                const SizedBox(height: 20),
                Text(
                  _uploadStatus,
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _totalUploads > 0 ? _uploadProgress / _totalUploads : 0,
                  backgroundColor: AppTheme.greyLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_uploadProgress dari $_totalUploads file',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                    fontSize: 12,
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
