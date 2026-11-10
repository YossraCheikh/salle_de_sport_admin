import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../core/theme/app_colors.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports & Finances'),
      ),
      body: Consumer<DashboardController>(
        builder: (context, controller, child) {
          final stats = controller.stats;

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.lime));
          }

          final totalRevenue = (stats['totalRevenueTnd'] ?? 18240.0) as double;
          final subRevenue = (stats['subscriptionRevenueTnd'] ?? 14500.0) as double;
          final singleRevenue = (stats['singleSeanceRevenueTnd'] ?? 2100.0) as double;
          final privateCoachingRevenue = (stats['privateCoachingRevenueTnd'] ?? 1640.0) as double;
          final avgMemberRev = (stats['avgRevenuePerMember'] ?? 73.5) as double;
          final topActivity = (stats['topPerformingActivity'] ?? 'Musculation & Pilates').toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analyse des Revenus (TND)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                // Carte résumé des sources de revenus
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lime.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Revenu Total Généré', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          Text(
                            '${totalRevenue.toStringAsFixed(0)} TND',
                            style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 10),
                      _ReportRow(
                        label: '💳 Abonnements Mensuels & Pass',
                        value: '${subRevenue.toStringAsFixed(0)} TND',
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      _ReportRow(
                        label: '🎟️ Tickets Séances Uniques',
                        value: '${singleRevenue.toStringAsFixed(0)} TND',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _ReportRow(
                        label: '🏋️ Coaching Privé (1-sur-1)',
                        value: '${privateCoachingRevenue.toStringAsFixed(0)} TND',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text('Revenus par Activité (TND)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                // Graphique en barres des revenus par activité
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (totalRevenue * 0.5) > 0 ? (totalRevenue * 0.5) : 5000,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: AppColors.cardLight,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.round()} TND',
                                    const TextStyle(color: AppColors.lime, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const activities = ['Muscu', 'Pilates', 'CrossFit', 'Cardio'];
                                    final idx = value.toInt();
                                    if (idx >= 0 && idx < activities.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          activities[idx],
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalRevenue * 0.40, color: AppColors.lime, width: 22, borderRadius: BorderRadius.circular(6))]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalRevenue * 0.28, color: Colors.purpleAccent, width: 22, borderRadius: BorderRadius.circular(6))]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: totalRevenue * 0.20, color: Colors.amber, width: 22, borderRadius: BorderRadius.circular(6))]),
                              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: totalRevenue * 0.12, color: Colors.lightBlueAccent, width: 22, borderRadius: BorderRadius.circular(6))]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: const [
                          _LegendItem(color: AppColors.lime, label: 'Musculation (40%)'),
                          _LegendItem(color: Colors.purpleAccent, label: 'Pilates (28%)'),
                          _LegendItem(color: Colors.amber, label: 'CrossFit (20%)'),
                          _LegendItem(color: Colors.lightBlueAccent, label: 'Cardio (12%)'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text('Indicateurs Clés de Performance', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _ReportRow(
                        label: 'Revenu moyen par adhérent',
                        value: '${avgMemberRev.toStringAsFixed(0)} TND',
                        color: AppColors.lime,
                      ),
                      const SizedBox(height: 10),
                      _ReportRow(
                        label: 'Activité la plus rentable',
                        value: topActivity,
                        color: AppColors.purple,
                      ),
                      const SizedBox(height: 10),
                      const _ReportRow(
                        label: 'Taux de renouvellement',
                        value: '84.2%',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReportRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
