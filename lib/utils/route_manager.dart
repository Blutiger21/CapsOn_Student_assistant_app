/**
 * Student Numbers: [TO BE FILLED BY GROUP MEMBERS]
 * Student Names  : [TO BE FILLED BY GROUP MEMBERS]
 * Question: Route Manager - Centralized Navigation
 */

import 'package:flutter/material.dart';
import '../../views/auth/login_view.dart';
import '../../views/student/home_view.dart';
import '../../views/student/application_form_view.dart';
import '../../views/student/application_detail_view.dart';
import '../../views/admin/admin_dashboard_view.dart';

class RouteManager {
  // ─── Static Route Names ───────────────────────────────────────────────────
  static const String login = '/';
  static const String studentHome = '/student-home';
  static const String applicationForm = '/application-form';
  static const String applicationDetail = '/application-detail';
  static const String adminDashboard = '/admin-dashboard';

  // ─── Generate Route ───────────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeView());

      case applicationForm:
        // Dynamic route: accepts optional 'edit' argument (bool)
        final isEdit = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => ApplicationFormView(isEditing: isEdit),
        );

      case applicationDetail:
        return MaterialPageRoute(
            builder: (_) => const ApplicationDetailView());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardView());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}