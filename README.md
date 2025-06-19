# TrashScan
# Deskripsi Proyek
TrashScan adalah sebuah aplikasi inovatif berbasis teknologi yang dirancang untuk membantu masyarakat, khususnya di daerah perkotaan seperti Surabaya, dalam mengelola sampah secara lebih efektif dan bertanggung jawab. Dengan mengusung slogan “Our Planet in Your Hand”, aplikasi ini hadir sebagai solusi cerdas untuk mengurangi pencemaran lingkungan, mengoptimalkan proses daur ulang, serta meningkatkan kesadaran masyarakat akan pentingnya pengelolaan sampah yang berkelanjutan.

Dokumentasi ini dibuat untuk memudahkan proses pemeliharaan dan pengembangan aplikasi di masa depan.
## Developer
- 187231006 | Maria Shelina Angie

- 187231010 | Adelia

- 187231011 | Cokorda Istri Trisna Shanti Maharani Pemayun

- 187231017 | Calista Dian Kemala

## Teknologi yang Digunakan

* **Framework**: [Flutter](https://flutter.dev/)
* **Bahasa**: [Dart](https://dart.dev/)
* **Backend / Database**: [Supabase](https://supabase.io/)
* **Lainnya**: Gemini API untuk CHATBOT

## Panduan Menjalankan Proyek Secara Lokal

Ikuti langkah-langkah di bawah ini untuk menjalankan proyek ini di lingkungan pengembangan Anda.

### 1. Prasyarat
Pastikan Anda sudah menginstal [Flutter SDK](https://docs.flutter.dev/get-started/install) di komputer Anda.

### 2. Clone Repository
Salin repositori ini ke mesin lokal Anda menggunakan perintah berikut:
```bash
git clone [URL_REPOSITORY_ANDA]
cd [NAMA_FOLDER_PROYEK]
```

### 3. Instal Dependencies
Jalankan perintah berikut untuk mengunduh semua package yang dibutuhkan oleh proyek:
```bash
flutter pub get
```

### 4. Konfigurasi Variabel Lingkungan
Untuk terhubung dengan layanan eksternal seperti Supabase, Anda perlu mengatur variabel lingkungan.

1.  Buat file baru bernama `.env` di dalam direktori root proyek Anda.
2.  Salin konten dari file `example.env` (jika ada) atau gunakan templat di bawah ini dan isi nilainya.

### 5. Jalankan Aplikasi
Hubungkan perangkat (emulator atau perangkat fisik) dan jalankan aplikasi dengan perintah:
```bash
flutter run
```

## Variabel Lingkungan (.env)

Proyek ini memerlukan beberapa kunci API dan konfigurasi yang disimpan dalam file `.env`. Pastikan file ini **tidak** di-commit ke repository publik dengan menambahkannya ke file `.gitignore`.

**Contoh isi file `.env`:**
```
# Konfigurasi untuk Supabase
SUPABASE_URL=[https://xxxxxxxxxxxxxxxxxxxx.supabase.co](https://xxxxxxxxxxxxxxxxxxxx.supabase.co)
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxxxxxxxxx.xxxxxxxxxxxx
```
Ganti nilai di atas dengan URL dan Kunci Anon Supabase proyek Anda.

## Manajemen Versi

Pengelolaan versi aplikasi dilakukan dengan cermat menggunakan **Git**. Setiap perubahan signifikan didorong (pushed) ke repositori ini untuk memastikan semua riwayat pengembangan tercatat dengan baik dan transparan.

## Sumber Daya Tambahan

Beberapa sumber daya untuk memulai jika ini adalah proyek Flutter pertama Anda:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Untuk bantuan lebih lanjut mengenai pengembangan Flutter, lihat [dokumentasi online](https://docs.flutter.dev/), yang menawarkan tutorial, sampel, panduan pengembangan seluler, dan referensi API lengkap.