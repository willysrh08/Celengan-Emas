import 'package:flutter/material.dart';

import 'common.dart';

/// Tab "Koleksi Emas": semua aset, bisa dicari, difilter, dan dibuka detailnya.
class KoleksiPage extends StatefulWidget {
  const KoleksiPage({super.key, this.assets = kSampleAssets});

  final List<Map<String, dynamic>> assets;

  @override
  State<KoleksiPage> createState() => _KoleksiPageState();
}

class _KoleksiPageState extends State<KoleksiPage> {
  static const _filters = ['Semua', 'Logam Mulia', 'Perhiasan', 'Tabungan'];
  String _filter = 'Semua';
  String _query = '';

  List<Map<String, dynamic>> get _visible => widget.assets.where((a) {
        final okFilter = _filter == 'Semua' || a['category'] == _filter;
        final okQuery = _query.isEmpty ||
            (a['name'] as String).toLowerCase().contains(_query.toLowerCase());
        return okFilter && okQuery;
      }).toList();

  int _count(String filter) => filter == 'Semua'
      ? widget.assets.length
      : widget.assets.where((a) => a['category'] == filter).length;

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final totalWeight = items.fold<double>(0, (s, a) => s + (a['weight'] as num));
    final totalValue = totalWeight * kGoldPricePerGram;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CePageHeader(title: 'Koleksi Emas', subtitle: 'Semua emas fisik & tabunganmu'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 13, color: CeColors.text),
              decoration: InputDecoration(
                hintText: 'Cari emas, contoh: Antam 50g',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0x99D0C5AF)),
                prefixIcon: const Icon(Icons.search, color: CeColors.textMuted, size: 20),
                filled: true,
                fillColor: CeColors.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => CeChip(
                label: '${_filters[i]} (${_count(_filters[i])})',
                selected: _filter == _filters[i],
                onTap: () => setState(() => _filter = _filters[i]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${items.length} aset • ${formatGram(totalWeight)} gr • estimasi ${formatRupiah(totalValue)}',
              style: const TextStyle(fontSize: 11, color: CeColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Tidak ada emas yang cocok.', style: TextStyle(color: CeColors.textMuted, fontSize: 13)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _AssetCard(asset: items[i], onTap: () => _showDetail(items[i])),
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Map<String, dynamic> a) {
    final weight = a['weight'] as num;
    final buy = a['purchase_price'] as num;
    final now = weight * kGoldPricePerGram;
    final gain = now - buy;

    showModalBottomSheet(
      context: context,
      backgroundColor: CeColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: CeColors.cardHigh, borderRadius: BorderRadius.circular(99))),
            ),
            const SizedBox(height: 16),
            Text(a['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CeColors.text)),
            const SizedBox(height: 6),
            Text('${a['category']} • ${a['pieces']} keping', style: TextStyle(fontSize: 12, color: categoryColor(a['category']))),
            const SizedBox(height: 16),
            _DetailRow('Total Berat', '${formatGram(weight)} gram'),
            _DetailRow('Harga Beli', formatRupiah(buy)),
            _DetailRow('Estimasi Nilai Sekarang', formatRupiah(now)),
            _DetailRow('Keuntungan', '${gain >= 0 ? '+' : ''}${formatRupiah(gain)}', valueColor: gain >= 0 ? CeColors.green : CeColors.red),
            _DetailRow('Tanggal Beli', a['purchase_date']),
            _DetailRow('No. Seri', a['serial']),
            _DetailRow('Lokasi Simpan', a['location']),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showSegeraHadir(context, 'Edit aset');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CeColors.text,
                      side: const BorderSide(color: CeColors.cardHigh),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showSegeraHadir(context, 'Hapus aset');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x33F87171),
                      foregroundColor: CeColors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.asset, required this.onTap});

  final Map<String, dynamic> asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = asset['category'] as String;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: CeColors.cardDeep, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: CeColors.cardHigh, borderRadius: BorderRadius.circular(8)),
              child: Icon(categoryIcon(category), color: categoryColor(category), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CeColors.text)),
                  const SizedBox(height: 2),
                  Text(
                    '${asset['pieces']} keping • ${formatGram(asset['weight'])} gr • ${asset['purchase_date']}',
                    style: const TextStyle(fontSize: 11, color: CeColors.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatRupiah(asset['purchase_price']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CeColors.gold)),
                const SizedBox(height: 2),
                Text(category, style: TextStyle(fontSize: 10, color: categoryColor(category))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.valueColor = CeColors.text});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: CeColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}
