import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../views/admin/admin_shell.dart';
import '../../views/admin/dashboard/dashboard_view.dart';
import '../../views/admin/management/coaches_view.dart';
import '../../views/admin/management/management_view.dart';
import '../../views/admin/management/notifications_view.dart';
import '../../views/admin/management/reports_view.dart';
import '../../views/admin/management/reservations_view.dart';
import '../../views/admin/management/subscriptions_view.dart';
import '../../views/admin/members/members_view.dart';
import '../../views/admin/planning/planning_view.dart';
import '../../views/auth/login_view.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/home',
                builder: (context, state) => const DashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/members',
                builder: (context, state) => const MembersView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/planning',
                builder: (context, state) => const PlanningView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/manage',
                builder: (context, state) => const ManagementView(),
                routes: [
                  GoRoute(
                    path: 'coaches',
                    builder: (context, state) => const CoachesView(),
                  ),
                  GoRoute(
                    path: 'subscriptions',
                    builder: (context, state) => const SubscriptionsView(),
                  ),
                  GoRoute(
                    path: 'reservations',
                    builder: (context, state) => const ReservationsView(),
                  ),
                  GoRoute(
                    path: 'reports',
                    builder: (context, state) => const ReportsView(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsView(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
