import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// BELUM BISA UBAH FOTO PROFIL

class UbahProfil extends StatefulWidget {
  const UbahProfil({Key? key}) : super(key: key);

  @override
  State<UbahProfil> createState() => _UbahProfilState();
}

class _UbahProfilState extends State<UbahProfil> {
  final supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedGender;
  String? _selectedKelurahan;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _kelurahanList = [];
  bool _isLoadingKelurahan = false;
  bool _isSaving = false;

  Map<String, dynamic>? userData;
  String? currentUserId;
  String? currentPhotoUrl;
  Uint8List? _selectedImageBytes;
  bool _isLoadingProfile = true;

  // Removed duplicate build method to resolve duplicate definition error.

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadKelurahan();
    await _loadUserProfile();
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

  // Load user profile data
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _showSnackBar('Pengguna tidak ditemukan. Silahkan masuk kembali.', Colors.red);
        return;
      }

      currentUserId = currentUser.id;
      print('Loading profile for user: $currentUserId');

      // Load data dari tabel pengguna
      final response = await supabase
          .from('pengguna')
          .select('nama_lengkap, jenis_kelamin, tanggal_lahir, nomor_telepon, detail_alamat, foto, id_kelurahan')
          .eq('id_pengguna', currentUserId!)
          .maybeSingle();

      print('Profile data response: $response');

      if (response != null) {
        userData = response; //userData

        // Set from fields dengan data yang diambil
        _nameController.text = response['nama_lengkap'] ?? '';
        _phoneController.text = response['nomor_telepon'] ?? '';
        _addressController.text = response['detail_alamat'] ?? '';
        _selectedGender = response['jenis_kelamin'] ?? '';

        _selectedKelurahan = response['id_kelurahan']?.toString();
        currentPhotoUrl = response['foto'];

        //Set tanggal lahir
        if (response['tanggal_lahir'] != null) {
          try {
            _selectedDate = DateTime.parse(response['tanggal_lahir']);
            _dateController.text = 
              "${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}";
          } catch (e) {
            print('Error parsing date: $e');
          }
        }
      } else {
        print('Tidak ada profil ditemukan untuk pengguna');
      }

      // Set email dari auth
      _emailController.text = currentUser.email ?? '';

      setState(() {
        _isLoadingProfile = false;
      });

    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoadingProfile = false;
      });

      if (e.toString().contains('PGRST')) {
        _showSnackBar('Error database: Perikasa koneksi dan struktur tabel.', Colors.red);
      } else {
        _showSnackBar('Gagal memuat profil: ${e.toString()}', Colors.red);
      }
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
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

  // Ambil gambar
Future<void> _pickImage() async {
  try {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Opsi untuk Mobile/Desktop Native
              //if (!kIsWeb) ...[
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: Text('Pilih dari File', style: GoogleFonts.poppins()),
                  onTap: () async {
                    Navigator.pop(context);
                    await _selectImageMobile(ImageSource.gallery); //ImageSource.gallery
                  },
                ),

                if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text('Ambil Foto', style: GoogleFonts.poppins()),
                  onTap: () async {
                    Navigator.pop(context);
                    await _selectImageMobile(ImageSource.camera);
                  },
                ),
              //],
              
              // Opsi untuk Web/Desktop
              //ListTile(
                //leading: const Icon(Icons.folder_open),
                //title: Text(
                  //kIsWeb ? 'Pilih dari Komputer' : 'Pilih dari File', 
                  //style: GoogleFonts.poppins()
                //),
                //onTap: () async {
                  //Navigator.pop(context);
                  //await _selectImageFromFile();
                //},
              //),
              
              // Opsi hapus foto
              if (currentPhotoUrl != null || _selectedImageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text('Hapus Foto', style: GoogleFonts.poppins(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  } catch (e) {
    print('Error showing image picker: $e');
    _showSnackBar('Gagal membuka pilihan gambar', Colors.red);
  }
}
 
// Method untuk mobile (existing)
Future<void> _selectImageMobile(ImageSource source) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      final imageBytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
      });
      print('Image selected from mobile: ${image.path}');
    }
  } catch (e) {
    print('Error selecting image from mobile: $e');
    _showSnackBar('Gagal memilih gambar: ${e.toString()}', Colors.red);
  }
}

