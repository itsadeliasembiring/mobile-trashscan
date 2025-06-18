import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_trashscan/KenaliSampah/deskripsi_sampah.dart';

// --- Integrasi Gemini Chatbot ---
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Model untuk data sampah dalam list manual
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
  const KenaliSampah({super.key});

  @override
  _KenaliSampahState createState() => _KenaliSampahState();
}

class _KenaliSampahState extends State<KenaliSampah> {
  // --- KONFIGURASI GEMINI ---
  final String _apiKey = "AIzaSyCYUQwJmn6RIyqr59AFm_cw-JsDX-rM5uM";

  // State untuk data sampah (input manual)
  List<WasteItem> wasteItems = [];
  bool _loadingWasteData = false;

  @override
  void initState() {
    super.initState();
    // Memuat data sampah untuk fitur input manual saat halaman pertama kali dibuka
    _loadWasteTypes();
  }

  // Fungsi untuk memuat data dari Supabase
  Future<void> _loadWasteTypes() async {
    if (!mounted) return;
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

      if (mounted) {
        setState(() {
          wasteItems =
              response.map<WasteItem>((item) => WasteItem.fromJson(item)).toList();
          _loadingWasteData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingWasteData = false;
        });
        print('Error loading waste types: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat data sampah: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // Fungsi untuk menampilkan bottom sheet input manual
  void _showManualInputSheet() {
    if (_loadingWasteData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sedang memuat data sampah, harap tunggu...'),
      ));
      return;
    }
    // Coba muat ulang jika data kosong, untuk memastikan data terbaru
    if (wasteItems.isEmpty) {
      _loadWasteTypes();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
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
                          color: const Color(0xFF3D7F5F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Silakan pilih jenis sampah yang ingin Anda ketahui:",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingWasteData)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF3D7F5F)),
                      ),
                    )
                  else if (wasteItems.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat atau tidak ada data.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _loadWasteTypes().then((_) => setModalState(() {}));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D7F5F)),
                              child: Text('Coba Lagi',
                                  style: GoogleFonts.poppins(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
                                  builder: (_) =>
                                      DeskripsiSampah(wasteId: wasteItem.idSampah),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              margin: const EdgeInsets.only(bottom: 8),
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
                                    child: Icon(Icons.delete_outline,
                                        color: _getIconColor(wasteItem.warnaTempat),
                                        size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          wasteItem.namaSampah,
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          'Jenis: ${wasteItem.namaJenisSampah}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios,
                                      color: Colors.grey, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Fungsi helper warna
  Color _getWasteColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'kuning': return Colors.yellow.shade600;
      case 'hijau': return Colors.green;
      case 'merah': return Colors.red;
      case 'biru': return Colors.blue;
      case 'putih': return Colors.grey.shade200;
      case 'hitam': return Colors.black87;
      default: return const Color(0xFF3D7F5F);
    }
  }

  Color _getIconColor(String colorName) {
     switch (colorName.toLowerCase()) {
      case 'kuning':
      case 'putih':
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "Kenali Sampah",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D7F5F),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Custom Manual Button at the top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: _showManualInputSheet,
              style: OutlinedButton.styleFrom(
                backgroundColor:Color(0xFF3D7F5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                side: const BorderSide(color: Color(0xFF3D7F5F)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "Pilih Sampah Manual",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chat View
          Expanded(
            child: LlmChatView(
              welcomeMessage:
                  "Halo! Saya TrashScan Bot siap membantu Anda. Ajukan pertanyaan seputar sampah dan daur ulang, atau gunakan tombol 'Manual' di atas untuk melihat daftar sampah.",
             
              suggestions: const [
                "Apa itu sampah organik?",
                "Jelaskan konsep 3R!",
                "Bagaimana cara mengolah sampah plastik?",
              ],

              provider: GeminiProvider(
                model: GenerativeModel(
                  model: "gemini-1.5-flash-latest",
                  apiKey: _apiKey,
                  systemInstruction: Content.system(
                    "Anda adalah 'TrashScan Bot', asisten virtual yang ramah dan ahli dalam pengelolaan sampah, daur ulang, dan isu lingkungan di Indonesia. "
                    "Tugas Anda adalah menjawab pertanyaan pengguna HANYA yang berkaitan dengan topik-topik tersebut. "
                    "Jika pengguna bertanya di luar topik (misal: kesehatan, politik, resep masakan), jawab dengan sopan: 'Maaf, saya hanya bisa menjawab pertanyaan seputar pengelolaan sampah dan lingkungan.' "
                    "Berikan jawaban yang jelas, singkat, dan mudah dimengerti."
                  ),
                ),
              ),

              // Use basic styling that's likely to be supported
              style: 
                LlmChatViewStyle(
                  backgroundColor: const Color(0xFFF5F6FA),
                  // bot
                  llmMessageStyle: LlmMessageStyle(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // user
                  userMessageStyle: UserMessageStyle(
                    decoration: BoxDecoration(
                      color: Color(0xFF3D7F5F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),

                  suggestionStyle: SuggestionStyle(
                    decoration: BoxDecoration(
                      color: Color(0xFF3D7F5F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}