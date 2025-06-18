import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LupaPassword extends StatefulWidget {
  @override
  _LupaPasswordState createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // Mendapatkan instance Supabase
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorMessage('Email harus diisi!');
      return;
    }
    
    // Validasi format email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorMessage('Format email tidak valid!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Menggunakan metode resetPasswordForEmail dari Supabase
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterauth://reset-callback/', // Sesuaikan dengan URL redirect Anda
      );

      // Jika berhasil
      _showSuccessMessage('Link reset password telah dikirim ke email Anda!');
    } on AuthException catch (error) {
      // Menangani error dari Supabase
      _showErrorMessage(error.message);
    } catch (error) {
      // Menangani error umum
      _showErrorMessage('Terjadi kesalahan. Silakan coba lagi nanti.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red, 
        content: Text(
          message,
          style: TextStyle(color: Colors.white), 
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green, 
        content: Text(
          message,
          style: TextStyle(color: Colors.white), 
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _backToLogin() {
    Navigator.pushReplacementNamed(context, '/form-login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 10.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 29.0),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gambar Logo
                    Image.asset('assets/maskot_with_circle.png', height: 220),
                    const SizedBox(height: 20),

                    // Judul
                    const Text(
                      'Lupa Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D8D7A),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    
                    // Deskripsi
                    const Text(
                      'Masukkan alamat email yang terdaftar untuk mendapatkan link reset password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA1A4B2),
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // Input Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      autofillHints: [AutofillHints.email],
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: Color(0xFFA1A4B2)),
                        filled: true,
                        fillColor: const Color(0xFFF2F3F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // Tombol Reset Password
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D8D7A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _isLoading ? null : _resetPassword,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Kirim Link Reset',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Kembali ke Halaman Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Ingat password?',
                          style: TextStyle(color: Color(0xFFA1A4B2)),
                        ),
                        TextButton(
                          onPressed: _backToLogin,
                          child: const Text(
                            'Kembali ke Login',
                            style: TextStyle(color: Color(0xFF2DCC70)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}