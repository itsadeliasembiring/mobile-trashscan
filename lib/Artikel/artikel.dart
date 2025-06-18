import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_wastewise/Artikel/detail_artikel.dart';
import 'package:mobile_wastewise/KenaliSampah/kenali_sampah.dart';
import 'package:intl/intl.dart';

class Artikel extends StatefulWidget {
  @override
  _ArtikelState createState() => _ArtikelState();
}

class _ArtikelState extends State<Artikel> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> artikelList = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadArtikels();
  }

  Future<void> _loadArtikels() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Query dengan join ke tabel bank_sampah untuk mendapatkan nama penulis dan foto
      final response = await supabase
          .from('artikel')
          .select('''
            id_artikel,
            judul_artikel,
            waktu_publikasi,
            detail_artikel,
            foto,
            penulis_artikel,
            bank_sampah:penulis_artikel (
              id_bank_sampah,
              nama_bank_sampah,
              foto
            )
          ''')
          .order('waktu_publikasi', ascending: false);

      if (mounted) {
        setState(() {
          artikelList = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Gagal memuat artikel: $e';
          isLoading = false;
        });
      }
      print('Error loading articles: $e');
    }
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'assets/default-article.png'; // Gambar default
    }
    
    // Jika sudah berupa URL lengkap, gunakan langsung
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    // Jika hanya nama file, buat URL dari Supabase Storage
    return supabase.storage
        .from('articles') // Nama bucket untuk artikel
        .getPublicUrl(imagePath);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tanggal tidak tersedia';
    
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd/MM/yyyy, HH:mm');
      return '${formatter.format(date)} WIB';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  String _getAuthorName(Map<String, dynamic> artikel) {
    try {
      // Akses data bank_sampah yang di-join
      final bankSampah = artikel['bank_sampah'];
      if (bankSampah != null && bankSampah['nama_bank_sampah'] != null) {
        return bankSampah['nama_bank_sampah'].toString().trim();
      }
      return 'WasteWise Team'; // Default author
    } catch (e) {
      return 'WasteWise Team'; // Fallback jika ada error
    }
  }

  String _getAuthorPhoto(Map<String, dynamic> artikel) {
    try {
      final bankSampah = artikel['bank_sampah'];
      if (bankSampah != null && bankSampah['foto'] != null) {
        String photoPath = bankSampah['foto'].toString().trim();
        if (photoPath.isNotEmpty) {
          // Jika sudah berupa URL lengkap,gunakan langsung
          if (photoPath.startsWith('http')) {
            return photoPath;
          }
          // Jika hanya nama file, buat URL dari Supabase Storage
          return supabase.storage
              .from('bank-sampah') // Nama bucket untuk foto bank sampah
              .getPublicUrl(photoPath);
        }
      }
      return ''; // Return empty string untuk default handling
    } catch (e) {
      return ''; // Fallback jika ada error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "Artikel",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D8D7A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3D8D7A)),
            onPressed: _loadArtikels,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadArtikels,
        color: const Color(0xFF3D8D7A),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // Kenali Sampah Card
            _buildKenaliSampahCard(),

            // Divider untuk Artikel
            _buildSectionDivider(),

            // Content berdasarkan state
            if (isLoading)
              _buildLoadingWidget()
            else if (error != null)
              _buildErrorWidget()
            else if (artikelList.isEmpty)
              _buildEmptyWidget()
            else
              ..._buildArtikelList(),
          ],
        ),
      ),
    );
  }

  Widget _buildKenaliSampahCard() {
    return GestureDetector(
      onTap: () => _navigateToKenaliSampah(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D8D7A).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3D8D7A),
              Color(0xFF2A6358),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildKenaliSampahIcon(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildKenaliSampahContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKenaliSampahIcon() {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF3D8D7A),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.document_scanner_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildKenaliSampahContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kenali Sampah",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Scan atau input manual untuk mengetahui jenis sampah dan cara pengelolaannya",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _navigateToKenaliSampah,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF3D8D7A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_rounded, size: 16),
              const SizedBox(width: 4),
              Text(
                "Mulai",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "ARTIKEL TERBARU",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D8D7A)),
            ),
            SizedBox(height: 16),
            Text(
              "Memuat artikel...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              "Gagal memuat artikel",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadArtikels,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D8D7A),
                foregroundColor: Colors.white,
              ),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada artikel",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Artikel akan muncul di sini setelah ditambahkan",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildArtikelList() {
    return List.generate(
      artikelList.length,
      (index) {
        final artikel = artikelList[index];
        return _buildArtikelCard(artikel);
      },
    );
  }

  Widget _buildArtikelCard(Map<String, dynamic> artikel) {
    return GestureDetector(
      onTap: () => _navigateToDetailArtikel(artikel),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArtikelImage(artikel),
            _buildArtikelContent(artikel),
          ],
        ),
      ),
    );
  }

  Widget _buildArtikelImage(Map<String, dynamic> artikel) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: artikel['foto'] != null && artikel['foto'].toString().isNotEmpty
          ? Image.network(
              _getImageUrl(artikel['foto']),
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImageLoading();
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D8D7A)),
        ),
      ),
    );
  }

  Widget _buildArtikelContent(Map<String, dynamic> artikel) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artikel["judul_artikel"]?.toString().trim() ?? 'Judul tidak tersedia',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            artikel["detail_artikel"] ?? 'Konten tidak tersedia',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _formatDate(artikel["waktu_publikasi"]),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ),
              // Author info dengan foto
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAuthorAvatar(artikel),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _getAuthorName(artikel),
                      style: GoogleFonts.inter(
                        fontSize: 12, 
                        color: const Color(0xFF3D8D7A),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorAvatar(Map<String, dynamic> artikel) {
    String photoUrl = _getAuthorPhoto(artikel);
    
    if (photoUrl.isEmpty) {
      // Default avatar jika tidak ada foto
      return CircleAvatar(
        radius: 12,
        backgroundColor: const Color(0xFF3D8D7A).withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: 12,
          color: const Color(0xFF3D8D7A),
        ),
      );
    }
    
    return CircleAvatar(
      radius: 12,
      backgroundImage: NetworkImage(photoUrl),
      backgroundColor: Colors.grey[300],
      onBackgroundImageError: (exception, stackTrace) {
        print('Error loading author photo: $exception');
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
      ),
    );
  }

  void _navigateToKenaliSampah() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KenaliSampah(),
      ),
    );
  }

  void _navigateToDetailArtikel(Map<String, dynamic> artikel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailArtikel(
          title: artikel['judul_artikel']?.toString().trim() ?? 'Judul tidak tersedia',
          content: artikel['detail_artikel'] ?? 'Konten tidak tersedia',
          date: _formatDate(artikel['waktu_publikasi']),
          image: _getImageUrl(artikel['foto']),
          author: _getAuthorName(artikel),
          authorPhoto: _getAuthorPhoto(artikel),
        ),
      ),
    );
  }
}
