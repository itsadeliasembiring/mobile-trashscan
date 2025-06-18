import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_wastewise/KenaliSampah/deskripsi_sampah.dart'; 
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model untuk data sampah dalam list
class WasteItem {
  final String idSampah;
  final String namaSampah;
  final String? foto;
  final String idJenisSampah;
  final String namaJenisSampah;
  final String warnaTempat;

  WasteItem({
    required this.idSampah,
    required this.namaSampah,
    this.foto,
    required this.idJenisSampah,
    required this.namaJenisSampah,
    required this.warnaTempat,
  });

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      idSampah: json['id_sampah'] ?? '',
      namaSampah: json['nama_sampah'] ?? '',
      foto: json['foto'],
      idJenisSampah: json['jenis_sampah']['id_jenis_sampah'] ?? '',
      namaJenisSampah: json['jenis_sampah']['nama_jenis_sampah'] ?? '',
      warnaTempat: json['jenis_sampah']['warna_tempat_sampah'] ?? '',
    );
  }
}

class KenaliSampah extends StatefulWidget {
  @override
  _KenaliSampahState createState() => _KenaliSampahState();
}

class _KenaliSampahState extends State<KenaliSampah> {
  File? _image;
  bool _scanning = false;
  bool _scanned = false;
  String _wasteId = '';
  String _wasteType = '';
  String _errorMessage = '';
  
  List<WasteItem> wasteItems = [];
  bool _loadingWasteData = false;

  @override
  void initState() {
    super.initState();
    _loadWasteTypes();
  }

  // Load waste types from Supabase
  Future<void> _loadWasteTypes() async {
    setState(() {
      _loadingWasteData = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('sampah')
          .select('''
            id_sampah,
            nama_sampah,
            foto,
            jenis_sampah (
              id_jenis_sampah,
              nama_jenis_sampah,
              warna_tempat_sampah
            )
          ''')
          .order('nama_sampah');

      setState(() {
        wasteItems = response.map<WasteItem>((item) => WasteItem.fromJson(item)).toList();
        _loadingWasteData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data sampah: $e';
        _loadingWasteData = false;
      });
      print('Error loading waste types: $e');
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _openCamera();
    } else if (status.isDenied) {
      setState(() {
        _errorMessage = 'Izin kamera ditolak. Silakan berikan izin di pengaturan perangkat Anda.';
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage = 'Izin kamera ditolak secara permanen. Silakan aktifkan di pengaturan perangkat Anda.';
      });
      await openAppSettings();
    }
  }

  Future<void> _openCamera() async {
    setState(() {
      _scanning = true;
      _scanned = false;
      _errorMessage = '';
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        
        // Simulasi scanning process 
        await Future.delayed(Duration(seconds: 2));
        
        // Simulasi hasil scan - pilih sampah random dari database
        if (wasteItems.isNotEmpty) {
          final randomWaste = wasteItems[0]; // Atau bisa random
          setState(() {
            _scanning = false;
            _scanned = true;
            _wasteId = randomWaste.idSampah;
            _wasteType = randomWaste.namaSampah;
          });
        } else {
          setState(() {
            _scanning = false;
            _wasteType = 'Botol Plastik'; // Fallback
            _wasteId = 'S01'; // Fallback ID
            _scanned = true;
          });
        }
      } else {
        // User membatalkan kamera
        setState(() {
          _scanning = false;
          _errorMessage = 'Pengambilan gambar dibatalkan';
        });
      }
    } catch (e) {
      setState(() {
        _scanning = false;
        _errorMessage = 'Terjadi kesalahan saat membuka kamera: ${e.toString()}';
      });
    }
  }

  Future<void> _getImage() async {
    // Izin kamera
    await _requestCameraPermission();
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _scanning = true;
      _scanned = false;
      _errorMessage = '';
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        
        // Simulasi scanning process
        await Future.delayed(Duration(seconds: 2));
        
        // Simulasi hasil scan
        if (wasteItems.isNotEmpty) {
          final randomWaste = wasteItems[0];
          setState(() {
            _scanning = false;
            _scanned = true;
            _wasteId = randomWaste.idSampah;
            _wasteType = randomWaste.namaSampah;
          });
        } else {
          setState(() {
            _scanning = false;
            _wasteType = 'Botol Plastik';
            _wasteId = 'S01';
            _scanned = true;
          });
        }
      } else {
        setState(() {
          _scanning = false;
        });
      }
    } catch (e) {
      setState(() {
        _scanning = false;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }
  
  // Input manual dengan data dari Supabase
  void _showManualInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pilih Jenis Sampah",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D8D7A),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Silakan pilih jenis sampah yang ingin Anda ketahui:",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_loadingWasteData) ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF3D8D7A),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Memuat data sampah...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xFF3D8D7A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (wasteItems.isEmpty) ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada data sampah tersedia',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadWasteTypes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3D8D7A),
                              ),
                              child: Text(
                                'Coba Lagi',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: wasteItems.length,
                        itemBuilder: (context, index) {
                          final wasteItem = wasteItems[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DeskripsiSampah(wasteId: wasteItem.idSampah),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: _getWasteColor(wasteItem.warnaTempat),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: _getIconColor(wasteItem.warnaTempat),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          wasteItem.namaSampah,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Jenis: ${wasteItem.namaJenisSampah}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
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
        return Color(0xFF3D8D7A);
    }
  }

  Color _getIconColor(String colorName) {
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
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "Edukasi Sampah",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D8D7A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_image == null) ...[
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF3D8D7A),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 64,
                            color: Color(0xFF3D8D7A),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Arahkan sampah ke kamera\nuntuk di scan",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _getImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3D8D7A),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Buka Kamera",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _showManualInputSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Color(0xFF3D8D7A), width: 1),
                            ),
                          ),
                          child: Text(
                            "Input Manual",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D8D7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _pickFromGallery,
                      icon: Icon(Icons.photo_library, color: Color(0xFF3D8D7A)),
                      label: Text(
                        "Pilih dari Galeri",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF3D8D7A),
                        ),
                      ),
                    ),
                  ] else ...[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 350,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF3D8D7A),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (_scanning)
                          Container(
                            height: 350,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  "Mengidentifikasi sampah...",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (_scanned) ...[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Teridentifikasi : $_wasteType",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DeskripsiSampah(wasteId: _wasteId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3D8D7A),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Lihat Penjelasan",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: _showManualInputSheet,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF3D8D7A)),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Input Manual",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3D8D7A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Scan berhasil! Sampah telah teridentifikasi.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _getImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3D8D7A),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Scan Ulang",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: _showManualInputSheet,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF3D8D7A)),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Input Manual",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3D8D7A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}