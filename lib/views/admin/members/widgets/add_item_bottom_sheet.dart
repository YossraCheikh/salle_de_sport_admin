import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/management_controller.dart';
import '../../../../controllers/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../models/coach.dart';

enum AddCategory { adherant, coach, seance }

class AddItemBottomSheet extends StatefulWidget {
  final Function(String name, String email, String phone, String subscription) onAddMember;

  const AddItemBottomSheet({
    super.key,
    required this.onAddMember,
  });

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  AddCategory _selectedCategory = AddCategory.adherant;

  final _formKey = GlobalKey<FormState>();

  // Champs Adhérent
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedSubscription;

  // Champs Coach
  final _coachNameController = TextEditingController();
  final _coachEmailController = TextEditingController();
  final _coachPhoneController = TextEditingController();
  final _coachSpecController = TextEditingController();
  CoachType _selectedCoachType = CoachType.gym;

  // Champs Séance
  final _sessionTitleController = TextEditingController();
  final _sessionCapacityController = TextEditingController(text: '15');
  final _sessionDurationController = TextEditingController(text: '45');
  final _singlePriceController = TextEditingController(text: '15');
  final _coachingFeeController = TextEditingController(text: '20');

  bool _isPrivateCoaching = false;
  String _sessionType = 'Musculation';
  String? _sessionCoach;
  DateTime _sessionDate = DateTime.now();
  TimeOfDay _sessionTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _activities = [
    'Musculation',
    'Cardio',
    'Pilates',
    'Yoga',
    'CrossFit',
    'Spinning',
    'Zumba',
    'Boxe',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _coachNameController.dispose();
    _coachEmailController.dispose();
    _coachPhoneController.dispose();
    _coachSpecController.dispose();
    _sessionTitleController.dispose();
    _sessionCapacityController.dispose();
    _sessionDurationController.dispose();
    _singlePriceController.dispose();
    _coachingFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mgmtCtrl = context.watch<ManagementController>();
    final availableCoaches = mgmtCtrl.coaches;
    final coachNames = availableCoaches.map((c) => c.name).toList();
    if (coachNames.isEmpty) {
      coachNames.addAll(['Coach Sami', 'Coach Yasmine', 'Coach Karem', 'Coach Sarra']);
    }
    _sessionCoach ??= coachNames.first;

    final availablePlans = mgmtCtrl.plans;
    final subOptions = availablePlans.map((p) => p.name).toList();
    if (subOptions.isEmpty) {
      subOptions.addAll([
        'Pass Tout Accès - Mensuel',
        'Pass Tout Accès - Trimestriel',
        'Pass Tout Accès - Premium Annuel',
        'Abonnement Mensuel - Musculation & Force',
        'Abonnement Mensuel - Pilates Reformer',
        'Abonnement Mensuel - CrossFit & WOD',
        'Pass Séance Unique - Pilates',
        'Sans abonnement',
      ]);
    } else {
      if (!subOptions.contains('Sans abonnement')) {
        subOptions.add('Sans abonnement');
      }
    }
    _selectedSubscription ??= subOptions.first;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                  'NOUVEL ÉLÉMENT',
                  style: TextStyle(
                    color: AppColors.lime,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
            const SizedBox(height: 4),

            Text(
              'Ajouter à la salle',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _categoryPill('Adhérent', AddCategory.adherant),
                  _categoryPill('Coach', AddCategory.coach),
                  _categoryPill('Séance', AddCategory.seance),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedCategory == AddCategory.adherant)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Nom complet',
                      hintText: 'Ex. Mohamed Amine',
                      controller: _nameController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Veuillez saisir un nom';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Adresse e-mail',
                      hintText: 'nom@exemple.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || !val.contains('@')) return 'Adresse email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Numéro de téléphone',
                      hintText: '+216 20 000 000',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Abonnement initial',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: subOptions.contains(_selectedSubscription)
                              ? _selectedSubscription
                              : subOptions.first,
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: AppColors.lime, fontSize: 13, fontWeight: FontWeight.bold),
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: subOptions.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSubscription = val);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Confirmer l\'ajout',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onAddMember(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _phoneController.text.trim(),
                            _selectedSubscription!,
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              )
            else if (_selectedCategory == AddCategory.coach)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type de Coach', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Coach Salle'),
                            selected: _selectedCoachType == CoachType.gym,
                            selectedColor: AppColors.lime,
                            labelStyle: TextStyle(
                              color: _selectedCoachType == CoachType.gym ? Colors.black : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedCoachType = CoachType.gym);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Coach Privé'),
                            selected: _selectedCoachType == CoachType.private,
                            selectedColor: AppColors.purple,
                            labelStyle: TextStyle(
                              color: _selectedCoachType == CoachType.private ? Colors.black : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedCoachType = CoachType.private);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Nom du Coach',
                      hintText: 'Ex. Coach Sami',
                      controller: _coachNameController,
                      validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'E-mail',
                      hintText: 'coach@gym.tn',
                      controller: _coachEmailController,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Numéro de téléphone',
                      hintText: '+216 20 123 456',
                      controller: _coachPhoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Spécialités (séparées par virgules)',
                      hintText: 'Musculation, Pilates, CrossFit',
                      controller: _coachSpecController,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Enregistrer le coach',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final specs = _coachSpecController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                          context.read<ManagementController>().addCoach(
                                name: _coachNameController.text.trim(),
                                email: _coachEmailController.text.trim(),
                                phone: _coachPhoneController.text.trim(),
                                bio: 'Nouveau coach enregistré.',
                                specialties: specs.isEmpty ? ['Fitness'] : specs,
                                type: _selectedCoachType,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Coach ${_coachNameController.text} enregistré !'),
                              backgroundColor: AppColors.lime,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Titre du cours / activité',
                      hintText: 'Ex. Pilates Reformer, CrossFit Power',
                      controller: _sessionTitleController,
                      validator: (val) => val == null || val.isEmpty ? 'Titre requis' : null,
                    ),
                    const SizedBox(height: 12),

                    // Sélecteur de Date de Séance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date de la séance', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _sessionDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _sessionDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(_sessionDate),
                                  style: const TextStyle(color: AppColors.lime, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.calendar_month_rounded, color: AppColors.lime, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Activité', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _sessionType,
                                dropdownColor: AppColors.card,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: _activities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _sessionType = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Coach responsable', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: coachNames.contains(_sessionCoach) ? _sessionCoach : coachNames.first,
                                dropdownColor: AppColors.card,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: coachNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _sessionCoach = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Horaire', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _sessionTime,
                                  );
                                  if (picked != null) {
                                    setState(() => _sessionTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_sessionTime.format(context), style: const TextStyle(color: Colors.white, fontSize: 13)),
                                      const Icon(Icons.access_time_rounded, color: AppColors.lime, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Prix séance (TND)',
                            hintText: '15',
                            controller: _singlePriceController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Durée (min)',
                            hintText: '45',
                            controller: _sessionDurationController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Places max',
                            hintText: '15',
                            controller: _sessionCapacityController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
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
                                  Text('Coaching Privé (1-sur-1)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                  Text('Frais de coach supplémentaire', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ],
                              ),
                              Switch(
                                value: _isPrivateCoaching,
                                activeColor: AppColors.lime,
                                onChanged: (val) => setState(() => _isPrivateCoaching = val),
                              ),
                            ],
                          ),
                          if (_isPrivateCoaching) ...[
                            const SizedBox(height: 10),
                            AppTextField(
                              label: 'Frais de Coaching Privé (TND)',
                              hintText: '20',
                              controller: _coachingFeeController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Programmer la séance',
                      icon: Icons.calendar_today_rounded,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final sessionCtrl = context.read<SessionController>();
                          final startAt = DateTime(_sessionDate.year, _sessionDate.month, _sessionDate.day, _sessionTime.hour, _sessionTime.minute);
                          final durationMin = int.tryParse(_sessionDurationController.text) ?? 45;

                          // Vérification de conflit d'horaire
                          final conflict = sessionCtrl.checkScheduleConflict(
                            startAt: startAt,
                            durationMin: durationMin,
                          );

                          if (conflict != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '⚠️ Créneau indisponible ! La séance "${conflict.title}" est déjà programmée à ${conflict.formattedTime}.',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                            return; // BLOQUER L'AJOUT
                          }

                          sessionCtrl.addSession(
                            title: _sessionTitleController.text.trim(),
                            type: _sessionType,
                            coachName: _sessionCoach!,
                            startAt: startAt,
                            durationMin: durationMin,
                            maxParticipants: int.tryParse(_sessionCapacityController.text) ?? 15,
                            singleSeancePriceTnd: double.tryParse(_singlePriceController.text),
                            isPrivateCoaching: _isPrivateCoaching,
                            coachingFeeTnd: _isPrivateCoaching ? double.tryParse(_coachingFeeController.text) : null,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Séance ${_sessionTitleController.text} ajoutée avec succès !'),
                              backgroundColor: AppColors.lime,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoryPill(String label, AddCategory category) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
