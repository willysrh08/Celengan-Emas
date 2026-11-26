import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/login.dart';

void main() => runApp(const CelenganEmasApp());

// ==========================================
// APLIKASI UTAMA & TEMA
// ==========================================
class CelenganEmasApp extends StatelessWidget {
  const CelenganEmasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Celengan Emas',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121315),
        primaryColor: const Color(0xFFF2CA50),
      ),
      home: const WelcomePage(),
    );
  }
}

// ==========================================
// 1. HALAMAN WELCOME
// ==========================================
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121315),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              _buildLogoContainer(),
              const SizedBox(height: 24),
              const Text('CELENGAN EMAS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.amber, letterSpacing: 2)),
              const SizedBox(height: 12),
              const Text('Simpan & Pantau\nInvestasi Emas', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
              const SizedBox(height: 16),
              const Text('Pencatat portofolio emas & perhiasan fisik Anda.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
              const Spacer(),
              _buildButton(
                text: 'Masuk ke Akun →',
                bgColor: Colors.amber.shade400,
                fgColor: Colors.black,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
              ),
              const SizedBox(height: 12),
              _buildButton(
                text: 'Buat Akun Baru',
                bgColor: const Color(0xFF1A1A1A),
                fgColor: Colors.white,
                borderColor: const Color(0xFF2C2C2C),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('Terenkripsi & Terlindungi', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      width: 90, height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.15), blurRadius: 25, spreadRadius: 5)],
      ),
      child: Center(
        child: Image.asset(
          'assets/logo_celengan_emas.png',
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required Color bgColor, required Color fgColor, Color? borderColor, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor, foregroundColor: fgColor,
          side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: bgColor == Colors.amber.shade400 ? 4 : 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN SIGN UP (DAFTAR AKUN)
// ==========================================
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF121315), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Buat Akun Baru', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mulai simpanan & portofolio emas fisik Anda', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildTextField('Nama Lengkap', 'Contoh: Aqwila Pratama'),
            const SizedBox(height: 16),
            _buildTextField('Alamat Email', 'Contoh: nama@email.com'),
            const SizedBox(height: 16),
            const Text('Nomor WhatsApp', style: TextStyle(fontSize: 12, color: Color(0xFFD0C5AF))),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(color: const Color(0xFF1F2022), borderRadius: BorderRadius.circular(10)),
                  child: const Text('🇮🇩 +62', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildInputBox('812-3456-7890', keyboardType: TextInputType.phone)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Metode Pengiriman OTP', style: TextStyle(fontSize: 12, color: Color(0xFFD0C5AF))),
            const SizedBox(height: 6),
            Row(
              children: ['WhatsApp', 'Email'].map((method) {
                bool isSelected = _selectedOtpMethod == method;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: method == 'WhatsApp' ? 10 : 0),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedOtpMethod = method),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF1F2022) : Colors.transparent,
                        side: BorderSide(color: isSelected ? Colors.amber : const Color(0xFF2C2C2C)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(method, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.amber),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Kirim Kode OTP via $_selectedOtpMethod', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2CA50), foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Buat Akun Sekarang →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFD0C5AF))),
        const SizedBox(height: 6),
        _buildInputBox(hint),
      ],
    );
  }

  Widget _buildInputBox(String hint, {TextInputType? keyboardType}) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true, fillColor: const Color(0xFF1F2022),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}

