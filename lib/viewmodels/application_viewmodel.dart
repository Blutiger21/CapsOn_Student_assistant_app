/**
 * Student Numbers: [TO BE FILLED BY GROUP MEMBERS]
 * Student Names  : [TO BE FILLED BY GROUP MEMBERS]
 * Question: Application ViewModel - CRUD Operations
 */

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationViewModel extends ChangeNotifier {
  ApplicationModel? _myApplication;
  List<ApplicationModel> _allApplications = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  ApplicationModel? get myApplication => _myApplication;
  List<ApplicationModel> get allApplications => _allApplications;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasApplication => _myApplication != null;

  // ─── READ: Fetch the current student's own application ───────────────────

  Future<void> fetchMyApplication(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await SupabaseConfig.client
          .from('applications')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();

      _myApplication = data != null ? ApplicationModel.fromMap(data) : null;
    } catch (e) {
      _errorMessage = 'Failed to load your application. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── READ: Admin fetches ALL applications ────────────────────────────────

  Future<void> fetchAllApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await SupabaseConfig.client
          .from('applications')
          .select()
          .order('created_at', ascending: false);

      _allApplications = (data as List)
          .map((item) => ApplicationModel.fromMap(item))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load applications. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── CREATE: Submit a new application WITH FILE UPLOAD ──────────────────

  Future<bool> submitApplication(ApplicationModel application, {File? documentFile}) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      String? finalDocUrl = application.documentUrl;

      // 1. Upload the file to Supabase Storage if one was provided
      if (documentFile != null) {
        // Create a unique file name using a timestamp
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${documentFile.path.split('/').last}';
        final filePath = '${application.studentId}/$fileName';

        await SupabaseConfig.client.storage
            .from('supporting_documents')
            .upload(filePath, documentFile);

        // Get the URL to save in the database
        finalDocUrl = SupabaseConfig.client.storage
            .from('supporting_documents')
            .getPublicUrl(filePath);
      }

      // 2. Attach the URL to the application model
      final appToSubmit = application.copyWith(documentUrl: finalDocUrl);

      // 3. Save to the database
      final data = await SupabaseConfig.client
          .from('applications')
          .insert(appToSubmit.toMap())
          .select()
          .single();

      _myApplication = ApplicationModel.fromMap(data);
      _successMessage = 'Your application has been submitted successfully!';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = 'DB Error: ${e.message}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Upload Error: Please ensure your file is valid and try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ─── UPDATE: Student edits their application WITH OPTIONAL FILE UPLOAD ───

  Future<bool> updateApplication(String applicationId, ApplicationModel updated, {File? documentFile}) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      String? finalDocUrl = updated.documentUrl;

      // If they selected a new file, upload it and overwrite the old URL
      if (documentFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${documentFile.path.split('/').last}';
        final filePath = '${updated.studentId}/$fileName';

        await SupabaseConfig.client.storage
            .from('supporting_documents')
            .upload(filePath, documentFile);

        finalDocUrl = SupabaseConfig.client.storage
            .from('supporting_documents')
            .getPublicUrl(filePath);
      }

      final appToSubmit = updated.copyWith(documentUrl: finalDocUrl);

      final data = await SupabaseConfig.client
          .from('applications')
          .update(appToSubmit.toMap())
          .eq('id', applicationId)
          .select()
          .single();

      _myApplication = ApplicationModel.fromMap(data);
      _successMessage = 'Application updated successfully!';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = 'DB Error: ${e.message}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Update Error: Please ensure your file is valid and try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ─── DELETE: Student deletes their pending application ───────────────────

  Future<bool> deleteApplication(String applicationId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseConfig.client
          .from('applications')
          .delete()
          .eq('id', applicationId);

      _myApplication = null;
      _successMessage = 'Application deleted successfully.';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application. Please try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ─── UPDATE: Admin approves or rejects an application ────────────────────

  Future<bool> updateApplicationStatus(
      String applicationId, String newStatus) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseConfig.client
          .from('applications')
          .update({'status': newStatus})
          .eq('id', applicationId);

      // Update the local list
      final index =
          _allApplications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        _allApplications[index] =
            _allApplications[index].copyWith(status: newStatus);
      }

      _successMessage =
          'Application ${newStatus == 'approved' ? 'approved' : 'rejected'} successfully.';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status. Please try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ─── DELETE: Admin removes an invalid application ─────────────────────────

  Future<bool> adminDeleteApplication(String applicationId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseConfig.client
          .from('applications')
          .delete()
          .eq('id', applicationId);

      _allApplications.removeWhere((app) => app.id == applicationId);
      _successMessage = 'Application removed successfully.';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove application. Please try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearApplication() {
    _myApplication = null;
    notifyListeners();
  }
}