import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'common.dart';

/// Tab "Harga Pasar": harga emas hari ini, grafik, harga per kadar, dan simulasi.
class HargaPasarPage extends StatefulWidget {
  const HargaPasarPage({super.key});

  @override
  State<HargaPasarPage> createState() => _HargaPasarPageState();
}

class _HargaPasarPageState extends State<HargaPasarPage> {
  static const _ranges = {'1M': 7, '1B': 30, '3B': 90, '6B': 180, '1T': 365};
  String _range = '1B';
  final _gramController = TextEditingController(text: '10');
  int _karat = 24;

  static const int _buyback = kGoldPricePerGram - 50000;
  static const double _changePercent = 0.8;

  /// Harga contoh: naik perlahan menuju harga hari ini dengan sedikit naik-turun.
  List<double> _history(int days) {
    return List.generate(days, (i) {
      final t = i / (days - 1);
      // Naik-turun kecil (sekitar 0,1%) di atas tren naik yang jelas.
      final wave = math.sin(i * 0.9) * 900.0 + math.sin(i * 0.23) * 1400.0;
      final drop = (0.0006 * days).clamp(0.008, 0.12);
      final start = kGoldPricePerGram * (1 - drop);
      return i == days - 1 ? kGoldPricePerGram.toDouble() : start + (kGoldPricePerGram - start) * t + wave;
    });
  }

  @override
  void dispose() {
    _gramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = _history(_ranges[_range]!);
    final gram = double.tryParse(_gramController.text.replaceAll(',', '.')) ?? 0;
    final simulasi = gram * kGoldPricePerGram * _karat / 24;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CePageHeader(title: 'Harga Pasar', subtitle: 'Hari ini, 27 Nov 2026 • 10.30 WIB'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: CeColors.card, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emas 24K per gram', style: TextStyle(fontSize: 12, color: CeColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatRupiah(kGoldPricePerGram), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: CeColors.text)),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text('▲ $_changePercent%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CeColors.green)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final r in _ranges.keys)
                          CeChip(label: r, selected: _range == r, onTap: () => setState(() => _range = r)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(height: 150, width: double.infinity, child: CustomPaint(painter: _LineChartPainter(points))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _PriceBox('Harga Beli', kGoldPricePerGram, CeColors.gold)),
                  const SizedBox(width: 10),
                  Expanded(child: _PriceBox('Harga Jual (Buyback)', _buyback, CeColors.text)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('HARGA PER KADAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CeColors.text, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(color: CeColors.cardDeep, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    for (final k in const [24, 22, 18, 16])
                      ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: CeColors.cardHigh,
                          child: Text('${k}K', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CeColors.gold)),
                        ),
                        title: Text('Emas ${k}K', style: const TextStyle(fontSize: 12, color: CeColors.text)),
                        subtitle: Text('Kadar ${(k / 24 * 100).toStringAsFixed(1).replaceAll('.', ',')}%', style: const TextStyle(fontSize: 10, color: CeColors.textMuted)),
                        trailing: Text('${formatRupiah(kGoldPricePerGram * k / 24)}/g', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CeColors.gold)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: CeColors.card, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Simulasi Nilai Emas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CeColors.text)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _gramController,
                            onChanged: (_) => setState(() {}),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 13, color: CeColors.text),
                            decoration: InputDecoration(
                              labelText: 'Berat (gram)',
                              labelStyle: const TextStyle(fontSize: 12, color: CeColors.textMuted),
                              filled: true,
                              fillColor: CeColors.cardDeep,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: CeColors.cardDeep, borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _karat,
                              dropdownColor: CeColors.card,
                              style: const TextStyle(fontSize: 13, color: CeColors.text, fontFamily: 'PlusJakartaSans'),
                              items: const [24, 22, 18, 16].map((k) => DropdownMenuItem(value: k, child: Text('${k}K'))).toList(),
                              onChanged: (v) => setState(() => _karat = v ?? 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Estimasi Nilai', style: TextStyle(fontSize: 11, color: CeColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(formatRupiah(simulasi), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CeColors.gold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox(this.label, this.price, this.color);

  final String label;
  final num price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: CeColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: CeColors.textMuted)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('${formatRupiah(price)}/g', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

/// Grafik garis emas dengan area bergradasi di bawahnya.
class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.points);

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV) == 0 ? 1 : maxV - minV;

    Offset at(int i) => Offset(
          size.width * i / (points.length - 1),
          size.height - 8 - (points[i] - minV) / span * (size.height - 16),
        );

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final grid = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1;
    for (var g = 1; g < 4; g++) {
      final y = size.height * g / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    canvas.drawPath(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x55F2CA50), Color(0x00F2CA50)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = CeColors.gold
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(at(points.length - 1), 4, Paint()..color = CeColors.gold);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => old.points != points;
}