// ==========================================
// 3. DASHBOARD UTAMA (HOMESCREEN)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceHidden = false;
  int _currentIndex = 0;
  final String authToken = "MASUKKAN_TOKEN_SANCTUM_ANDA";

  Map<String, dynamic> _dummyData() => {
    'total_estimated_value': 184750000,
    'total_weight': 135.50,
    'assets': [
      {'name': 'Antam CertiCard 50g', 'weight': 50.00, 'purchase_price': 66000000, 'location': 'Brankas Toko', 'category': 'Logam Mulia'},
      {'name': 'Gelang Rantai Figaro 25g', 'weight': 25.00, 'purchase_price': 23000000, 'location': 'Simpan Mandiri', 'category': 'Perhiasan'},
      {'name': 'Batangan UBS Gold 10g', 'weight': 10.00, 'purchase_price': 13200000, 'location': 'Brankas Toko', 'category': 'Logam Mulia'},
    ]
  };

  Future<Map<String, dynamic>> fetchGoldData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.15:8000/api/gold-assets'),
        headers: {'Authorization': 'Bearer $authToken', 'Accept': 'application/json'},
      );
      return response.statusCode == 200 ? json.decode(response.body) : _dummyData();
    } catch (_) {
      return _dummyData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121315),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: const Color(0xFF121315), elevation: 0, automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF292A2C).withOpacity(0.6)),
                child: const Center(child: Text('🪙', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Row(children: [
                    Text('Halo, ', style: TextStyle(fontSize: 11, color: Color(0xFFD0C5AF))),
                    Text('Aqwila', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE3E2E5))),
                  ]),
                  Text('Celengan Emas', style: TextStyle(fontSize: 10, color: Color(0xFFF2CA50), fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Color(0xFFD0C5AF), size: 22),
                  Positioned(top: 2, right: 2, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF2CA50), shape: BoxShape.circle))),
                ],
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchGoldData(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? _dummyData();
          final totalValue = data['total_estimated_value'] ?? 184750000;
          final totalWeight = data['total_weight'] ?? 135.50;
          final assets = data['assets'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Net Worth Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2022), borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Estimasi Nilai Emas', style: TextStyle(fontSize: 12, color: Color(0xFFD0C5AF))),
                          IconButton(
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            icon: Icon(_isBalanceHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFD0C5AF), size: 20),
                            onPressed: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isBalanceHidden ? 'Rp ••••••••••' : 'Rp ${_formatCurrency(totalValue)}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFFE3E2E5), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF4D4635), width: 0.3))),
                        child: Row(
                          children: [
                            Expanded(child: _buildInfoCard(
                              icon: Icons.scale, iconColor: const Color(0xFFF2CA50), iconBg: const Color(0xFFF2CA50).withOpacity(0.1),
                              title: 'Total Berat', badge: '24K', value: '$totalWeight', unit: 'g',
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: _buildInfoCard(
                              icon: Icons.trending_up, iconColor: const Color(0xFF34D399), iconBg: const Color(0xFF10B981).withOpacity(0.15),
                              title: 'Keuntungan', customContent: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SizedBox(height: 2),
                                  Text('+Rp 5,72 Jt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                                  Text('(+3.2%)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF34D399))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Live Price Ticker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF0D0E10), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('Harga Toko Hari Ini', style: TextStyle(fontSize: 11, color: Color(0xFFD0C5AF))),
                        ],
                      ),
                      Row(
                        children: const [
                          Text('24K: Rp1.320.000/g', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50))),
                          SizedBox(width: 8),
                          Text('▲ 0.8%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Action Buttons
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2CA50), foregroundColor: const Color(0xFF3C2F00),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4,
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_circle, size: 20),
                          SizedBox(width: 8),
                          Text('Catat Aset Emas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildActionButton(Icons.calculate, 'Kalkulator Emas')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildActionButton(Icons.verified_user, 'Cek Sertifikat')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Asset Composition
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0D0E10), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('KOMPOSISI PORTOFOLIO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE3E2E5), letterSpacing: 0.5)),
                          Text('Total $totalWeight gr', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(color: const Color(0xFF343537), borderRadius: BorderRadius.circular(99)),
                        child: Row(
                          children: [
                            Expanded(flex: 7, child: Container(decoration: BoxDecoration(color: const Color(0xFFF2CA50), borderRadius: BorderRadius.circular(99)))),
                            const SizedBox(width: 2),
                            Expanded(flex: 2, child: Container(decoration: BoxDecoration(color: const Color(0xFFB89065), borderRadius: BorderRadius.circular(99)))),
                            const SizedBox(width: 2),
                            Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: const Color(0xFF7D8774), borderRadius: BorderRadius.circular(99)))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _CompositionLegend(color: Color(0xFFF2CA50), title: 'Logam Mulia ', percentage: '70%', textColor: Color(0xFFF2CA50)),
                          _CompositionLegend(color: Color(0xFFB89065), title: 'Perhiasan ', percentage: '20%', textColor: Color(0xFFC9A47C)),
                          _CompositionLegend(color: Color(0xFF7D8774), title: 'Tabungan ', percentage: '10%', textColor: Color(0xFF98A58F)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Recent Assets List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: const [
                      Icon(Icons.history, color: Color(0xFFF2CA50), size: 18),
                      SizedBox(width: 6),
                      Text('ASET TERAKHIR DITAMBAHKAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE3E2E5), letterSpacing: 0.5)),
                    ]),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                      onPressed: () {},
                      child: Row(children: const [
                        Text('Lihat Semua', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF2CA50))),
                        Icon(Icons.arrow_forward, size: 14, color: Color(0xFFF2CA50)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    var item = assets[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF0D0E10), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: const Color(0xFF292A2C), borderRadius: BorderRadius.circular(8)),
                                child: const Center(child: Icon(Icons.shield, color: Color(0xFFF2CA50), size: 22)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE3E2E5))),
                                  const SizedBox(height: 2),
                                  Text('${item['weight']} gr • ${item['location'] ?? 'Brankas'}', style: const TextStyle(fontSize: 11, color: Color(0xFFD0C5AF))),
                                ],
                              ),
                            ],
                          ),
                          Text('Rp ${_formatCurrency(item['purchase_price'])}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50))),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0E10).withOpacity(0.9),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Beranda'),
            _buildNavItem(1, Icons.inventory_2, 'Koleksi Emas'),
            _buildNavItem(2, Icons.receipt_long, 'Transaksi'),
            _buildNavItem(3, Icons.bar_chart, 'Harga Pasar'),
            _buildNavItem(4, Icons.account_circle, 'Profil / Akun'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon, required Color iconColor, required Color iconBg,
    required String title, String? badge, String? value, String? unit, Widget? customContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF292A2C).withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFFD0C5AF))),
                    if (badge != null) Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFF2CA50))),
                  ],
                ),
                customContent ?? Column(
                  children: [
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(value ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE3E2E5))),
                        const SizedBox(width: 2),
                        Text(unit ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFFD0C5AF))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF1F2022), foregroundColor: const Color(0xFFE3E2E5),
        side: BorderSide.none, padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      icon: Icon(icon, color: const Color(0xFFF2CA50), size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    Color color = isSelected ? const Color(0xFFF2CA50) : const Color(0xFFD0C5AF);
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: color)),
          if (isSelected)
            Container(margin: const EdgeInsets.only(top: 2), width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFF2CA50), shape: BoxShape.circle)),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

// Widget kecil tambahan untuk merapikan legenda komposisi portofolio
class _CompositionLegend extends StatelessWidget {
  final Color color;
  final String title;
  final String percentage;
  final Color textColor;

  const _CompositionLegend({required this.color, required this.title, required this.percentage, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFFE3E2E5))),
        Text(percentage, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }
}