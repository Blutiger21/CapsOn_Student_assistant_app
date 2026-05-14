/**
 *223038085 BF MOTSEKI
 *223040545 FB AMATEBELLE
 *223051025 LD MOKHETI
 *223007530 A JARA
 *223020021 B MBINGA
 * 221034577 ML MWENDA
 *222033434 KD TSOLO
 *224020157 KP MOLELEKENG
 *223005893 TV THABISI
 */
/// Question: Student Home View - Dashboard for Students
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../utils/app_theme.dart';
import '../../utils/route_manager.dart';
import '../../utils/shared_widgets.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  @override
  void initState() {
    super.initState();
    // Fetch the application data when the screen initializes
    // Safe to use context.read here as it's a one-time action
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.currentUser != null) {
        context
            .read<ApplicationViewModel>()
            .fetchMyApplication(authVM.currentUser!.id);
      }
    });
  }

  Future<void> _handleRefresh() async {
    final authVM = context.read<AuthViewModel>();
    if (authVM.currentUser != null) {
      await context
          .read<ApplicationViewModel>()
          .fetchMyApplication(authVM.currentUser!.id);
    }
  }

  void _handleLogout() async {
    await context.read<AuthViewModel>().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteManager.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.accentColor,
        // Using Consumer to specifically listen to ApplicationViewModel changes
        child: Consumer<ApplicationViewModel>(
          builder: (context, appVM, child) {
            if (appVM.isLoading && !appVM.hasApplication) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Welcome Header ─────────────────────────────────────────
                  Text(
                    'Welcome,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF78909C),
                        ),
                  ),
                  Text(
                    user?.email.split('@').first ?? 'Student',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),

                  // ─── Application Dashboard ──────────────────────────────────
                  const SectionHeader(
                    title: 'Your Dashboard',
                    subtitle: 'Manage your Student Assistant applications',
                  ),
                  const SizedBox(height: 16),

                  // If they have an application, show the summary card.
                  // If not, show the call-to-action to apply.
                  if (appVM.hasApplication)
                    _buildApplicationSummaryCard(appVM)
                  else
                    _buildEmptyStateCard(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Component: Empty State (No Application Submitted) ────────────────────
  Widget _buildEmptyStateCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.post_add_rounded,
                size: 48,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Application Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You have not submitted an application to be a Student Assistant for the upcoming semester.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the form, passing 'false' because it's a new submission
                  Navigator.pushNamed(
                    context,
                    RouteManager.applicationForm,
                    arguments: false,
                  );
                },
                child: const Text('Start New Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Component: Summary Card (Application Exists) ─────────────────────────
  Widget _buildApplicationSummaryCard(ApplicationViewModel appVM) {
    final application = appVM.myApplication!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Application',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                StatusBadge(status: application.status),
              ],
            ),
            const Divider(height: 30),
            InfoRow(
              icon: Icons.book_outlined,
              label: 'Primary Module',
              value: '${application.module1Name} (${application.module1Level})',
            ),
            if (application.module2Name != null &&
                application.module2Name!.isNotEmpty)
              InfoRow(
                icon: Icons.my_library_books_outlined,
                label: 'Secondary Module',
                value:
                    '${application.module2Name} (${application.module2Level})',
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RouteManager.applicationDetail);
                    },
                    child: const Text('View Details'),
                  ),
                ),
                // Only allow editing if the status is pending (Business Logic)
                if (application.status.toLowerCase() == 'pending') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to form, passing 'true' to indicate editing mode
                        Navigator.pushNamed(
                          context,
                          RouteManager.applicationForm,
                          arguments: true,
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
