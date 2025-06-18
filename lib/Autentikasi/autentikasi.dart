import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Autentikasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar Maskot
              Image.asset('assets/logo-trashscan.png', height: 230),
              const SizedBox(height: 35),

              // Judul "Selamat Datang"
              Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D7F5F),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Subjudul
              Text(
                'Our Planet in Your Hands\nJoin the Movement!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D7F5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/form-login');
                  },
                  child: Text(
                    'Masuk',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3D7F5F), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/form-register');
                  },
                  child: Text(
                    'Daftar',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600, 
                      color: Color(0xFF3D7F5F)),
                  ),
                ),
              ),
              const SizedBox(height: 23),

              // Persetujuan Kebijakan Privasi
              Text.rich(
                TextSpan(
                  text: 'Dengan masuk atau mendaftar, Anda menyetujui ',
                    style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: const Color(0xFFA1A4B2),
                  ),
                  children: [
                    TextSpan(
                      text: '\nPersyaratan Layanan',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF80D48F),
                      ),
                    ),
                    const TextSpan(text: ' dan '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF80D48F),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
