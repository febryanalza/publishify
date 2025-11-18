import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/percetakan.dart';
import 'package:publishify/widgets/percetakan_card.dart';

class PilihPercetakanPage extends StatefulWidget {
  const PilihPercetakanPage({super.key});

  @override
  State<PilihPercetakanPage> createState() => _PilihPercetakanPageState();
}

class _PilihPercetakanPageState extends State<PilihPercetakanPage> {
  List<Percetakan> _percetakanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading from cache/API
    await Future.delayed(const Duration(milliseconds: 500));

    // Load dummy data
    _percetakanList = Percetakan.getDummyData();

    setState(() {
      _isLoading = false;
    });
  }

  void _handlePercetakanTap(Percetakan percetakan) {
    showDialog(
      context: context,
      builder: (context) => _PercetakanDetailDialog(percetakan: percetakan),
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
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cetak',
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle, color: AppTheme.white),
            onPressed: () {
              // Random shuffle
              setState(() {
                _percetakanList.shuffle();
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                  )
                : _percetakanList.isEmpty
                    ? _buildEmptyState()
                    : _buildPercetakanGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildPercetakanGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Adjust ratio for card height
      ),
      itemCount: _percetakanList.length,
      itemBuilder: (context, index) {
        final percetakan = _percetakanList[index];
        return PercetakanCard(
          percetakan: percetakan,
          onTap: () => _handlePercetakanTap(percetakan),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.print_disabled,
            size: 80,
            color: AppTheme.greyText,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada percetakan tersedia',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.greyText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Dialog
class _PercetakanDetailDialog extends StatelessWidget {
  final Percetakan percetakan;

  const _PercetakanDetailDialog({required this.percetakan});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    percetakan.nama,
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                percetakan.imageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 150,
                    color: AppTheme.greyBackground,
                    child: Icon(
                      Icons.print,
                      size: 60,
                      color: AppTheme.greyText,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Rating
            if (percetakan.rating != null)
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 20,
                    color: AppTheme.yellow,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    percetakan.rating!.toStringAsFixed(1),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${percetakan.jumlahReview ?? 0} review)',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    percetakan.alamat,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyText,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Phone
            if (percetakan.telepon != null)
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 20,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    percetakan.telepon!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Description
            if (percetakan.deskripsi != null) ...[
              Text(
                'Deskripsi',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                percetakan.deskripsi!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyText,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to print history or confirmation
                  Navigator.pushNamed(context, '/print');
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('Pilih Percetakan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
