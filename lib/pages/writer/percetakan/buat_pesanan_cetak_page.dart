import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/cetak_models.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:publishify/services/writer/cetak_service.dart';
import 'package:publishify/services/writer/naskah_service.dart';

/// Halaman untuk membuat pesanan cetak baru
class BuatPesananCetakPage extends StatefulWidget {
  const BuatPesananCetakPage({super.key});

  @override
  State<BuatPesananCetakPage> createState() => _BuatPesananCetakPageState();
}

class _BuatPesananCetakPageState extends State<BuatPesananCetakPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Data naskah yang bisa dicetak (status: diterbitkan)
  List<NaskahData> _naskahList = [];
  bool _isLoadingNaskah = true;
  String? _errorNaskah;
  
  // Form values
  NaskahData? _selectedNaskah;
  int _jumlah = 100;
  String _formatKertas = 'A5';
  String _jenisKertas = 'HVS 80gr';
  String _jenisCover = 'Soft Cover';
  final List<String> _finishingTambahan = [];
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController(text: '100');
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadNaskahDiterbitkan();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _loadNaskahDiterbitkan() async {
    setState(() {
      _isLoadingNaskah = true;
      _errorNaskah = null;
    });

    try {
      final response = await NaskahService.getNaskahSaya(
        limit: 100,
        status: 'diterbitkan',
      );

      setState(() {
        _isLoadingNaskah = false;
        if (response.sukses && response.data != null) {
          _naskahList = response.data!;
        } else {
          _errorNaskah = response.pesan;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingNaskah = false;
        _errorNaskah = 'Gagal memuat daftar naskah';
      });
    }
  }

  Future<void> _submitPesanan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNaskah == null) {
      _showSnackBar('Pilih naskah terlebih dahulu', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final request = BuatPesananRequest(
      idNaskah: _selectedNaskah!.id,
      jumlah: _jumlah,
      formatKertas: _formatKertas,
      jenisKertas: _jenisKertas,
      jenisCover: _jenisCover,
      finishingTambahan: _finishingTambahan.isEmpty ? ['Tidak Ada'] : _finishingTambahan,
      catatan: _catatanController.text.isEmpty ? null : _catatanController.text,
    );

    final response = await CetakService.buatPesanan(request);

    setState(() {
      _isSubmitting = false;
    });

    if (response.sukses) {
      _showSnackBar('Pesanan cetak berhasil dibuat!');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      _showSnackBar(response.pesan ?? 'Gagal membuat pesanan', isError: true);
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
          'Buat Pesanan Cetak',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.white),
        ),
      ),
      body: _isLoadingNaskah
          ? _buildLoading()
          : _errorNaskah != null
              ? _buildError()
              : _naskahList.isEmpty
                  ? _buildEmptyNaskah()
                  : _buildForm(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.black),
            ),
            const SizedBox(height: 8),
            Text(
              _errorNaskah ?? 'Terjadi kesalahan',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNaskahDiterbitkan,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: AppTheme.primaryButtonStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNaskah() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Naskah',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda belum memiliki naskah dengan status "Diterbitkan".\nHanya naskah yang sudah diterbitkan yang dapat dicetak.',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: AppTheme.secondaryButtonStyle,
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pilih Naskah
          _buildSectionTitle('Pilih Naskah'),
          _buildNaskahDropdown(),
          const SizedBox(height: 24),

          // Jumlah Cetak
          _buildSectionTitle('Jumlah Eksemplar'),
          _buildJumlahField(),
          const SizedBox(height: 24),

          // Spesifikasi Cetak
          _buildSectionTitle('Spesifikasi Cetak'),
          _buildSpecCard(),
          const SizedBox(height: 24),

          // Finishing Tambahan
          _buildSectionTitle('Finishing Tambahan (Opsional)'),
          _buildFinishingChips(),
          const SizedBox(height: 24),

          // Catatan
          _buildSectionTitle('Catatan (Opsional)'),
          _buildCatatanField(),
          const SizedBox(height: 32),

          // Submit Button
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }

  Widget _buildNaskahDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyDisabled),
      ),
      child: DropdownButtonFormField<NaskahData>(
        initialValue: _selectedNaskah,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'Pilih naskah yang akan dicetak',
        ),
        items: _naskahList.map((naskah) {
          return DropdownMenuItem<NaskahData>(
            value: naskah,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  naskah.judul,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${naskah.jumlahHalaman} halaman',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.greyText),
                ),
              ],
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
            return 'Pilih naskah terlebih dahulu';
          }
          return null;
        },
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildJumlahField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _jumlahController,
            keyboardType: TextInputType.number,
            decoration: AppTheme.inputDecoration(
              hintText: 'Masukkan jumlah',
              prefixIcon: const Icon(Icons.layers_outlined, color: AppTheme.primaryGreen),
            ),
            onChanged: (value) {
              _jumlah = int.tryParse(value) ?? 100;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan jumlah eksemplar';
              }
              final num = int.tryParse(value);
              if (num == null || num < 1) {
                return 'Jumlah minimal 1';
              }
              if (num > 10000) {
                return 'Jumlah maksimal 10.000';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'eksemplar',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyText),
        ),
      ],
    );
  }

  Widget _buildSpecCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyDisabled),
      ),
      child: Column(
        children: [
          // Format Kertas
          _buildSpecRow(
            label: 'Format Kertas',
            icon: Icons.aspect_ratio,
            child: _buildDropdown(
              value: _formatKertas,
              items: CetakOptions.formatKertas,
              onChanged: (value) => setState(() => _formatKertas = value!),
            ),
          ),
          const Divider(height: 24),
          // Jenis Kertas
          _buildSpecRow(
            label: 'Jenis Kertas',
            icon: Icons.description_outlined,
            child: _buildDropdown(
              value: _jenisKertas,
              items: CetakOptions.jenisKertas,
              onChanged: (value) => setState(() => _jenisKertas = value!),
            ),
          ),
          const Divider(height: 24),
          // Jenis Cover
          _buildSpecRow(
            label: 'Jenis Cover',
            icon: Icons.book_outlined,
            child: _buildDropdown(
              value: _jenisCover,
              items: CetakOptions.jenisCover,
              onChanged: (value) => setState(() => _jenisCover = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.black),
          ),
        ),
        Expanded(
          flex: 3,
          child: child,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.black),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFinishingChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CetakOptions.finishingTambahan.where((f) => f != 'Tidak Ada').map((finishing) {
        final isSelected = _finishingTambahan.contains(finishing);
        return FilterChip(
          label: Text(finishing),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _finishingTambahan.add(finishing);
              } else {
                _finishingTambahan.remove(finishing);
              }
            });
          },
          backgroundColor: AppTheme.white,
          selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.primaryGreen,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.greyText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.greyDisabled,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCatatanField() {
    return TextFormField(
      controller: _catatanController,
      maxLines: 3,
      maxLength: 1000,
      decoration: AppTheme.inputDecoration(
        hintText: 'Tambahkan catatan untuk percetakan (opsional)',
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitPesanan,
        style: AppTheme.primaryButtonStyle,
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              )
            : const Text('Buat Pesanan Cetak'),
      ),
    );
  }
}
