import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/writer/naskah_models.dart';
import '../../../services/writer/naskah_service.dart';
import '../../../services/writer/percetakan_service.dart';
import '../../../utils/theme.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  final _formKey = GlobalKey<FormState>();

  List<NaskahData> _naskahList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Form Controllers
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // Form Values
  String? _selectedNaskah;
  String _selectedFormatKertas = 'A5';
  String _selectedJenisKertas = 'HVS';
  String _selectedJenisCover = 'Soft Cover';
  final List<String> _selectedFinishing = [];

  // Options
  final List<String> _formatKertasOptions = ['A4', 'A5', 'B5'];
  final List<String> _jenisKertasOptions = ['HVS', 'Art Paper', 'Book Paper'];
  final List<String> _jenisCoverOptions = ['Soft Cover', 'Hard Cover'];
  final List<String> _finishingOptions = [
    'Laminating',
    'UV Coating',
    'Emboss',
    'Foil Stamping'
  ];

  @override
  void initState() {
    super.initState();
    _loadNaskahDiterbitkan();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadNaskahDiterbitkan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final naskahList = await NaskahService.getNaskahPenulisWithStatus('diterbitkan');
      setState(() {
        _naskahList = naskahList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat naskah: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Percetakan'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.greyLight,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            )
          : _naskahList.isEmpty
              ? _buildEmptyState()
              : _buildForm(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.print_disabled,
            size: 64,
            color: AppTheme.greyMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak Ada Naskah Terbit',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda belum memiliki naskah yang diterbitkan.\nTerbitkan naskah terlebih dahulu untuk mencetak.',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNaskahDiterbitkan,
            style: AppTheme.primaryButtonStyle,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Info
          Card(
            elevation: 2,
            color: AppTheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.print,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesan Cetak Buku',
                          style: AppTheme.headingSmall,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Isi form di bawah untuk memesan cetak buku Anda',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pilih Naskah
          _buildSectionCard(
            title: 'Pilih Naskah',
            child: DropdownButtonFormField<String>(
              value: _selectedNaskah,
              decoration: AppTheme.inputDecoration(
                hintText: 'Pilih naskah yang akan dicetak',
              ),
              items: _naskahList.map((naskah) {
                return DropdownMenuItem<String>(
                  value: naskah.id,
                  child: Text(
                    naskah.judul,
                    style: AppTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNaskah = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Pilih naskah yang akan dicetak';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Jumlah Eksemplar
          _buildSectionCard(
            title: 'Jumlah Eksemplar',
            child: TextFormField(
              controller: _jumlahController,
              decoration: AppTheme.inputDecoration(
                hintText: 'Masukkan jumlah eksemplar',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan jumlah eksemplar';
                }
                final jumlah = int.tryParse(value);
                if (jumlah == null || jumlah <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                if (jumlah > 10000) {
                  return 'Jumlah maksimal 10.000 eksemplar';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Spesifikasi Cetak
          _buildSectionCard(
            title: 'Spesifikasi Cetak',
            child: Column(
              children: [
                // Format Kertas
                DropdownButtonFormField<String>(
                  value: _selectedFormatKertas,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Pilih format kertas',
                  ),
                  items: _formatKertasOptions.map((format) {
                    return DropdownMenuItem<String>(
                      value: format,
                      child: Text(format, style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFormatKertas = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Jenis Kertas
                DropdownButtonFormField<String>(
                  value: _selectedJenisKertas,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Pilih jenis kertas',
                  ),
                  items: _jenisKertasOptions.map((jenis) {
                    return DropdownMenuItem<String>(
                      value: jenis,
                      child: Text(jenis, style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedJenisKertas = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Jenis Cover
                DropdownButtonFormField<String>(
                  value: _selectedJenisCover,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Pilih jenis cover',
                  ),
                  items: _jenisCoverOptions.map((cover) {
                    return DropdownMenuItem<String>(
                      value: cover,
                      child: Text(cover, style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedJenisCover = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Finishing Tambahan
          _buildSectionCard(
            title: 'Finishing Tambahan (Opsional)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih finishing yang diinginkan:',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                ..._finishingOptions.map((finishing) {
                  return CheckboxListTile(
                    title: Text(
                      finishing,
                      style: AppTheme.bodyLarge,
                    ),
                    value: _selectedFinishing.contains(finishing),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedFinishing.add(finishing);
                        } else {
                          _selectedFinishing.remove(finishing);
                        }
                      });
                    },
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Catatan
          _buildSectionCard(
            title: 'Catatan Tambahan (Opsional)',
            child: TextFormField(
              controller: _catatanController,
              decoration: AppTheme.inputDecoration(
                hintText: 'Masukkan catatan untuk pesanan...',
              ),
              maxLines: 3,
              maxLength: 1000,
              validator: (value) {
                if (value != null && value.length > 1000) {
                  return 'Catatan maksimal 1000 karakter';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: AppTheme.primaryButtonStyle,
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Memproses...'),
                      ],
                    )
                  : const Text('Buat Pesanan Cetak'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      color: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedNaskah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih naskah yang akan dicetak'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await PercetakanService.buatPesananCetak(
        idNaskah: _selectedNaskah!,
        jumlah: int.parse(_jumlahController.text),
        formatKertas: _selectedFormatKertas,
        jenisKertas: _selectedJenisKertas,
        jenisCover: _selectedJenisCover,
        finishingTambahan: _selectedFinishing,
        catatan: _catatanController.text.isEmpty ? null : _catatanController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan cetak berhasil dibuat!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}