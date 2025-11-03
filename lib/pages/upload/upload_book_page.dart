import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/book_submission.dart';
import 'package:publishify/pages/upload/upload_file_page.dart';

class UploadBookPage extends StatefulWidget {
  const UploadBookPage({super.key});

  @override
  State<UploadBookPage> createState() => _UploadBookPageState();
}

class _UploadBookPageState extends State<UploadBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publishYearController = TextEditingController();
  final _isbnController = TextEditingController();
  final _synopsisController = TextEditingController();
  
  String? _selectedCategory;
  final List<String> _categories = [
    'Fiksi',
    'Non-Fiksi',
    'Biografi',
    'Sejarah',
    'Teknologi',
    'Pendidikan',
    'Agama',
    'Seni',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publishYearController.dispose();
    _isbnController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon pilih kategori'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      final submission = BookSubmission(
        title: _titleController.text,
        authorName: _authorController.text,
        publishYear: _publishYearController.text,
        isbn: _isbnController.text,
        category: _selectedCategory!,
        synopsis: _synopsisController.text,
      );

      // Navigate to upload file page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadFilePage(submission: submission),
        ),
      );
    }
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
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title
                      Text(
                        'Identitas Buku',
                        style: AppTheme.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Judul',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.greyMedium,
                          fontSize: 14,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Nama Penulis
                      _buildTextField(
                        label: 'Nama Penulis',
                        controller: _authorController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama penulis harus diisi';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tahun Penulisan & Jaminan Usia Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Tahun Penulisan',
                              controller: _publishYearController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tahun harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Jaminan Usia',
                              controller: _isbnController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ISBN harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Kategori Dropdown
                      _buildCategoryDropdown(),
                      
                      const SizedBox(height: 16),
                      
                      // Sinopsis
                      _buildSynopsisField(),
                      
                      const SizedBox(height: 32),
                      
                      // Next Button
                      _buildNextButton(),
                      
                      const SizedBox(height: 20),
                    ],
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
            ),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.greyDisabled,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.greyDisabled,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.greyDisabled,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Pilih kategori',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsisField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinopsis',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _synopsisController,
          maxLines: 6,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sinopsis harus diisi';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Tulis sinopsis buku...',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
            ),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.greyDisabled,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.greyDisabled,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: AppTheme.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
