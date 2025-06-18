import 'package:flutter/material.dart';
import './riwayat_poin.dart';
import './detail_donasi.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class Transaction {
  final String type;
  final String title;
  final int points;
  final DateTime dateTime;
  final String? redemptionCode; 

  Transaction({
    required this.type,
    required this.title,
    required this.points,
    required this.dateTime,
    this.redemptionCode, 
  });
}

class Donation {
  final String title;
  final String address;
  final String description;
  final String imageAsset;
  final int totalDonation;

  Donation({
    required this.title,
    required this.address,
    required this.description,
    required this.imageAsset,
    required this.totalDonation,
  });
}

class EcoItem {
  final String title;
  final int points;
  final String imageAsset;

  EcoItem({
    required this.title,
    required this.points,
    required this.imageAsset,
  });
}

class TukarPoin extends StatefulWidget {
  const TukarPoin({super.key});

  @override
  State<TukarPoin> createState() => _TukarPoinState();
}

class _TukarPoinState extends State<TukarPoin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int totalPoints = 308;
  // List to store transaction history
  List<Transaction> transactions = [];

  // List of donation data
  final List<Donation> _donations = [
    Donation(
      title: "Panti Asuhan Harapan Sejahtera",
      address: "Jl. Raya Manyar No. 32, Kel. Manyar Sabrangan, Kec. Mulyorejo, Surabaya 60116",
      description: "Puluhan tahun para siswa dan guru belajar mengajar dalam bangunan sekolah yang sesak. Berlantai, berdinding dan berjendela papan kayu seakan menjadi teman akrab dalam menyenyam pendidikan di pelosok Indonesia. Salah satunya di MI Nurul Huda Desa Pulau Palas, Kec. Tembilahan Hulu Kab. Indragiri Hilir, Riau.\n\nBangunan panggung yang berada di tengah-tengah areal perkebunan kelapa ini berdiri sejak tahun 1989 atas swadaya masyarakat, dan hingga saat ini belum pernah mendapatkan bantuan baik sarana dan prasarana.",
      imageAsset: 'assets/donation-default.png',
      totalDonation: 3456,
    ),
    Donation(
      title: "Panti Asuhan Cahaya Hati",
      address: "Jl. Raya Keputih Barat No. 12, Kel. Keputih Timur, Kec. Rungkut, Surabaya 60298",
      description: "Panti Asuhan Cahaya Hati didirikan pada tahun 2005 oleh Yayasan Cahaya Kasih. Panti ini menampung lebih dari 45 anak yatim piatu dari berbagai usia dan latar belakang. Mereka membutuhkan bantuan untuk biaya pendidikan, makanan, dan fasilitas yang lebih baik.\n\nDalam beberapa tahun terakhir, jumlah anak yang ditampung terus bertambah namun dana yang tersedia sangat terbatas. Bantuan dari para donatur sangat berarti untuk memastikan anak-anak ini mendapatkan pendidikan dan kehidupan yang layak.",
      imageAsset: 'assets/donation-default.png',
      totalDonation: 2845,
    ),
  ];
  
  final List<EcoItem> _ecoItems = [
    EcoItem(title: "Tempat Minum Stainless Steel", points: 110, imageAsset: 'assets/botol-minum.png'),
    EcoItem(title: "Gelas dari Bahan Bambu", points: 90, imageAsset: 'assets/gelas-bambu.png'),
    EcoItem(title: "Tote Bag Ramah Lingkungan", points: 75, imageAsset: 'assets/tote-bag.png'),
    EcoItem(title: "Alat Makan dari Bahan Kayu", points: 86, imageAsset: 'assets/alat-makan.png'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    transactions = [
      Transaction(
        type: "Donasi",
        title: "Panti Asuhan Harapan Sejahtera",
        points: -100,
        dateTime: DateTime(2025, 2, 2, 7, 30),
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
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
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                          child: Image.asset('assets/poin.png', width: 16, height: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$totalPoints Poin",
                          style: const TextStyle(color: Color(0xFF3D8D7A), fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
                ),
                child: SizedBox(
                  height: 40,
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
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTukarPoinTab(),
                    RiwayatPoin(totalPoints: totalPoints, transactions: transactions),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTukarPoinTab() {
    return ListView(
      children: [
        const Text('Donasi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3D8D7A))),
        const SizedBox(height: 16),
        ..._donations.map((donation) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDonationItem(donation),
            )),
        const SizedBox(height: 24),
        const Text('Barang Ramah Lingkungan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3D8D7A))),
        const SizedBox(height: 16),
        ..._ecoItems.map((item) => _buildEcoItem(item)),
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
              child: Image.asset(
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
                      Text(donation.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        donation.address,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => DetailDonasi(
                        //   donation: donation,
                        //   addTransaction: (transaction) {
                        //     setState(() {
                        //       // Decrease user's points (transaction.points is negative, so we add it)
                        //       totalPoints += transaction.points;
                              
                        //       // Add donation transaction to history
                        //       transactions.insert(0, transaction);
                        //     });
                        //   },
                        // ),
                        builder: (context) => DetailDonasi(
                          donation: donation,
                          totalPoints: totalPoints, // ✅ tambahkan ini
                          addTransaction: (transaction) {
                            setState(() {
                              totalPoints += transaction.points;
                              transactions.insert(0, transaction);
                            });
                          },
                        ),
                      ),
                    );
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

  Widget _buildEcoItem(EcoItem item) {
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
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
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showTukarDialog(item.title, item.points),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF609966),
              side: const BorderSide(color: Color(0xFF609966)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(0, 35),
            ),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  void _showTukarDialog(String title, int points) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text('Tukar Poin', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3D8D7A))),
        ),
        content: Text('Apakah Anda yakin ingin menukar $points poin untuk $title?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (totalPoints >= points) {
                // Generate a random redemption code
                final String redemptionCode = _generateRedemptionCode();
                
                setState(() {
                  totalPoints -= points;

                  // Add transaction to history with redemption code
                  transactions.insert(0, Transaction(
                    type: 'Barang Ecofriendly',
                    title: title,
                    points: -points,
                    dateTime: DateTime.now(),
                    redemptionCode: redemptionCode, // Include the redemption code
                  ));
                });
                
                // Show bottom sheet with redemption code
                _showRedemptionCodeBottomSheet(title, points, redemptionCode);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Berhasil menukar poin untuk $title'), backgroundColor: Color(0xFF3D8D7A)),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Center(
                      child: Text('Poin Tidak Cukup', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                    ),
                    backgroundColor: Colors.white,
                    content: 
                      Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Icon(Icons.close, color: Colors.red, size: 70),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Poin Anda tidak mencukupi untuk melakukan penukaran ini.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),    
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child:  const Text('Tutup', style: TextStyle(color: Color(0xFF3D8D7A)))
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Tukar', style: TextStyle(color: Color(0xFF3D8D7A))),
          ),
        ],
      ),
    );
  }

  // Generate a random alphanumeric redemption code
  String _generateRedemptionCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    
    // Generate a code in format: XXXX-XXXX-XXXX
    String part1 = '';
    String part2 = '';
    String part3 = '';
    
    for (int i = 0; i < 4; i++) {
      part1 += chars[random.nextInt(chars.length)];
      part2 += chars[random.nextInt(chars.length)];
      part3 += chars[random.nextInt(chars.length)];
    }
    
    return '$part1-$part2-$part3';
  }

  void _showRedemptionCodeBottomSheet(String title, int points, String code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF3D8D7A),
                      size: 70,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Penukaran Berhasil!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D8D7A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '- $points poin',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tunjukkan kode redeem ini kepada petugas:',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF3D8D7A)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFA3D1C6).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Color(0xFF3D8D7A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kode disalin ke clipboard'),
                                  backgroundColor: Color(0xFF3D8D7A),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.copy,
                              color: Color(0xFF3D8D7A),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to history tab
                          _tabController.animateTo(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D8D7A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Lihat Riwayat Penukaran'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}