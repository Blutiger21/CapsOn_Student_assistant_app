/// Student Numbers: [TO BE FILLED BY GROUP MEMBERS]
/// Student Names  : [TO BE FILLED BY GROUP MEMBERS]
/// Question: Application ViewModel

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/application_model.dart';
import '../services/supabase_config.dart';

class ApplicationViewModel extends ChangeNotifier {
  final List<ApplicationModel> _applications = [];
  ApplicationModel? _selectedApplication;

  bool _isLoading = false;
  String? _errorMessage;

  List<ApplicationModel> get applications => List.unmodifiable(_applications);
  ApplicationModel? get selectedApplication => _selectedApplication;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads the signed-in user's applications.
  Future<void> fetchMyApplications() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        _applications.clear();
        _selectedApplication = null;
        _setLoading(false);
        return;
      }

      final response = await SupabaseConfig.client
          .from('applications')
          .select()
          .eq('student_id', user.id)
          .order('updated_at', ascending: false);

      final data = response as List<dynamic>;
      _applications
        ..clear()
        ..addAll(data
            .map((e) => ApplicationModel.fromMap(e as Map<String, dynamic>)));

      _setLoading(false);
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
    }
  }

  /// Fetch a single application by id.
  Future<void> fetchApplicationById(String applicationId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await SupabaseConfig.client
          .from('applications')
          .select()
          .eq('id', applicationId)
          .single();

      _selectedApplication =
          ApplicationModel.fromMap(response as Map<String, dynamic>);

      _setLoading(false);
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      _selectedApplication = null;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _selectedApplication = null;
      _setLoading(false);
    }
  }

  /// Creates a new application for the signed-in user.
  Future<bool> createApplication({
    required String studentNumber,
    required String fullName,
    required int yearOfStudy,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool meetsRequirements,
    String? documentUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        _errorMessage = 'Please sign in first.';
        _setLoading(false);
        return false;
      }

      final app = ApplicationModel(
        studentId: user.id,
        studentNumber: studentNumber,
        fullName: fullName,
        yearOfStudy: yearOfStudy,
        module1Level: module1Level,
        module1Name: module1Name,
        module2Level: module2Level,
        module2Name: module2Name,
        meetsRequirements: meetsRequirements,
        documentUrl: documentUrl,
        status: 'pending',
      );

      final payload = app.toMap();

      final response = await SupabaseConfig.client
          .from('applications')
          .insert(payload)
          .select()
          .single();

      final created =
          ApplicationModel.fromMap(response as Map<String, dynamic>);

      _applications.insert(0, created);
      _selectedApplication = created;

      _setLoading(false);
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Updates the selected application.
  Future<bool> updateSelectedApplication({
    String? studentNumber,
    String? fullName,
    int? yearOfStudy,
    String? module1Level,
    String? module1Name,
    String? module2Level,
    String? module2Name,
    bool? meetsRequirements,
    String? documentUrl,
    String? status,
  }) async {
    final current = _selectedApplication;
    if (current == null || current.id == null) {
      _errorMessage = 'No application selected.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final updated = current.copyWith(
        studentNumber: studentNumber,
        fullName: fullName,
        yearOfStudy: yearOfStudy,
        module1Level: module1Level,
        module1Name: module1Name,
        module2Level: module2Level,
        module2Name: module2Name,
        meetsRequirements: meetsRequirements,
        documentUrl: documentUrl,
        status: status,
      );

      final payload = updated.toMap();

      final response = await SupabaseConfig.client
          .from('applications')
          .update(payload)
          .eq('id', updated.id)
          .select()
          .single();

      final saved =
          ApplicationModel.fromMap(response as Map<String, dynamic>);

      _selectedApplication = saved;
      final idx = _applications.indexWhere((a) => a.id == saved.id);
      if (idx >= 0) {
        _applications[idx] = saved;
      } else {
        _applications.insert(0, saved);
      }

      _setLoading(false);
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }
}

