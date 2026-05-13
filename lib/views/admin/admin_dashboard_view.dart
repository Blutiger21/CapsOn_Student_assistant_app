/**
 * Student Numbers: 223007530; 223038085; 223005893; 223051025 ; 223040545; 221034577; 222033434; 223020021; 224020157
 * Student Names  :A Jara; BF Motseki; TV Thabisi; LD MoKheti;FB Amatebelle;ML Mwenda; KD Tsolo;B Mbinga ;KP Molelekeng
 * Question: Admin Dashboard (Read / Update / Delete Operations)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/application_model.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_theme.dart';
import '../../utils/route_manager.dart';
import '../../utils/shared_widgets.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  String _selectedFilter = 'All'; // Filter state

  @override
  void initState() {
    super.initState();
    // Fetch all applications when the dashboard loads (Read Operation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchAllApplications();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<ApplicationViewModel>().fetchAllApplications();
  }

  void _handleLogout() async {
    await context.read<AuthViewModel>().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteManager.login);
    }
  }

  // ─── Update Operation ──────────────────────────────────────────────────────
  Future<void> _updateStatus(String id, String newStatus) async {
    final appVM = context.read<ApplicationViewModel>();
    final success = await appVM.updateApplicationStatus(id, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? appVM.successMessage! : appVM.errorMessage!),
          backgroundColor:
              success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  // ─── Delete Operation ──────────────────────────────────────────────────────
  Future<void> _confirmDelete(String id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Application'),
        content: const Text(
            'Are you sure you want to permanently delete this invalid application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final appVM = context.read<ApplicationViewModel>();
      final success = await appVM.adminDeleteApplication(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(success ? appVM.successMessage! : appVM.errorMessage!),
            backgroundColor:
                success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _openDocument(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filtering Section ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    ['All', 'Pending', 'Approved', 'Rejected'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppTheme.accentColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? AppTheme.primaryColor
                            : Colors.black87,
                        fontWeight: _selectedFilter == filter
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Applications List ─────────────────────────────────────────────
          Expanded(
            child: Consumer<ApplicationViewModel>(
              builder: (context, appVM, child) {
                if (appVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Apply the selected filter
                final filteredList = appVM.allApplications.where((app) {
                  if (_selectedFilter == 'All') return true;
                  return app.status.toLowerCase() ==
                      _selectedFilter.toLowerCase();
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${_selectedFilter.toLowerCase()} applications found.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final app = filteredList[index];
                      return _buildApplicationAdminCard(app);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationAdminCard(ApplicationModel app) {
    final isPending = app.status.toLowerCase() == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          app.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${app.studentNumber} • Year ${app.yearOfStudy}'),
        trailing: StatusBadge(status: app.status),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          InfoRow(
              icon: Icons.book_outlined,
              label: 'Primary Module',
              value: '${app.module1Name} (${app.module1Level})'),
          if (app.module2Name != null && app.module2Name!.isNotEmpty)
            InfoRow(
                icon: Icons.my_library_books_outlined,
                label: 'Secondary Module',
                value: '${app.module2Name} (${app.module2Level})'),

          const SizedBox(height: 16),

          if (app.documentUrl != null && app.documentUrl!.isNotEmpty) ...[
            const Divider(),
            TextButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('View Supporting Document'),
              onPressed: () => _openDocument(app.documentUrl!),
            ),
          ],

          // ─── Admin Action Buttons ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.errorColor),
                tooltip: 'Remove Invalid Application',
                onPressed: () => _confirmDelete(app.id!),
              ),
              const Spacer(),
              if (isPending) ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                  ),
                  onPressed: () => _updateStatus(app.id!, 'rejected'),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor),
                  onPressed: () => _updateStatus(app.id!, 'approved'),
                  child: const Text('Approve'),
                ),
              ] else ...[
                // If already processed, give option to revert to pending
                TextButton.icon(
                  icon: const Icon(Icons.undo),
                  label: const Text('Revert to Pending'),
                  onPressed: () => _updateStatus(app.id!, 'pending'),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
