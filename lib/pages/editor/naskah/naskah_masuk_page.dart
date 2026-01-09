import 'package:flutter/material.dart';
import 'dart:async';

import '../../../models/editor/review_models.dart';
import '../../../services/editor/naskah_masuk_service.dart';

class NaskahMasukPage extends StatefulWidget {
  const NaskahMasukPage({super.key});

  @override
  State<NaskahMasukPage> createState() => _NaskahMasukPageState();
}

class _NaskahMasukPageState extends State<NaskahMasukPage> {
  bool _isLoading = false;
  List<ReviewNaskah> _reviewList = [];
  StatusReview? _selectedStatus; // Filter by status: null = semua
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviewMasuk();
  }

  Future<void> _loadReviewMasuk() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await NaskahMasukService.ambilNaskahMasuk(
        halaman: 1,
        limit: 100,
        status: _selectedStatus,
      );

      if (response.sukses && response.data != null) {
        setState(() {
          _reviewList = response.data!;
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
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naskah Masuk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviewMasuk,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(158, 158, 158, 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Status Review:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: _selectedStatus == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = null;
                  });
                  _loadReviewMasuk();
                },
              ),
              FilterChip(
                label: const Text('Ditugaskan'),
                selected: _selectedStatus == StatusReview.ditugaskan,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? StatusReview.ditugaskan : null;
                  });
                  _loadReviewMasuk();
                },
              ),
              FilterChip(
                label: const Text('Dalam Proses'),
                selected: _selectedStatus == StatusReview.dalam_proses,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? StatusReview.dalam_proses : null;
                  });
                  _loadReviewMasuk();
                },
              ),
              FilterChip(
                label: const Text('Selesai'),
                selected: _selectedStatus == StatusReview.selesai,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? StatusReview.selesai : null;
                  });
                  _loadReviewMasuk();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadReviewMasuk,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_reviewList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada review yang ditugaskan',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviewMasuk,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviewList.length,
        itemBuilder: (context, index) {
          return _buildReviewCard(_reviewList[index]);
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewNaskah review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openReviewDetail(review),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Judul Naskah & Status Review
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.naskah.judul,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (review.naskah.subJudul != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            review.naskah.subJudul!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(review.status),
                ],
              ),
              const SizedBox(height: 12),

              // Penulis
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      review.naskah.penulis?.profilPengguna?.namaLengkap ?? 
                      review.naskah.penulis?.email ?? 'Tidak diketahui',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Kategori & Genre
              if (review.naskah.kategori != null && review.naskah.genre != null)
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '${review.naskah.kategori!.nama} • ${review.naskah.genre!.nama}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Tanggal Ditugaskan
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Ditugaskan: ${_formatDate(review.ditugaskanPada)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              // Rekomendasi (jika sudah selesai)
              if (review.rekomendasi != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getRekomendasiColor(review.rekomendasi!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getRekomendasiColor(review.rekomendasi!).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getRekomendasiIcon(review.rekomendasi!),
                        size: 18,
                        color: _getRekomendasiColor(review.rekomendasi!),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rekomendasi: ${_getRekomendasiLabel(review.rekomendasi!)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _getRekomendasiColor(review.rekomendasi!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Feedback Count
              if (review.feedbackCount != null && review.feedbackCount! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '${review.feedbackCount} Feedback',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StatusReview status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case StatusReview.ditugaskan:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        label = 'Ditugaskan';
        break;
      case StatusReview.dalam_proses:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        label = 'Dalam Proses';
        break;
      case StatusReview.selesai:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        label = 'Selesai';
        break;
      case StatusReview.dibatalkan:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        label = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRekomendasiColor(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return Colors.green;
      case Rekomendasi.revisi:
        return Colors.orange;
      case Rekomendasi.tolak:
        return Colors.red;
    }
  }

  IconData _getRekomendasiIcon(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return Icons.check_circle;
      case Rekomendasi.revisi:
        return Icons.edit;
      case Rekomendasi.tolak:
        return Icons.cancel;
    }
  }

  String _getRekomendasiLabel(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return 'Setujui';
      case Rekomendasi.revisi:
        return 'Perlu Revisi';
      case Rekomendasi.tolak:
        return 'Tolak';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return 'Hari ini, $hour:$minute';
    } else if (difference.inDays == 1) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return 'Kemarin, $hour:$minute';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day-$month-$year';
    }
  }

  void _openReviewDetail(ReviewNaskah review) {
    // TODO: Navigate to review detail page
    Navigator.pushNamed(
      context,
      '/editor/review/detail',
      arguments: review.id,
    ).then((_) {
      // Refresh when back from detail
      _loadReviewMasuk();
    });
  }
}
