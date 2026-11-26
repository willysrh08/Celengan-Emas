import 'package:flutter/material.dart';
import 'package:celengan_emas_app/main.dart'; // Diperlukan untuk navigasi kembali ke HomeScreen

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _selectedOtpMethod = 'WhatsApp';

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
                            onTap: () => setState(() => _selectedOtpMethod = 'WhatsApp'),
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
                            onTap: () => setState(() => _selectedOtpMethod = 'Email'),
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
                      onPressed: () {},
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
                        onPressed: () {},
                        child: const Text('Kirim Ulang (58s)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFF2CA50))),
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
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
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
                          onPressed: () => Navigator.pop(context),
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