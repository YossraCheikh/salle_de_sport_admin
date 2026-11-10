import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/management_controller.dart';
import '../../../controllers/member_controller.dart';
import '../../../controllers/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/coach.dart';
import '../../../models/gym_session.dart';
import '../../../models/member.dart';
import '../planning/widgets/session_detail_sheet.dart';
import 'widgets/add_item_bottom_sheet.dart';
import 'widgets/member_detail_sheet.dart';

enum GlobalViewTab { adherants, coachs, seances }

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  GlobalViewTab _currentTab = GlobalViewTab.adherants;

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

  void _showDetailSheet(BuildContext context, Member member, MemberController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MemberDetailSheet(
        member: member,
        onUpdateStatus: (updated) {
          controller.updateMember(updated);
        },
        onDelete: () {
          controller.deleteMember(member.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member.name} a été supprimé.'),
              backgroundColor: AppColors.danger,
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
        onUpdateSession: (updated) {
          controller.updateSession(updated);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Séance ${updated.title} mise à jour !'),
              backgroundColor: AppColors.lime,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // En-tête sécurisé avec Expanded
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CENTRE D\'ADMINISTRATION',
                          style: TextStyle(
                            color: AppColors.lime,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vue Globale',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const Text(
                          'Supervision des adhérents, coachs et cours.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onPressed: () => _showAddBottomSheet(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      'Ajouter',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // Onglets : Adhérents / Coachs / Séances
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _tabPill('Adhérents', GlobalViewTab.adherants),
                    _tabPill('Coachs', GlobalViewTab.coachs),
                    _tabPill('Séances', GlobalViewTab.seances),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Contenu selon l'onglet
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lime,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
        onPressed: () => _showAddBottomSheet(context),
      ),
    );
  }

  Widget _tabPill(String label, GlobalViewTab tab) {
    final isSelected = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lime : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case GlobalViewTab.adherants:
        return _buildAdherantsContent();
      case GlobalViewTab.coachs:
        return _buildCoachsContent();
      case GlobalViewTab.seances:
        return _buildSeancesContent();
    }
  }

  // 1. Contenu Adhérents
  Widget _buildAdherantsContent() {
    return Consumer<MemberController>(
      builder: (context, controller, child) {
        final membersList = controller.filteredMembers;

        return Column(
          children: [
            TextField(
              onChanged: (value) => controller.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Rechercher un adhérent...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _filterChip(controller, 'Tous', MemberFilterTab.tous),
                const SizedBox(width: 8),
                _filterChip(controller, 'Actifs', MemberFilterTab.actifs),
                const SizedBox(width: 8),
                _filterChip(controller, 'À vérifier', MemberFilterTab.aVerifier),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${membersList.length} adhérent${membersList.length > 1 ? 's' : ''}',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Row(
                  children: [
                    Text('Trier ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Icon(Icons.arrow_downward_rounded, size: 12, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
                  : membersList.isEmpty
                      ? const Center(child: Text('Aucun adhérent trouvé.', style: TextStyle(color: AppColors.textMuted)))
                      : ListView.builder(
                          itemCount: membersList.length,
                          itemBuilder: (context, index) {
                            final member = membersList[index];
                            return _MemberTile(
                              member: member,
                              onTap: () => _showDetailSheet(context, member, controller),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  // 2. Contenu Coachs
  Widget _buildCoachsContent() {
    return Consumer<ManagementController>(
      builder: (context, controller, child) {
        final coaches = controller.coaches;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${coaches.length} coachs enregistrés',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Text('Équipe GYM', style: TextStyle(color: AppColors.lime, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
                  : ListView.builder(
                      itemCount: coaches.length,
                      itemBuilder: (context, index) {
                        final coach = coaches[index];
                        return _CoachTile(coach: coach);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // 3. Contenu Séances
  Widget _buildSeancesContent() {
    return Consumer<SessionController>(
      builder: (context, controller, child) {
        final sessions = controller.sessions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sessions.length} séances au planning',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Taux : ${controller.fillRatePercentage}%',
                  style: const TextStyle(color: AppColors.lime, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return _SessionTile(
                          session: session,
                          onTap: () => _showSessionDetailSheet(context, session, controller),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip(MemberController controller, String label, MemberFilterTab tab) {
    final isSelected = controller.selectedTab == tab;
    return GestureDetector(
      onTap: () => controller.setFilterTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lime : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.lime : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;

  const _MemberTile({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarBg = member.status == MemberStatus.active
        ? AppColors.purple
        : member.status == MemberStatus.expiring
            ? Colors.orangeAccent
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarBg.withValues(alpha: 0.25),
                radius: 22,
                child: Text(
                  member.initials,
                  style: TextStyle(color: avatarBg, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(member.subscriptionName, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              StatusBadge.fromStatusString(member.status.name),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachTile extends StatelessWidget {
  final Coach coach;

  const _CoachTile({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(coach.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                Text(coach.specialties.join(' · '), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${coach.activeSessionsCount} cours', style: const TextStyle(color: AppColors.lime, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final GymSession session;
  final VoidCallback onTap;

  const _SessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.formattedTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${session.durationMin} min', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('avec ${session.coachName}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Text('${session.enrolledCount}/${session.maxParticipants}', style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
