import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/gym_session.dart';
import 'widgets/add_session_sheet.dart';
import 'widgets/session_detail_sheet.dart';

class PlanningView extends StatelessWidget {
  const PlanningView({super.key});

  static const List<String> _activityFilters = [
    'Tous',
    'Musculation',
    'Cardio',
    'Pilates',
    'Yoga',
    'CrossFit',
    'Spinning',
    'Zumba',
    'Boxe',
  ];

  void _showAddSessionSheet(BuildContext context, SessionController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddSessionSheet(
        onAddSession: (newSession) {
          controller.addSession(
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

  void _showSessionDetailSheet(BuildContext context, GymSession session, SessionController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SessionDetailSheet(
        session: session,
        onDelete: () {
          controller.deleteSession(session.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Séance ${session.title} annulée.'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, controller, child) {
        final filteredSessions = controller.filteredSessions;
        final selectedDate = controller.selectedDate;

        // Génération dynamique des 5 jours de la semaine (LUN - VEN)
        final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        final weekDays = List.generate(5, (index) => monday.add(Duration(days: index)));

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PLANNING DE LA SALLE',
                            style: TextStyle(
                              color: AppColors.lime,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Séances',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const Text(
                            'Gérez les cours, tarifs et inscriptions.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black, size: 24),
                          onPressed: () => _showAddSessionSheet(context, controller),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Filtres d'activités
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _activityFilters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, idx) {
                        final act = _activityFilters[idx];
                        final isSelected = controller.selectedActivityFilter == act;
                        return ChoiceChip(
                          label: Text(act),
                          selected: isSelected,
                          selectedColor: AppColors.lime,
                          backgroundColor: AppColors.card,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => controller.setActivityFilter(act),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Sélecteur de jours réactif
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekDays.map((dayDate) {
                      final isSelected = dayDate.year == selectedDate.year &&
                          dayDate.month == selectedDate.month &&
                          dayDate.day == selectedDate.day;

                      final dayName = DateFormat('EEE', 'fr_FR').format(dayDate).toUpperCase().replaceAll('.', '');
                      final dayNum = DateFormat('dd').format(dayDate);

                      return GestureDetector(
                        onTap: () => controller.setSelectedDate(dayDate),
                        child: Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.lime : AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.lime : AppColors.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dayNum,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredSessions.length} séance${filteredSessions.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE d MMMM', 'fr_FR').format(selectedDate),
                        style: const TextStyle(color: AppColors.lime, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Liste des séances du jour
                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
                        : filteredSessions.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aucune séance pour ce filtre à cette date.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              )
                            : ListView(
                                children: [
                                  ...filteredSessions.map((s) => _SessionCard(
                                        session: s,
                                        onTap: () => _showSessionDetailSheet(context, s, controller),
                                      )),
                                  const SizedBox(height: 12),

                                  // Taux de remplissage dynamique
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Taux de remplissage global',
                                                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${controller.fillRatePercentage}%',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayLarge
                                                        ?.copyWith(fontSize: 32),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${controller.totalReserved} places réservées sur ${controller.totalCapacity}',
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 54,
                                              height: 54,
                                              child: CircularProgressIndicator(
                                                value: controller.totalCapacity > 0
                                                    ? (controller.totalReserved / controller.totalCapacity)
                                                    : 0,
                                                strokeWidth: 6,
                                                backgroundColor: AppColors.border,
                                                color: AppColors.lime,
                                              ),
                                            ),
                                            Text(
                                              '${controller.fillRatePercentage}%',
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
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

class _SessionCard extends StatelessWidget {
  final GymSession session;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: session.isPrivateCoaching ? Colors.amber.withOpacity(0.6) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.formattedTime,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${session.durationMin} min',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lime.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            session.type,
                            style: const TextStyle(color: AppColors.lime, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (session.isPrivateCoaching) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Coaching Privé',
                              style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'avec ${session.coachName}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people_alt_outlined, color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${session.enrolledCount} / ${session.maxParticipants} inscrits',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        if (session.singleSeancePriceTnd != null) ...[
                          const Spacer(),
                          Text(
                            '${session.totalPriceTnd.toStringAsFixed(0)} TND / séance',
                            style: const TextStyle(color: AppColors.lime, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
