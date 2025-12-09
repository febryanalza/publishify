import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/review_naskah_models.dart';
import 'package:publishify/services/editor/review_naskah_service.dart';
import 'package:publishify/pages/editor/review/detail_review_naskah_page.dart';

/// Halaman untuk menampilkan list naskah yang perlu direview
class ReviewNaskahPage extends StatefulWidget {
  const ReviewNaskahPage({super.key});

  @override
  State<ReviewNaskahPage> createState() => _ReviewNaskahPageState();
}

class _ReviewNaskahPageState extends State<ReviewNaskahPage> {
  List<NaskahSubmission> _naskahList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'semua';
  Map<String, int> _statusCount = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadStatusCount();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ReviewNaskahService.getNaskahSubmissions(
        status: _selectedStatus == 'semua' ? null : _selectedStatus,
      );

      if (response.sukses && response.data != null) {
        setState(() {
          _naskahList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.pesan;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatusCount() async {
    try {
      final count = await ReviewNaskahService.getStatusCount();
      setState(() {
        _statusCount = count;
      });
    } catch (e) {
      // Ignore error for count
    }
  }

  Future<void> _terimaReview(NaskahSubmission naskah) async {
    // Simpan ScaffoldMessenger sebelum masuk async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menerima review naskah "${naskah.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // Show loading
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Memproses permintaan...'),
                  duration: Duration(seconds: 1),
                ),
              );

              try {
                final response = await ReviewNaskahService.terimaReview(
                  naskah.id,
                  'current_editor_id', // TODO: Ambil dari auth
                );

                if (!mounted) return;

                if (response.sukses) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(response.pesan)),
                  );
                  _loadData(); // Reload data
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(response.pesan),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Terjadi kesalahan: ${e.toString()}'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Ya, Terima'),
          ),
        ],
      ),
    );
  }

  void _tugaskanEditorLain(NaskahSubmission naskah) {
    // Simpan ScaffoldMessenger sebelum masuk async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _TugaskanEditorDialog(
        naskah: naskah,
        onTugaskan: (idEditor, alasan) async {
          try {
            final response = await ReviewNaskahService.tugaskanEditor(
              naskah.id,
              idEditor,
              alasan,
            );

            if (!mounted) return;

            if (response.sukses) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(response.pesan)),
              );
              _loadData(); // Reload data
            } else {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(response.pesan),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Terjadi kesalahan: ${e.toString()}'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
      ),
    );
  }

  void _lihatDetail(NaskahSubmission naskah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailReviewNaskahPage(naskahId: naskah.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _naskahList.isEmpty
                          ? _buildEmptyState()
                          : _buildNaskahList(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Review Naskah',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: AppTheme.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola dan review naskah yang telah disubmit',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'menunggu_review', 'label': 'Menunggu Review'},
      {'key': 'dalam_review', 'label': 'Dalam Review'},
      {'key': 'selesai_review', 'label': 'Selesai Review'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedStatus == filter['key'];
            final count = _statusCount[filter['key']] ?? 0;
            
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = filter['key']!;
                  });
                  _loadData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.greyLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.greyMedium,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter['label']!,
                        style: AppTheme.bodySmall.copyWith(
                          color: isSelected ? AppTheme.white : AppTheme.greyLight,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.white.withValues(alpha: 0.2) : AppTheme.greyMedium,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.white : AppTheme.greyLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNaskahList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _naskahList.length,
        itemBuilder: (context, index) {
          return _buildNaskahCard(_naskahList[index]);
        },
      ),
    );
  }

  Widget _buildNaskahCard(NaskahSubmission naskah) {
    Color statusColor;
    Color prioritasColor;
    
    switch (naskah.status) {
      case 'menunggu_review':
        statusColor = Colors.orange;
        break;
      case 'dalam_review':
        statusColor = Colors.blue;
        break;
      case 'selesai_review':
        statusColor = AppTheme.primaryGreen;
        break;
      default:
        statusColor = AppTheme.greyMedium;
    }

    switch (naskah.prioritas) {
      case 'urgent':
        prioritasColor = AppTheme.errorRed;
        break;
      case 'tinggi':
        prioritasColor = Colors.orange;
        break;
      case 'sedang':
        prioritasColor = Colors.blue;
        break;
      case 'rendah':
        prioritasColor = AppTheme.greyMedium;
        break;
      default:
        prioritasColor = AppTheme.greyMedium;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul dan status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        naskah.judul,
                        style: AppTheme.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (naskah.subJudul?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          naskah.subJudul!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyMedium,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        naskah.statusLabel,
                        style: AppTheme.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: prioritasColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        naskah.prioritasLabel,
                        style: AppTheme.bodySmall.copyWith(
                          color: prioritasColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Info penulis dan kategori
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.greyMedium),
                const SizedBox(width: 4),
                Text(
                  naskah.namaPenulis,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: AppTheme.greyMedium),
                const SizedBox(width: 4),
                Text(
                  '${naskah.kategori} • ${naskah.genre}',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Info halaman dan tanggal
            Row(
              children: [
                Icon(Icons.description, size: 16, color: AppTheme.greyMedium),
                const SizedBox(width: 4),
                Text(
                  '${naskah.jumlahHalaman} halaman',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: AppTheme.greyMedium),
                const SizedBox(width: 4),
                Text(
                  _formatTanggal(naskah.tanggalSubmit),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                ),
              ],
            ),
            
            if (naskah.namaEditorDitugaskan != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_pin, size: 16, color: AppTheme.greyMedium),
                  const SizedBox(width: 4),
                  Text(
                    'Editor: ${naskah.namaEditorDitugaskan}',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Sinopsis singkat
            Text(
              naskah.sinopsis,
              style: AppTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _lihatDetail(naskah),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Lihat Detail'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (naskah.status == 'menunggu_review') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _terimaReview(naskah),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Terima'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tugaskanEditorLain(naskah),
                    icon: const Icon(Icons.assignment_ind, size: 16),
                    label: const Text('Tugaskan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          SizedBox(height: 16),
          Text('Memuat data naskah...', style: TextStyle(color: AppTheme.greyMedium)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Naskah',
              style: AppTheme.headingMedium.copyWith(color: AppTheme.greyMedium),
            ),
            const SizedBox(height: 8),
            Text(
              'Naskah yang perlu direview akan muncul di sini',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTanggal(DateTime tanggal) {
    final now = DateTime.now();
    final difference = now.difference(tanggal);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
    }
  }
}

/// Dialog untuk menugaskan editor lain
class _TugaskanEditorDialog extends StatefulWidget {
  final NaskahSubmission naskah;
  final Function(String idEditor, String alasan) onTugaskan;

  const _TugaskanEditorDialog({
    required this.naskah,
    required this.onTugaskan,
  });

  @override
  State<_TugaskanEditorDialog> createState() => _TugaskanEditorDialogState();
}

class _TugaskanEditorDialogState extends State<_TugaskanEditorDialog> {
  List<EditorTersedia> _editorList = [];
  bool _isLoading = true;
  String? _selectedEditorId;
  final _alasanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEditors();
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _loadEditors() async {
    try {
      final response = await ReviewNaskahService.getEditorTersedia();
      
      if (!mounted) return;

      if (response.sukses && response.data != null) {
        setState(() {
          _editorList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.pesan)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data editor: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.greyMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Tugaskan Editor',
                  style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Info naskah
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.naskah.judul,
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'oleh ${widget.naskah.namaPenulis}',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // List editor
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : _editorList.isEmpty
                    ? const Center(child: Text('Tidak ada editor tersedia'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _editorList.length,
                        itemBuilder: (context, index) {
                          final editor = _editorList[index];
                          final isSelected = _selectedEditorId == editor.id;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryGreen : AppTheme.greyMedium,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: editor.urlFoto != null 
                                    ? NetworkImage(editor.urlFoto!)
                                    : null,
                                child: editor.urlFoto == null 
                                    ? Text(editor.nama.substring(0, 1).toUpperCase())
                                    : null,
                              ),
                              title: Text(
                                editor.nama,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(editor.spesialisasi),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('${editor.rating}'),
                                      const SizedBox(width: 12),
                                      Text('${editor.jumlahTugasAktif} tugas aktif'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: editor.tersedia
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedEditorId == editor.id 
                                              ? AppTheme.primaryGreen 
                                              : AppTheme.greyMedium,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedEditorId == editor.id
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppTheme.primaryGreen,
                                                ),
                                              ),
                                            )
                                          : null,
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.greyMedium,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Tidak Tersedia',
                                        style: TextStyle(fontSize: 11, color: AppTheme.white),
                                      ),
                                    ),
                              onTap: editor.tersedia
                                  ? () {
                                      setState(() {
                                        _selectedEditorId = editor.id;
                                      });
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
          
          // Input alasan dan button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.greyLight)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _alasanController,
                  decoration: const InputDecoration(
                    labelText: 'Alasan penugasan (opsional)',
                    hintText: 'Masukkan alasan mengapa editor ini cocok...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedEditorId != null
                        ? () {
                            Navigator.pop(context);
                            widget.onTugaskan(
                              _selectedEditorId!,
                              _alasanController.text.trim(),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tugaskan Editor'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}