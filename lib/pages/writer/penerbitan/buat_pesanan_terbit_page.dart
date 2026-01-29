import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/pesanan_terbit_models.dart';
import 'package:publishify/services/writer/pesanan_terbit_service.dart';
import 'package:publishify/services/writer/naskah_service.dart';
import 'package:publishify/models/writer/naskah_models.dart';

/// Halaman untuk membuat pesanan penerbitan baru
class BuatPesananTerbitPage extends StatefulWidget {
  const BuatPesananTerbitPage({super.key});

  @override
  State<BuatPesananTerbitPage> createState() => _BuatPesananTerbitPageState();
}

class _BuatPesananTerbitPageState extends State<BuatPesananTerbitPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingNaskah = true;
  
  List<NaskahData> _naskahList = [];
  List<PaketPenerbitan> _paketList = [];
  
  String? _selectedNaskahId;
  String? _selectedPaketId;
  int _jumlahBuku = 100;
  final _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingNaskah = true;
    });

    try {
      // Load naskah yang sudah siap terbit dan paket penerbitan secara paralel
      final results = await Future.wait([
        NaskahService.getNaskahSaya(
          status: 'siap_terbit',
          limit: 100,
        ),
        PesananTerbitService.getPaketPenerbitan(),
      ]);

      final naskahResponse = results[0] as NaskahListResponse;
      final paketResponse = results[1] as DaftarPaketResponse;

      debugPrint('Naskah response: sukses=${naskahResponse.sukses}, count=${naskahResponse.data?.length ?? 0}');
      debugPrint('Paket response: sukses=${paketResponse.sukses}, count=${paketResponse.data.length}');

      setState(() {
        if (naskahResponse.sukses && naskahResponse.data != null) {
          _naskahList = naskahResponse.data!;
        }
        if (paketResponse.sukses) {
          _paketList = paketResponse.data;
        }
        _isLoadingNaskah = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading data: $e');
      debugPrint('StackTrace: $stackTrace');
      setState(() {
        _isLoadingNaskah = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _submitPesanan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNaskahId == null || _selectedPaketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih naskah dan paket terlebih dahulu'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = BuatPesananTerbitRequest(
        idNaskah: _selectedNaskahId!,
        idPaket: _selectedPaketId!,
        jumlahBuku: _jumlahBuku,
        catatanPenulis: _catatanController.text.isNotEmpty
            ? _catatanController.text
            : null,
      );

      final response = await PesananTerbitService.buatPesananTerbit(request);

      setState(() {
        _isLoading = false;
      });

      if (response.sukses) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Buat Pesanan Penerbitan'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: _isLoadingNaskah
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pilih Naskah
                    _buildSectionTitle('Pilih Naskah'),
                    const SizedBox(height: 8),
                    _buildNaskahDropdown(),
                    
                    const SizedBox(height: 24),
                    
                    // Pilih Paket
                    _buildSectionTitle('Pilih Paket Penerbitan'),
                    const SizedBox(height: 8),
                    _buildPaketList(),
                    
                    const SizedBox(height: 24),
                    
                    // Jumlah Buku
                    _buildSectionTitle('Jumlah Buku'),
                    const SizedBox(height: 8),
                    _buildJumlahBukuField(),
                    
                    const SizedBox(height: 24),
                    
                    // Catatan
                    _buildSectionTitle('Catatan (Opsional)'),
                    const SizedBox(height: 8),
                    _buildCatatanField(),
                    
                    const SizedBox(height: 24),
                    
                    // Ringkasan Harga
                    _buildRingkasanHarga(),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    _buildSubmitButton(),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryDark,
      ),
    );
  }

  Widget _buildNaskahDropdown() {
    if (_naskahList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada naskah yang siap diterbitkan. Pastikan naskah sudah disetujui.',
                style: AppTheme.bodySmall.copyWith(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedNaskahId,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      hint: const Text('Pilih naskah'),
      items: _naskahList.map((naskah) {
        return DropdownMenuItem(
          value: naskah.id,
          child: Text(
            naskah.judul,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedNaskahId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih naskah yang akan diterbitkan';
        }
        return null;
      },
    );
  }

  Widget _buildPaketList() {
    if (_paketList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada paket penerbitan tersedia. Silakan hubungi admin.',
                style: AppTheme.bodySmall.copyWith(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _paketList.map((paket) {
        final isSelected = _selectedPaketId == paket.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPaketId = paket.id;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.greyLight,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppTheme.primaryGreen.withValues(alpha: 0.05)
                    : AppTheme.white,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: paket.id,
                    groupValue: _selectedPaketId,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaketId = value;
                      });
                    },
                    activeColor: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paket.nama,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          paket.deskripsi ?? '',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatRupiah(paket.harga),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJumlahBukuField() {
    return Row(
      children: [
        IconButton(
          onPressed: _jumlahBuku > 50
              ? () {
                  setState(() {
                    _jumlahBuku -= 50;
                  });
                }
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppTheme.primaryGreen,
        ),
        Expanded(
          child: TextFormField(
            initialValue: _jumlahBuku.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixText: 'buku',
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed > 0) {
                setState(() {
                  _jumlahBuku = parsed;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan jumlah buku';
              }
              final parsed = int.tryParse(value);
              if (parsed == null || parsed < 1) {
                return 'Jumlah minimal 1 buku';
              }
              return null;
            },
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _jumlahBuku += 50;
            });
          },
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildCatatanField() {
    return TextFormField(
      controller: _catatanController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Tambahkan catatan untuk tim penerbitan...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildRingkasanHarga() {
    PaketPenerbitan? selectedPaket;
    try {
      selectedPaket = _paketList.firstWhere((p) => p.id == _selectedPaketId);
    } catch (_) {
      selectedPaket = null;
    }

    final hargaPaket = selectedPaket?.harga ?? 0;
    final hargaCetak = _jumlahBuku * 25000.0; // Contoh: Rp 25.000/buku
    final totalHarga = hargaPaket + hargaCetak;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Biaya',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildHargaRow('Paket ${selectedPaket?.nama ?? '-'}', hargaPaket),
          _buildHargaRow('Cetak $_jumlahBuku buku', hargaCetak),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatRupiah(totalHarga),
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHargaRow(String label, double harga) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
          Text(
            _formatRupiah(harga),
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPesanan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              )
            : const Text(
                'Buat Pesanan',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  String _formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }
}
