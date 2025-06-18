import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../UbahPassword/ubah_password.dart';
import '../UbahProfil/ubah_profil.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final supabase = Supabase.instance.client;

  //Data pengguna
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? userEmail; //userId
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Supabase
  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      //Ambil user yang sedang login
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        setState(() {
          errorMessage = 'Pengguna tidak ditemukan. Silakan login kembali.';
          isLoading = false;
        });
        return;
      }

      // Set email dari auth
      userEmail = currentUser.email;
      print('Current User ID: ${currentUser.id}');
      print('Current User Email: ${currentUser.email}');

      // Ambil data pengguna dari tabel pengguna
      final response = await supabase
          .from('pengguna')
          .select('''
            nama_lengkap,
            jenis_kelamin,
            tanggal_lahir,
            nomor_telepon,
            detail_alamat,
            total_poin,
            foto,
            kelurahan:id_kelurahan(
              nama_kelurahan
            )
          ''')
          .eq('id_pengguna', currentUser.id)
          .maybeSingle();

      print('User data response: $response');

      if (response != null) {
        setState(() {
          userData = response;
          isLoading = false;
        });
        print('User data loaded successfully: $userData');
      } else {
        print('No data found in database, using auth data');
        // Jika tidak ada data pengguna, gunakan data dari auth
        setState(() {
          userData = {
            'nama_lengkap': currentUser.userMetadata?['full_name'] ?? currentUser.email?.split('@')[0] ?? 'Pengguna',
            'total_poin': 0,
            'foto': null,
            'nomor_telepon': null,
            'jenis_kelamin': null,
            'tanggal_lahir': null,
            'detail_alamat': null,
        };
        isLoading = false;
        });
      }

    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        errorMessage = 'Gagal memuat data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Fungsi untuk refresh data pengguna
  Future<void> _forceRefresh() async {
    setState(() {
      userData = null; // Reset user data
      isLoading = true;
      errorMessage = '';
    });
    await _loadUserData();
  }

  // Fungsi logout
  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Konfirmasi Keluar',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Keluar',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        await supabase.auth.signOut();
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal keluar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget untuk menampilkan foto profil
  Widget _buildProfileImage() {
    // Jika ada foto dari database, gunakan itu
    if (userData?['foto'] != null && userData!['foto'].toString().trim().isNotEmpty) {
      return Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3D7F5F), width: 3),
        ),
        child: ClipOval(
          child: Image.network(
            userData!['foto'],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3D7F5F),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Error loading profile image: $error');
              return _buildDefaultAvatar();
            },
          ),
        ),
      );
    }
    
    // Jika tidak ada foto, gunakan avatar default
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    String firstLetter = 'U';
    if (userData?['nama_lengkap'] != null && userData!['nama_lengkap'].toString().isNotEmpty) {
      firstLetter = userData!['nama_lengkap'].toString().substring(0, 1).toUpperCase();
    }

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF3D7F5F),
        border: Border.all(color: const Color(0xFF3D7F5F), width: 3),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: GoogleFonts.poppins(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper method to format date
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Widget untuk info item dengan icon
  Widget _buildInfoItem(IconData icon, String text, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.black54),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk informasi pengguna
  Widget _buildUserInfo() {
    List<Widget> infoWidgets = [];

    // Nomor telepon
    if (userData?['nomor_telepon'] != null && 
        userData!['nomor_telepon'].toString().isNotEmpty) {
      infoWidgets.add(_buildInfoItem(Icons.phone, userData!['nomor_telepon']));
    }

    // Jenis kelamin
    if (userData?['jenis_kelamin'] != null && 
        userData!['jenis_kelamin'].toString().isNotEmpty) {
      infoWidgets.add(_buildInfoItem(
        userData!['jenis_kelamin'] == 'Laki-laki' ? Icons.male : Icons.female,
        userData!['jenis_kelamin'],
        iconColor: userData!['jenis_kelamin'] == 'Laki-laki' ? Colors.blue : Colors.pink,
      ));
    }

    // Tanggal lahir
    if (userData?['tanggal_lahir'] != null && 
        userData!['tanggal_lahir'].toString().isNotEmpty) {
      infoWidgets.add(_buildInfoItem(
        Icons.calendar_today,
        _formatDate(userData!['tanggal_lahir']),
      ));
    }

    // Alamat
    if (userData?['detail_alamat'] != null && 
        userData!['detail_alamat'].toString().isNotEmpty) {
      String alamat = userData!['detail_alamat'];
      if (userData?['kelurahan']?['nama_kelurahan'] != null) {
        alamat += ', ${userData!['kelurahan']['nama_kelurahan']}';
      }
      infoWidgets.add(_buildInfoItem(Icons.location_on, alamat));
    }

    return Column(children: infoWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D7F5F),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3D7F5F)),
            onPressed: _forceRefresh,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _forceRefresh,
              color: const Color(0xFF3D7F5F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Loading atau Error State
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D7F5F)),
                          ),
                        ),
                      )
                    else if (errorMessage.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _forceRefresh,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D7F5F),
                                ),
                                child: Text(
                                  'Coba Lagi', 
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Profile Image
                      Center(child: _buildProfileImage()),

                      const SizedBox(height: 20),

                      // Name
                      Text(
                        userData?['nama_lengkap']?.toString() ?? 'Nama Pengguna',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 4),

                      // Email
                      Text(
                        userEmail ?? 'email@gmail.com',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Points
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D7F5F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 18,
                              color: Color(0xFF3D7F5F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${userData?['total_poin'] ?? 0} poin',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3D7F5F),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // User Info
                      _buildUserInfo(),

                      const SizedBox(height: 40),

                      // Edit Profile Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UbahProfil(),
                              ),
                            );
                            
                            if (result == true) {
                              await _forceRefresh();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D7F5F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Ubah Profil',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Change Password Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UbahPassword(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.password_outlined, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Ubah Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Keluar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}