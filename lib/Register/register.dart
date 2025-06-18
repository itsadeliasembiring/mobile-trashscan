import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_wastewise/Beranda/beranda.dart';
import 'package:mobile_wastewise/Menu/menu.dart';
import 'package:mobile_wastewise/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Daftar extends StatefulWidget {
  const Daftar({Key? key}) : super(key: key);
  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  String? _selectedKelurahan;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _kelurahanList = [];
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isPrivacyChecked = false;
  bool _isLoading = false;
  bool _isLoadingKelurahan = false;

  @override
  void initState() {
    super.initState();
    _loadKelurahan();
  }

  // Load kelurahan data from database
  Future<void> _loadKelurahan() async {
    setState(() {
      _isLoadingKelurahan = true;
    });

    try {
      final response = await supabase
          .from('kelurahan')
          .select('id_kelurahan, nama_kelurahan')
          .order('nama_kelurahan', ascending: true);
      
      print('Kelurahan loaded: ${response.length} items');
      
      // Debug: tampilkan beberapa contoh data kelurahan
      if (response.isNotEmpty) {
        print('Contoh data kelurahan:');
        for (int i = 0; i < (response.length > 3 ? 3 : response.length); i++) {
          print('  ${response[i]['id_kelurahan']} - ${response[i]['nama_kelurahan']}');
        }
      }
      
      setState(() {
        _kelurahanList = List<Map<String, dynamic>>.from(response);
        _isLoadingKelurahan = false;
      });
    } catch (e) {
      print('Error loading kelurahan: $e');
      
      setState(() {
        _isLoadingKelurahan = false;
      });
      _showSnackBar('Gagal memuat data kelurahan: ${e.toString()}', Colors.red);
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 tahun yang lalu
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      });
    }
  }

  // Validasi format ID kelurahan
  bool _validateKelurahanId() {
    if (_selectedKelurahan == null) {
      _showSnackBar('Harap pilih kelurahan!', Colors.red);
      return false;
    }
    
    // Validasi format id_kelurahan (harus seperti K011, K012, dll)
    if (!RegExp(r'^L\d{3}$').hasMatch(_selectedKelurahan!)) {
      print('Invalid kelurahan format: $_selectedKelurahan');
      _showSnackBar('Format ID kelurahan tidak valid!', Colors.red);
      return false;
    }
    
    return true;
  }

  // Validasi input
  bool _validateInput() {
    // Cek semua field wajib sesuai database schema
    if (_nameController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedDate == null ||
        _addressController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedKelurahan == null) {
      _showSnackBar('Harap lengkapi semua data!', Colors.red);
      return false;
    }

    if (!_validateKelurahanId()) {
      return false;
    }

    // Validasi panjang nama (max 60 karakter sesuai database)
    if (_nameController.text.trim().length > 60) {
      _showSnackBar('Nama lengkap maksimal 60 karakter!', Colors.red);
      return false;
    }

    // Validasi panjang alamat (max 120 karakter sesuai database)
    if (_addressController.text.trim().length > 120) {
      _showSnackBar('Detail alamat maksimal 120 karakter!', Colors.red);
      return false;
    }

    // Validasi nomor telepon (max 13 karakter sesuai database)
    if (_phoneController.text.trim().length > 13) {
      _showSnackBar('Nomor telepon maksimal 13 karakter!', Colors.red);
      return false;
    }

    // Validasi format email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text.trim())) {
      _showSnackBar('Format email tidak valid!', Colors.red);
      return false;
    }

    // Validasi password match
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Password dan konfirmasi tidak cocok!', Colors.red);
      return false;
    }

    // Validasi panjang password
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password harus minimal 6 karakter!', Colors.red);
      return false;
    }

    // Validasi nomor telepon (hanya angka, +, -, dan spasi)
    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(_phoneController.text.trim())) {
      _showSnackBar('Format nomor telepon tidak valid!', Colors.red);
      return false;
    }

    // Validasi kebijakan privasi
    if (!_isPrivacyChecked) {
      _showSnackBar('Harap setujui Kebijakan Privasi!', Colors.red);
      return false;
    }

    return true;
  }

  // Helper method untuk menampilkan snackbar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Fungsi untuk mengecek apakah user sudah punya data di tabel pengguna
  Future<bool> _checkUserDataExists(String userId) async {
    try {
      final response = await supabase
          .from('pengguna')
          .select('id_pengguna')
          .eq('id_pengguna', userId)
          .maybeSingle();
    
      print('User data exists: ${response != null}');
      return response != null;
    } catch (e) {
      print('Error checking user data: $e');
      return false;
    }
  }

  // Simpan data ke tabel pengguna sesuai schema database
  Future<void> _saveUserData(String userId) async {
    try {
      String formattedDate = _selectedDate != null 
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : "";
      
      print('Attempting to insert user data:');
      print('User ID: $userId');
      print('Nama: ${_nameController.text.trim()}');
      print('Gender: ${_selectedGender!}');
      print('Tanggal: $formattedDate');
      print('Phone: ${_phoneController.text.trim()}');
      print('Alamat: ${_addressController.text.trim()}');
      print('Kelurahan ID: $_selectedKelurahan (type: ${_selectedKelurahan.runtimeType})');

      final insertData = {
        'id_pengguna': userId,
        'nama_lengkap': _nameController.text.trim(),
        'jenis_kelamin': _selectedGender!, // Sesuaikan dengan enum
        'tanggal_lahir': formattedDate,
        'nomor_telepon': _phoneController.text.trim(),
        'detail_alamat': _addressController.text.trim(),
        'id_kelurahan': _selectedKelurahan!,
        'total_poin': 0, // Default value
        'foto': null, // Default null
      };

      print('Data: $insertData');

      final response = await supabase
          .from('pengguna')
          .upsert(insertData)
          .select();
      print('Insert response: $response');

    } catch (e) {
      print('Error type: ${e.runtimeType}');
      print('Error detail: $e');

      if (e.toString().contains('foreign key')) {
        throw Exception('Error: ID Kelurahan tidak valid atau tidak ditemukan');
      } else if (e.toString().contains('enum')) {
        throw Exception('Error: Jenis kelamin tidak sesuai format yang diizinkan');
      } else if (e.toString().contains('RLS') || e.toString().contains('policy')) {
        throw Exception('Error: Tidak ada izin akses ke database (RLS Policy)');
      } else {
        throw Exception('Database error: ${e.toString()}');
      }
    }
  }

  // Fungsi registrasi dengan Supabase
  Future<void> _register() async {
    if (!_validateInput()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Registrasi ke Supabase Auth
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text.trim(),
        },
      );

      print('Auth Response: ${response.user?.id}');

      if (!mounted) return;

      if (response.user != null) {
        try {
          // Simpan data ke tabel pengguna
          await _saveUserData(response.user!.id);
          _showSnackBar(
            'Registrasi berhasil! Data pengguna telah disimpan.',
            const Color(0xFF3D8D7A),
          );
          // Redirect ke halaman beranda
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => Menu()),
                (route) => false,
              );
            }
          });

        } catch (saveError) {
          print('Gagal menyimpan data pengguna: $saveError');

          if (saveError.toString().contains('RLS') ||
              saveError.toString().contains('permission') ||
              saveError.toString().contains('policy')) {
            _showSnackBar(
              'Error: Tidak ada izin untuk menyimpan data. Cek RLS policy di Supabase!',
              Colors.orange,
            );
          } else {
            _showSnackBar(
              'Registrasi berhasil, tetapi gagal menyimpan data pengguna: ${saveError.toString()}',
              Colors.orange,
            );
          }
          // Redirect ke halaman beranda meskipun data pengguna sudah terdaftar
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => Menu()),
                (route) => false,
              );
            }
          });
        }
      } else {
        _showSnackBar('Gagal membuat akun', Colors.red);
      }
    } on AuthException catch (error) {
      print('Auth Error: ${error.message}');
      if (!mounted) return;
      
      String errorMessage = 'Terjadi kesalahan saat registrasi';
      
      // Handle specific error types
      switch (error.message) {
        case 'User already registered':
          errorMessage = 'Email sudah terdaftar!';
          break;
        case 'Password should be at least 6 characters':
          errorMessage = 'Password harus minimal 6 karakter!';
          break;
        case 'Unable to validate email address: invalid format':
          errorMessage = 'Format email tidak valid!';
          break;
        case 'Signup is disabled':
          errorMessage = 'Registrasi sedang dinonaktifkan!';
          break;
        default:
          errorMessage = error.message ?? 'Terjadi kesalahan saat registrasi';
      }
      
      _showSnackBar(errorMessage, Colors.red);
    } catch (error) {
      print('Unexpected error: $error');
      if (!mounted) return;
      _showSnackBar('Terjadi kesalahan tidak terduga: ${error.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, top: 12.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 28.0),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/maskot_with_circle.png', height: 150),
                      const SizedBox(height: 20),
                      Text(
                        'Buat Akun\nWasteWarriors!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D8D7A),
                          ),
                        )
                      ),
                      const SizedBox(height: 22),
                      _buildTextField(
                        controller: _nameController, 
                        hint: "Nama Lengkap (max 60 karakter)",
                        enabled: !_isLoading,
                        maxLength: 60,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        hint: "Jenis Kelamin",
                        value: _selectedGender,
                        items: const ["Laki-laki", "Perempuan"],
                        enabled: !_isLoading,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDateField(),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _addressController, 
                        hint: "Detail Alamat (max 120 karakter)",
                        enabled: !_isLoading,
                        maxLength: 120,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _buildKelurahanDropdown(),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _phoneController, 
                        hint: "Nomor Telepon (max 13 karakter)",
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        maxLength: 13,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _emailController, 
                        hint: "Email",
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: _passwordController,
                        hint: "Password",
                        isObscure: _isObscure,
                        enabled: !_isLoading,
                        toggleObscure: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hint: "Konfirmasi Password",
                        isObscure: _isConfirmObscure,
                        enabled: !_isLoading,
                        toggleObscure: () {
                          setState(() {
                            _isConfirmObscure = !_isConfirmObscure;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: const Color(0xFF3D8D7A),
                            ),
                            child: Checkbox(
                              value: _isPrivacyChecked,
                              activeColor: const Color(0xFF3D8D7A),
                              onChanged: _isLoading ? null : (value) {
                                setState(() {
                                  _isPrivacyChecked = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: _isLoading ? null : () {
                                // Navigasi ke halaman kebijakan privasi
                                // Navigator.pushNamed(context, '/privacy-policy');
                              },
                              child: Text("Saya setuju dengan Kebijakan Privasi",
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFF2DCC70),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500
                                  ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D8D7A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Daftar',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600, 
                                    color: Colors.white
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.montserrat(),
      keyboardType: keyboardType,
      enabled: enabled,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
          color: const Color(0xFFA1A4B2), 
          fontSize: 14, 
          fontWeight: FontWeight.w500
        ),
        filled: true,
        fillColor: const Color(0xFFF2F3F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        counterText: maxLength != null ? null : "",
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required List<String> items,
    String? value,
    bool enabled = true,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        hint: Text(hint,
         style: GoogleFonts.montserrat(
          fontSize: 14,
          color: const Color(0xFFA1A4B2),
          fontWeight: FontWeight.w500,
         )),
        underline: Container(),
        onChanged: enabled ? onChanged : null,
        items: items.map((e) => DropdownMenuItem(
          value: e, 
          child: Text(e, style: GoogleFonts.montserrat())
        )).toList(),
      ),
    );
  }

  Widget _buildKelurahanDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: _isLoadingKelurahan
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : DropdownButton<String>(
              isExpanded: true,
              value: _selectedKelurahan,
              hint: Text("Pilih Kelurahan",
               style: GoogleFonts.montserrat(
                fontSize: 14,
                color: const Color(0xFFA1A4B2),
                fontWeight: FontWeight.w500,
               )),
              underline: Container(),
              onChanged: !_isLoading ? (value) {
                setState(() {
                  _selectedKelurahan = value;
                  print('Selected Kelurahan: $value');
                });
              } : null,
              items: _kelurahanList.map((kelurahan) {
                final kelurahanId = kelurahan['id_kelurahan'].toString();
                final kelurahanNama = kelurahan['nama_kelurahan'].toString();

                return DropdownMenuItem<String>(
                  value: kelurahanId, 
                  child: Text(
                    kelurahanNama, 
                    style: GoogleFonts.montserrat()
                  )
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      enabled: !_isLoading,
      onTap: _isLoading ? null : _pickDate,
      style: GoogleFonts.montserrat(),
      decoration: InputDecoration(
        hintText: "Tanggal Lahir",
        hintStyle: GoogleFonts.montserrat(
          color: const Color(0xFFA1A4B2), 
          fontSize: 14, 
          fontWeight: FontWeight.w500
        ),
        filled: true,
        fillColor: const Color(0xFFF2F3F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFA1A4B2)),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    bool enabled = true,
    required Function toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      enabled: enabled,
      style: GoogleFonts.montserrat(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
          color: const Color(0xFFA1A4B2), 
          fontWeight: FontWeight.w500, 
          fontSize: 14
        ),
        filled: true,
        fillColor: const Color(0xFFF2F3F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: enabled ? () => toggleObscure() : null,
        ),
      ),
    );
  }
}