import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/management_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/member.dart';
import '../../../../services/member_service.dart';

class MemberDetailSheet extends StatefulWidget {
  final Member member;
  final Function(Member updated) onUpdateStatus;
  final VoidCallback onDelete;

  const MemberDetailSheet({
    super.key,
    required this.member,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  State<MemberDetailSheet> createState() => _MemberDetailSheetState();
}

class _MemberDetailSheetState extends State<MemberDetailSheet> {
  int _activeTab = 0; // 0: Infos, 1: Historique d'activités
  late Member _currentMember;

  @override
  void initState() {
    super.initState();
    _currentMember = widget.member;
  }

  void _showRenewSubscriptionDialog(BuildContext context) {
    final plans = context.read<ManagementController>().plans;
    final planNames = plans.map((p) => p.name).toList();
    if (planNames.isEmpty) {
      planNames.addAll([
        'Pass Tout Accès - Mensuel',
        'Pass Tout Accès - Trimestriel',
        'Abonnement Mensuel - Pilates',
        'Abonnement Mensuel - Musculation & Force',
        'Abonnement Mensuel - CrossFit & HIIT',
        'Pass Tout Accès - Premium Annuel',
      ]);
    }

    String selectedPlan = planNames.contains(_currentMember.subscriptionName)
        ? _currentMember.subscriptionName
        : planNames.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Renouveler l\'Abonnement', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adhérent : ${_currentMember.name}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 14),
              const Text('Sélectionnez la nouvelle offre :', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedPlan,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.lime, fontSize: 13, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: planNames.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) {
                  if (val != null) selectedPlan = val;
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.lime, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Paiement encaissé à l\'accueil. Le statut repasse instantanément en ACTIF.',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
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
              final updated = _currentMember.copyWith(
                subscriptionName: selectedPlan,
                status: MemberStatus.active,
              );
              setState(() {
                _currentMember = updated;
              });
              widget.onUpdateStatus(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abonnement de ${_currentMember.name} renouvelé !'),
                  backgroundColor: AppColors.lime,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirmer & Encaisser', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: _currentMember.name);
    final emailCtrl = TextEditingController(text: _currentMember.email);
    final phoneCtrl = TextEditingController(text: _currentMember.phone);
    String selectedSub = _currentMember.subscriptionName;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Modifier le profil', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Nom complet', hintText: '', controller: nameCtrl),
              const SizedBox(height: 10),
              AppTextField(label: 'Email', hintText: '', controller: emailCtrl),
              const SizedBox(height: 10),
              AppTextField(label: 'Téléphone', hintText: '', controller: phoneCtrl),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedSub,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Abonnement',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Pass Tout Accès - Mensuel', child: Text('Pass Tout Accès - Mensuel')),
                  DropdownMenuItem(value: 'Pass Tout Accès - Trimestriel', child: Text('Pass Tout Accès - Trimestriel')),
                  DropdownMenuItem(value: 'Abonnement Mensuel - Pilates', child: Text('Abonnement Mensuel - Pilates')),
                  DropdownMenuItem(value: 'Abonnement Mensuel - Musculation & Force', child: Text('Abonnement Mensuel - Musculation')),
                  DropdownMenuItem(value: 'Pass Tout Accès - Premium Annuel', child: Text('Premium Annuel')),
                  DropdownMenuItem(value: 'Sans abonnement', child: Text('Sans abonnement')),
                ],
                onChanged: (v) {
                  if (v != null) selectedSub = v;
                },
              ),
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
              final updated = _currentMember.copyWith(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                subscriptionName: selectedSub,
              );
              setState(() {
                _currentMember = updated;
              });
              widget.onUpdateStatus(updated);
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
            // En-tête
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.lime.withValues(alpha: 0.2),
                  child: Text(
                    _currentMember.initials,
                    style: const TextStyle(
                      color: AppColors.lime,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentMember.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentMember.subscriptionName,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.lime, size: 20),
                  onPressed: () => _showEditMemberDialog(context),
                ),
                StatusBadge.fromStatusString(_currentMember.status.name),
              ],
            ),
            const SizedBox(height: 16),

            // Bouton rapide de Renouvellement d'Abonnement
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Renouveler l\'Abonnement (Encaisser)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () => _showRenewSubscriptionDialog(context),
              ),
            ),

            const SizedBox(height: 20),

            // Onglets : Informations / Historique d'activités
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? AppColors.lime : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Informations',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _activeTab == 0 ? Colors.black : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? AppColors.lime : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Historique d\'activités',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _activeTab == 1 ? Colors.black : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_activeTab == 0) ...[
              _infoTile(Icons.email_outlined, 'Adresse e-mail', _currentMember.email),
              const SizedBox(height: 12),
              _infoTile(Icons.phone_outlined, 'Téléphone', _currentMember.phone.isEmpty ? 'Non renseigné' : _currentMember.phone),
              const SizedBox(height: 12),
              _infoTile(
                Icons.calendar_month_outlined,
                'Membre depuis',
                DateFormat('dd MMMM yyyy', 'fr_FR').format(_currentMember.createdAt),
              ),
            ] else ...[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: MemberService().fetchMemberActivityHistory(_currentMember.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.lime));
                  }
                  final history = snapshot.data!;
                  if (history.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.history_toggle_off_rounded, color: AppColors.textMuted, size: 36),
                          SizedBox(height: 8),
                          Text(
                            'Aucune activité enregistrée',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cet adhérent n\'a pas encore effectué de séances.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: history.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center_rounded, color: AppColors.lime, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'] ?? item['sessionTitle'] ?? 'Séance', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('à ${item['time'] ?? item['sessionTime'] ?? ""}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.lime.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Confirmée', style: TextStyle(color: AppColors.lime, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _currentMember.status == MemberStatus.active ? AppColors.warning : AppColors.lime,
                      side: BorderSide(
                        color: _currentMember.status == MemberStatus.active ? AppColors.warning : AppColors.lime,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final newStatus = _currentMember.status == MemberStatus.active ? MemberStatus.inactive : MemberStatus.active;
                      final updated = _currentMember.copyWith(status: newStatus);
                      widget.onUpdateStatus(updated);
                      Navigator.pop(context);
                    },
                    child: Text(
                      _currentMember.status == MemberStatus.active ? 'Désactiver' : 'Activer le profil',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  onPressed: () {
                    widget.onDelete();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
