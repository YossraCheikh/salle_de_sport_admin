import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/management_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/coach.dart';
import '../../../services/coach_service.dart';

class CoachesView extends StatelessWidget {
  const CoachesView({super.key});

  void _showAddOrEditCoachSheet(BuildContext context, {Coach? existingCoach}) {
    final controller = context.read<ManagementController>();
    final nameCtrl = TextEditingController(text: existingCoach?.name ?? '');
    final emailCtrl = TextEditingController(text: existingCoach?.email ?? '');
    final phoneCtrl = TextEditingController(text: existingCoach?.phone ?? '');
    final bioCtrl = TextEditingController(text: existingCoach?.bio ?? '');
    final specCtrl = TextEditingController(text: existingCoach?.specialties.join(', ') ?? '');
    CoachType selectedType = existingCoach?.type ?? CoachType.gym;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingCoach == null ? 'Ajouter un Coach' : 'Modifier le Coach',
                  style: Theme.of(ctx).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),

                // Sélecteur de type de coach
                const Text('Rôle / Type de Coach', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Coach Salle (Collectif)'),
                        selected: selectedType == CoachType.gym,
                        selectedColor: AppColors.lime,
                        labelStyle: TextStyle(
                          color: selectedType == CoachType.gym ? Colors.black : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedType = CoachType.gym);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Coach Privé (Personnel)'),
                        selected: selectedType == CoachType.private,
                        selectedColor: AppColors.purple,
                        labelStyle: TextStyle(
                          color: selectedType == CoachType.private ? Colors.black : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedType = CoachType.private);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                AppTextField(label: 'Nom complet', hintText: 'Ex. Sarah Ben Ali', controller: nameCtrl),
                const SizedBox(height: 12),
                AppTextField(label: 'E-mail', hintText: 'sarah@pulse.tn', controller: emailCtrl),
                const SizedBox(height: 12),
                AppTextField(label: 'Téléphone', hintText: '+216 22 000 000', controller: phoneCtrl),
                const SizedBox(height: 12),
                AppTextField(label: 'Spécialités (séparées par des virgules)', hintText: 'HIIT, Cardio, Fitness', controller: specCtrl),
                const SizedBox(height: 12),
                AppTextField(label: 'Bio / Présentation', hintText: 'Présentation...', controller: bioCtrl, maxLines: 2),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: existingCoach == null ? 'Enregistrer le coach' : 'Sauvegarder les modifications',
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                      final specs = specCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      if (existingCoach == null) {
                        controller.addCoach(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                          specialties: specs.isEmpty ? ['Fitness'] : specs,
                          type: selectedType,
                        );
                      } else {
                        controller.updateCoach(
                          Coach(
                            id: existingCoach.id,
                            name: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            bio: bioCtrl.text.trim(),
                            specialties: specs,
                            activeSessionsCount: existingCoach.activeSessionsCount,
                            type: selectedType,
                          ),
                        );
                      }
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCoachSessionsDialog(BuildContext context, Coach coach) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Cours dispensés par ${coach.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: CoachService().fetchCoachSessions(coach.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.lime));
            final sessions = snapshot.data!;
            if (sessions.isEmpty) {
              return const Text('Aucun cours assigné pour le moment.', style: TextStyle(color: AppColors.textMuted));
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: sessions.map((s) {
                final title = s['title'] ?? 'Séance';
                final time = s['time'] ?? s['formattedTime'] ?? '';
                final parts = s['participants'] ?? '${s['enrolledCount'] ?? 0}/${s['maxParticipants'] ?? 15} inscrits';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fitness_center_rounded, color: AppColors.lime),
                  title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  trailing: Text(parts, style: const TextStyle(color: AppColors.lime, fontSize: 11, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer', style: TextStyle(color: AppColors.lime)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Coachs'),
      ),
      body: Consumer<ManagementController>(
        builder: (context, controller, child) {
          final coaches = controller.coaches;

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.lime));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: coaches.length,
            itemBuilder: (context, index) {
              final coach = coaches[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: coach.type == CoachType.private
                              ? AppColors.purple.withValues(alpha: 0.25)
                              : AppColors.lime.withValues(alpha: 0.2),
                          child: Text(
                            coach.initials,
                            style: TextStyle(
                              color: coach.type == CoachType.private ? AppColors.purple : AppColors.lime,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      coach.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: coach.type == CoachType.private
                                          ? AppColors.purple.withValues(alpha: 0.2)
                                          : AppColors.lime.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      coach.typeLabel,
                                      style: TextStyle(
                                        color: coach.type == CoachType.private ? AppColors.purple : AppColors.lime,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(coach.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit_outlined, color: AppColors.lime, size: 18),
                          onPressed: () => _showAddOrEditCoachSheet(context, existingCoach: coach),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                          onPressed: () => controller.deleteCoach(coach.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(coach.bio, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: coach.specialties.map((s) {
                              return Chip(
                                label: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.lime)),
                                backgroundColor: AppColors.border.withValues(alpha: 0.4),
                                padding: EdgeInsets.zero,
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showCoachSessionsDialog(context, coach),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lime.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${coach.activeSessionsCount} cours >',
                              style: const TextStyle(color: AppColors.lime, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.lime,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Coach', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddOrEditCoachSheet(context),
      ),
    );
  }
}
