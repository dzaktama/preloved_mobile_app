import 'package:flutter/material.dart';
import '../../controller/profile_controller.dart';
import '../../model/userModel.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  
  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController _profileController = ProfileController();
  
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _nomorHpController;
  late TextEditingController _alamatController;
  
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFFE84118);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF2F3640);
  static const Color textLight = Color(0xFF57606F);
  static const Color borderColor = Color(0xFFDFE4EA);

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.uName);
    _emailController = TextEditingController(text: widget.user.uEmail);
    _nomorHpController = TextEditingController(text: widget.user.uPhone);
    _alamatController = TextEditingController(text: widget.user.uAddress);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nomorHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _handleSimpanProfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Cek email tersedia
      bool emailTersedia = await _profileController.cekEmailTersedia(
        _emailController.text,
        widget.user.uEmail ?? '',
      );

      if (!emailTersedia) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah digunakan oleh user lain'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update profil
      bool berhasil = await _profileController.updateProfil(
        user: widget.user,
        namaBaru: _namaController.text,
        emailBaru: _emailController.text,
        nomorHpBaru: _nomorHpController.text,
        alamatBaru: _alamatController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: widget.user.uFotoProfil != null &&
                                  widget.user.uFotoProfil!.isNotEmpty
                              ? Image.network(
                                  widget.user.uFotoProfil!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to change photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _alamatController,
                      maxLines: 3,
                      style: const TextStyle(color: textDark),
                      decoration: _inputDecoration('Address', Icons.location_on_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: textDark),
                      decoration: _inputDecoration('Email', Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nomorHpController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: textDark),
                      decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor HP tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _alamatController,
                      maxLines: 3,
                      style: const TextStyle(color: textDark),
                      decoration: _inputDecoration('Address', Icons.location_on_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSimpanProfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: primaryColor.withOpacity(0.1),
      child: Center(
        child: Text(
          widget.user.uName?.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: textLight),
      labelStyle: const TextStyle(color: textLight),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 12, height: 0.8),
    );
  }
}