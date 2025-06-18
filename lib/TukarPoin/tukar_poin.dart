import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_wastewise/Providers/points.provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import './riwayat_poin.dart';
import './detail_donasi.dart'; // Pastikan path ini benar

// Data model for Eco-friendly items from the 'barang' table.
class EcoItem {
  final String id;
  final String title;
  final int points;
  final String imageAsset;
  int stock;
  final String? description;

  EcoItem({
    required this.id,
    required this.title,
    required this.points,
    required this.imageAsset,
    required this.stock,
    this.description,
  });

  factory EcoItem.fromJson(Map<String, dynamic> json) {
    return EcoItem(
      id: json['id_barang'],
      title: json['nama_barang'],
      points: json['bobot_poin'],
      imageAsset: json['foto'] ?? 'assets/fallback.png', // Fallback image
      stock: json['stok'],
      description: json['deskripsi_barang'],
    );
  }
}

class TukarPoin extends StatefulWidget {
  const TukarPoin({super.key});

  @override
  State<TukarPoin> createState() => _TukarPoinState();
}

class _TukarPoinState extends State<TukarPoin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Donation> _donations = [];
  List<EcoItem> _ecoItems = [];
  bool _isLoading = true;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Updated initState to properly initialize points
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _refreshData();
      }
    });
  }

  Future<void> _initializeData() async {
    // Initialize points provider first
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    await pointsProvider.fetchPoints();
    
    // Then load other data
    await _loadData();
  }

  // Updated _refreshData method
  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      // Refresh points from database
      await Provider.of<PointsProvider>(context, listen: false).fetchPoints();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadDonations(), _loadEcoItems()]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
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

  Future<void> _loadDonations() async {
    final response = await _supabase.from('donasi').select('*').order('nama_donasi');
    if (mounted) {
      // Perlu membuat object Donation dari file detail_donasi.dart
      _donations = response.map((item) => Donation.fromJson(item)).toList();
    }
  }

  Future<void> _loadEcoItems() async {
    final response = await _supabase
        .from('barang')
        .select('*')
        .gt('stok', 0)
        .order('nama_barang');
    if (mounted) {
      _ecoItems = response.map((item) => EcoItem.fromJson(item)).toList();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildHeader(pointsProvider),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D8D7A)))
                        : RefreshIndicator(
                            onRefresh: _refreshData,
                            color: const Color(0xFF3D8D7A),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildTukarPoinTab(pointsProvider),
                                const RiwayatPoin(),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(PointsProvider pointsProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tukar Poin',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3D8D7A)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFA3D1C6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Image.asset('assets/poin.png', width: 20, height: 20),
                const SizedBox(width: 8),
                Text(
                  "${pointsProvider.totalPoints} Poin",
                  style: const TextStyle(color: Color(0xFF3D8D7A), fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [Tab(text: 'Tukar Poin'), Tab(text: 'Riwayat Tukar')],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        indicator: BoxDecoration(
          color: const Color(0xFF3D8D7A),
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTukarPoinTab(PointsProvider pointsProvider) {
    return ListView(
      children: [
        const Text('Donasi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3D8D7A))),
        const SizedBox(height: 16),
        if (_donations.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Tidak ada donasi tersedia', style: TextStyle(color: Colors.grey)))),
        ..._donations.map((donation) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDonationItem(donation),
            )),
        const SizedBox(height: 24),
        const Text('Barang Ramah Lingkungan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3D8D7A))),
        const SizedBox(height: 16),
        if (_ecoItems.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Tidak ada barang tersedia', style: TextStyle(color: Colors.grey)))),
        ..._ecoItems.map((item) => _buildEcoItem(item, pointsProvider)),
      ],
    );
  }

  Widget _buildDonationItem(Donation donation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: Image.network(
                donation.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset('assets/donation-default.png', fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donation.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (donation.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          donation.description!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Total donasi: ${donation.totalDonation} poin',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailDonasi(donation: donation),
                      ),
                    ).then((_) => _refreshData());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF609966),
                    side: const BorderSide(color: Color(0xFF609966)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(0, 35),
                  ),
                  child: const Text('Donasi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoItem(EcoItem item, PointsProvider pointsProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                item.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset('assets/fallback.png', fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Image.asset('assets/poin.png', width: 18, height: 18),
                    const SizedBox(width: 4),
                    Text('${item.points} poin', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${item.stock}',
                  style: TextStyle(
                    color: item.stock > 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: item.stock > 0 ? () => _showTukarDialog(item, pointsProvider) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF609966),
              side: const BorderSide(color: Color(0xFF609966)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(0, 35),
            ),
            child: Text(item.stock > 0 ? 'Tukar' : 'Habis'),
          ),
        ],
      ),
    );
  }

  // =================== PERBAIKAN UTAMA UNTUK PENUKARAN BARANG ===================
  
  // 1. PERBAIKI ID GENERATION - sesuaikan dengan constraint database
  Future<String> _generateTransactionId(String table, String prefix) async {
    String idColumn;
    int padLength;
    
    switch (table) {
      case 'penukaran_barang':
        idColumn = 'id_penukaran_barang';
        padLength = 2; // Total 4 karakter: PB + 2 digit (PB01, PB02, dst)
        break;
      case 'riwayat_poin':
        idColumn = 'id_riwayat';
        padLength = 3; // Total 5 karakter: RP + 3 digit (RP001, RP002, dst)
        break;
      default:
        throw Exception('Unknown table: $table');
    }

    try {
      // Ambil ID terakhir dengan timeout lebih pendek
      final response = await _supabase
          .from(table)
          .select(idColumn)
          .order(idColumn, ascending: false)
          .limit(1)
              .timeout(const Duration(seconds: 8));
    
          Map<String, dynamic>? responseSingle;
          if (response is List && response.isNotEmpty) {
            responseSingle = response.first;
          } else if (response is Map<String, dynamic>) {
            responseSingle = response as Map<String, dynamic>?;
          } else {
            responseSingle = null;
          }

      int nextNumber = 1;
      if (responseSingle != null) {
        final lastId = responseSingle[idColumn] as String;
        final numberPart = lastId.substring(prefix.length);
        try {
          nextNumber = int.parse(numberPart) + 1;
        } catch (e) {
          print("Could not parse ID number: $e, using fallback");
          nextNumber = DateTime.now().millisecondsSinceEpoch % 100 + 1;
        }
      }
      
      final newId = '$prefix${nextNumber.toString().padLeft(padLength, '0')}';
      print("Generated ID: $newId");
      return newId;
    } catch (e) {
      print("Error generating transaction ID: $e");
      // Fallback dengan timestamp yang lebih pendek
      final timestamp = DateTime.now().millisecondsSinceEpoch % 100;
      final fallbackId = '$prefix${timestamp.toString().padLeft(padLength, '0')}';
      print("Using fallback ID: $fallbackId");
      return fallbackId;
    }
  }

  // 2. PERBAIKI REDEMPTION CODE GENERATION - maksimal 10 karakter
  Future<String> _generateRedemptionCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String code;
    int attempts = 0;
    const maxAttempts = 5;
    
    while (attempts < maxAttempts) {
      // Generate 8-character code (sesuai constraint VARCHAR(10))
      final random = DateTime.now().microsecondsSinceEpoch + attempts;
      code = String.fromCharCodes(Iterable.generate(
        8, (i) => chars.codeUnitAt((random + i) % chars.length)
      ));
      
      try {
        // Cek apakah code sudah ada dengan timeout pendek
        final existingList = await _supabase
            .from('penukaran_barang')
            .select('kode_redeem')
            .eq('kode_redeem', code)
            .timeout(const Duration(seconds: 5));
        
        if (existingList == null || (existingList is List && existingList.isEmpty)) {
          print("Generated redemption code: $code");
          return code;
        }
        attempts++;
      } catch (e) {
        print("Error checking redemption code: $e");
        // Jika ada error, gunakan code yang sudah digenerate
        print("Using generated code due to check error: $code");
        return code;
      }
    }
    
    // Fallback dengan timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fallbackCode = timestamp.toString().substring(timestamp.toString().length - 8);
    print("Using timestamp fallback code: $fallbackCode");
    return fallbackCode;
  }

  // 3. PERBAIKI PROSES EXCHANGE DENGAN LOGGING DETAIL
  Future<void> _processExchange(EcoItem item, PointsProvider pointsProvider) async {
    print("\n=== MEMULAI PROSES EXCHANGE ===");
    print("Item: ${item.title}, Points: ${item.points}, Stock: ${item.stock}");
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Validasi koneksi
      print("1. Validating connection...");
      final isConnected = await _validateConnection();
      if (!isConnected) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      print("✓ Connection OK");

      // 2. Validasi autentikasi
      print("2. Validating authentication...");
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Sesi berakhir. Silakan login kembali.');
      }
      print("✓ User ID: $userId");

      // 3. Refresh dan validasi poin
      print("3. Validating points...");
      await pointsProvider.fetchPoints();
      if (pointsProvider.totalPoints < item.points) {
        throw Exception('Poin tidak mencukupi. Dibutuhkan: ${item.points}, Tersedia: ${pointsProvider.totalPoints}');
      }
      print("✓ Points OK: ${pointsProvider.totalPoints} >= ${item.points}");

      // 4. Generate ID dan kode
      print("4. Generating transaction data...");
      final transactionId = await _generateTransactionId('penukaran_barang', 'PB');
      final redemptionCode = await _generateRedemptionCode();
      print("✓ Transaction ID: $transactionId");
      print("✓ Redemption Code: $redemptionCode");

      // 5. Execute transaction
      print("5. Executing transaction...");
      await _executeItemExchange(
        transactionId: transactionId,
        userId: userId,
        itemId: item.id,
        points: item.points,
        redemptionCode: redemptionCode,
        itemTitle: item.title,
      );

      // 6. Refresh data
      print("6. Refreshing data...");
      await pointsProvider.fetchPoints();
      await _loadEcoItems();
      
      print("✓ EXCHANGE COMPLETED SUCCESSFULLY");
      
      // 7. Tampilkan hasil
      if (mounted) {
        _showRedemptionCodeBottomSheet(item.title, item.points, redemptionCode);
      }

    } catch (e) {
      print("❌ EXCHANGE FAILED: $e");
      
      if (mounted) {
        String errorMessage = _getExchangeErrorMessage(e.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Detail',
              textColor: Colors.white,
              onPressed: () {
                // Tampilkan detail error untuk debugging
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Detail Error'),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 4. PERBAIKI EXECUTE TRANSACTION DENGAN STEP-BY-STEP VALIDATION
  Future<void> _executeItemExchange({
    required String transactionId,
    required String userId,
    required String itemId,
    required int points,
    required String redemptionCode,
    required String itemTitle,
  }) async {
    
    print("\n--- EXECUTING TRANSACTION ---");
    
    // Store untuk rollback
    int? originalUserPoints;
    int? originalItemStock;
    
    try {
      // STEP 1: Ambil data user dengan validasi
      print("Step 1: Getting user data...");
      final userResponse = (await _supabase
          .from('pengguna')
          .select('total_poin')
          .eq('id_pengguna', userId)
          .timeout(const Duration(seconds: 10)))[0];
      
      originalUserPoints = userResponse['total_poin'] as int;
      print("✓ User points: $originalUserPoints");
      
      if (originalUserPoints < points) {
        throw Exception('Poin berubah! Dibutuhkan: $points, Tersedia: $originalUserPoints');
      }

      // STEP 2: Ambil data barang dengan validasi
      print("Step 2: Getting item data...");
      final itemResponse = (await _supabase
          .from('barang')
          .select('stok, nama_barang')
          .eq('id_barang', itemId)
          .timeout(const Duration(seconds: 10)))[0];
      
      originalItemStock = itemResponse['stok'] as int;
      final itemName = itemResponse['nama_barang'] as String;
      print("✓ Item stock: $originalItemStock, Name: $itemName");
      
      if (originalItemStock <= 0) {
        throw Exception('Stok habis! Stok tersedia: $originalItemStock');
      }

      // STEP 3: Update stock barang
      print("Step 3: Updating item stock...");
      final stockUpdateResult = await (_supabase
          .from('barang')
          .update({'stok': originalItemStock - 1})
          .eq('id_barang', itemId)
          .eq('stok', originalItemStock) // Optimistic locking
          .timeout(const Duration(seconds: 15)));
      final stockUpdate = await stockUpdateResult.select();
      
      if (stockUpdateResult.isEmpty) {
        throw Exception('Gagal update stok - barang sedang ditukar pengguna lain');
      }
      print("✓ Stock updated: ${originalItemStock - 1}");

      // STEP 4: Update poin user
      print("Step 4: Updating user points...");
      final pointsUpdateResult = await _supabase
          .from('pengguna')
          .update({'total_poin': originalUserPoints - points})
          .eq('id_pengguna', userId)
          .eq('total_poin', originalUserPoints) // Optimistic locking
          .timeout(const Duration(seconds: 15))
          .select();

      if (pointsUpdateResult.isEmpty) {
        print("❌ Points update failed, rolling back stock...");
        // Rollback stock
        await _supabase
            .from('barang')
            .update({'stok': originalItemStock})
            .eq('id_barang', itemId)
            .timeout(const Duration(seconds: 10));
        
        throw Exception('Gagal update poin - poin Anda mungkin telah berubah');
      }
      print("✓ Points updated: ${originalUserPoints - points}");

      // STEP 5: Insert ke penukaran_barang
      print("Step 5: Inserting exchange record...");
      final exchangeData = {
        'id_penukaran_barang': transactionId,
        'waktu': DateTime.now().toIso8601String(),
        'jumlah_poin': points,
        'kode_redeem': redemptionCode,
        'id_pengguna': userId,
        'id_barang': itemId,
      };
      
      print("Exchange data: $exchangeData");
      
      final exchangeResult = await _supabase
          .from('penukaran_barang')
          .insert(exchangeData)
          .timeout(const Duration(seconds: 15))
          .select();
      
      print("✓ Exchange record inserted: ${exchangeResult.length} rows");

      // STEP 6: Insert ke riwayat_poin
      print("Step 6: Inserting point history...");
      final historyId = await _generateTransactionId('riwayat_poin', 'RP');
      final historyData = {
        'id_riwayat': historyId,
        'waktu': DateTime.now().toIso8601String(),
        'jenis_perubahan': 'penukaran_barang',
        'jumlah_poin': -points,
        'id_pengguna': userId,
      };
      
      print("History data: $historyData");
      
      final historyResult = await _supabase
          .from('riwayat_poin')
          .insert(historyData)
          .timeout(const Duration(seconds: 15))
          .select();
      
      print("✓ History record inserted: ${historyResult.length} rows");
      
      print("✅ TRANSACTION COMPLETED SUCCESSFULLY");

    } catch (e) {
      print("❌ TRANSACTION FAILED: $e");
      
      // Rollback jika diperlukan
      if (originalUserPoints != null && originalItemStock != null) {
        print("🔄 Attempting rollback...");
        try {
          await Future.wait([
            _supabase
                .from('pengguna')
                .update({'total_poin': originalUserPoints})
                .eq('id_pengguna', userId)
                .timeout(const Duration(seconds: 10)),
            _supabase
                .from('barang')
                .update({'stok': originalItemStock})
                .eq('id_barang', itemId)
                .timeout(const Duration(seconds: 10)),
          ]);
          print("✓ Rollback completed");
        } catch (rollbackError) {
          print("❌ Rollback failed: $rollbackError");
        }
      }
      
      rethrow; // Re-throw untuk handling di level atas
    }
  }

  // 5. TAMBAHKAN METODE UNTUK VALIDATE CONNECTION
  Future<bool> _validateConnection() async {
    try {
      print('Testing database connection...');
      await _supabase
          .from('pengguna')
          .select('count')
          .limit(1)
          .timeout(const Duration(seconds: 8));
      
      print('✓ Database connection OK');
      return true;
    } catch (e) {
      print('❌ Database connection failed: $e');
      return false;
    }
  }

  // 6. PERBAIKI ERROR MESSAGE HANDLING
  String _getExchangeErrorMessage(String errorString) {
    print("Processing error: $errorString");
    
    if (errorString.contains('Sesi berakhir')) {
      return 'Sesi berakhir. Silakan login kembali.';
    } else if (errorString.contains('Poin tidak mencukupi')) {
      return 'Poin Anda tidak mencukupi untuk penukaran ini.';
    } else if (errorString.contains('Stok habis')) {
      return 'Maaf, stok barang sudah habis.';
    } else if (errorString.contains('sedang ditukar')) {
      return 'Barang sedang ditukar pengguna lain. Silakan coba lagi.';
    } else if (errorString.contains('poin Anda mungkin telah berubah')) {
      return 'Poin Anda berubah saat transaksi. Silakan coba lagi.';
    } else if (errorString.contains('connection') || errorString.contains('server')) {
      return 'Masalah koneksi server. Periksa internet dan coba lagi.';
    } else if (errorString.contains('timeout')) {
      return 'Transaksi timeout. Silakan coba lagi.';
    } else if (errorString.contains('permission')) {
      return 'Tidak memiliki izin untuk transaksi ini.';
    } else {
      return 'Terjadi kesalahan: ${errorString.length > 100 ? errorString.substring(0, 100) + "..." : errorString}';
    }
  }

  // Updated _showTukarDialog with better validation
  void _showTukarDialog(EcoItem item, PointsProvider pointsProvider) {
    // Check points in real-time
    if (pointsProvider.totalPoints < item.points) {
      _showInsufficientPointsDialog(item, pointsProvider);
      return;
    }
    
    if (item.stock <= 0) {
      _showOutOfStockDialog(item);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.swap_horiz, color: Color(0xFF3D8D7A), size: 24),
              SizedBox(width: 8),
              Text(
                'Konfirmasi Penukaran',
                style: TextStyle(
                  color: Color(0xFF3D8D7A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F8F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(
                          item.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/fallback.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Image.asset('assets/poin.png', width: 16, height: 16),
                              SizedBox(width: 4),
                              Text(
                                '${item.points} poin',
                                style: TextStyle(
                                  color: Color(0xFF3D8D7A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Poin Anda saat ini:'),
                        Text(
                          '${pointsProvider.totalPoints} poin',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Akan dikurangi:'),
                        Text(
                          '${item.points} poin',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sisa poin:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${pointsProvider.totalPoints - item.points} poin',
                          style: TextStyle(
                            color: Color(0xFF3D8D7A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Setelah penukaran berhasil, Anda akan mendapatkan kode redeem untuk mengambil barang.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processExchange(item, pointsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3D8D7A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Tukar Sekarang'),
            ),
          ],
        );
      },
    );
  }

  void _showInsufficientPointsDialog(EcoItem item, PointsProvider pointsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'Poin Tidak Mencukupi',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Poin Anda tidak mencukupi untuk menukar barang ini.'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Poin dibutuhkan:'),
                        Text(
                          '${item.points} poin',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Poin Anda:'),
                        Text(
                          '${pointsProvider.totalPoints} poin',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kekurangan:'),
                        Text(
                          '${item.points - pointsProvider.totalPoints} poin',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showOutOfStockDialog(EcoItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Stok Habis',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text('Maaf, stok untuk barang "${item.title}" sudah habis.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showRedemptionCodeBottomSheet(String itemTitle, int points, String code) {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF3D8D7A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF3D8D7A),
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                'Penukaran Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D8D7A),
                ),
              ),
              SizedBox(height: 8),
              
              Text(
                'Anda berhasil menukar $points poin untuk "$itemTitle"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              
              // Redemption code section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF3D8D7A).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Kode Redeem Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF3D8D7A)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            code,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3D8D7A),
                              letterSpacing: 2,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kode redeem berhasil disalin'),
                                  backgroundColor: Color(0xFF3D8D7A),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(Icons.copy, color: Color(0xFF3D8D7A)),
                            tooltip: 'Salin kode',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              // Instructions
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tunjukkan kode redeem ini kepada petugas untuk mengambil barang Anda. Kode ini dapat dilihat di riwayat penukaran.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _tabController.animateTo(1); // Go to history tab
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF3D8D7A),
                        side: BorderSide(color: Color(0xFF3D8D7A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Lihat Riwayat'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3D8D7A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Selesai'),
                    ),
                  ),
                ],
              ),
              
              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}

extension on Future {
  select() {}
}