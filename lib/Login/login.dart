import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_wastewise/Beranda/beranda.dart';
import 'package:mobile_wastewise/Menu/menu.dart';
import 'package:mobile_wastewise/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Masuk extends StatefulWidget {
  const Masuk({super.key});

  @override
  State<Masuk> createState() => _MasukState();
}

class _MasukState extends State<Masuk> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isLoading = false;

  // Static constants for better maintainability
  static const Duration _snackBarDuration = Duration(seconds: 3);
  static const Duration _navigationDelay = Duration(seconds: 1);
  static const int _minPasswordLength = 6;
  
  // Color constants
  static const Color _primaryColor = Color(0xFF3D8D7A);
  static const Color _successColor = Color(0xFF2DCC70);
  static const Color _warningColor = Colors.orange;
  static const Color _errorColor = Colors.red;
  static const Color _hintColor = Color(0xFFA1A4B2);
  static const Color _fillColor = Color(0xFFF2F3F7);

  // Fungsi login menggunakan Supabase
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      final user = response.user;
      if (user != null) {
        // Cek konfirmasi email
        if (user.emailConfirmedAt == null) {
          _showSnackBar(
            'Email belum dikonfirmasi! Silakan cek email Anda.',
            _warningColor,
          );
          return;
        }

        // Cek kelengkapan data pengguna
        final userDataExists = await _checkUserDataExists(user.id);
        
        if (!userDataExists) {
          _showSnackBar(
            'Data pengguna tidak lengkap. Silakan lengkapi profil Anda.',
            _warningColor,
          );
          _navigateAfterDelay('/form-register');
          return;
        }
        
        _showSnackBar(
          'Login berhasil! Selamat datang kembali.',
          _primaryColor,
        );

        _navigateToMenuAfterDelay();
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _handleAuthError(error);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        'Terjadi kesalahan tidak terduga: ${error.toString()}',
        _errorColor,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Handle AuthException dengan mapping yang lebih komprehensif
  void _handleAuthError(AuthException error) {
    final errorMessages = {
      'Invalid login credentials': 'Email atau password salah!',
      'Email not confirmed': 'Email belum dikonfirmasi! Silakan cek email Anda.',
      'Too many requests': 'Terlalu banyak percobaan. Coba lagi nanti.',
      'User not found': 'Akun tidak ditemukan!',
      'Invalid email': 'Format email tidak valid!',
      'Weak password': 'Password terlalu lemah!',
      'Password should be at least 6 characters': 'Password harus minimal 6 karakter!',
    };
    
    final errorMessage = errorMessages[error.message] ?? error.message;
    
    _showSnackBar(errorMessage, _errorColor);
  }

  // Cek apakah data pengguna sudah ada di tabel pengguna
  Future<bool> _checkUserDataExists(String userId) async {
    try {
      final response = await supabase
          .from('pengguna')
          .select('id_pengguna')
          .eq('id_pengguna', userId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('Error checking user data: $e');
      return false;
    }
  }

  // Helper method untuk navigasi dengan delay
  void _navigateAfterDelay(String routeName) {
    Future.delayed(_navigationDelay, () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, routeName);
      }
    });
  }

  // Helper method untuk navigasi ke menu
  void _navigateToMenuAfterDelay() {
    Future.delayed(_navigationDelay, () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => Menu()),
          (route) => false,
        );
      }
    });
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
        duration: _snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Validator untuk email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi!';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid!';
    }
    
    return null;
  }

  // Validator untuk password
  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password harus diisi!';
    }
    
    if (value.length < _minPasswordLength) {
      return 'Password harus minimal $_minPasswordLength karakter!';
    }
    
    return null;
  }

  void _forgotPassword() {
    if (_isLoading) return;
    Navigator.pushNamed(context, '/form-lupa-password');
  }

  void _register() {
    if (_isLoading) return;
    Navigator.pushNamed(context, '/form-register');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Kembali
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 10.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 29.0),
                  tooltip: 'Kembali',
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 35),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gambar Logo
                      Image.asset(
                        'assets/maskot_with_circle.png', 
                        height: 220,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              color: _fillColor,
                              borderRadius: BorderRadius.circular(110),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: _hintColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Judul
                      Text(
                        'Halo,\nWasteWarriors!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Input Email
                      _buildEmailField(),
                      const SizedBox(height: 16.0),

                      // Input Password
                      _buildPasswordField(),
                      const SizedBox(height: 24.0),

                      // Tombol Masuk
                      _buildLoginButton(),
                      const SizedBox(height: 18.0),

                      // Lupa Password
                      _buildForgotPasswordButton(),
                      const SizedBox(height: 60.0),

                      // Daftar Sekarang
                      _buildRegisterSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: GoogleFonts.montserrat(fontSize: 15),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      autofillHints: const [AutofillHints.email],
      enabled: !_isLoading,
      validator: _validateEmail,
      decoration: _buildInputDecoration('Email'),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      style: GoogleFonts.montserrat(fontSize: 15),
      obscureText: _isObscure,
      textInputAction: TextInputAction.done,
      enabled: !_isLoading,
      validator: _validatePassword,
      onFieldSubmitted: (_) => _login(),
      decoration: _buildInputDecoration('Password').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: _hintColor,
          ),
          onPressed: _isLoading ? null : () {
            setState(() => _isObscure = !_isObscure);
          },
          tooltip: _isObscure ? 'Tampilkan password' : 'Sembunyikan password',
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(
        fontSize: 15,
        color: _hintColor,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: _fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: GoogleFonts.montserrat(
        fontSize: 12,
        color: _errorColor,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
          disabledBackgroundColor: _primaryColor.withOpacity(0.6),
        ),
        onPressed: _isLoading ? null : _login,
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
                'Masuk',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _isLoading ? null : _forgotPassword,
      child: Text(
        'Lupa password?',
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _isLoading ? _hintColor : _primaryColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum memiliki akun?',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: _hintColor,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _register,
          child: Text(
            'Daftar Sekarang',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isLoading ? _hintColor : _successColor,
            ),
          ),
        ),
      ],
    );
  }
}