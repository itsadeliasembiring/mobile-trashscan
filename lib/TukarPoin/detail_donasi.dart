import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_wastewise/Providers/points.provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Data model for Donations from the 'donasi' table.
class Donation {
  final String id;
  final String title;
  final String? description;
  final String imageAsset;
  int totalDonation;

  Donation({
    required this.id,
    required this.title,
    this.description,
    required this.imageAsset,
    required this.totalDonation,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id_donasi'],
      title: json['nama_donasi'],
      description: json['deskripsi_donasi'],
      imageAsset: json['foto'] ?? 'assets/donation-default.png',
      totalDonation: json['total_donasi'] ?? 0,
    );
  }
}


class DetailDonasi extends StatefulWidget {
  final Donation donation;

  const DetailDonasi({
    super.key,
    required this.donation,
  });

  @override
  State<DetailDonasi> createState() => _DetailDonasiState();
}

class _DetailDonasiState extends State<DetailDonasi> {
  final TextEditingController _pointsController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isProcessing = false;

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Future<String> _generateTransactionId() async {
    const table = 'penukaran_donasi';
    const prefix = 'PD';
    const idColumn = 'id_penukaran_donasi';

    final response = await _supabase.from(table).select(idColumn).order(idColumn, ascending: false).limit(1).maybeSingle();

    int nextNumber = 1;
    if (response != null) {
      final lastId = response[idColumn] as String;
      final numberPart = lastId.substring(prefix.length);
      try {
        nextNumber = int.parse(numberPart) + 1;
      } catch (e) {
        print('Could not parse ID number: $e');
        nextNumber = DateTime.now().millisecondsSinceEpoch % 1000;
      }
    }
    return '$prefix${nextNumber.toString().padLeft(2, '0')}';
  }

  Future<void> _processDonation(int points, PointsProvider pointsProvider) async {
    setState(() => _isProcessing = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Pengguna tidak terautentikasi');

      final transactionId = await _generateTransactionId();

      await _supabase.from('penukaran_donasi').insert({
        'id_penukaran_donasi': transactionId,
        'waktu': DateTime.now().toIso8601String(),
        'jumlah_poin': points,
        'id_pengguna': userId,
        'id_donasi': widget.donation.id,
      });

      final newTotalDonation = widget.donation.totalDonation + points;
      await _supabase.from('donasi').update({'total_donasi': newTotalDonation}).eq('id_donasi', widget.donation.id);

      final newTotalPoints = pointsProvider.totalPoints - points;
      await _supabase.from('pengguna').update({'total_poin': newTotalPoints}).eq('id_pengguna', userId);

      await pointsProvider.fetchPoints();

      setState(() {
        widget.donation.totalDonation = newTotalDonation;
      });

      _showSuccessDialog(points);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melakukan donasi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Donasi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF3D8D7A))),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      widget.donation.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFA3D1C6), child: const Center(child: Icon(Icons.volunteer_activism, size: 80, color: Color(0xFF3D8D7A)))),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.donation.title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF3D8D7A))),
                    const SizedBox(height: 16),
                    Text('Total Donasi Terkumpul', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('${widget.donation.totalDonation} Poin', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showDonationInputDialog(pointsProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D8D7A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Donasi Sekarang', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    if (widget.donation.description != null && widget.donation.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Deskripsi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.donation.description!, textAlign: TextAlign.justify, style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, height: 1.5)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  void _showDonationInputDialog(PointsProvider pointsProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Jumlah Donasi', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3D8D7A)))),
              const SizedBox(height: 16),
              TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah poin',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: Padding(padding: const EdgeInsets.only(right: 12.0), child: Image.asset('assets/poin.png', width: 20, height: 20)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Poin tersedia: ${pointsProvider.totalPoints}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final points = int.tryParse(_pointsController.text) ?? 0;
                    if (points <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan jumlah poin yang valid'), backgroundColor: Colors.red));
                      return;
                    }
                    Navigator.pop(context);
                    _showConfirmationDialog(points, pointsProvider);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3D8D7A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Donasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(int points, PointsProvider pointsProvider) {
    if (points > pointsProvider.totalPoints) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Center(child: Text('Poin Tidak Cukup', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red))),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 70),
                const SizedBox(height: 16),
                Text('Poin Anda tidak mencukupi untuk donasi sebesar $points poin.', textAlign: TextAlign.center),
              ]),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup', style: TextStyle(color: Color(0xFF3D8D7A))))]));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(child: Text('Konfirmasi Donasi', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3D8D7A)))),
        content: Text('Apakah Anda yakin ingin mendonasikan $points poin untuk ${widget.donation.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () {
            Navigator.pop(context);
            _processDonation(points, pointsProvider);
          }, child: const Text('Donasi', style: TextStyle(color: Color(0xFF3D8D7A)))),
        ],
      ),
    );
  }

  void _showSuccessDialog(int points) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(child: Text('Donasi Berhasil', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3D8D7A)))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF3D8D7A), size: 70),
            const SizedBox(height: 16),
            Text('Terima kasih telah mendonasikan $points poin untuk ${widget.donation.title}', textAlign: TextAlign.center),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Selesai', style: TextStyle(color: Color(0xFF3D8D7A))),
          ),
        ],
      ),
    );
  }
}