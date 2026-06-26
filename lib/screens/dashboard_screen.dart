import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/quote_doc.dart';
import '../storage/local_db.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = LocalDB.instance.getDocuments();
    final quotations = docs.where((d) => d.type == DocType.quotation).toList();
    final invoices = docs.where((d) => d.type == DocType.invoice).toList();

    final totalQuoted = quotations.fold(0.0, (s, d) => s + d.total);
    final totalInvoiced = invoices.fold(0.0, (s, d) => s + d.total);
    final totalPaid = invoices.fold(0.0, (s, d) => s + d.amountPaid);
    final totalOutstanding = invoices.fold(0.0, (s, d) => s + d.balanceDue);

    // Last 6 months invoice totals for a simple bar chart.
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));
    final monthlyTotals = months.map((m) {
      return invoices
          .where((d) => d.date.year == m.year && d.date.month == m.month)
          .fold(0.0, (s, d) => s + d.total);
    }).toList();
    final maxVal = monthlyTotals.fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _statCard('Quotations', quotations.length.toString(), formatRupees(totalQuoted)),
              _statCard('Invoices', invoices.length.toString(), formatRupees(totalInvoiced)),
              _statCard('Amount Paid', '', formatRupees(totalPaid), color: AppColors.ok),
              _statCard('Outstanding', '', formatRupees(totalOutstanding), color: AppColors.danger),
            ],
          ),
          const SizedBox(height: 22),
          const Text('INVOICE TOTAL — LAST 6 MONTHS',
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.blueprintDk, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: maxVal == 0
                ? const Center(child: Text('No invoices yet', style: TextStyle(color: AppColors.inkSoft)))
                : BarChart(
                    BarChartData(
                      maxY: maxVal * 1.2,
                      barGroups: List.generate(
                        6,
                        (i) => BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: monthlyTotals[i],
                            color: AppColors.blueprint,
                            width: 22,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ]),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= months.length) return const SizedBox();
                              const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(labels[months[i].month - 1],
                                    style: const TextStyle(fontSize: 10, color: AppColors.inkSoft)),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String count, String amount, {Color color = AppColors.ink}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label.toUpperCase(),
                style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            if (count.isNotEmpty)
              Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text(amount, style: TextStyle(fontSize: count.isEmpty ? 18 : 12.5, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
