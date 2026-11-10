import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/management_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/reservation_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class ManagementView extends StatefulWidget {
  const ManagementView({super.key});

  @override
  State<ManagementView> createState() => _ManagementViewState();
}

class _ManagementViewState extends State<ManagementView> {
  void _showAdminProfileSheet(BuildContext context) {
    final auth = context.read<AuthController>();
    final user = auth.user;

    final nameCtrl = TextEditingController(text: user?.name ?? 'Administrateur');
    final emailCtrl = TextEditingController(text: user?.email ?? 'admin@gym.tn');
    final passCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PROFIL ADMINISTRATEUR',
                    style: TextStyle(
                      color: AppColors.lime,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.purple.withValues(alpha: 0.25),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrateur',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Administrateur Principal · GYM',
                          style: TextStyle(color: AppColors.lime, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 14),

              Text('Modifier les informations', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),

              AppTextField(label: 'Nom & Prénom', hintText: 'Administrateur', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Adresse e-mail', hintText: 'admin@gym.tn', controller: emailCtrl),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Nouveau mot de passe (optionnel)',
                hintText: '••••••••',
                controller: passCtrl,
                obscureText: true,
              ),

              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Sauvegarder le profil',
                icon: Icons.save_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil administrateur mis à jour avec succès !'),
                      backgroundColor: AppColors.lime,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mgmtCtrl = context.watch<ManagementController>();
    final resCtrl = context.watch<ReservationController>();
    final notifCtrl = context.watch<NotificationController>();

    final coachCount = mgmtCtrl.coaches.length;
    final planCount = mgmtCtrl.plans.length;
    final resCount = resCtrl.reservations.length;
    final notifCount = notifCtrl.notifications.length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'ADMINISTRATION',
                style: TextStyle(
                  color: AppColors.lime,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Gestion',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const Text(
                'Paramètres et ressources de votre salle.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),

              const SizedBox(height: 24),
              // Card Profil Admin cliquable
              InkWell(
                onTap: () => _showAdminProfileSheet(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.purple.withValues(alpha: 0.25),
                        child: const Text(
                          'AD',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Administrateur',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Administrateur principal',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Centre de gestion',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Menu d'options avec sous-titres dynamiques
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _ManagementMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Coachs',
                      subtitle: '$coachCount coach${coachCount > 1 ? 's' : ''} enregistré${coachCount > 1 ? 's' : ''}',
                      onTap: () => context.push('/admin/manage/coaches'),
                    ),
                    const _Divider(),
                    _ManagementMenuItem(
                      icon: Icons.credit_card_rounded,
                      title: 'Abonnements',
                      subtitle: '$planCount offre${planCount > 1 ? 's' : ''} disponible${planCount > 1 ? 's' : ''}',
                      onTap: () => context.push('/admin/manage/subscriptions'),
                    ),
                    const _Divider(),
                    _ManagementMenuItem(
                      icon: Icons.calendar_today_rounded,
                      title: 'Réservations',
                      subtitle: '$resCount réservation${resCount > 1 ? 's' : ''}',
                      onTap: () => context.push('/admin/manage/reservations'),
                    ),
                    const _Divider(),
                    _ManagementMenuItem(
                      icon: Icons.show_chart_rounded,
                      title: 'Rapports & statistiques',
                      subtitle: 'Consulter les performances',
                      onTap: () => context.push('/admin/manage/reports'),
                    ),
                    const _Divider(),
                    _ManagementMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: '$notifCount campagne${notifCount > 1 ? 's' : ''} diffusée${notifCount > 1 ? 's' : ''}',
                      onTap: () => context.push('/admin/manage/notifications'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              // Bouton Se déconnecter
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    context.read<AuthController>().logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'GYM ADMIN · VERSION 1.0.0',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagementMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 16,
      endIndent: 16,
    );
  }
}
