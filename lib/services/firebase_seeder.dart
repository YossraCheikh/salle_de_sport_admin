import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../models/coach.dart';
import '../models/gym_session.dart';
import '../models/member.dart';
import '../models/reservation.dart';
import '../models/subscription_plan.dart';

class FirebaseSeeder {
  static Future<void> seedInitialData() async {
    if (Firebase.apps.isEmpty) return;
    final db = FirebaseFirestore.instance;

    try {
      // 1. Seed Admin User
      final usersSnap = await db.collection('users').get();
      if (usersSnap.docs.isEmpty) {
        await db.collection('users').doc('admin1').set({
          'name': 'Administrateur GYM',
          'email': 'admin@gym.tn',
          'role': 'admin',
          'isActive': true,
        });
        if (kDebugMode) print('FirebaseSeeder: Admin User seeded.');
      }

      // 2. Seed Subscription Plans (Tout Accès, Spécifique Activité & Séance Unique)
      final plansSnap = await db.collection('subscription_plans').get();
      if (plansSnap.docs.isEmpty) {
        final plans = [
          SubscriptionPlan(
            id: 'p1',
            name: 'Pass Tout Accès - Mensuel',
            priceTnd: 80,
            durationMonths: 1,
            benefits: ['Accès illimité à tous les cours collectifs', 'Accès plateau musculation & cardio', 'Bilan physique initial'],
            category: PlanCategory.allInclusive,
          ),
          SubscriptionPlan(
            id: 'p2',
            name: 'Pass Tout Accès - Trimestriel',
            priceTnd: 220,
            durationMonths: 3,
            benefits: ['Économisez 20 TND sur 3 mois', 'Accès prioritaire aux réservations', '1 séance bilan coach offerte'],
            category: PlanCategory.allInclusive,
          ),
          SubscriptionPlan(
            id: 'p3',
            name: 'Abonnement Mensuel - Pilates',
            priceTnd: 90,
            durationMonths: 1,
            benefits: ['Accès illimité aux cours Pilates Reformer & Matwork', 'Tapis & serviette fournis', 'Petits groupes (max 12)'],
            category: PlanCategory.activitySpecific,
            targetActivity: 'Pilates',
          ),
          SubscriptionPlan(
            id: 'p4',
            name: 'Abonnement Mensuel - Musculation & Force',
            priceTnd: 75,
            durationMonths: 1,
            benefits: ['Accès illimité plateau musculation & haltérophilie', 'Programme d\'entraînement personnalisé'],
            category: PlanCategory.activitySpecific,
            targetActivity: 'Musculation',
          ),
          SubscriptionPlan(
            id: 'p5',
            name: 'Abonnement Mensuel - CrossFit & HIIT',
            priceTnd: 100,
            durationMonths: 1,
            benefits: ['Accès illimité Box CrossFit & WODs quotidiens', 'Suivi de performance athlétique'],
            category: PlanCategory.activitySpecific,
            targetActivity: 'CrossFit',
          ),
          SubscriptionPlan(
            id: 'p6',
            name: 'Pass Séance Unique - Pilates',
            priceTnd: 18,
            durationMonths: 1,
            benefits: ['Valable pour 1 séance de Pilates Reformer au choix'],
            category: PlanCategory.singleSeance,
            targetActivity: 'Pilates',
          ),
          SubscriptionPlan(
            id: 'p7',
            name: 'Pass Séance Unique - CrossFit',
            priceTnd: 20,
            durationMonths: 1,
            benefits: ['Valable pour 1 WOD CrossFit intense avec coach'],
            category: PlanCategory.singleSeance,
            targetActivity: 'CrossFit',
          ),
          SubscriptionPlan(
            id: 'p8',
            name: 'Pass Séance Unique - Cours Général',
            priceTnd: 15,
            durationMonths: 1,
            benefits: ['Valable pour 1 cours au choix (Cardio, Spinning, Yoga, Zumba, Boxe)'],
            category: PlanCategory.singleSeance,
            targetActivity: 'Cardio',
          ),
          SubscriptionPlan(
            id: 'p9',
            name: 'Pass Tout Accès - Premium Annuel',
            priceTnd: 750,
            durationMonths: 12,
            benefits: ['Meilleure offre (-210 TND)', 'Serviette & boissons incluses', 'Invité gratuit 1x/mois', 'Accès VIP sauna & casier'],
            category: PlanCategory.allInclusive,
          ),
        ];

        for (final p in plans) {
          await db.collection('subscription_plans').doc(p.id).set(p.toMap());
        }
        if (kDebugMode) print('FirebaseSeeder: Subscription plans seeded.');
      }

      // 3. Seed Diverse Coaches
      final coachesSnap = await db.collection('coaches').get();
      if (coachesSnap.docs.isEmpty) {
        final coaches = [
          Coach(
            id: 'c1',
            name: 'Sami Ben Ali',
            email: 'sami.benali@gym.tn',
            phone: '+216 20 123 456',
            bio: 'Head Coach Musculation et Bodybuilding avec 8 ans d\'expérience.',
            specialties: ['Musculation', 'Bodybuilding', 'Prise de masse'],
            activeSessionsCount: 12,
            type: CoachType.gym,
          ),
          Coach(
            id: 'c2',
            name: 'Yasmine Trabelsi',
            email: 'yasmine.trabelsi@gym.tn',
            phone: '+216 22 987 654',
            bio: 'Instructrice certifiée Pilates Reformer et Yoga Vinyasa.',
            specialties: ['Pilates', 'Yoga', 'Souplesse & Posture'],
            activeSessionsCount: 10,
            type: CoachType.gym,
          ),
          Coach(
            id: 'c3',
            name: 'Karem Louati',
            email: 'karem.louati@gym.tn',
            phone: '+216 55 444 333',
            bio: 'Master Coach CrossFit L2 et préparation physique haute intensité.',
            specialties: ['CrossFit', 'HIIT', 'Haltérophilie'],
            activeSessionsCount: 15,
            type: CoachType.private,
          ),
          Coach(
            id: 'c4',
            name: 'Sarra Gharbi',
            email: 'sarra.gharbi@gym.tn',
            phone: '+216 98 111 222',
            bio: 'Coach dynamique Spinning, Aérobic et Cardio Training.',
            specialties: ['Spinning', 'Aérobic', 'Perte de poids'],
            activeSessionsCount: 8,
            type: CoachType.gym,
          ),
          Coach(
            id: 'c5',
            name: 'Bilel Trabelsi',
            email: 'bilel.trabelsi@gym.tn',
            phone: '+216 24 555 666',
            bio: 'Champion régional de Boxe Anglaise et Kickboxing.',
            specialties: ['Boxe Anglaise', 'Kickboxing', 'Self-défense'],
            activeSessionsCount: 6,
            type: CoachType.private,
          ),
          Coach(
            id: 'c6',
            name: 'Meryem Slama',
            email: 'meryem.slama@gym.tn',
            phone: '+216 93 777 888',
            bio: 'Instructrice officielle Zumba Fitness et Danse rythmique.',
            specialties: ['Zumba', 'Danse Fitness', 'Cardio Dance'],
            activeSessionsCount: 7,
            type: CoachType.gym,
          ),
        ];

        for (final c in coaches) {
          await db.collection('coaches').doc(c.id).set(c.toMap());
        }
        if (kDebugMode) print('FirebaseSeeder: Coaches seeded.');
      }

      // 4. Seed Diverse Adherents (Members)
      final membersSnap = await db.collection('members').get();
      if (membersSnap.docs.isEmpty) {
        final now = DateTime.now();
        final members = [
          Member(
            id: 'm1',
            name: 'Mohamed Amine Ayari',
            email: 'amine.ayari@gmail.com',
            phone: '+216 21 001 002',
            status: MemberStatus.active,
            subscriptionName: 'Pass Tout Accès - Trimestriel',
            createdAt: now.subtract(const Duration(days: 45)),
          ),
          Member(
            id: 'm2',
            name: 'Sarra Mansouri',
            email: 'sarra.m@gmail.com',
            phone: '+216 52 334 455',
            status: MemberStatus.active,
            subscriptionName: 'Pass Tout Accès - Premium Annuel',
            createdAt: now.subtract(const Duration(days: 90)),
          ),
          Member(
            id: 'm3',
            name: 'Ahmed Jaziri',
            email: 'ahmed.j@yahoo.fr',
            phone: '+216 97 889 900',
            status: MemberStatus.expiring,
            subscriptionName: 'Pass Tout Accès - Mensuel',
            createdAt: now.subtract(const Duration(days: 25)),
          ),
          Member(
            id: 'm4',
            name: 'Ines Bouchoucha',
            email: 'ines.b@gmail.com',
            phone: '+216 26 112 233',
            status: MemberStatus.toVerify,
            subscriptionName: 'Abonnement Mensuel - Pilates',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
          Member(
            id: 'm5',
            name: 'Billal Hammami',
            email: 'billal.h@outlook.com',
            phone: '+216 50 667 788',
            status: MemberStatus.inactive,
            subscriptionName: 'Sans abonnement',
            createdAt: now.subtract(const Duration(days: 120)),
          ),
          Member(
            id: 'm6',
            name: 'Nadia Bouaziz',
            email: 'nadia.b@gmail.com',
            phone: '+216 93 445 566',
            status: MemberStatus.active,
            subscriptionName: 'Abonnement Mensuel - Musculation & Force',
            createdAt: now.subtract(const Duration(days: 60)),
          ),
          Member(
            id: 'm7',
            name: 'Oussama Khelifi',
            email: 'oussama.k@gmail.com',
            phone: '+216 25 888 999',
            status: MemberStatus.active,
            subscriptionName: 'Abonnement Mensuel - CrossFit & HIIT',
            createdAt: now.subtract(const Duration(days: 15)),
          ),
          Member(
            id: 'm8',
            name: 'Syrine Chaabane',
            email: 'syrine.c@yahoo.fr',
            phone: '+216 54 111 333',
            status: MemberStatus.toVerify,
            subscriptionName: 'Pass Séance Unique - Pilates',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ];

        for (final m in members) {
          await db.collection('members').doc(m.id).set(m.toMap());
        }
        if (kDebugMode) print('FirebaseSeeder: Members seeded.');
      }

      // 5. Seed Gym Sessions (Distinct Activities across Today & Tomorrow)
      final sessionsSnap = await db.collection('sessions').get();
      if (sessionsSnap.docs.isEmpty) {
        final now = DateTime.now();
        final todayMorning = DateTime(now.year, now.month, now.day, 9, 0);
        final todayMidday = DateTime(now.year, now.month, now.day, 11, 0);
        final todayAfternoon = DateTime(now.year, now.month, now.day, 14, 30);
        final todayEvening = DateTime(now.year, now.month, now.day, 17, 0);
        final todayNight = DateTime(now.year, now.month, now.day, 18, 30);
        final tomorrowMorning = DateTime(now.year, now.month, now.day + 1, 8, 30);
        final tomorrowAfternoon = DateTime(now.year, now.month, now.day + 1, 16, 0);

        final sessions = [
          GymSession(
            id: 's1',
            title: 'CrossFit WOD Power 1-on-1',
            type: 'CrossFit',
            coachId: 'c3',
            coachName: 'Karem Louati',
            startAt: todayMorning,
            durationMin: 60,
            maxParticipants: 15,
            enrolledCount: 8,
            singleSeancePriceTnd: 20,
            isPrivateCoaching: true,
            coachingFeeTnd: 20,
          ),
          GymSession(
            id: 's2',
            title: 'Spinning Cardio Burn',
            type: 'Spinning',
            coachId: 'c4',
            coachName: 'Sarra Gharbi',
            startAt: todayMidday,
            durationMin: 45,
            maxParticipants: 20,
            enrolledCount: 15,
            singleSeancePriceTnd: 15,
          ),
          GymSession(
            id: 's3',
            title: 'Pilates Reformer & Core',
            type: 'Pilates',
            coachId: 'c2',
            coachName: 'Yasmine Trabelsi',
            startAt: todayAfternoon,
            durationMin: 60,
            maxParticipants: 12,
            enrolledCount: 10,
            singleSeancePriceTnd: 18,
          ),
          GymSession(
            id: 's4',
            title: 'Musculation Hypertrophie & Force',
            type: 'Musculation',
            coachId: 'c1',
            coachName: 'Sami Ben Ali',
            startAt: todayEvening,
            durationMin: 75,
            maxParticipants: 10,
            enrolledCount: 9,
            singleSeancePriceTnd: 15,
          ),
          GymSession(
            id: 's5',
            title: 'Boxe Anglaise & Conditionnement',
            type: 'Boxe',
            coachId: 'c5',
            coachName: 'Bilel Trabelsi',
            startAt: todayNight,
            durationMin: 60,
            maxParticipants: 12,
            enrolledCount: 7,
            singleSeancePriceTnd: 20,
            isPrivateCoaching: true,
            coachingFeeTnd: 25,
          ),
          GymSession(
            id: 's6',
            title: 'Yoga Flow Matinal',
            type: 'Yoga',
            coachId: 'c2',
            coachName: 'Yasmine Trabelsi',
            startAt: tomorrowMorning,
            durationMin: 60,
            maxParticipants: 15,
            enrolledCount: 5,
            singleSeancePriceTnd: 15,
          ),
          GymSession(
            id: 's7',
            title: 'Zumba Dance Party',
            type: 'Zumba',
            coachId: 'c6',
            coachName: 'Meryem Slama',
            startAt: tomorrowAfternoon,
            durationMin: 50,
            maxParticipants: 25,
            enrolledCount: 18,
            singleSeancePriceTnd: 15,
          ),
        ];

        for (final s in sessions) {
          await db.collection('sessions').doc(s.id).set(s.toMap());
        }
        if (kDebugMode) print('FirebaseSeeder: Sessions seeded.');
      }

      // 6. Seed Reservations (linking distinct members to sessions with payment modes)
      final resSnap = await db.collection('reservations').get();
      if (resSnap.docs.isEmpty) {
        final now = DateTime.now();
        final reservations = [
          Reservation(
            id: 'res1',
            sessionId: 's1',
            sessionTitle: 'CrossFit WOD Power 1-on-1',
            sessionTime: '09:00',
            memberId: 'm1',
            memberName: 'Mohamed Amine Ayari',
            memberEmail: 'amine.ayari@gmail.com',
            bookingTime: now.subtract(const Duration(hours: 5)),
            status: ReservationStatus.confirmed,
            paymentType: 'singleSeance',
            pricePaidTnd: 20,
            isPrivateCoaching: true,
            coachingFeeTnd: 20,
          ),
          Reservation(
            id: 'res2',
            sessionId: 's2',
            sessionTitle: 'Spinning Cardio Burn',
            sessionTime: '11:00',
            memberId: 'm2',
            memberName: 'Sarra Mansouri',
            memberEmail: 'sarra.m@gmail.com',
            bookingTime: now.subtract(const Duration(hours: 3)),
            status: ReservationStatus.confirmed,
            paymentType: 'subscription',
          ),
          Reservation(
            id: 'res3',
            sessionId: 's3',
            sessionTitle: 'Pilates Reformer & Core',
            sessionTime: '14:30',
            memberId: 'm4',
            memberName: 'Ines Bouchoucha',
            memberEmail: 'ines.b@gmail.com',
            bookingTime: now.subtract(const Duration(hours: 2)),
            status: ReservationStatus.confirmed,
            paymentType: 'subscription',
          ),
          Reservation(
            id: 'res4',
            sessionId: 's3',
            sessionTitle: 'Pilates Reformer & Core',
            sessionTime: '14:30',
            memberId: 'm8',
            memberName: 'Syrine Chaabane',
            memberEmail: 'syrine.c@yahoo.fr',
            bookingTime: now.subtract(const Duration(hours: 1)),
            status: ReservationStatus.confirmed,
            paymentType: 'singleSeance',
            pricePaidTnd: 18,
          ),
          Reservation(
            id: 'res5',
            sessionId: 's4',
            sessionTitle: 'Musculation Hypertrophie & Force',
            sessionTime: '17:00',
            memberId: 'm6',
            memberName: 'Nadia Bouaziz',
            memberEmail: 'nadia.b@gmail.com',
            bookingTime: now.subtract(const Duration(minutes: 45)),
            status: ReservationStatus.confirmed,
            paymentType: 'subscription',
          ),
          Reservation(
            id: 'res6',
            sessionId: 's5',
            sessionTitle: 'Boxe Anglaise & Conditionnement',
            sessionTime: '18:30',
            memberId: 'm7',
            memberName: 'Oussama Khelifi',
            memberEmail: 'oussama.k@gmail.com',
            bookingTime: now.subtract(const Duration(minutes: 20)),
            status: ReservationStatus.confirmed,
            paymentType: 'singleSeance',
            pricePaidTnd: 20,
            isPrivateCoaching: true,
            coachingFeeTnd: 25,
          ),
        ];

        for (final r in reservations) {
          await db.collection('reservations').doc(r.id).set(r.toMap());
        }
        if (kDebugMode) print('FirebaseSeeder: Reservations seeded.');
      }

      // 7. Seed Notifications
      final notifSnap = await db.collection('notifications').get();
      if (notifSnap.docs.isEmpty) {
        final now = DateTime.now();
        final notifications = [
          AppNotification(
            id: 'n1',
            title: 'Nouveau planning disponible',
            body: 'Le planning des cours de Pilates, CrossFit, Musculation, Boxe et Zumba de la semaine est en ligne !',
            target: NotificationTarget.all,
            scheduledAt: now.subtract(const Duration(days: 1)),
            status: NotificationStatus.sent,
          ),
          AppNotification(
            id: 'n2',
            title: 'Relance Automatique Expiration (≤ 5 jours)',
            body: 'Rappel automatique envoyé aux membres expirant sous 5 jours.',
            target: NotificationTarget.members,
            scheduledAt: now,
            status: NotificationStatus.sent,
          ),
        ];

        for (final n in notifications) {
          await db.collection('notifications').doc(n.id).set(n.toMap());
        }
        if (kDebugMode) print('FirebaseSeeder: Notifications seeded.');
      }
    } catch (e) {
      if (kDebugMode) print('FirebaseSeeder error: $e');
    }
  }
}
