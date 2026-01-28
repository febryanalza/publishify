import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:publishify/services/writer/naskah_service.dart';

/// Widget untuk menampilkan dialog Terbitkan Naskah (Editor/Admin)
class TerbitkanNaskahDialog extends StatefulWidget {
  final String naskahId;
  final String judulNaskah;
  final int? jumlahHalamanSaatIni;
  final Function(bool sukses, String pesan)? onResult;

  const TerbitkanNaskahDialog({
    super.key,
    required this.naskahId,
    required this.judulNaskah,
    this.jumlahHalamanSaatIni,
    this.onResult,
  });

  @override
  State<TerbitkanNaskahDialog> createState() => _TerbitkanNaskahDialogState();
}

class _TerbitkanNaskahDialogState extends State<TerbitkanNaskahDialog> {
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final _jumlahHalamanController = TextEditingController();
  String _formatBuku = 'A5';
  bool _isLoading = false;

  final List<String> _formatOptions = ['A4', 'A5', 'B5'];

  @override
  void initState() {
    super.initState();
    if (widget.jumlahHalamanSaatIni != null && widget.jumlahHalamanSaatIni! > 0) {
      _jumlahHalamanController.text = widget.jumlahHalamanSaatIni.toString();
    }
  }

  @override
  void dispose() {
    _isbnController.dispose();
    _jumlahHalamanController.dispose();
    super.dispose();
  }

  Future<void> _handleTerbitkan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = TerbitkanNaskahRequest(
      isbn: _isbnController.text.trim(),
      formatBuku: _formatBuku,
      jumlahHalaman: int.tryParse(_jumlahHalamanController.text.trim()),
    );