// Method baru untuk file picker (desktop/web)
Future<void> _selectImageFromFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // Penting untuk mendapatkan byte data
      //allowedExtensions: null, // Akan otomatis filter image files
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      
      // Validasi ukuran file (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        _showSnackBar('Ukuran file terlalu besar. Maksimal 5MB.', Colors.red);
        return;
      }
      
      // Validasi tipe file
      if (!_isValidImageType(file.extension)) {
        _showSnackBar('Format file tidak didukung. Gunakan JPG, PNG, atau GIF.', Colors.red);
        return;
      }

      //Uint8List? fileBytes = file.bytes;
      
      if (file.bytes != null) {
        setState(() {
          _selectedImageBytes = file.bytes;
        });
        _showSnackBar('Foto berhasil dipilih!', Colors.green);
      } else {
        _showSnackBar('Gagal membaca file gambar', Colors.red);
      }
    }
  } catch (e) {
    print('Error selecting image from file: $e');
    _showSnackBar('Gagal memilih gambar: ${e.toString()}', Colors.red);
  }
}

bool _isValidImageType(String? extension) {
  if (extension == null) return false;
  
  final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  return validExtensions.contains(extension.toLowerCase());
}

void _removePhoto() {
  setState(() {
    _selectedImageBytes = null;
    currentPhotoUrl = null;
  });
}

Future<String?> _uploadImage() async {
  try {
    // Generate a unique filename for the image
    final String fileName = 'profile_${currentUserId ?? DateTime.now().millisecondsSinceEpoch}.jpg';
    print('Uploading image: $fileName (${_selectedImageBytes!.length} bytes)');
    
    await supabase.storage
        .from('avatars')
        .uploadBinary(fileName, _selectedImageBytes!);

    final imageUrl = supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

    print('Image uploaded successfully: $imageUrl');
    return imageUrl;
  } catch (e) {
    print('Error uploading image: $e');
    
    // Handle specific errors
    String errorMessage = 'Gagal mengupload foto';
    if (e.toString().contains('413')) {
      errorMessage = 'File terlalu besar. Maksimal 5MB.';
    } else if (e.toString().contains('401')) {
      errorMessage = 'Tidak memiliki izin upload. Silakan login kembali.';
    } else if (e.toString().contains('404')) {
      errorMessage = 'Bucket avatars tidak ditemukan. Perikasa konfigurasi Storage.';
    } else {
      errorMessage = 'Gagal mengupload foto: ${e.toString()}';
    }
    
    _showSnackBar(errorMessage, Colors.red);
    return null;
  }
}
  // Validasi form
  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Nama lengkap harus diisi!', Colors.red);
      return false;
    }

    if (_selectedGender == null) {
      _showSnackBar('Jenis kelamin harus dipilih!', Colors.red);
      return false;
    }

    if (_selectedDate == null) {
      _showSnackBar('Tanggal lahir harus dipilih!', Colors.red);
      return false;
    }

    if (_phoneController.text.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9+\-\s]{10,15}$');
      if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
        _showSnackBar('Format nomor telepon tidak valid!', Colors.red);
        return false;
      }
    }

    return true;
  }

  // Save changes to database
  Future<void> _saveChanges() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      String? newPhotoUrl = currentPhotoUrl;
      
      // Upload foto baru jika ada
      if (_selectedImageBytes != null) {
        newPhotoUrl = await _uploadImage();
      }

      // Prepare data untuk update
      Map<String, dynamic> updateData = {
        'nama_lengkap': _nameController.text.trim(),
        'jenis_kelamin': _selectedGender,
        'tanggal_lahir': _selectedDate!.toIso8601String().split('T')[0],
        'nomor_telepon': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'detail_alamat': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'id_kelurahan': _selectedKelurahan,
        'foto': newPhotoUrl,
        //'updated_at': DateTime.now().toIso8601String(),
      };

      print('Updating user data: $updateData');

      // Check if user data exists
      final existingData = await supabase
          .from('pengguna')
          .select('id_pengguna')
          .eq('id_pengguna', currentUserId!)
          .maybeSingle();

      if (existingData != null) {
        // Update existing record
        await supabase
            .from('pengguna')
            .update(updateData)
            .eq('id_pengguna', currentUserId!);
      } else {
        // Insert new record
        updateData['id_pengguna'] = currentUserId!;
        //updateData['created_at'] = DateTime.now().toIso8601String();
        
        await supabase
            .from('pengguna')
            .insert(updateData);
      }

      print('Profile updated successfully');
      
      _showSnackBar('Profil berhasil diperbarui!', Colors.green);
      
      // Return true to indicate success
      Navigator.pop(context, true);

    } catch (e) {
      print('Error saving profile: $e');

      String errorMessage = 'Gagal menyimpan profil';

      if (e.toString().contains('PGRST204')) {
        errorMessage = 'Error: Kolom database tidak ditemukan. Periksa struktur tabel.';
      } else if (e.toString().contains('PGRST')) {
        errorMessage = 'Error database: ${e.toString()}';
      } else {
        errorMessage = 'Gagal menyimpan profil: ${e.toString()}';
      }

      _showSnackBar(errorMessage, Colors.red);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Build profile image widget
  Widget _buildProfileImage() {
    Widget imageWidget;
    
    if (_selectedImageBytes != null) {
      // Show selected image
      imageWidget = Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
      );
    } else if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty) {
      // Show current image from URL
      imageWidget = Image.network(
        currentPhotoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D8D7A)),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading profile image: $error');
          return _buildDefaultAvatar();
        },
      );
    } else {
      // Show default avatar
      imageWidget = _buildDefaultAvatar();
    }

    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        child: imageWidget,
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    String firstLetter = 'U';
    if (_nameController.text.isNotEmpty) {
      firstLetter = _nameController.text.substring(0, 1).toUpperCase();
    }

    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFF3D8D7A),
      child: Center(
        child: Text(
          firstLetter,
          style: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ubah Profil",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color(0xFF3D8D7A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D8D7A)),
              ),
            )
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

