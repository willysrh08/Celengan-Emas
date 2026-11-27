import 'package:flutter/material.dart';

/// Warna yang dipakai bersama oleh semua halaman (sama dengan Beranda).
class CeColors {
  CeColors._();

  static const Color surface = Color(0xFF121315);
  static const Color card = Color(0xFF1F2022);
  static const Color cardDeep = Color(0xFF0D0E10);
  static const Color cardHigh = Color(0xFF292A2C);
  static const Color gold = Color(0xFFF2CA50);
  static const Color goldDark = Color(0xFF3C2F00);
  static const Color text = Color(0xFFE3E2E5);
  static const Color textMuted = Color(0xFFD0C5AF);
  static const Color green = Color(0xFF4ADE80);
  static const Color red = Color(0xFFF87171);
  static const Color jewelry = Color(0xFFB89065);
  static const Color savings = Color(0xFF7D8774);
}

/// Harga emas 24K per gram yang juga tampil di Beranda.
const int kGoldPricePerGram = 1320000;

/// Format angka menjadi Rupiah: 13200000 -> "Rp 13.200.000".
String formatRupiah(num value) {
  final digits = value.round().abs().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
  return '${value < 0 ? '-' : ''}Rp $digits';
}

/// Format berat: 50.0 -> "50", 2.5 -> "2,5".
String formatGram(num value) {
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
  return text.replaceAll('.', ',');
}

/// Data contoh selama API aset emas di server belum dibuat.
/// Tiga aset pertama sama dengan yang tampil di Beranda.
const List<Map<String, dynamic>> kSampleAssets = [
  {
    'name': 'Antam CertiCard 50g',
    'category': 'Logam Mulia',
    'weight': 50.0,
    'pieces': 1,
    'purchase_price': 66000000,
    'purchase_date': '12 Jan 2026',
    'location': 'Brankas Toko',
    'serial': 'LM-ANT-0012345',
  },
  {
    'name': 'Gelang Rantai Figaro 25g',
    'category': 'Perhiasan',
    'weight': 25.0,
    'pieces': 1,
    'purchase_price': 23000000,
    'purchase_date': '3 Mar 2026',
    'location': 'Simpan Mandiri',
    'serial': '-',
  },
  {
    'name': 'Batangan UBS Gold 10g',
    'category': 'Logam Mulia',
    'weight': 10.0,
    'pieces': 2,
    'purchase_price': 13200000,
    'purchase_date': '20 Mei 2026',
    'location': 'Brankas Toko',
    'serial': 'UBS-0098812',
  },
  {
    'name': 'Tabungan Emas Pegadaian',
    'category': 'Tabungan',
    'weight': 13.5,
    'pieces': 1,
    'purchase_price': 17010000,
    'purchase_date': '8 Agu 2026',
    'location': 'Digital',
    'serial': '-',
  },
];

/// Riwayat transaksi contoh.
const List<Map<String, dynamic>> kSampleTransactions = [
  {'title': 'Beli Tabungan Emas', 'type': 'Pembelian', 'weight': 1.0, 'amount': 1320000, 'date': '25 Nov 2026'},
  {'title': 'Jual Antam 1g', 'type': 'Penjualan', 'weight': 1.0, 'amount': 1270000, 'date': '18 Nov 2026'},
  {'title': 'Beli Tabungan Emas', 'type': 'Pembelian', 'weight': 2.5, 'amount': 3250000, 'date': '2 Okt 2026'},
  {'title': 'Tabungan Emas Pegadaian', 'type': 'Pembelian', 'weight': 10.0, 'amount': 12440000, 'date': '8 Agu 2026'},
  {'title': 'Batangan UBS Gold 10g', 'type': 'Pembelian', 'weight': 10.0, 'amount': 13200000, 'date': '20 Mei 2026'},
  {'title': 'Gelang Rantai Figaro 25g', 'type': 'Pembelian', 'weight': 25.0, 'amount': 23000000, 'date': '3 Mar 2026'},
  {'title': 'Antam CertiCard 50g', 'type': 'Pembelian', 'weight': 50.0, 'amount': 66000000, 'date': '12 Jan 2026'},
];

Color categoryColor(String category) {
  switch (category) {
    case 'Perhiasan':
      return CeColors.jewelry;
    case 'Tabungan':
      return CeColors.savings;
    default:
      return CeColors.gold;
  }
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Perhiasan':
      return Icons.diamond_outlined;
    case 'Tabungan':
      return Icons.savings_outlined;
    default:
      return Icons.shield;
  }
}

/// Judul halaman seragam untuk tab Koleksi, Transaksi, Harga Pasar, Profil.
class CePageHeader extends StatelessWidget {
  const CePageHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CeColors.text)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: CeColors.textMuted)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Pilihan berbentuk kapsul (filter / tab kecil).
class CeChip extends StatelessWidget {
  const CeChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? CeColors.gold : CeColors.card,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? CeColors.goldDark : CeColors.textMuted,
          ),
        ),
      ),
    );
  }
}

void showSegeraHadir(BuildContext context, String fitur) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$fitur segera hadir.')),
  );
}
