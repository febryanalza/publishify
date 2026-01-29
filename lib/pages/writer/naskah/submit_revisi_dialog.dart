import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:publishify/services/writer/revisi_service.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// Helper untuk format tanggal dalam Bahasa Indonesia
/// Menerima String (ISO 8601) atau DateTime
String formatTanggal(dynamic dateInput, {bool withTime = false}) {
  try {
    DateTime date;
    if (dateInput is String) {
      date = DateTime.parse(dateInput);
    } else if (dateInput is DateTime) {
      date = dateInput;
    } else {
      return '-';
    }
    
    final bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    final day = date.day.toString().padLeft(2, '0');
    final month = bulan[date.month];
    final year = date.year;
    
    if (withTime) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day $month $year $hour:$minute';
    }
    
    return '$day $month $year';
  } catch (e) {
    return '-';
  }
}

/// Dialog untuk Submit Revisi Naskah
class SubmitRevisiDialog extends StatefulWidget {
  final NaskahDetail naskah;
  final VoidCallback onSuccess;

  const SubmitRevisiDialog({
    Key? key,
    required this.naskah,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<SubmitRevisiDialog> createState() => _SubmitRevisiDialogState();
}

class _SubmitRevisiDialogState extends State<SubmitRevisiDialog> {
  File? _fileNaskahBaru;
  final _catatanController = TextEditingController();
  bool _isLoading = false;
  String? _fileNameBaru;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        dialogTitle: 'Pilih File Naskah Revisi',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileNaskahBaru = File(result.files.single.path!);
          _fileNameBaru = result.files.single.name;
        });
      }
    } catch (e) {
      _logger.e('Error pilih file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitRevisi() async {
    if (_fileNaskahBaru == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih file naskah revisi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await RevisiService.submitRevisi(
        idNaskah: widget.naskah.id,
        fileNaskahBaru: _fileNaskahBaru!,
        catatan: _catatanController.text.isNotEmpty
            ? _catatanController.text
            : null,
      );

      if (mounted) {
        if (response.sukses) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSuccess();
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error submit revisi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.upload_file, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Submit Revisi Naskah',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.naskah.judul,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Naskah Saat Ini
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'File Saat Ini:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Naskah Utama',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    'Diupload: ${formatTanggal(widget.naskah.dibuatPada)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pilih File Revisi
                  Text(
                    'File Revisi Naskah',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : _pilihFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _fileNaskahBaru != null
                              ? Colors.green
                              : Colors.grey[300]!,
                          width: _fileNaskahBaru != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _fileNaskahBaru != null
                            ? Colors.green[50]
                            : Colors.grey[50],
                      ),
                      child: _fileNaskahBaru == null
                          ? Column(
                              children: [
                                Icon(Icons.cloud_upload,
                                    size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Pilih file naskah revisi',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PDF, DOC, DOCX, atau TXT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _fileNameBaru ?? 'File dipilih',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${(_fileNaskahBaru!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.close,
                                    color: Colors.grey[400], size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Catatan (Opsional)
                  Text(
                    'Catatan Revisi (Opsional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _catatanController,
                    enabled: !_isLoading,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Jelaskan perubahan atau revisi yang Anda lakukan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRevisi,
                          child: const Text('Submit Revisi'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Mengirim revisi naskah...',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Page untuk menampilkan daftar revisi naskah
class RevisiHistoryPage extends StatefulWidget {
  final NaskahDetail naskah;

  const RevisiHistoryPage({Key? key, required this.naskah}) : super(key: key);

  @override
  State<RevisiHistoryPage> createState() => _RevisiHistoryPageState();
}

class _RevisiHistoryPageState extends State<RevisiHistoryPage> {
  late Future<DaftarRevisiResponse> _futureDaftarRevisi;

  @override
  void initState() {
    super.initState();
    _futureDaftarRevisi = RevisiService.getDaftarRevisi(
      idNaskah: widget.naskah.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Revisi'),
        elevation: 0,
      ),
      body: FutureBuilder<DaftarRevisiResponse>(
        future: _futureDaftarRevisi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Terjadi kesalahan: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureDaftarRevisi = RevisiService.getDaftarRevisi(
                          idNaskah: widget.naskah.id,
                        );
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final response = snapshot.data;

          if (!response!.sukses || response.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Colors.grey[400], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat revisi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revisi yang Anda submit akan ditampilkan di sini',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final revisi = response.data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'v${revisi.versi}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatTanggal(revisi.dibuatPada, withTime: true),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (revisi.status != 'aktif')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Status: ${revisi.status}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (revisi.catatan != null && revisi.catatan!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  revisi.catatan!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
