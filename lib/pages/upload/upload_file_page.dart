import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/book_submission.dart';
import 'package:publishify/services/upload_service.dart';
import 'package:publishify/services/naskah_service.dart';

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
  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isUploading = false;

  void _pickFile() async {
    try {
      // Pick file dengan filter .doc dan .docx
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        
        // Check file size (max 50MB sesuai backend)
        const maxSize = 50 * 1024 * 1024; // 50MB
        if (fileSize > maxSize) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran file terlalu besar! Maksimal 50MB'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
          return;
        }

        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.single.name;
          _selectedFileSize = fileSize;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File dipilih: $_selectedFileName'),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih file: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void _handleSubmit() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih file terlebih dahulu'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Step 1: Upload file naskah
      final uploadResponse = await UploadService.uploadNaskah(
        file: _selectedFile!,
        deskripsi: 'Naskah: ${widget.submission.title}',
      );

      if (!uploadResponse.sukses || uploadResponse.data == null) {
        if (!mounted) return;
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadResponse.pesan),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      // Step 2: Create naskah with uploaded file URL
      // Build full URL from relative path (backend returns /uploads/...)
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:4000';
      final fileUrl = uploadResponse.data!.url.startsWith('http')
          ? uploadResponse.data!.url
          : '$baseUrl${uploadResponse.data!.url}';
      
      final createResponse = await NaskahService.createNaskah(
        judul: widget.submission.title,
        subJudul: null,
        sinopsis: widget.submission.synopsis,
        idKategori: widget.submission.category,
        idGenre: widget.submission.genre,
        isbn: widget.submission.isbn,
        urlFile: fileUrl,  // Full URL: http://localhost:4000/uploads/naskah/file.docx
        publik: false,
      );

      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      if (createResponse.sukses) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Naskah berhasil diupload!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(createResponse.pesan),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
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
                // Header
                _buildHeader(),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Upload File',
                          style: AppTheme.headingMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pilih file naskah Anda (DOC/DOCX)',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.greyMedium,
                            fontSize: 14,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Upload Area
                        _buildUploadArea(),
                        
                        const Spacer(),
                        
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
            if (_isUploading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(32),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Mengupload naskah...',
                            style: AppTheme.bodyMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mohon tunggu sebentar',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.greyMedium,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Upload',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickFile,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isUploading ? AppTheme.greyDisabled : AppTheme.greyDisabled,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedFileName == null) ...[
              // Upload Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.greyDisabled,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Klik untuk memilih file',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.greyMedium,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DOC, DOCX (Max 50MB)',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                  fontSize: 12,
                ),
              ),
            ] else ...[
              // Selected File
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFileName!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedFileSize != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(_selectedFileSize!),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (!_isUploading)
                TextButton(
                  onPressed: _pickFile,
                  child: Text(
                    'Ganti File',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryGreen,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
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
            : Text(
                'Submit',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
