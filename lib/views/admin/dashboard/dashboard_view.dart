import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/member_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_card.dart';
import '../members/widgets/add_item_bottom_sheet.dart';
import '../planning/widgets/add_session_sheet.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  void _showAddBottomSheet(BuildContext context) {
    final memberCtrl = context.read<MemberController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddItemBottomSheet(
        onAddMember: (name, email, phone, subscription) {
          memberCtrl.addMember(
            name: name,
            email: email,
            phone: phone,
            subscriptionName: subscription,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Élément $name ajouté avec succès !'),
              backgroundColor: AppColors.lime,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showAddSessionSheet(BuildContext context) {
    final sessionCtrl = context.read<SessionController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddSessionSheet(
        onAddSession: (newSession) {
          sessionCtrl.addSession(
            title: newSession.title,
            type: newSession.type,
            coachName: newSession.coachName,
            startAt: newSession.startAt,
            durationMin: newSession.durationMin,
            maxParticipants: newSession.maxParticipants,
            singleSeancePriceTnd: newSession.singleSeancePriceTnd,
            isPrivateCoaching: newSession.isPrivateCoaching,
            coachingFeeTnd: newSession.coachingFeeTnd,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Séance ${newSession.title} programmée !'),
              backgroundColor: AppColors.lime,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        final stats = controller.stats;

        if (controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.lime),
            ),
          );
        }

        final weeklyData = List<double>.from(
          stats['weeklyReservationsByDay'] ?? [180.0, 210.0, 195.0, 240.0, 280.0, 310.0, 120.0],
        );

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ESPACE ADMIN',
                            style: TextStyle(
                              color: AppColors.lime,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bonjour, Admin',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const Text(
                            'Voici l\'activité de votre salle aujourd\'hui.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Consumer<NotificationController>(
                          builder: (context, notifCtrl, child) {
                            final count = notifCtrl.notifications.length;
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                                  onPressed: () => context.push('/admin/manage/notifications'),
                                ),
                                if (count > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.lime,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  InkWell(
                    onTap: () => context.push('/admin/manage/reports'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.lime.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(radius: 3, backgroundColor: AppColors.lime),
                                      SizedBox(width: 6),
                                      Text(
                                        'EN DIRECT',
                                        style: TextStyle(
                                          color: AppColors.lime,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Fréquentation actuelle',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${stats['attendancePercentage'] ?? 68}',
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                            fontSize: 38,
                                            color: Colors.white,
                                          ),
                                    ),
                                    const Text(
                                      '%',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.lime,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${stats['currentPresent'] ?? 102} membres présents sur ${stats['capacityMax'] ?? 150}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 75,
                                  height: 75,
                                  child: CircularProgressIndicator(
                                    value: ((stats['attendancePercentage'] ?? 68) / 100),
                                    strokeWidth: 8,
                                    backgroundColor: AppColors.border,
                                    color: AppColors.lime,
                                  ),
                                ),
                                const Icon(Icons.fitness_center_rounded, color: AppColors.lime, size: 28),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vue d\'ensemble',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Text(
                        'Septembre',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      StatCard(
                        title: 'Adhérents',
                        value: '${stats['totalMembers'] ?? 248}',
                        subtitle: '+${stats['newMembersThisMonth'] ?? 12} ce mois',
                        icon: Icons.people_outline_rounded,
                        iconColor: AppColors.lime,
                        onTap: () => context.go('/admin/members'),
                      ),
                      StatCard(
                        title: 'Abonnements actifs',
                        value: '${stats['activeSubscriptions'] ?? 214}',
                        subtitle: '${stats['activeSubscriptionPercentage'] ?? 86}% du total',
                        icon: Icons.card_membership_rounded,
                        iconColor: AppColors.purple,
                        subtitleColor: AppColors.lime,
                        onTap: () => context.push('/admin/manage/subscriptions'),
                      ),
                      StatCard(
                        title: 'Abonnements expirés',
                        value: '${stats['expiredSubscriptions'] ?? 14}',
                        subtitle: 'À relancer',
                        icon: Icons.history_toggle_off_rounded,
                        iconColor: AppColors.danger,
                        subtitleColor: AppColors.danger,
                        onTap: () => context.push('/admin/manage/reports'),
                      ),
                      StatCard(
                        title: 'Coachs actifs',
                        value: '${stats['totalCoaches'] ?? 12}',
                        subtitle: 'Équipe GYM',
                        icon: Icons.badge_outlined,
                        iconColor: AppColors.info,
                        subtitleColor: AppColors.textMuted,
                        onTap: () => context.push('/admin/manage/coaches'),
                      ),
                      StatCard(
                        title: 'Séances planifiées',
                        value: '${stats['sessionsToday'] ?? 18}',
                        subtitle: 'Aujourd\'hui',
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.warning,
                        subtitleColor: AppColors.textMuted,
                        onTap: () => context.go('/admin/planning'),
                      ),
                      StatCard(
                        title: 'Réservations',
                        value: '${stats['weeklyReservationsTotal'] ?? 1284}',
                        subtitle: '+18% ce mois',
                        icon: Icons.bookmark_added_outlined,
                        iconColor: AppColors.lime,
                        subtitleColor: AppColors.lime,
                        onTap: () => context.push('/admin/manage/reservations'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Actions rapides',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _QuickActionButton(
                        icon: Icons.add_rounded,
                        title: 'Ajouter',
                        subtitle: 'Adhérent ou coach',
                        onTap: () => _showAddBottomSheet(context),
                      ),
                      const SizedBox(width: 10),
                      _QuickActionButton(
                        icon: Icons.calendar_month_rounded,
                        title: 'Planifier',
                        subtitle: 'Nouvelle séance',
                        onTap: () => _showAddSessionSheet(context),
                      ),
                      const SizedBox(width: 10),
                      _QuickActionButton(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notifier',
                        subtitle: 'Envoyer un message',
                        onTap: () => context.push('/admin/manage/notifications'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () => context.push('/admin/manage/reports'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Activité de la semaine',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${stats['weeklyReservationsTotal'] ?? 1284}',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'réservations',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.lime.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+${stats['weeklyGrowthPercentage'] ?? 18}%',
                                  style: const TextStyle(
                                    color: AppColors.lime,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 140,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 350,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: AppColors.cardLight,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${rod.toY.round()} résa',
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
                                        const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                                        final index = value.toInt();
                                        if (index >= 0 && index < days.length) {
                                          final isMaxDay = index == 5;
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              days[index],
                                              style: TextStyle(
                                                color: isMaxDay ? AppColors.lime : AppColors.textMuted,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
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
                                barGroups: weeklyData.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final val = entry.value;
                                  final isHighlight = index == 5;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: val,
                                        color: isHighlight ? AppColors.lime : AppColors.cardLight,
                                        width: 24,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.lime, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
