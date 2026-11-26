import 'package:flutter/material.dart';

import 'package:celengan_emas_app/main.dart' as app;

import 'api_service.dart';
import 'login.dart';
import 'signup_page.dart';

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
            final double logoSize = isCompact ? 92 : 108;
            final double headlineSize = isCompact ? 24 : 28;

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
                                'Simpan & Pantau\nInvestasi Emas',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: headlineSize,
                                  fontWeight: FontWeight.bold,
                                  color: _onSurface,
                                  height: 1.25,
                                  letterSpacing: -0.5,
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
                              SizedBox(
                                width: double.infinity,
                                height: 54,
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
                                    backgroundColor: _primary,
                                    foregroundColor: const Color(0xFF3C2F00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                    shadowColor: const Color(0x4DF2CA50),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Masuk ke Akun',
                                        style: TextStyle(
                                          fontSize: 15,
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
                                height: 50,
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
                              const SizedBox(height: 20),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x66F2CA50), width: 1.5),
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
