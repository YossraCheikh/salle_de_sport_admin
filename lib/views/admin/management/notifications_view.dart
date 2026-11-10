import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/notification_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/app_notification.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  void _showCreateNotificationSheet(BuildContext context, NotificationController controller) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    NotificationTarget target = NotificationTarget.all;

    final Map<String, Map<String, String>> presets = {
      'Personnalisé': {'title': '', 'body': ''},
      'Relance Expiration 5 jours': {
        'title': 'Rappel Renouvellement Abonnement',
        'body': 'Votre abonnement expire dans moins de 5 jours. Renouvelez-le à l\'accueil pour conserver votre accès !',
      },
      'Confirmation de réservation': {
        'title': 'Réservation confirmée !',
        'body': 'Votre réservation pour le cours a bien été prise en compte.',
      },
      'Annulation d\'une séance': {
        'title': 'Annulation de cours',
        'body': 'En raison d\'un imprévu, la séance prévue est annulée. Nos excuses pour la gêne.',
      },
      'Rappel de séance (1h avant)': {
        'title': 'Rappel de votre cours',
        'body': 'N\'oubliez pas ! Votre séance de sport commence dans 1 heure.',
      },
      'Nouveau cours au planning': {
        'title': 'Nouveaux créneaux disponibles !',
        'body': 'De nouveaux cours collectifs de Pilates, CrossFit et Musculation sont ouverts.',
      },
      'Communication Officielle': {
        'title': 'Annonce importante Administration',
        'body': 'Chers membres, veuillez prendre connaissance des horaires d\'ouverture exceptionnels.',
      },
    };

    String selectedPreset = 'Personnalisé';

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
                Text('Nouvelle Campagne Push', style: Theme.of(ctx).textTheme.displaySmall),
                const SizedBox(height: 14),

                const Text('Modèle de notification pré-défini', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedPreset,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.lime, fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: presets.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedPreset = val;
                        titleCtrl.text = presets[val]!['title']!;
                        bodyCtrl.text = presets[val]!['body']!;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                AppTextField(label: 'Titre de la notification', hintText: 'Ex. Offre spéciale', controller: titleCtrl),
                const SizedBox(height: 12),
                AppTextField(label: 'Contenu du message', hintText: 'Tapez votre notification...', controller: bodyCtrl, maxLines: 3),
                const SizedBox(height: 12),
                const Text('Destinataires', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<NotificationTarget>(
                  initialValue: target,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: NotificationTarget.all, child: Text('Tous les membres')),
                    DropdownMenuItem(value: NotificationTarget.members, child: Text('Adhérents uniquement')),
                    DropdownMenuItem(value: NotificationTarget.coaches, child: Text('Coachs uniquement')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => target = val);
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Diffuser la campagne Push',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
                      controller.createNotification(
                        title: titleCtrl.text.trim(),
                        body: bodyCtrl.text.trim(),
                        target: target,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Campagne Push transmise à Firebase !'),
                          backgroundColor: AppColors.lime,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campagnes & Notifications Push'),
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          final notifications = controller.notifications;

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.lime));
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte d'action rapide pour la relance automatique à 5 jours
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lime.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.lime.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time_filled_rounded, color: AppColors.lime, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Relance Automatique Expiration (≤ 5 jours)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Envoyer une relance Push automatique aux membres en fin d\'abonnement.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lime,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          controller.sendExpiringAlerts(5);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Relance automatique 5 jours envoyée !'),
                              backgroundColor: AppColors.lime,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Relancer (5j)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text('Historique des campagnes (${notifications.length})', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                Expanded(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune notification diffusée pour le moment.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: notif.status == NotificationStatus.sent
                                              ? AppColors.lime.withValues(alpha: 0.15)
                                              : AppColors.warning.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          notif.status == NotificationStatus.sent ? 'Envoyée' : 'Planifiée',
                                          style: TextStyle(
                                            color: notif.status == NotificationStatus.sent ? AppColors.lime : AppColors.warning,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(notif.body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Cible : ${notif.targetLabel}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                      const Icon(Icons.notifications_active_outlined, color: AppColors.lime, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.lime,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Nouvelle Campagne', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateNotificationSheet(context, context.read<NotificationController>()),
      ),
    );
  }
}
