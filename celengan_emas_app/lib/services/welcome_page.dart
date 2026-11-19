import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121315),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Stack(
              children: [
                // Ambient Atmospheric Gold Aura (Efek Cahaya Latar Belakang)
                Positioned(
                  top: -40,
                  left: MediaQuery.of(context).size.width / 2 - 160,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2CA50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Main Scrollable Flow
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        
                        // Hero 3D Logo Section
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2CA50).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 112,
                              height: 112,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1C1E),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCY4R1_JS0fNirb0m1yh1mkxR-srO2XVn8eT4wia6LbE-XI6NBvACxfh14a9EDM8omOdqXg_0GlO6fXYdg7liP8KDD46yGK9BakLC5gJWbSK9PfdezUAXdABp3IopZp_5CQPfIfa4hNktB4GoCxmgw095fAgNCj4hg_R9fLU9SVzIjyAZ5x3Z7_y567Kv0zlp__d_mshmZPk1csVfScUerLkd5EZlocoHwSDJT1zuPuS9rz2EraprHAe_Ih-mrED-7aOg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tracked Brand Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, const Color(0xFFF2CA50).withOpacity(0.4)],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'CELENGAN EMAS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3.5,
                                  color: Color(0xFFF2CA50),
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color(0xFFF2CA50).withOpacity(0.4), Colors.transparent],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Editorial Headline & Subtitle
                        const Text(
                          'Simpan & Pantau\nInvestasi Emas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE3E2E5),
                            height: 1.25,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Pencatat portofolio emas & perhiasan fisik Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFC6C6CA),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // CTA Decision Group (Tombol Masuk & Buat Akun)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF2CA50),
                              foregroundColor: const Color(0xFF3C2F00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              shadowColor: const Color(0xFFF2CA50).withOpacity(0.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Masuk ke Akun',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.login, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF292A2C),
                              foregroundColor: const Color(0xFFE3E2E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Buat Akun Baru',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Guest / Direct Market Overview Link
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Cek Harga Emas Hari Ini',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF2CA50),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('→', style: TextStyle(fontSize: 14, color: Color(0xFFF2CA50))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Security & Legal Compliance Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.lock_outline, size: 13, color: Color(0x99C6C6CA)),
                            SizedBox(width: 6),
                            Text(
                              'Terenkripsi & Terlindungi',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0x99C6C6CA),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}