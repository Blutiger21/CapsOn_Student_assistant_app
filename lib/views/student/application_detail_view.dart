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
///Question: Application Detail View - Displaying Application Information and Management Actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../utils/app_theme.dart';
import '../../utils/route_manager.dart';
import '../../utils/shared_widgets.dart';

class ApplicationDetailView extends StatefulWidget {
  const ApplicationDetailView({super.key});

  @override
  State<ApplicationDetailView> createState() => _ApplicationDetailViewState();
}

class _ApplicationDetailViewState extends State<ApplicationDetailView> {
  // ─── Delete Confirmation Dialog (Requirement 1.4) ────────────────────────
  Future<void> _confirmDelete(
      BuildContext context, String applicationId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Application'),
          content: const Text(
            'Are you sure you want to withdraw your Student Assistant application? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // If user confirmed, execute the delete operation
    if (shouldDelete == true && mounted) {
      final appVM = context.read<ApplicationViewModel>();
      final success = await appVM.deleteApplication(applicationId);

      if (success && mounted) {
        Navigator.pop(context); // Return to Student Home Screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appVM.successMessage ?? 'Application deleted.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appVM.errorMessage ?? 'Failed to delete.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _openDocument(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      // Opens the link in the phone's external browser
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document. The link might be broken.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel to ensure the UI updates if the application is edited
    final appVM = context.watch<ApplicationViewModel>();
    final application = appVM.myApplication;

    // Safety check in case the user navigates here without an application
    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: const Center(child: Text('No application found.')),
      );
    }

    final isPending = application.status.toLowerCase() == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
      ),
      body: LoadingOverlay(
        isLoading: appVM.isSubmitting,
        message: 'Processing...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Status Card ────────────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Status',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          StatusBadge(status: application.status),
                        ],
                      ),
                      if (!isPending)
                        Icon(
                          AppTheme.statusIcon(application.status),
                          color: AppTheme.statusColor(application.status),
                          size: 32,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Applicant Details ──────────────────────────────────────────
              const SectionHeader(title: 'Applicant Information'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: application.fullName,
                      ),
                      const Divider(height: 24),
                      InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Student Number',
                        value: application.studentNumber,
                      ),
                      const Divider(height: 24),
                      InfoRow(
                        icon: Icons.school_outlined,
                        label: 'Year of Study',
                        value: 'Year ${application.yearOfStudy}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Module Details ─────────────────────────────────────────────
              const SectionHeader(title: 'Selected Modules'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.book_outlined,
                        label: 'Primary Module (${application.module1Level})',
                        value: application.module1Name,
                      ),
                      if (application.module2Name != null &&
                          application.module2Name!.isNotEmpty) ...[
                        const Divider(height: 24),
                        InfoRow(
                          icon: Icons.my_library_books_outlined,
                          label:
                              'Secondary Module (${application.module2Level})',
                          value: application.module2Name!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Declaration Details ────────────────────────────────────────
              const SectionHeader(title: 'Declaration'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(
                        application.meetsRequirements
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: application.meetsRequirements
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Applicant confirmed they meet the minimum academic requirements for the selected modules.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Supporting Document ──────────────────────────────────────────────
              if (application.documentUrl != null &&
                  application.documentUrl!.isNotEmpty) ...[
                const SectionHeader(title: 'Supporting Documentation'),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.file_present,
                        color: AppTheme.primaryColor),
                    title: const Text('View Uploaded Document'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openDocument(application.documentUrl!),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // ─── Management Actions (Only available if Pending) ─────────────
              if (isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Withdraw'),
                        onPressed: () =>
                            _confirmDelete(context, application.id!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        onPressed: () {
                          // Navigate to form, passing 'true' for edit mode
                          Navigator.pushNamed(
                            context,
                            RouteManager.applicationForm,
                            arguments: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'You can only modify or withdraw an application while it is pending.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ] else ...[
                Center(
                  child: Text(
                    'This application has been processed and can no longer be modified.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
