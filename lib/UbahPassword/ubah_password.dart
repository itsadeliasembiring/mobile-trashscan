import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UbahPassword extends StatefulWidget {
  const UbahPassword({Key? key}) : super(key: key);

  @override
  State<UbahPassword> createState() => _UbahPassword();
}

class _UbahPassword extends State<UbahPassword> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validasi Password baru
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password baru tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password harus minimal 6 karakter';
    }
    return null;
  }

  // Validasi Konfirmasi Password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _newPasswordController.text) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  // Validasi Password Saat Ini
  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password saat ini tidak boleh kosong';
    }
    // Di sini bisa ditambahkan logika untuk memeriksa apakah password saat ini benar
    // Misalnya, dengan memanggil API atau memeriksa di database
    return null;
  }

  // Fungsi untuk mengubah password
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jika form tidak valid, hentikan eksekusi
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception("Pengguna tidak ditemukan");
      }

      // Verifikasi password saat ini dengan login ulang
      final email = currentUser.email;
      if (email == null) {
        throw Exception("Email pengguna tidak ditemukan");
      }

      // Coba login ulang dengan password saat ini
      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: _currentPasswordController.text,
        );
      } catch (e) {
        throw Exception("Password saat ini salah");
      }

      // Jika verifikasi berhasil, ubah password
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (mounted) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password berhasil diubah!',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Bersihkan form
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Kembali ke halaman sebelumnya setelah 1 detik
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal mengubah password';

        if (e.toString().contains('Password saat ini tidak benar')) {
          errorMessage = 'Password saat ini tidak benar';
        } else if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Password saat ini tidak benar';
        } else if (e.toString().contains('Password should be at least 6 characters')) {
          errorMessage = 'Password minimal 6 karakter';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Periksa koneksi internet Anda';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "Ubah Password",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color(0xFF3C9586),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3C9586)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C9586).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        color: Color(0xFF3C9586),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Keamanan Password",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3C9586),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Password harus minimal 6 karakter dan mengandung huruf serta angka",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Ubah Password Anda",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                // Input Password Saat Ini
                _buildPasswordField(
                  controller: _currentPasswordController,
                  hint: "Password saat ini",
                  isVisible: _isCurrentPasswordVisible,
                  validator: _validateCurrentPassword,
                  onToggle: () {
                    setState(() {
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Input Password Baru
                _buildPasswordField(
                  controller: _newPasswordController,
                  hint: "Password baru",
                  isVisible: _isNewPasswordVisible,
                  validator: _validateNewPassword,
                  onToggle: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Input Konfirmasi Password
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hint: "Konfirmasi password baru",
                  isVisible: _isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
                  onToggle: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 40),

                // Tombol Simpan Perubahan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C9586),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Mengubah Password...",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Simpan Perubahan",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tips keamanan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tips_and_updates,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Tips Keamanan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• Gunakan kombinasi huruf besar, kecil, angka, dan simbol\n"
                        "• Jangan gunakan informasi pribadi yang mudah ditebak\n"
                        "• Ubah password secara berkala untuk keamanan maksimal",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk Input Password dengan Toggle Eye Icon dan Validasi
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: GoogleFonts.poppins(),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3C9586), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}