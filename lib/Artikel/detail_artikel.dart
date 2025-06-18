import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailArtikel extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String image;
  final String author;
  final String? authorPhoto; // Parameter opsional untuk foto author
  
  // Supabase client instance
  final SupabaseClient supabase = Supabase.instance.client;

  DetailArtikel({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.image,
    required this.author,
    this.authorPhoto, // Parameter opsional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "Detail Artikel", 
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D7F5F), 
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF3D7F5F),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Container
            Container(
              width: double.infinity,
              height: 230,
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImage(),
              ),
            ),
            
            // Content Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Author and Date Info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF3D7F5F).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildAuthorAvatar(),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ditulis oleh",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                author,
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF3D7F5F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    date, 
                                    style: GoogleFonts.inter(
                                      fontSize: 12, 
                                      color: Colors.grey[600],
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
                  SizedBox(height: 24),
                  
                  // Content Divider
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  SizedBox(height: 24),
                  
                  // Content
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar() {
    // Jika authorPhoto tidak tersedia atau kosong, gunakan default avatar
    if (authorPhoto == null || authorPhoto!.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFF3D7F5F).withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFF3D7F5F).withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.person, 
          color: Color(0xFF3D7F5F),
          size: 24,
        ),
      );
    }

    // Jika authorPhoto tersedia, tampilkan sebagai network image
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0xFF3D7F5F).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          _getAuthorPhotoUrl(authorPhoto!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback ke default avatar jika foto gagal dimuat
            return Container(
              width: 50,
              height: 50,
              color: Color(0xFF3D7F5F).withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Color(0xFF3D7F5F),
                size: 24,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D7F5F)),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getAuthorPhotoUrl(String photoPath) {
    // Jika sudah berupa URL lengkap, gunakan langsung
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    
    // Jika hanya nama file, buat URL dari Supabase Storage
    return supabase.storage
        .from('bank-sampah') // Nama bucket untuk foto bank sampah
        .getPublicUrl(photoPath);
  }

  Widget _buildImage() {
    final String imageUrl = _getImageUrl(image);
    
    // Check if it's a network URL
    if (imageUrl.startsWith('http')) {
      // Network image from Supabase Storage
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 230,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 230,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey[500],
                ),
                SizedBox(height: 8),
                Text(
                  'Gambar tidak dapat dimuat',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 230,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D7F5F)),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      // Fallback to default image
      return Container(
        width: double.infinity,
        height: 230,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 50,
              color: Colors.grey[500],
            ),
            SizedBox(height: 8),
            Text(
              'Gambar tidak tersedia',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
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
}