    final response = await NaskahService.terbitkanNaskah(widget.naskahId, request);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onResult?.call(response.sukses, response.pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.publish, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Terbitkan Naskah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Naskah: ${widget.judulNaskah}',
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // ISBN Field
              TextFormField(
                controller: _isbnController,
                decoration: AppTheme.inputDecoration(
                  hintText: 'ISBN (contoh: 978-602-xxxxx-x-x)',
                  prefixIcon: const Icon(Icons.book, color: AppTheme.greyMedium),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ISBN wajib diisi untuk penerbitan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Format Buku Dropdown
              DropdownButtonFormField<String>(
                value: _formatBuku,
                decoration: AppTheme.inputDecoration(
                  hintText: 'Format Buku',
                  prefixIcon: const Icon(Icons.aspect_ratio, color: AppTheme.greyMedium),
                ),
                items: _formatOptions.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(format),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _formatBuku = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Jumlah Halaman Field
              TextFormField(
                controller: _jumlahHalamanController,
                decoration: AppTheme.inputDecoration(
                  hintText: 'Jumlah Halaman (opsional)',
                  prefixIcon: const Icon(Icons.pages, color: AppTheme.greyMedium),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = int.tryParse(value);
                    if (num == null || num < 1) {
                      return 'Jumlah halaman harus lebih dari 0';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.greyDisabled),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pastikan ISBN sudah terdaftar di Perpusnas',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.greyText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleTerbitkan,
          style: AppTheme.primaryButtonStyle.copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                )
              : const Text('Terbitkan'),
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan dialog Ubah Status Naskah (Editor/Admin)
class UbahStatusNaskahDialog extends StatefulWidget {
  final String naskahId;
  final String judulNaskah;
  final String statusSaatIni;
  final Function(bool sukses, String pesan, String? statusBaru)? onResult;

  const UbahStatusNaskahDialog({
    super.key,
    required this.naskahId,
    required this.judulNaskah,
    required this.statusSaatIni,
    this.onResult,
  });

  @override
  State<UbahStatusNaskahDialog> createState() => _UbahStatusNaskahDialogState();
}

class _UbahStatusNaskahDialogState extends State<UbahStatusNaskahDialog> {
  late String _selectedStatus;
  bool _isLoading = false;

  final Map<String, String> _statusLabels = {
    'draft': 'Draft',
    'diajukan': 'Diajukan',
    'dalam_review': 'Dalam Review',
    'dalam_editing': 'Dalam Editing',
    'perlu_revisi': 'Perlu Revisi',
    'siap_terbit': 'Siap Terbit',
    'diterbitkan': 'Diterbitkan',
    'ditolak': 'Ditolak',
  };

  final Map<String, IconData> _statusIcons = {
    'draft': Icons.edit_note,
    'diajukan': Icons.send,
    'dalam_review': Icons.rate_review,
    'dalam_editing': Icons.edit,
    'perlu_revisi': Icons.refresh,
    'siap_terbit': Icons.check_circle_outline,
    'diterbitkan': Icons.publish,
    'ditolak': Icons.cancel,
  };

  final Map<String, Color> _statusColors = {
    'draft': Colors.grey,
    'diajukan': Colors.blue,
    'dalam_review': Colors.orange,
    'dalam_editing': Colors.purple,
    'perlu_revisi': Colors.amber,
    'siap_terbit': AppTheme.primaryGreen,
    'diterbitkan': Colors.green,
    'ditolak': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.statusSaatIni;
  }

  Future<void> _handleUbahStatus() async {
    if (_selectedStatus == widget.statusSaatIni) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih status yang berbeda')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await NaskahService.ubahStatusNaskah(widget.naskahId, _selectedStatus);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onResult?.call(response.sukses, response.pesan, response.sukses ? _selectedStatus : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.swap_horiz, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ubah Status Naskah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naskah: ${widget.judulNaskah}',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status saat ini: ', style: AppTheme.bodySmall),
                _buildStatusChip(widget.statusSaatIni),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Pilih status baru:', style: AppTheme.bodyMedium),
            const SizedBox(height: 12),
            
            // Status Options
            ..._statusLabels.entries.map((entry) {
              final isSelected = entry.key == _selectedStatus;
              final isCurrent = entry.key == widget.statusSaatIni;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isCurrent ? null : () {
                      setState(() => _selectedStatus = entry.key);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected 
                              ? AppTheme.primaryGreen 
                              : AppTheme.greyDisabled,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _statusIcons[entry.key],
                            color: isCurrent 
                                ? AppTheme.greyDisabled 
                                : _statusColors[entry.key],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isCurrent 
                                    ? AppTheme.greyDisabled 
                                    : AppTheme.black,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.greyLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Saat ini',
                                style: TextStyle(fontSize: 10, color: AppTheme.greyText),
                              ),
                            ),
                          if (isSelected && !isCurrent)
                            const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedStatus == widget.statusSaatIni 
              ? null 
              : _handleUbahStatus,
          style: AppTheme.primaryButtonStyle.copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (_statusColors[status] ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _statusColors[status] ?? Colors.grey),
      ),
      child: Text(
        _statusLabels[status] ?? status,
        style: TextStyle(
          fontSize: 12,
          color: _statusColors[status] ?? Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan dialog Atur Harga Jual (Penulis)
class AturHargaJualDialog extends StatefulWidget {
  final String naskahId;
  final String judulNaskah;
  final double? hargaSaatIni;
  final Function(bool sukses, String pesan, double? hargaBaru)? onResult;

  const AturHargaJualDialog({
    super.key,
    required this.naskahId,
    required this.judulNaskah,
    this.hargaSaatIni,
    this.onResult,
  });

  @override
  State<AturHargaJualDialog> createState() => _AturHargaJualDialogState();
}

class _AturHargaJualDialogState extends State<AturHargaJualDialog> {
  final _formKey = GlobalKey<FormState>();
  final _hargaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.hargaSaatIni != null && widget.hargaSaatIni! > 0) {
      _hargaController.text = widget.hargaSaatIni!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _handleAturHarga() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final harga = double.tryParse(_hargaController.text.trim().replaceAll('.', '')) ?? 0;
    final response = await NaskahService.aturHargaJual(widget.naskahId, harga);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onResult?.call(response.sukses, response.pesan, response.sukses ? harga : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.attach_money, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Atur Harga Jual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buku: ${widget.judulNaskah}',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Harga Field
            TextFormField(
              controller: _hargaController,
              decoration: AppTheme.inputDecoration(
                hintText: 'Harga Jual (Rp)',
                prefixIcon: const Icon(Icons.monetization_on, color: AppTheme.greyMedium),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga jual wajib diisi';
                }
                final harga = double.tryParse(value.replaceAll('.', ''));
                if (harga == null || harga <= 0) {
                  return 'Harga jual harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.greyDisabled),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Catatan Penting',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Setelah harga ditetapkan, buku akan tersedia di katalog\n'
                    '• Harga dapat diubah kapan saja\n'
                    '• Pertimbangkan harga cetak dan royalti',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAturHarga,
          style: AppTheme.primaryButtonStyle.copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan dialog konfirmasi Hapus Naskah
class HapusNaskahDialog extends StatefulWidget {
  final String naskahId;
  final String judulNaskah;
  final String statusNaskah;
  final Function(bool sukses, String pesan)? onResult;

  const HapusNaskahDialog({
    super.key,
    required this.naskahId,
    required this.judulNaskah,
    required this.statusNaskah,
    this.onResult,
  });

  @override
  State<HapusNaskahDialog> createState() => _HapusNaskahDialogState();
}

class _HapusNaskahDialogState extends State<HapusNaskahDialog> {
  bool _isLoading = false;
  bool _konfirmasi = false;

  Future<void> _handleHapus() async {
    setState(() => _isLoading = true);

    final response = await NaskahService.hapusNaskah(widget.naskahId);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onResult?.call(response.sukses, response.pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDiterbitkan = widget.statusNaskah == 'diterbitkan';

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_forever, color: AppTheme.errorRed),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hapus Naskah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDiterbitkan) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorRed),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppTheme.errorRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Naskah yang sudah diterbitkan tidak dapat dihapus!',
                      style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Apakah Anda yakin ingin menghapus naskah ini?',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: AppTheme.primaryGreen, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.judulNaskah,
                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${widget.statusNaskah.replaceAll('_', ' ')}',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
              ),
              child: Text(
                '⚠️ Tindakan ini tidak dapat dibatalkan. Semua data naskah termasuk revisi dan review akan dihapus permanen.',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _konfirmasi,
              onChanged: (value) {
                setState(() => _konfirmasi = value ?? false);
              },
              title: const Text(
                'Saya mengerti dan ingin menghapus naskah ini',
                style: TextStyle(fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.errorRed,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        if (!isDiterbitkan)
          ElevatedButton(
            onPressed: _isLoading || !_konfirmasi ? null : _handleHapus,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                    ),
                  )
                : const Text('Hapus'),
          ),
      ],
    );
  }
}

/// Helper function untuk menampilkan dialog terbitkan naskah
void showTerbitkanNaskahDialog(
  BuildContext context, {
  required String naskahId,
  required String judulNaskah,
  int? jumlahHalamanSaatIni,
  Function(bool sukses, String pesan)? onResult,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TerbitkanNaskahDialog(
      naskahId: naskahId,
      judulNaskah: judulNaskah,
      jumlahHalamanSaatIni: jumlahHalamanSaatIni,
      onResult: onResult,
    ),
  );
}

/// Helper function untuk menampilkan dialog ubah status naskah
void showUbahStatusNaskahDialog(
  BuildContext context, {
  required String naskahId,
  required String judulNaskah,
  required String statusSaatIni,
  Function(bool sukses, String pesan, String? statusBaru)? onResult,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => UbahStatusNaskahDialog(
      naskahId: naskahId,
      judulNaskah: judulNaskah,
      statusSaatIni: statusSaatIni,
      onResult: onResult,
    ),
  );
}

/// Helper function untuk menampilkan dialog atur harga jual
void showAturHargaJualDialog(
  BuildContext context, {
  required String naskahId,
  required String judulNaskah,
  double? hargaSaatIni,
  Function(bool sukses, String pesan, double? hargaBaru)? onResult,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AturHargaJualDialog(
      naskahId: naskahId,
      judulNaskah: judulNaskah,
      hargaSaatIni: hargaSaatIni,
      onResult: onResult,
    ),
  );
}

/// Helper function untuk menampilkan dialog hapus naskah
void showHapusNaskahDialog(
  BuildContext context, {
  required String naskahId,
  required String judulNaskah,
  required String statusNaskah,
  Function(bool sukses, String pesan)? onResult,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => HapusNaskahDialog(
      naskahId: naskahId,
      judulNaskah: judulNaskah,
      statusNaskah: statusNaskah,
      onResult: onResult,
    ),
  );
}
