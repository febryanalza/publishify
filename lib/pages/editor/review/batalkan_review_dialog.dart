import 'package:flutter/material.dart';
import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/services/editor/editor_review_service.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// Dialog untuk Batalkan Review
class BatalkanReviewDialog extends StatefulWidget {
  final ReviewNaskah review;
  final VoidCallback onSuccess;

  const BatalkanReviewDialog({
    Key? key,
    required this.review,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<BatalkanReviewDialog> createState() => _BatalkanReviewDialogState();
}

class _BatalkanReviewDialogState extends State<BatalkanReviewDialog> {
  final _alasanController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _batalkanReview() async {
    if (_alasanController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Alasan pembatalan wajib diisi';
      });
      return;
    }

    if (_alasanController.text.length < 10) {
      setState(() {
        _errorMessage = 'Alasan minimal 10 karakter';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EditorReviewService.batalkanReview(
        reviewId: widget.review.id,
        alasan: _alasanController.text,
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
          setState(() {
            _errorMessage = response.pesan;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _logger.e('Error batalkan review: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
          _isLoading = false;
        });
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
                  // Header dengan warning icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.cancel, color: Colors.red[700]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Batalkan Review?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              'Tindakan ini tidak dapat dibatalkan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apa yang akan terjadi?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _WarningItem(
                          icon: Icons.undo,
                          text: 'Naskah akan dikembalikan ke status "Diajukan"',
                          color: Colors.red,
                        ),
                        const SizedBox(height: 6),
                        _WarningItem(
                          icon: Icons.delete_outline,
                          text:
                              'Semua feedback dan komentar review akan dihapus',
                          color: Colors.red,
                        ),
                        const SizedBox(height: 6),
                        _WarningItem(
                          icon: Icons.info_outline,
                          text: 'Penulis akan diberi tahu tentang pembatalan ini',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Alasan Pembatalan
                  Text(
                    'Alasan Pembatalan',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _alasanController,
                    enabled: !_isLoading,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Jelaskan alasan pembatalan review ini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      errorText: _errorMessage,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimal 10 karakter - Penulis akan melihat pesan ini',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
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
                          child: const Text('Tidak, Jangan Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _batalkanReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Ya, Batalkan Review'),
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
                        'Membatalkan review...',
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

/// Widget untuk menampilkan warning item
class _WarningItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _WarningItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
