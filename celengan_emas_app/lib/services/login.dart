import 'package:flutter/material.dart';
import 'main.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _currentMethod = 'wa'; // 'wa' atau 'email'

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
              // Brand & Mascot Header
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2CA50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBKqAVzg_ufcMmk3RWGDeZ6NstSiF29QlgD7FcO7AQHrkVDea9o1jRXHYUKubuyXYIOrSUTHQxT2F95O3NUeFai-1sgSy71F6O4GtBEWA82rhob2Isfe-IXl5A-h6Um8FVJcjzNvSFxXRzGAWWSII_sMxAsksDVouZghO6QqSzrKuSYTYBaL0-vd5AGmjh3UQB4H8y8fGnegLdhjWlt_sKjiV631ZxTy-eHM4UlQ1HfWaaorjqAhirE41RRK3nCUeCPfw',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'CELENGAN EMAS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF2CA50),
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk Akun',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE3E2E5),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Akses brankas & portofolio emas Anda',
                style: TextStyle(fontSize: 12, color: Color(0xFFD0C5AF)),
              ),
              const SizedBox(height: 24),

              // Main Interaction Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1C1E),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Switcher: WhatsApp / Email
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0E10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _currentMethod = 'wa'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _currentMethod == 'wa' ? const Color(0xFF292A2C) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      size: 17,
                                      color: _currentMethod == 'wa' ? const Color(0xFFF2CA50) : const Color(0xFFC6C6CA),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'WhatsApp',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: _currentMethod == 'wa' ? FontWeight.bold : FontWeight.w500,
                                        color: _currentMethod == 'wa' ? const Color(0xFFF2CA50) : const Color(0xFFC6C6CA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _currentMethod = 'email'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _currentMethod == 'email' ? const Color(0xFF292A2C) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.mail,
                                      size: 17,
                                      color: _currentMethod == 'email' ? const Color(0xFFF2CA50) : const Color(0xFFC6C6CA),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: _currentMethod == 'email' ? FontWeight.bold : FontWeight.w500,
                                        color: _currentMethod == 'email' ? const Color(0xFFF2CA50) : const Color(0xFFC6C6CA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact Input Panels
                    if (_currentMethod == 'wa') ...[
                      // WhatsApp Form Panel
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Nomor WhatsApp Terdaftar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                              Text('Aktif', style: TextStyle(fontSize: 10, color: Color(0xFFF2CA50), letterSpacing: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2022),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🇮🇩', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 4),
                                    Text('+62', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE3E2E5))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(fontSize: 14, color: Color(0xFFE3E2E5)),
                                  decoration: InputDecoration(
                                    hintText: 'Contoh: 812-3456-7890',
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
                        ],
                      ),
                    ] else ...[
                      // Email Form Panel
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Alamat Email Terdaftar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0C5AF))),
                              Text('Valid', style: TextStyle(fontSize: 10, color: Color(0xFFF2CA50), letterSpacing: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 14, color: Color(0xFFE3E2E5)),
                            decoration: InputDecoration(
                              hintText: 'Contoh: nama@email.com',
                              hintStyle: const TextStyle(color: Color(0xFF99907C), fontSize: 13),
                              prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF99907C), size: 18),
                              filled: true,
                              fillColor: const Color(0xFF1F2022),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Verification Mode Container (PIN Keamanan 4-Digit)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2022).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.lock, color: Color(0xFFF2CA50), size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'PIN KEAMANAN (4-DIGIT)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE3E2E5), letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                                onPressed: () {},
                                child: const Text('Lupa PIN?', style: TextStyle(fontSize: 11, color: Color(0xFFF2CA50), fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: index == 1 || index == 2 ? 6 : 0),
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
                                      fillColor: const Color(0xFF292A2C),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary Action Button (CTA)
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
                          foregroundColor: const Color(0xFF241A00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Masuk Sekarang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Switch Link to Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun?', style: TextStyle(fontSize: 12, color: Color(0xFFD0C5AF))),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                          child: const Row(
                            children: [
                              Text('Daftar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50))),
                              SizedBox(width: 2),
                              Icon(Icons.east, size: 14, color: Color(0xFFF2CA50)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}