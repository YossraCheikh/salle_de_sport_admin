import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/reservation_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/reservation.dart';

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervision des Réservations'),
      ),
      body: Consumer<ReservationController>(
        builder: (context, controller, child) {
          final reservations = controller.filteredReservations;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => controller.setSearchQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par membre ou cours...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.lime))
                      : reservations.isEmpty
                          ? const Center(child: Text('Aucune réservation trouvée.', style: TextStyle(color: AppColors.textMuted)))
                          : ListView.builder(
                              itemCount: reservations.length,
                              itemBuilder: (context, index) {
                                final res = reservations[index];
                                final isCancelled = res.status == ReservationStatus.cancelled;
                                final isSingleSeance = res.paymentType == 'singleSeance';

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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isSingleSeance
                                                        ? Colors.orange.withOpacity(0.15)
                                                        : AppColors.lime.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    isSingleSeance
                                                        ? 'Séance Unique (${res.pricePaidTnd?.toStringAsFixed(0) ?? "15"} TND)'
                                                        : 'Abonnement',
                                                    style: TextStyle(
                                                      color: isSingleSeance ? Colors.orange : AppColors.lime,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                if (res.isPrivateCoaching) ...[
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
                                            Text(res.memberName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 2),
                                            Text('${res.sessionTitle} à ${res.sessionTime}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      if (isCancelled)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('Annulée', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold)),
                                        )
                                      else
                                        IconButton(
                                          icon: const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 20),
                                          onPressed: () => controller.cancelReservation(res.id),
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
    );
  }
}
