import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/management_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/subscription_plan.dart';

class SubscriptionsView extends StatefulWidget {
  const SubscriptionsView({super.key});

  @override
  State<SubscriptionsView> createState() => _SubscriptionsViewState();
}

class _SubscriptionsViewState extends State<SubscriptionsView> {
  static const List<String> _activities = [
    'Musculation',
    'Cardio',
    'Pilates',
    'Yoga',
    'CrossFit',
    'Spinning',
    'Zumba',
    'Boxe',
  ];

  void _showAddOrEditPlanSheet(BuildContext context, {SubscriptionPlan? existingPlan}) {
    final controller = context.read<ManagementController>();
    final nameCtrl = TextEditingController(text: existingPlan?.name ?? '');
    final priceCtrl = TextEditingController(text: existingPlan?.priceTnd.toStringAsFixed(0) ?? '');
    final durationCtrl = TextEditingController(text: existingPlan?.durationMonths.toString() ?? '1');
    final coachFeeCtrl = TextEditingController(text: existingPlan?.coachFeeTnd?.toStringAsFixed(0) ?? '20');
    final benefitsCtrl = TextEditingController(text: existingPlan?.benefits.join(', ') ?? '');

    PlanCategory selectedCategory = existingPlan?.category ?? PlanCategory.allInclusive;
    String selectedActivity = existingPlan?.targetActivity ?? _activities.first;
    bool hasCoachOption = existingPlan?.hasCoachOption ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
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
                    existingPlan == null ? 'Créer une offre d\'abonnement' : 'Modifier l\'abonnement',
                    style: Theme.of(ctx).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  const Text('Catégorie d\'offre', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tout Accès'),
                        selected: selectedCategory == PlanCategory.allInclusive,
                        selectedColor: AppColors.lime,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: selectedCategory == PlanCategory.allInclusive ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (sel) {
                          if (sel) setState(() => selectedCategory = PlanCategory.allInclusive);
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Activité Spécifique'),
                        selected: selectedCategory == PlanCategory.activitySpecific,
                        selectedColor: AppColors.lime,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: selectedCategory == PlanCategory.activitySpecific ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (sel) {
                          if (sel) setState(() => selectedCategory = PlanCategory.activitySpecific);
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Séance Unique'),
                        selected: selectedCategory == PlanCategory.singleSeance,
                        selectedColor: AppColors.lime,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: selectedCategory == PlanCategory.singleSeance ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (sel) {
                          if (sel) setState(() => selectedCategory = PlanCategory.singleSeance);
                        },
                      ),
                    ],
                  ),
                  if (selectedCategory == PlanCategory.activitySpecific || selectedCategory == PlanCategory.singleSeance) ...[
                    const SizedBox(height: 12),
                    const Text('Activité concernée', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedActivity,
                          isExpanded: true,
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: _activities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedActivity = val);
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(label: 'Nom de l\'offre', hintText: 'Ex. Mensuel Pilates, Ticket CrossFit', controller: nameCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Prix de base (TND)',
                          hintText: '80',
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Durée (mois)',
                          hintText: '1',
                          controller: durationCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Option Coach de Salle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Option Coach de Salle', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                Text('Ajoute un supplément de coaching', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                            Switch(
                              value: hasCoachOption,
                              activeColor: AppColors.lime,
                              onChanged: (val) => setState(() => hasCoachOption = val),
                            ),
                          ],
                        ),
                        if (hasCoachOption) ...[
                          const SizedBox(height: 10),
                          AppTextField(
                            label: 'Supplément Coach de Salle (TND)',
                            hintText: '20',
                            controller: coachFeeCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Avantages (séparés par des virgules)',
                    hintText: 'Accès illimité, Option Coach de Salle (+20 TND)',
                    controller: benefitsCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: existingPlan == null ? 'Créer l\'offre' : 'Enregistrer les modifications',
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                        final benefitsList = benefitsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                        final price = double.tryParse(priceCtrl.text) ?? 80;
                        final duration = int.tryParse(durationCtrl.text) ?? 1;
                        final coachFee = double.tryParse(coachFeeCtrl.text) ?? 20.0;

                        if (existingPlan == null) {
                          controller.addPlan(
                            name: nameCtrl.text.trim(),
                            priceTnd: price,
                            durationMonths: duration,
                            benefits: benefitsList.isEmpty ? ['Accès sélectionné'] : benefitsList,
                            category: selectedCategory,
                            targetActivity: (selectedCategory != PlanCategory.allInclusive) ? selectedActivity : null,
                            hasCoachOption: hasCoachOption,
                            coachFeeTnd: hasCoachOption ? coachFee : 0,
                          );
                        } else {
                          controller.updatePlan(
                            SubscriptionPlan(
                              id: existingPlan.id,
                              name: nameCtrl.text.trim(),
                              priceTnd: price,
                              durationMonths: duration,
                              benefits: benefitsList,
                              category: selectedCategory,
                              targetActivity: (selectedCategory != PlanCategory.allInclusive) ? selectedActivity : null,
                              hasCoachOption: hasCoachOption,
                              coachFeeTnd: hasCoachOption ? coachFee : 0,
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres d\'Abonnement'),
      ),
      body: Consumer<ManagementController>(
        builder: (context, controller, child) {
          final allPlans = controller.plans;

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.lime));
          }

          final allInclusivePlans = allPlans.where((p) => p.category == PlanCategory.allInclusive).toList();
          final activitySpecificPlans = allPlans.where((p) => p.category == PlanCategory.activitySpecific).toList();
          final singleSeancePlans = allPlans.where((p) => p.category == PlanCategory.singleSeance).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Menu Déroulant Accordéon : ABONNEMENT TOUT ACCÈS
                _CategoryAccordionSection(
                  title: 'Abonnement Tout Accès',
                  subtitle: 'Pass général accès complet à la salle & cours',
                  badgeText: '${allInclusivePlans.length} offres',
                  icon: Icons.all_inclusive_rounded,
                  themeColor: AppColors.lime,
                  initiallyExpanded: true,
                  plans: allInclusivePlans,
                  onEdit: (plan) => _showAddOrEditPlanSheet(context, existingPlan: plan),
                  onDelete: (id) => controller.deletePlan(id),
                ),

                const SizedBox(height: 14),

                // 2. Menu Déroulant Accordéon : ABONNEMENT SPÉCIFIQUE
                _CategoryAccordionSection(
                  title: 'Abonnement Spécifique par Sport',
                  subtitle: 'Abonnements mensuels dédiés à chaque activité',
                  badgeText: '${activitySpecificPlans.length} activités',
                  icon: Icons.fitness_center_rounded,
                  themeColor: Colors.lightBlueAccent,
                  initiallyExpanded: true,
                  plans: activitySpecificPlans,
                  onEdit: (plan) => _showAddOrEditPlanSheet(context, existingPlan: plan),
                  onDelete: (id) => controller.deletePlan(id),
                ),

                const SizedBox(height: 14),

                // 3. Menu Déroulant Accordéon : SÉANCE UNIQUE
                _CategoryAccordionSection(
                  title: 'Pass Séance Unique (Ticket)',
                  subtitle: 'Paiement à l\'unité pour 1 cours au choix',
                  badgeText: '${singleSeancePlans.length} tickets',
                  icon: Icons.confirmation_number_outlined,
                  themeColor: Colors.orange,
                  initiallyExpanded: true,
                  plans: singleSeancePlans,
                  onEdit: (plan) => _showAddOrEditPlanSheet(context, existingPlan: plan),
                  onDelete: (id) => controller.deletePlan(id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.lime,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Offre', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddOrEditPlanSheet(context),
      ),
    );
  }
}

class _CategoryAccordionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final Color themeColor;
  final bool initiallyExpanded;
  final List<SubscriptionPlan> plans;
  final Function(SubscriptionPlan plan) onEdit;
  final Function(String id) onDelete;

  const _CategoryAccordionSection({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
    required this.themeColor,
    this.initiallyExpanded = true,
    required this.plans,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          iconColor: themeColor,
          collapsedIconColor: AppColors.textMuted,
          leading: CircleAvatar(
            backgroundColor: themeColor.withValues(alpha: 0.15),
            child: Icon(icon, color: themeColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText,
              style: TextStyle(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          children: [
            if (plans.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Aucune offre enregistrée dans cette catégorie.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Column(
                  children: plans.map((plan) {
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                plan.formattedPrice,
                                style: TextStyle(color: themeColor, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.edit_outlined, color: themeColor, size: 18),
                                onPressed: () => onEdit(plan),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                                onPressed: () => onDelete(plan.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Flexible Wrap pour éviter tout overflow
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                plan.category == PlanCategory.singleSeance ? 'Achat à la séance' : 'Durée : ${plan.durationMonths} mois',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                              if (plan.hasCoachOption && (plan.coachFeeTnd ?? 0) > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '🏋️ Option Coach: +${plan.coachFeeTnd!.toStringAsFixed(0)} TND (Total: ${plan.totalPriceWithCoach.toStringAsFixed(0)} TND)',
                                    style: const TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...plan.benefits.map((b) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, color: themeColor, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
