import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Providers/points.provider.dart';

// Model terpadu untuk menampilkan semua jenis transaksi.
class TransactionHistory {
  final String id;
  final String type;
  final String title;
  final int points;
  final DateTime dateTime;
  final String? redemptionCode;

  TransactionHistory({
    required this.id,
    required this.type,
    required this.title,
    required this.points,
    required this.dateTime,
    this.redemptionCode,
  });
}

class RiwayatPoin extends StatefulWidget {
  const RiwayatPoin({super.key});

  @override
  State<RiwayatPoin> createState() => _RiwayatPoinState();
}

class _RiwayatPoinState extends State<RiwayatPoin> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<TransactionHistory> _transactionHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadTransactionHistory();
  }

  Future<void> _loadTransactionHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cek apakah user sudah login
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User belum login');
      }

      final userId = user.id;
      print('Loading data for user ID: $userId');

      // Load data secara terpisah dengan error handling individual
      List<TransactionHistory> allTransactions = [];
      
      // 1. Load Item Exchanges
      try {
        final itemExchanges = await _fetchItemExchanges(userId);
        allTransactions.addAll(itemExchanges);
        print('Loaded ${itemExchanges.length} item exchanges');
      } catch (e) {
        print('Error loading item exchanges: $e');
      }

      // 2. Load Donations
      try {
        final donations = await _fetchDonations(userId);
        allTransactions.addAll(donations);
        print('Loaded ${donations.length} donations');
      } catch (e) {
        print('Error loading donations: $e');
      }

      // 3. Load Point History
      try {
        final pointHistory = await _fetchPointHistory(userId);
        allTransactions.addAll(pointHistory);
        print('Loaded ${pointHistory.length} point history');
      } catch (e) {
        print('Error loading point history: $e');
      }

      // Sort berdasarkan tanggal terbaru
      allTransactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      if (mounted) {
        setState(() {
          _transactionHistory = allTransactions;
        });
      }
    } catch (e) {
      print('General error loading transaction history: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat riwayat: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<TransactionHistory>> _fetchItemExchanges(String userId) async {
    try {
      // Query tanpa RLS dulu untuk testing
      final response = await _supabase
          .from('penukaran_barang')
          .select('*, barang:id_barang(nama_barang)')
          .eq('id_pengguna', userId)
          .order('waktu', ascending: false);

      return response.map<TransactionHistory>((item) {
        final barangData = item['barang'] as Map<String, dynamic>?;
        final title = barangData?['nama_barang'] as String? ?? 'Barang Dihapus';

        return TransactionHistory(
          id: item['id_penukaran_barang'].toString(),
          type: 'Barang Ecofriendly',
          title: title,
          points: -(item['jumlah_poin'] as int),
          dateTime: DateTime.parse(item['waktu']),
          redemptionCode: item['kode_redeem'],
        );
      }).toList();
    } catch (e) {
      print('Detailed error in _fetchItemExchanges: $e');
      // Jika error RLS, coba query sederhana
      try {
        final response = await _supabase
            .from('penukaran_barang')
            .select('*')
            .eq('id_pengguna', userId)
            .order('waktu', ascending: false);
        
        return response.map<TransactionHistory>((item) {
          return TransactionHistory(
            id: item['id_penukaran_barang'].toString(),
            type: 'Barang Ecofriendly',
            title: 'Penukaran Barang',
            points: -(item['jumlah_poin'] as int),
            dateTime: DateTime.parse(item['waktu']),
            redemptionCode: item['kode_redeem'],
          );
        }).toList();
      } catch (e2) {
        print('Fallback query also failed: $e2');
        return [];
      }
    }
  }

  Future<List<TransactionHistory>> _fetchDonations(String userId) async {
    try {
      final response = await _supabase
          .from('penukaran_donasi')
          .select('*, donasi:id_donasi(nama_donasi)')
          .eq('id_pengguna', userId)
          .order('waktu', ascending: false);

      return response.map<TransactionHistory>((item) {
        final donasiData = item['donasi'] as Map<String, dynamic>?;
        final title = donasiData?['nama_donasi'] as String? ?? 'Donasi Dihapus';

        return TransactionHistory(
          id: item['id_penukaran_donasi'].toString(),
          type: 'Donasi',
          title: title,
          points: -(item['jumlah_poin'] as int),
          dateTime: DateTime.parse(item['waktu']),
        );
      }).toList();
    } catch (e) {
      print('Error in _fetchDonations: $e');
      return [];
    }
  }

  Future<List<TransactionHistory>> _fetchPointHistory(String userId) async {
    try {
      final response = await _supabase
          .from('riwayat_poin')
          .select('*')
          .eq('id_pengguna', userId)
          .order('waktu', ascending: false);

      return response.map<TransactionHistory>((item) => TransactionHistory(
        id: item['id_riwayat'].toString(),
        type: item['jenis_perubahan'] ?? 'Poin',
        title: item['deskripsi'] ?? 'Perubahan Poin',
        points: item['jumlah_poin'] as int,
        dateTime: DateTime.parse(item['waktu']),
      )).toList();
    } catch (e) {
      print('Error in _fetchPointHistory: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTransactionHistory,
        color: const Color(0xFF3D8D7A),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D8D7A)))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTransactionHistory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D8D7A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : _transactionHistory.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Belum ada riwayat transaksi.'),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: _transactionHistory.map((transaction) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHistoryItem(transaction),
                        )).toList(),
                      ),
      ),
    );
  }

  Widget _buildHistoryItem(TransactionHistory transaction) {
    final dateFormatter = DateFormat('d MMMM yyyy', 'id_ID');
    final timeFormatter = DateFormat('HH:mm', 'id_ID');
    final date = dateFormatter.format(transaction.dateTime);
    final time = timeFormatter.format(transaction.dateTime) + ' WIB';
    final pointsText = transaction.points >= 0 ? '+${transaction.points}' : '${transaction.points}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$date - $time',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/poin.png', width: 20, height: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$pointsText Poin',
                        style: TextStyle(
                          color: transaction.points < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (transaction.redemptionCode != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildRedemptionCodeChip(transaction.redemptionCode!),
            ),
        ],
      ),
    );
  }

  Widget _buildRedemptionCodeChip(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFA3D1C6).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3D8D7A).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 16, color: Color(0xFF3D8D7A)),
          const SizedBox(width: 6),
          Text(
            'Kode Redeem: $code',
            style: const TextStyle(
              color: Color(0xFF3D8D7A),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kode disalin ke clipboard'),
                  backgroundColor: Color(0xFF3D8D7A),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.copy, size: 16, color: Color(0xFF3D8D7A)),
          ),
        ],
      ),
    );
  }
}