Center(
  child: Column(
    children: [
      // Foto Profil dengan indikator
      Stack(
        children: [
          _buildProfileImage(),
          
          // Tombol edit foto
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF3D8D7A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          
          // Indikator bahwa ada gambar baru yang dipilih
          if (_selectedImageBytes != null)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
      
      const SizedBox(height: 10),
      
      // Teks info jika ada gambar baru
      if (_selectedImageBytes != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Foto baru dipilih',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      
      const SizedBox(height: 8),
      
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _nameController.text.isEmpty ? "Nama Pengguna" : _nameController.text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _emailController.text.isEmpty ? "xxxxxx@gmail.com" : _emailController.text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    ],
  ),
),
                      const SizedBox(height: 30),

                      // Form fields
                      _buildTextField(
                        controller: _nameController,
                        hint: "Nama Lengkap",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildDateField(),
                      const SizedBox(height: 12),

                      _buildDropdownField(
                        hint: "Jenis Kelamin",
                        value: _selectedGender,
                        items: ["Laki-laki", "Perempuan"],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _phoneController,
                        hint: "Nomor Telepon (Opsional)",
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _addressController,
                        hint: "Alamat Lengkap (Opsional)",
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      _buildKelurahanDropdown(),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _emailController,
                        hint: "Email",
                        enabled: false, // Email tidak bisa diubah
                      ),
                      const SizedBox(height: 30),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D8D7A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _isSaving ? null : _saveChanges,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  "Simpan Perubahan",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3D8D7A)),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required List<String> items,
    String? value,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        hint: Text(
          hint,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
        underline: Container(),
        onChanged: onChanged,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.poppins()),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildKelurahanDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: _isLoadingKelurahan
          ? const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D8D7A)),
                  ),
                ),
              ),
            )
          : DropdownButton<String>(
              isExpanded: true,
              value: _selectedKelurahan,
              hint: Text(
                "Pilih Kelurahan",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              underline: Container(),
              onChanged: (value) {
                setState(() {
                  _selectedKelurahan = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    "Tidak dipilih",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
                ..._kelurahanList.map((kelurahan) => DropdownMenuItem<String>(
                  value: kelurahan['id_kelurahan']?.toString(),
                  child: Text(
                    kelurahan['nama_kelurahan'],
                    style: GoogleFonts.poppins(),
                  ),
                )),
              ],
            ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? "Tanggal Lahir"
                  : "${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}",
              style: GoogleFonts.poppins(
                color: _selectedDate == null ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}