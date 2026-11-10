import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../models/gym_session.dart';
import '../../../../services/session_service.dart';

class SessionDetailSheet extends StatefulWidget {
  final GymSession session;
  final Function(GymSession updated)? onUpdateSession;
  final VoidCallback onDelete;

  const SessionDetailSheet({
    super.key,
    required this.session,
    this.onUpdateSession,
    required this.onDelete,
  });

  @override
  State<SessionDetailSheet> createState() => _SessionDetailSheetState();
}

class _SessionDetailSheetState extends State<SessionDetailSheet> {
  late GymSession _currentSession;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
  }

  void _showEditDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: _currentSession.title);
    final capacityCtrl = TextEditingController(text: _currentSession.maxParticipants.toString());
    final durationCtrl = TextEditingController(text: _currentSession.durationMin.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Modifier la séance', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Nom du cours', hintText: '', controller: titleCtrl),
              const SizedBox(height: 10),
              AppTextField(label: 'Capacité maximale', hintText: '', controller: capacityCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              AppTextField(label: 'Durée (minutes)', hintText: '', controller: durationCtrl, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: Colors.black),
            onPressed: () {
              final updated = _currentSession.copyWith(
                title: titleCtrl.text.trim(),
                maxParticipants: int.tryParse(capacityCtrl.text) ?? _currentSession.maxParticipants,
                durationMin: int.tryParse(durationCtrl.text) ?? _currentSession.durationMin,
              );
              setState(() {
                _currentSession = updated;
              });
              if (widget.onUpdateSession != null) {
                widget.onUpdateSession!(updated);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _currentSession.type,
                    style: const TextStyle(color: AppColors.lime, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_currentSession.formattedTime} (${_currentSession.durationMin} min)',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.lime, size: 20),
                      onPressed: () => _showEditDialog(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              _currentSession.title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Coach : ${_currentSession.coachName}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inscrits', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        '${_currentSession.enrolledCount} / ${_currentSession.maxParticipants}',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Remplissage', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        '${_currentSession.occupancyPercentage}%',
                        style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Adhérents inscrits à ce cours',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Icon(Icons.people_alt_rounded, color: AppColors.lime, size: 18),
              ],
            ),
            const SizedBox(height: 10),

            // Stream des membres inscrits à cette séance en direct
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: SessionService().getEnrolledMembersStream(_currentSession.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.lime));
                }
                final enrolled = snapshot.data ?? [];
                if (enrolled.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Aucun membre inscrit pour le moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  );
                }
                return Column(
                  children: enrolled.map((item) {
                    final memberName = item['memberName'] ?? item['name'] ?? 'Adhérent';
                    final memberEmail = item['memberEmail'] ?? item['email'] ?? '';
                    final initialChar = memberName.isNotEmpty ? memberName[0].toUpperCase() : 'M';
                    final isSingleSeance = item['paymentType'] == 'singleSeance';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.purple.withOpacity(0.25),
                            child: Text(initialChar, style: const TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(memberName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                if (memberEmail.isNotEmpty)
                                  Text(memberEmail, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSingleSeance ? Colors.orange.withOpacity(0.15) : AppColors.lime.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isSingleSeance ? 'Séance Unique' : 'Abonné',
                              style: TextStyle(
                                color: isSingleSeance ? Colors.orange : AppColors.lime,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      widget.onDelete();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Annuler le cours', style: TextStyle(fontWeight: FontWeight.bold)),
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
