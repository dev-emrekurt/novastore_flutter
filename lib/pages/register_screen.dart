import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novastore_flutter/theme.dart';
import 'package:novastore_flutter/services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// Validasyon kontrol et
  bool _validateForm() {
    if (_fullNameController.text.isEmpty) {
      _showError('Ad Soyad boş bırakılamaz');
      return false;
    }

    if (_emailController.text.isEmpty) {
      _showError('E-mail adresi boş bırakılamaz');
      return false;
    }

    if (!_emailController.text.contains('@')) {
      _showError('Geçerli bir e-mail adresi giriniz');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Şifre boş bırakılamaz');
      return false;
    }

    if (_passwordController.text.length < 8) {
      _showError('Şifre en az 8 karakter olmalıdır');
      return false;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      _showError('Şifreler eşleşmiyor');
      return false;
    }

    return true;
  }

  /// Hata göster
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.montserrat()),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Kayıt işlemini gerçekleştir
  Future<void> _handleRegister() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      developer.log('Kayıt işlemi başlatıldı', name: 'REGISTER', level: 800);

      await ApiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      developer.log(
        'Kayıt başarılı, login_screen\'e yönlendiriliyour',
        name: 'REGISTER',
        level: 800,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hesap başarıyla oluşturuldu! Lütfen giriş yapınız.',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        // Login ekranına yönlendir
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      developer.log('Kayıt hatası: $e', name: 'REGISTER', level: 1000);

      if (mounted) {
        _showError('Kayıt başarısız: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.secondary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(Icons.create, size: 32, color: colorScheme.primary),

                  Text(
                    'Hesap Oluştur',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Alışverişe başlamak için hesabınızı oluşturun',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ad Soyad',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Ad Soyad alanı
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        hintText: 'Adınız ve soyadınız',
                        filled: true,
                        fillColor: colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.person,
                          color: colorScheme.onSurface,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-mail Adresi',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Email alanı
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'E-posta adresiniz',
                        filled: true,
                        fillColor: colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.email,
                          color: colorScheme.onSurface,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Şifre alanı
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Şifre',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Şifreniz',
                        filled: true,
                        fillColor: colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: colorScheme.onSurface,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Şifre Tekrar',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _passwordConfirmController,
                      obscureText: _obscurePasswordConfirm,
                      decoration: InputDecoration(
                        hintText: 'Şifrenizi tekrar giriniz',
                        filled: true,
                        fillColor: colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: colorScheme.onSurface,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePasswordConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePasswordConfirm =
                                  !_obscurePasswordConfirm;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.onSurface,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Giriş Yap Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      if (_isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Icon(Icons.edit, color: colorScheme.onPrimary),
                      Text(
                        _isLoading ? 'Kaydediliyor...' : 'Hesap Oluştur',
                        style: GoogleFonts.montserrat(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kayıt Ol
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Zaten bir hesabınız var mı?',
                    style: GoogleFonts.montserrat(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Hemen giriş yapın',
                      style: GoogleFonts.montserrat(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
