import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/book_submission.dart';

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
  String? _selectedFileName;
  bool _isUploading = false;

  void _pickFile() async {
    // TODO: Implement file picker
    // For now, simulate file selection
    setState(() {
      _selectedFileName = 'contoh_buku.pdf';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker akan diimplementasikan dengan file_picker package'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSubmit() async {
    if (_selectedFileName == null) {
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

    // TODO: Implement actual upload to server
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buku berhasil diupload!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );

    // Navigate back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
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
                      'Pilih File',
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
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.greyDisabled,
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
                  Icons.add,
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
                'PDF, DOC, DOCX (Max 10MB)',
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
              ),
              const SizedBox(height: 8),
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
