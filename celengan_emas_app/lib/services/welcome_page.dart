import 'package:flutter/material.dart';

import 'package:celengan_emas_app/main.dart' as app;

import 'api_service.dart';
import 'login.dart';
import 'signup_page.dart';

// Gradasi emas dari Figma: #F2CA50 -> #FFE088 -> #D4AF37 (kiri ke kanan)
const LinearGradient _goldGradient = LinearGradient(
  colors: [Color(0xFFF2CA50), Color(0xFFFFE088), Color(0xFFD4AF37)],
);

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  static const Color _surface = Color(0xFF121315);
  static const Color _primary = Color(0xFFF2CA50);
  static const Color _surfaceContainerHigh = Color(0xFF292A2C);
  static const Color _onSurface = Color(0xFFE3E2E5);
  static const Color _secondary = Color(0xFFC6C6CA);

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await ApiService.readToken();
    if (token == null || !mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const app.HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final bool isCompact = viewport.maxWidth < 360;
            final double logoSize = isCompact ? 96 : 112; // Figma: 112 px
            final double headlineSize = isCompact ? 22 : 24; // Figma: 24 px

            return Stack(
              children: [
                // Ambient gold aura behind the hero content.
                const Positioned(
                  top: -180,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: SizedBox(
                      height: 420,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.55,
                            colors: [
                              Color(0x33F2CA50),
                              Color(0x14F2CA50),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewport.maxHeight,
                      ),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 440),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildHeroLogo(logoSize),
                              const SizedBox(height: 20),
                              _buildBrandLabel(),
                              const SizedBox(height: 14),
                              Text(
                                'Simpan & Pantau',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: headlineSize,
                                  fontWeight: FontWeight.bold,
                                  color: _onSurface,
                                  height: 1.25,
                                ),
                              ),
                              // "Investasi Emas" bergradasi emas seperti di Figma
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) =>
                                    _goldGradient.createShader(bounds),
                                child: Text(
                                  'Investasi Emas',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: headlineSize,
                                    fontWeight: FontWeight.bold,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Pencatat portofolio emas & perhiasan fisik Anda.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _secondary,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Primary action: masuk ke akun yang sudah ada.
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: _goldGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x33F2CA50),
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: const Color(0xFF3C2F00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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

                              // Secondary action: registrasi akun baru.
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _surfaceContainerHigh,
                                    foregroundColor: _onSurface,
                                    side: const BorderSide(
                                      color: Color(0x33F2CA50),
                                    ),
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

                              // Tautan "Cek Harga Emas Hari Ini" dari Figma.
                              // Halaman harga belum ada, jadi untuk sementara
                              // menampilkan pemberitahuan.
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Halaman Harga Emas segera hadir.',
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Cek Harga Emas Hari Ini',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 14,
                                      color: _primary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSecurityFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroLogo(double logoSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: logoSize + 56,
          height: logoSize + 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0x33F2CA50),
                Color(0x0AF2CA50),
                Colors.transparent,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(8),
          // Kotak logo sesuai Figma: #1B1C1E, sudut 16 px
          decoration: BoxDecoration(
            color: const Color(0xFF1B1C1E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40F2CA50),
                blurRadius: 32,
                spreadRadius: 2,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/logo_celengan_emas.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x66F2CA50)],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'CELENGAN EMAS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.5,
              color: _primary,
            ),
          ),
        ),
        Container(
          width: 24,
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x66F2CA50), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 13, color: Color(0x99C6C6CA)),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Terenkripsi & Terlindungi',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Color(0x99C6C6CA),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
