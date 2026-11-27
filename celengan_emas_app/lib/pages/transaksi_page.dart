import 'package:flutter/material.dart';

import 'common.dart';

/// Tab "Transaksi": riwayat pembelian dan penjualan emas.
class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key, this.transactions = kSampleTransactions});

  final List<Map<String, dynamic>> transactions;

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  static const _tabs = ['Semua', 'Pembelian', 'Penjualan'];
  String _tab = 'Semua';

  @override
  Widget build(BuildContext context) {
    final items = widget.transactions.where((t) => _tab == 'Semua' || t['type'] == _tab).toList();
    num sum(String type) => widget.transactions
        .where((t) => t['type'] == type)
        .fold<num>(0, (s, t) => s + (t['amount'] as num));

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CePageHeader(
            title: 'Transaksi',
            subtitle: 'Riwayat beli & jual emasmu',
            trailing: IconButton(
              onPressed: () => showSegeraHadir(context, 'Unduh laporan transaksi'),
              icon: const Icon(Icons.file_download_outlined, color: CeColors.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _SummaryCard('Total Pembelian', sum('Pembelian'), Icons.south_west, CeColors.green)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryCard('Total Penjualan', sum('Penjualan'), Icons.north_east, CeColors.red)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final t in _tabs) ...[
                  CeChip(label: t, selected: _tab == t, onTap: () => setState(() => _tab = t)),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Belum ada transaksi.', style: TextStyle(color: CeColors.textMuted, fontSize: 13)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _TransactionTile(items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.label, this.amount, this.icon, this.color);

  final String label;
  final num amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: CeColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 10, color: CeColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(formatRupiah(amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CeColors.text)),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile(this.t);

  final Map<String, dynamic> t;

  @override
  Widget build(BuildContext context) {
    final isBuy = t['type'] == 'Pembelian';
    final color = isBuy ? CeColors.green : CeColors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: CeColors.cardDeep, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isBuy ? const Color(0x1A4ADE80) : const Color(0x1AF87171),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isBuy ? Icons.add_shopping_cart : Icons.sell_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['title'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CeColors.text)),
                const SizedBox(height: 2),
                Text('${t['type']} • ${t['date']}', style: const TextStyle(fontSize: 11, color: CeColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isBuy ? '+' : '-'}${formatGram(t['weight'])} gr',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(formatRupiah(t['amount']), style: const TextStyle(fontSize: 11, color: CeColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
