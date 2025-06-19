import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Menu/menu.dart';
import '../Artikel/detail_artikel.dart';

class Beranda extends StatefulWidget {
  const Beranda({Key? key}) : super(key: key);

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;

  String _userName = 'Pengguna'; // Default name
  String? _userPhotoUrl; // Default photo URL

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadUserData(); // Call this to load user-specific data
  }

  // New method to load user data
  Future<void> _loadUserData() async {
    try {
      final User? user = supabase.auth.currentUser;
      if (user != null) {
        print('Fetching user data for ID: ${user.id}');
        final response = await supabase
            .from('pengguna')
            .select('nama_lengkap, foto')
            .eq('id_pengguna', user.id)
            .single(); // Use single() to expect one row

        print('User data response: $response');

        if (response != null) {
          setState(() {
            _userName = response['nama_lengkap'] ?? 'Pengguna';
            _userPhotoUrl = response['foto'];
          });
          print('User name: $_userName, User photo: $_userPhotoUrl');
        } else {
          print('No user data found for ID: ${user.id}');
        }
      } else {
        print('No authenticated user found.');
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pengguna: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading articles from Supabase...');

      // Query artikel dari database dengan join ke bank_sampah
      final response = await supabase
          .from('artikel')
          .select('''
            id_artikel,
            judul_artikel,
            waktu_publikasi,
            detail_artikel,
            foto,
            penulis_artikel,
            bank_sampah!artikel_penulis_artikel_fkey (
              nama_bank_sampah,
              foto
            )
          ''')
          .order('waktu_publikasi', ascending: false)
          .limit(4);

      print('Supabase response: $response');
      print('Number of articles fetched: ${response.length}');

      if (response.isNotEmpty) {
        setState(() {
          _articles = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
        print('Articles loaded successfully: ${_articles.length} articles');
      } else {
        print('No articles found in database');
        setState(() {
          _articles = [];
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error loading articles: $error');
      print('Error type: ${error.runtimeType}');
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat artikel: $error'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
      
      setState(() {
        _isLoading = false;
        _articles = []; // Set empty list instead of static data
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

  void _navigateToDetailArtikel(Map<String, dynamic> article) {
    print('=== NAVIGATION DEBUG ===');
    print('Navigating to article: ${article['judul_artikel']}');
    print('Article ID: ${article['id_artikel']}');
    print('Content available: ${article['detail_artikel'] != null}');
    print('Content length: ${article['detail_artikel']?.length ?? 0}');
    print('Author: ${article['bank_sampah']?['nama_bank_sampah']}');
    print('Photo: ${article['foto']}');
    print('========================');
    
    if (!mounted) {
      print('Widget is not mounted, cannot navigate');
      return;
    }

    // Validate required data
    if (article['judul_artikel'] == null || article['detail_artikel'] == null) {
      print('Missing required article data');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data artikel tidak lengkap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailArtikel(
            title: article['judul_artikel'] ?? 'Judul Tidak Tersedia',
            content: article['detail_artikel'] ?? 'Konten tidak tersedia',
            date: _formatDate(article['waktu_publikasi'] ?? DateTime.now().toIso8601String()),
            image: article['foto'] ?? '',
            author: article['bank_sampah']?['nama_bank_sampah'] ?? 'Penulis Tidak Diketahui',
            authorPhoto: article['bank_sampah']?['foto'], // Correctly access 'foto' from bank_sampah
          ),
        ),
      ).then((value) {
        print('Navigation completed successfully');
      }).catchError((error) {
        print('Navigation error: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan saat membuka artikel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (error) {
      print('Exception during navigation: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka artikel'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to get public URL for user photos
  String _getUserPhotoUrl(String photoPath) {
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    // Assuming 'profile_photos' is your bucket name for user profile pictures
    return supabase.storage.from('profile_photos').getPublicUrl(photoPath);
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Profile Picture
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFA3D1C6),
                      backgroundImage: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                          ? NetworkImage(_getUserPhotoUrl(_userPhotoUrl!))
                          : const AssetImage('assets/maskot-trashscan.png') as ImageProvider, // Default asset image
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Error loading user profile image: $exception');
                        // Fallback to default asset image if network image fails
                        // setState(() {
                        //   _userPhotoUrl = null; // Or set to a default asset path
                        // });
                      },
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

                // Kartu Selamat Datang
                Stack(
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/background-container-home-trashscan.png',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.transparent,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                'assets/maskot-trashscan.png',
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
                                          text: '$_userName!', // Use dynamic name here
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

                // Tombol Kenali Sampah
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      MenuState.of(context)?.changeTab(1);
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

                // Bagian Artikel Lingkungan
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
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
                                ],
                              ),
                            ),
                            // Refresh button
                            IconButton(
                              onPressed: () {
                                print('Refresh button pressed');
                                _loadArticles();
                                _loadUserData(); // Also refresh user data
                              },
                              icon: Icon(
                                Icons.refresh,
                                color: Color(0xFF3D7F5F),
                              ),
                              tooltip: 'Muat ulang artikel',
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        // Loading indicator atau artikel
                        if (_isLoading)
                          Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D7F5F)),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Memuat artikel...',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        else if (_articles.isEmpty)
                          Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.article_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Belum ada artikel tersedia',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _loadArticles,
                                        child: Text('Coba Lagi'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF3D7F5F),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        else
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _articles.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final article = _articles[index];
                              return _ArticleCard(
                                imagePath: article['foto'] ?? '',
                                title: article['judul_artikel'] ?? 'Judul Tidak Tersedia',
                                onTap: () {
                                  print('Card tapped for article: ${article['judul_artikel']}');
                                  _navigateToDetailArtikel(article);
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('Article card InkWell tapped: $title');
          onTap();
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE4F2EE),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImage(context),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tombol Baca Selengkapnya
                    InkWell( // This InkWell handles the tap for "Baca Selengkapnya" area
                      onTap: () {
                        print('Baca Selengkapnya tapped for: $title');
                        onTap(); // Trigger the main card's onTap function
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding( // Add Padding to give some space around the text and icon
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Adjust padding as needed
                        child: Row( // Use a Row to place text and icon side-by-side
                          mainAxisSize: MainAxisSize.min, // Make Row only take necessary space
                          children: [
                            Text(
                              'Baca Selengkapnya',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3D7F5F),
                                decoration: TextDecoration.underline, // Underline the text
                              ),
                            ),
                            const SizedBox(width: 4), // Space between text and icon
                            Icon(
                              Icons.arrow_forward_ios, // Forward arrow icon
                              size: 12, // Adjust size to match text
                              color: const Color(0xFF3D7F5F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    
    if (imagePath.isEmpty) {
      return Container(
        width: 75, // Changed from 70 to 75
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.article,
          color: Colors.grey[500],
          size: 30,
        ),
      );
    }

    String imageUrl;
    if (imagePath.startsWith('http')) {
      imageUrl = imagePath;
    } else {
      // Build Supabase Storage URL
      imageUrl = supabase.storage
          .from('articles')
          .getPublicUrl(imagePath);
    }

    return Image.network(
      imageUrl,
      width: 75, // Changed from 70 to 75
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return Container(
          width: 75, // Changed from 70 to 75
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[500],
            size: 30,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D7F5F)),
              ),
            ),
          ),
        );
      },
    );
  }
}