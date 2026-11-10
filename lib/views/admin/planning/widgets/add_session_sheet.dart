import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/management_controller.dart';
import '../../../../controllers/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../models/gym_session.dart';
import '../../../../services/session_service.dart';

class AddSessionSheet extends StatefulWidget {
  final void Function(GymSession session) onAddSession;

  const AddSessionSheet({
    super.key,
    required this.onAddSession,
  });

  @override
  State<AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<AddSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '15');
  final _durationController = TextEditingController(text: '45');
  final _singlePriceController = TextEditingController(text: '15');
  final _coachingFeeController = TextEditingController(text: '20');

  bool _isPrivateCoaching = false;
  String _selectedType = 'Musculation';
  String? _selectedCoach;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  final List<String> _types = [
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
    _titleController.dispose();
    _maxParticipantsController.dispose();
    _durationController.dispose();
    _singlePriceController.dispose();
    _coachingFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableCoaches = context.watch<ManagementController>().coaches;
    final coachNames = availableCoaches.map((c) => c.name).toList();
    if (coachNames.isEmpty) {
      coachNames.addAll(['Coach Sami', 'Coach Yasmine', 'Coach Karem', 'Coach Sarra']);
    }
    _selectedCoach ??= coachNames.first;

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
        child: Form(
          key: _formKey,
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
                    'PROGRAMMATION DE SÉANCE',
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
                'Nouvelle séance',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Nom du cours / activité',
                hintText: 'Ex. Pilates Reformer, CrossFit Power',
                controller: _titleController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Saisissez le nom du cours';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Sélecteur de Date (Jour / Mois / Année)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date de la séance',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
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
                            DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(_selectedDate),
                            style: const TextStyle(color: AppColors.lime, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.calendar_month_rounded, color: AppColors.lime, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activité',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
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
                        const Text(
                          'Coach responsable',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: coachNames.contains(_selectedCoach) ? _selectedCoach : coachNames.first,
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: coachNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCoach = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Heure de début',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) {
                              setState(() => _selectedTime = picked);
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
                                  _selectedTime.format(context),
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                ),
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
                      label: 'Prix séance unique (TND)',
                      hintText: '15',
                      controller: _singlePriceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Capacité max',
                      hintText: '15',
                      controller: _maxParticipantsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Durée (min)',
                      hintText: '45',
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Coaching Privé / Avec Coach Dédié
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
                            Text(
                              'Coaching Privé (1-sur-1)',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Séance personnalisée avec frais de coach',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isPrivateCoaching,
                          activeThumbColor: AppColors.lime,
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

              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Publier la séance',
                icon: Icons.calendar_month_rounded,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final sessionCtrl = Provider.of<SessionController>(context, listen: false);
                    final startAt = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );
                    final durationMin = int.tryParse(_durationController.text) ?? 45;

                    // Vérification de conflit de créneau sur le même jour
                    final conflict = SessionService().checkScheduleConflict(
                      sessions: sessionCtrl.sessions,
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
                      return; // BLOQUER L'AJOUT EN CONFLIT
                    }

                    final newSession = GymSession(
                      id: 's_${DateTime.now().millisecondsSinceEpoch}',
                      title: _titleController.text.trim(),
                      type: _selectedType,
                      coachId: 'coach_default',
                      coachName: _selectedCoach!,
                      startAt: startAt,
                      durationMin: durationMin,
                      maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 15,
                      enrolledCount: 0,
                      singleSeancePriceTnd: double.tryParse(_singlePriceController.text),
                      isPrivateCoaching: _isPrivateCoaching,
                      coachingFeeTnd: _isPrivateCoaching ? double.tryParse(_coachingFeeController.text) : null,
                    );

                    widget.onAddSession(newSession);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
