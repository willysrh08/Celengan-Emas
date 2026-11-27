import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/welcome_page.dart';
import 'common.dart';

/// Tab "Profil / Akun": data akun dari server, ringkasan, menu, dan tombol Keluar.
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key, this.assets = kSampleAssets});

  final List<Map<String, dynamic>> assets;

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late Future<Map<String, dynamic>> _user = ApiService.getUser();

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CeColors.card,
        title: const Text('Keluar dari akun?', style: TextStyle(fontSize: 16, color: CeColors.text)),
        content: const Text('Kamu perlu memasukkan email dan PIN lagi untuk masuk.', style: TextStyle(fontSize: 13, color: CeColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: CeColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar', style: TextStyle(color: CeColors.red))),
        ],
      ),
    );
    if (ok != true) return;
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalWeight = widget.assets.fold<double>(0, (s, a) => s + (a['weight'] as num));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CePageHeader(title: 'Profil / Akun'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _user,
                builder: (context, snap) {
                  final loading = snap.connectionState != ConnectionState.done;
                  final name = (snap.data?['name'] as String?) ?? (loading ? 'Memuat...' : 'Pengguna');
                  final email = (snap.data?['email'] as String?) ?? (snap.hasError ? '${snap.error}' : '');
                  final initial = name.isNotEmpty && !loading ? name[0].toUpperCase() : '?';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: CeColors.card, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: CeColors.gold,
                          child: Text(initial, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CeColors.goldDark)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CeColors.text)),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: TextStyle(fontSize: 12, color: snap.hasError ? CeColors.red : CeColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (snap.hasError)
                          IconButton(
                            onPressed: () => setState(() => _user = ApiService.getUser()),
                            icon: const Icon(Icons.refresh, color: CeColors.gold),
                          )
                        else
                          TextButton(
                            onPressed: () => showSegeraHadir(context, 'Edit profil'),
                            child: const Text('Edit', style: TextStyle(fontSize: 12, color: CeColors.gold)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _Stat('Total Aset', '${widget.assets.length}')),
                  const SizedBox(width: 10),
                  Expanded(child: _Stat('Total Berat', '${formatGram(totalWeight)} gr')),
                  const SizedBox(width: 10),
                  const Expanded(child: _Stat('Target', '50%')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(color: CeColors.cardDeep, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    for (final m in const [
                      [Icons.flag_outlined, 'Target Tabungan'],
                      [Icons.folder_copy_outlined, 'Brankas Dokumen'],
                      [Icons.lock_outline, 'Ubah PIN Keamanan'],
                      [Icons.notifications_outlined, 'Notifikasi Harga Emas'],
                      [Icons.help_outline, 'Pusat Bantuan'],
                      [Icons.info_outline, 'Tentang Aplikasi'],
                    ])
                      ListTile(
                        leading: Icon(m[0] as IconData, color: CeColors.gold, size: 20),
                        title: Text(m[1] as String, style: const TextStyle(fontSize: 13, color: CeColors.text)),
                        trailing: const Icon(Icons.chevron_right, color: CeColors.textMuted, size: 20),
                        onTap: () => showSegeraHadir(context, m[1] as String),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x26F87171),
                    foregroundColor: CeColors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(child: Text('Celengan Emas v1.0.0', style: TextStyle(fontSize: 10, color: Color(0x99D0C5AF)))),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: CeColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CeColors.gold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: CeColors.textMuted)),
        ],
      ),
    );
  }
}
