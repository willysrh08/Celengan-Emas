import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:celengan_emas_app/main.dart'; // Diperlukan untuk navigasi kembali ke HomeScreen
import 'api_service.dart';
import 'login.dart';
import 'welcome_page.dart' as welcome;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _selectedOtpMethod = 'WhatsApp';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());
  bool _otpSent = false;
  bool _isLoading = false;
  bool _isSendingOtp = false;
  String? _otpTarget;
  Timer? _resendTimer;
  int _resendSeconds = 0;

  static const int _otpResendCooldownSeconds = 60;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpDestination => _selectedOtpMethod == 'WhatsApp'
      ? ApiService.normalizePhone(_phoneController.text)
      : _emailController.text.trim();

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFFE3E2E5), fontSize: 12),
        ),
        backgroundColor: const Color(0xFF292A2C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _setOtpMethod(String method) {
    if (_selectedOtpMethod == method) {
      return;
    }
    _resendTimer?.cancel();
    setState(() {
      _selectedOtpMethod = method;
      _otpSent = false;
      _otpTarget = null;
      _resendSeconds = 0;
      for (final controller in _otpControllers) {
        controller.clear();
      }
    });
  }

  void _handleDigitChanged(
    int index,
    String value,
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty && index < controllers.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
  }

  String? _validateOtpDestination() {
    if (_selectedOtpMethod == 'WhatsApp') {
      final phone = ApiService.normalizePhone(_phoneController.text);
      if (phone.length < 10 || phone.length > 15) {
        return 'Nomor WhatsApp tidak valid. Gunakan 10–15 digit angka.';
      }
    } else {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        return 'Alamat email wajib diisi.';
      }
      if (!_isValidEmail(email)) {
        return 'Format alamat email tidak valid.';
      }
    }
    return null;
  }

  Future<void> _handleSendOtp() async {
    if (_isSendingOtp || _resendSeconds > 0) {
      return;
    }

    final destinationError = _validateOtpDestination();
    if (destinationError != null) {
      _showMessage(destinationError);
      return;
    }

    final target = _otpDestination;
    final type = _selectedOtpMethod == 'WhatsApp' ? 'wa' : 'email';

    setState(() => _isSendingOtp = true);
    try {
      await ApiService.sendOtp(target: target, type: type);
      if (!mounted) {
        return;
      }
      setState(() {
        _otpSent = true;
        _otpTarget = target;
        for (final controller in _otpControllers) {
          controller.clear();
        }
      });
      _showMessage('Kode OTP dikirim ke $target.');
      _startResendCountdown();
    } on ApiException catch (exception) {
      _showMessage(exception.message);
    } catch (_) {
      _showMessage('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() => _resendSeconds = _otpResendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() {
        _resendSeconds--;
      });
    });
  }

  String? _validateRegistration() {
    if (_nameController.text.trim().isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return 'Alamat email wajib diisi.';
    }
    if (!_isValidEmail(email)) {
      return 'Format alamat email tidak valid.';
    }

    final phone = ApiService.normalizePhone(_phoneController.text);
    if (phone.length < 10 || phone.length > 15) {
      return 'Nomor WhatsApp tidak valid. Gunakan 10–15 digit angka.';
    }
    if (!_otpSent) {
      return 'Silakan kirim kode OTP terlebih dahulu.';
    }

    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      return 'Kode OTP harus 6 digit lengkap.';
    }

    final pin = _pinControllers.map((controller) => controller.text).join();
    if (pin.length != 4) {
      return 'PIN keamanan harus 4 digit lengkap.';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    final validationError = _validateRegistration();
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();

      await ApiService.verifyOtp(
        target: _otpTarget ?? _otpDestination,
        type: _selectedOtpMethod == 'WhatsApp' ? 'wa' : 'email',
        code: _otpControllers.map((controller) => controller.text).join(),
      );

      final password = ApiService.passwordFromPin(
        _pinControllers.map((controller) => controller.text).join(),
        email,
      );

      await ApiService.register(
        name: _nameController.text.trim(),
        email: email,
        password: password,
      );
      // Endpoint register belum mengembalikan token, jadi login otomatis
      // dilakukan untuk mendapatkan token Sanctum.
      await ApiService.login(email: email, password: password);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (exception) {
      _showMessage(exception.message);
    } catch (_) {
      _showMessage('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (Navigator.canPop(context)) {
      navigator.pop();
      return;
    }
    navigator.push(
      MaterialPageRoute(builder: (_) => const welcome.WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121315),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: _handleBack,
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFF2CA50)),
                  tooltip: 'Kembali',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                ),
              ),

              // Brand Showcase (Persis dengan logo dan efek blur/glow aslinya)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2CA50).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset(
                    'assets/logo_celengan_emas.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'CELENGAN EMAS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF2CA50),
                  letterSpacing: 3.5,
                ),
              ),
              const SizedBox(height: 16),

              // Editorial Welcome Card
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE3E2E5),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mulai simpanan & portofolio emas fisik Anda',
                style: TextStyle(fontSize: 12, color: Color(0xFFC6C6CA)),
              ),
              const SizedBox(height: 24),

              // Form Fields Container
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field 1: Nama Lengkap
                  const Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Color(0xFFF2CA50)),
                      SizedBox(width: 6),
                      Text('Nama Lengkap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 14, color: Color(0xFFE3E2E5)),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Aqwila Pratama',
                      hintStyle: const TextStyle(color: Color(0xFF99907C), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F2022),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field Alamat Email
                  const Row(
                    children: [
                      Icon(Icons.mail, size: 14, color: Color(0xFFF2CA50)),
                      SizedBox(width: 6),
                      Text('Alamat Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14, color: Color(0xFFE3E2E5)),
                    decoration: InputDecoration(
                      hintText: 'Contoh: nama@email.com',
                      hintStyle: const TextStyle(color: Color(0xFF99907C), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1F2022),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field 2: Nomor WhatsApp
                  const Row(
                    children: [
                      Icon(Icons.chat, size: 14, color: Color(0xFFF2CA50)),
                      SizedBox(width: 6),
                      Text('Nomor WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF292A2C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('🇮🇩 +62', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 14, color: Color(0xFFE3E2E5)),
                          decoration: InputDecoration(
                            hintText: '812-3456-7890',
                            hintStyle: const TextStyle(color: Color(0xFF99907C), fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFF1F2022),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Field 3: Metode Pengiriman OTP
                  const Row(
                    children: [
                      Icon(Icons.send_to_mobile, size: 14, color: Color(0xFFF2CA50)),
                      SizedBox(width: 6),
                      Text('Metode Pengiriman OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2022),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _setOtpMethod('WhatsApp'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedOtpMethod == 'WhatsApp' ? const Color(0xFF292A2C) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: _selectedOtpMethod == 'WhatsApp' ? Border.all(color: const Color(0xFF4D4635)) : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.chat, size: 14, color: Color(0xFFF2CA50)),
                                  const SizedBox(width: 6),
                                  Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _selectedOtpMethod == 'WhatsApp' ? const Color(0xFFF2CA50) : const Color(0xFFC6C6CA))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _setOtpMethod('Email'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedOtpMethod == 'Email' ? const Color(0xFF292A2C) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.mail, size: 14, color: Color(0xFFC6C6CA)),
                                  const SizedBox(width: 6),
                                  Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _selectedOtpMethod == 'Email' ? const Color(0xFFF2CA50) : const Color(0xFFC6C6CA))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol Kirim Kode OTP
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: (_isLoading || _isSendingOtp || _resendSeconds > 0) ? null : _handleSendOtp,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2CA50).withOpacity(0.1),
                        side: BorderSide(color: const Color(0xFFF2CA50).withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.send, size: 14, color: Color(0xFFF2CA50)),
                      label: Text('Kirim Kode OTP via $_selectedOtpMethod', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF2CA50))),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kode Verifikasi OTP (6 Kotak)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user, size: 14, color: Color(0xFFF2CA50)),
                          SizedBox(width: 6),
                          Text('Kode Verifikasi OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                        ],
                      ),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                        onPressed: (_isLoading || _isSendingOtp || _resendSeconds > 0) ? null : _handleSendOtp,
                        child: Text('Kirim Ulang (${_resendSeconds > 0 ? _resendSeconds : 58}s)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFF2CA50))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => SizedBox(
                      width: 44,
                      height: 44,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        onChanged: (value) => _handleDigitChanged(
                          index,
                          value,
                          _otpControllers,
                          _otpFocusNodes,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50)),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '•',
                          hintStyle: const TextStyle(color: Color(0xFF99907C)),
                          filled: true,
                          fillColor: const Color(0xFF1F2022),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF4D4635))),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),

                  // PIN Keamanan (4 Digit)
                  const Row(
                    children: [
                      Icon(Icons.lock, size: 14, color: Color(0xFFF2CA50)),
                      SizedBox(width: 6),
                      Text('PIN Keamanan (4 Digit)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: index == 1 || index == 2 ? 4 : 0),
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _pinControllers[index],
                            focusNode: _pinFocusNodes[index],
                            onChanged: (value) => _handleDigitChanged(
                              index,
                              value,
                              _pinControllers,
                              _pinFocusNodes,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            obscureText: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50)),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFF1F2022),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),

                  // Terms Micro-Notice
                  const Center(
                    child: Text(
                      'Dengan mendaftar, Anda menyetujui Ketentuan & Privasi',
                      style: TextStyle(fontSize: 11, color: Color(0xFFC6C6CA)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Primary Action Button (Buat Akun Sekarang)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2CA50),
                        foregroundColor: const Color(0xFF3C2F00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Buat Akun Sekarang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Navigation Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun?', style: TextStyle(fontSize: 12, color: Color(0xFFC6C6CA))),
                        TextButton(
                          onPressed: _goToLogin,
                          child: const Text('Masuk →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}