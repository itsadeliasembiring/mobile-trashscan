import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../SetorSampah/riwayat_setor_sampah.dart';
import '../SetorSampah/pilih_bank_sampah.dart';
import '../KenaliSampah/kenali_sampah.dart'; 
import '../Artikel/artikel.dart';

final List<Map<String, String>> wasteBankData = [
  {
    'name': 'Bank Sampah Mulyorejo Tengah',
    'address': 'Jl. Mulyorejo Tengah No. 67',
    'distance': '1.4 KM',
    'imagePath': 'assets/default-bank-sampah.png',
  },
  {
    'name': 'Bank Sampah Kalijudan',
    'address': 'Jl. Kalijudan V No. 33D',
    'distance': '2.8 KM',
    'imagePath': 'assets/default-bank-sampah.png',
  },
  {
    'name': 'Bank Sampah Jojoran 1',
    'address': 'Jl. Jojoran 1 Blok Z No. 101',
    'distance': '3.9 KM',
    'imagePath': 'assets/default-bank-sampah.png',
  },
];

class Beranda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/maskot.png'),
                  backgroundColor: Color(0xFFA3D1C6),
                ),
                SizedBox(width: 10), 
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Halo, ',
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Trisna!',
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Color(0xFFA3D1C6),
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Poin terkumpul',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Image.asset(
                                'assets/poin.png',
                                width: 35,
                                height: 35,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '250 Poin',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3D8D7A),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child:   
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const RiwayatSetorSampah(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFD6EFD8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  minimumSize: Size(70, 30), 
                                ),
                                child: Text(
                                  '5 Kg Sampah Terkumpul',
                                  style: TextStyle(color: Color(0xFF3D8D7A), fontSize: 12),
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/recycle-outline.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const PilihBankSampah(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Color(0xFFD6EFD8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: Image.asset(
                          'assets/icon-setor-sampah.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                          'Setor Sampah',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3D8D7A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 7),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              KenaliSampah(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Color(0xFFD6EFD8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: Image.asset(
                          'assets/icon-kenali-sampah.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                          'Kenal Sampah',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3D8D7A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Bank Sampah Terdekat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D8D7A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ubah sampah jadi berkah lewat bank sampah!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), 
                      itemCount: wasteBankData.length,
                      itemBuilder: (context, index) {
                        final wasteBank = wasteBankData[index];
                        return Column(
                          children: [
                            WasteBankCard(
                              name: wasteBank['name']!,
                              address: wasteBank['address']!,
                              distance: wasteBank['distance']!,
                              imagePath: wasteBank['imagePath']!,
                            ),
                            SizedBox(height: 10), 
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
              SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: Colors.white,
                elevation: 4,
                child: 
                  Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 7),
                    child: 
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.asset(
                                    'assets/default-bank-sampah.png', 
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'WasteWise: Inovasi Aplikasi Bank Sampah untuk Lingkungan Lebih Bersih',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child:   
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                                      Artikel(),
                                                  transitionDuration: Duration.zero,
                                                  reverseTransitionDuration: Duration.zero,
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFFD6EFD8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              minimumSize: Size(100, 30), 
                                            ),
                                            child: Text(
                                              'Baca Selengkapnya',
                                              style: TextStyle(color: Color(0xFF3D8D7A), fontSize: 12),
                                            ),
                                          ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  )   
              )
          ],
        ),
      ),
    );
  }
}

class WasteBankCard extends StatelessWidget {
  final String name;
  final String address;
  final String distance;
  final String imagePath;

  const WasteBankCard({
    Key? key,
    required this.name,
    required this.address,
    required this.distance,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFA3D1C6).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, 
            backgroundImage: AssetImage(imagePath), 
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF3D8D7A),
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: const TextStyle(
                    color: Color(0xFF3D8D7A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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