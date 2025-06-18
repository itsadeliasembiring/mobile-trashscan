import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model untuk data sampah
class WasteData {
  final String idSampah;
  final String namaSampah;
  final String deskripsiSampah;
  final String detailCiri;
  final String detailManfaat;
  final int bobotPoin;
  final String? foto;
  final String idJenisSampah;
  final String namaJenisSampah;
  final String warnaTempat;
  final String deskripsiJenis;

  WasteData({
    required this.idSampah,
    required this.namaSampah,
    required this.deskripsiSampah,
    required this.detailCiri,
    required this.detailManfaat,
    required this.bobotPoin,
    this.foto,
    required this.idJenisSampah,
    required this.namaJenisSampah,
    required this.warnaTempat,
    required this.deskripsiJenis,
  });

  factory WasteData.fromJson(Map<String, dynamic> json) {
    return WasteData(
      idSampah: json['id_sampah'] ?? '',
      namaSampah: json['nama_sampah'] ?? '',
      deskripsiSampah: json['deskripsi_sampah'] ?? '',
      detailCiri: json['detail_ciri'] ?? '',
      detailManfaat: json['detail_manfaat'] ?? '',
      bobotPoin: json['bobot_poin'] ?? 0,
      foto: json['foto'],
      idJenisSampah: json['jenis_sampah']['id_jenis_sampah'] ?? '',
      namaJenisSampah: json['jenis_sampah']['nama_jenis_sampah'] ?? '',
      warnaTempat: json['jenis_sampah']['warna_tempat_sampah'] ?? '',
      deskripsiJenis: json['jenis_sampah']['deskripsi_jenis_sampah'] ?? '',
    );
  }
}

class DeskripsiSampah extends StatefulWidget {
  final String wasteId; // Menggunakan ID sampah sebagai parameter

  const DeskripsiSampah({
    Key? key,
    required this.wasteId,
  }) : super(key: key);

  @override
  State<DeskripsiSampah> createState() => _DeskripsiSampahState();
}

class _DeskripsiSampahState extends State<DeskripsiSampah> {
  WasteData? wasteData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    try {
      final response = await Supabase.instance.client
          .from('sampah')
          .select('''
            id_sampah,
            nama_sampah,
            deskripsi_sampah,
            detail_ciri,
            detail_manfaat,
            bobot_poin,
            foto,
            jenis_sampah (
              id_jenis_sampah,
              nama_jenis_sampah,
              warna_tempat_sampah,
              deskripsi_jenis_sampah
            )
          ''')
          .eq('id_sampah', widget.wasteId)
          .single();

      setState(() {
        wasteData = WasteData.fromJson(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "Penjelasan Sampah",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D8D7A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? _buildLoadingWidget()
          : errorMessage != null
              ? _buildErrorWidget()
              : _buildContentWidget(),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF3D8D7A),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Color(0xFF3D8D7A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadWasteData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3D8D7A),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar sampah
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: wasteData!.foto != null
                  ? Image.network(
                      wasteData!.foto!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
            SizedBox(height: 24),
            
            // Nama sampah
            Text(
              wasteData!.namaSampah,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Deskripsi sampah
            Text(
              wasteData!.deskripsiSampah,
              textAlign: TextAlign.justify,
              style: GoogleFonts.poppins(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            
            // Jenis sampah
            Text(
              "Jenis Sampah",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              wasteData!.deskripsiJenis,
              style: GoogleFonts.poppins(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            
            // Warna tempat sampah
            Text(
              "Warna Tempat Sampah",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getWasteColor(wasteData!.warnaTempat),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                wasteData!.warnaTempat,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(wasteData!.warnaTempat),
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Ciri-ciri
            Text(
              "Ciri-ciri:",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoints(wasteData!.detailCiri),
            SizedBox(height: 24),
            
            // Pemanfaatan
            Text(
              "Pemanfaatan:",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildNumberedPoints(wasteData!.detailManfaat),
            SizedBox(height: 24),
            
            // Bobot poin
            //Container(
              //padding: EdgeInsets.all(16),
              //decoration: BoxDecoration(
                //color: Color(0xFF3D8D7A).withOpacity(0.1),
                //borderRadius: BorderRadius.circular(12),
              //),
              //child: Row(
                //children: [
                  //Icon(
                    //Icons.star,
                    //color: Color(0xFF3D8D7A),
                    //size: 24,
                  //),
                  //SizedBox(width: 8),
                  //Text(
                    //"Poin yang didapat: ${wasteData!.bobotPoin}",
                    //style: GoogleFonts.poppins(
                      //fontSize: 16,
                      //fontWeight: FontWeight.w600,
                      //color: Color(0xFF3D8D7A),
                    //),
                  //),
                //],
              //),
            //),
            //SizedBox(height: 32),
            
            // Tombol kembali
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3D8D7A),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Kembali",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoints(String text) {
    List<String> points = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return Column(
      children: points.map((point) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "• ",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  point.trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberedPoints(String text) {
    List<String> points = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return Column(
      children: points.asMap().entries.map((entry) {
        int index = entry.key;
        String point = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${index + 1}. ",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  point.trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getWasteColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'kuning':
        return Colors.yellow;
      case 'hijau':
        return Colors.green;
      case 'merah':
        return Colors.red;
      case 'biru':
        return Colors.blue;
      case 'putih':
        return Colors.white;
      case 'hitam':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'kuning':
      case 'putih':
        return Colors.black87;
      case 'hijau':
      case 'merah':
      case 'biru':
      case 'hitam':
        return Colors.white;
      default:
        return Colors.black87;
    }
  }
}