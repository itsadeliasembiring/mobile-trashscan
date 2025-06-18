import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../KenaliSampah/kenali_sampah.dart'; 
import '../Artikel/artikel.dart';

class Beranda extends StatelessWidget {
  const Beranda({Key? key}) : super(key: key);

  // Data dummy untuk artikel, sesuaikan dengan data Anda
  final List<Map<String, String>> _articles = const [
    {
      'image': 'assets/waste-wise-artikel.png', // Ganti dengan path aset Anda
      'title': 'TrashScan: Aplikasi Cerdas untuk Deteksi Sampah dan Edukasi Pengelolaan Sampah',
    },
    {
      'image': 'assets/waste-wise-artikel.png', // Ganti dengan path aset Anda
      'title': 'Kelola Sampah dengan Cerdas: Langkah Mudah Menuju Lingkungan Bersih dan Sehat',
    },
    {
      'image': 'assets/waste-wise-artikel.png', // Ganti dengan path aset Anda
      'title': 'Sampah Plastik di Laut Ancam Ekosistem dan Biota Laut',
    },
    {
      'image': 'assets/waste-wise-artikel.png', // Ganti dengan path aset Anda
      'title': 'Aksi Bersih Pantai di Surabaya: Warga dan Relawan Bersatu Demi Laut yang Lebih Bersih',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar (Avatar dan Notifikasi)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      // avatar
                      backgroundImage: AssetImage('assets/maskot-trashscan.png'), // Ganti dengan path avatar Anda
                      backgroundColor: Color(0xFFA3D1C6),
                    ),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(
                          Icons.notifications_none_outlined,
                          size: 32,
                          color: Colors.black54,
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Kartu Selamat Datang
                Stack(
                  children: [
                    // 1. Gambar Latar Belakang Transparan
                    Opacity(
                      opacity: 0.2, // Sesuaikan tingkat transparansi di sini
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/background-container-home-trashscan.png', // Ganti dengan path gambar latar belakang Anda
                          height: 160, // Sesuaikan tinggi sesuai kebutuhan
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // 2. Konten Utama Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.transparent, // Atur warna Card menjadi transparan
                      elevation: 0,
                      margin: EdgeInsets.zero, // Hapus margin default Card jika perlu
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                'assets/maskot-trashscan.png', // Ganti dengan path maskot utama Anda
                                height: 120,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Halo, ',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Mike!',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Ayo Kelola Sampahmu!',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scan, Kenali, dan Kelola',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: const Color(0xFF3D7F5F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Tombol Kenali Sampah
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KenaliSampah()),
                      );
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined, 
                      color: Color(0xFF1E5245),
                      size: 30,
                    ),
                    label: Text(
                      'Kenali Sampah',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E5245),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3D1C6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Bagian Artikel Lingkungan
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Artikel Lingkungan',
                           style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jadilah Bagian dari Solusi, Mulai dari Edukasi!',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Color(0xFF3D7F5F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Daftar Artikel
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _articles.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final article = _articles[index];
                            return _ArticleCard(
                              imagePath: article['image']!,
                              title: article['title']!,
                              onTap: () {
                                 Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Artikel()),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget kustom untuk kartu artikel
class _ArticleCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const _ArticleCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE4F2EE),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Baca Selengkapnya',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3D7F5F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}