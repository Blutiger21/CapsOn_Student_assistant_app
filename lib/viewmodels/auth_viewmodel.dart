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
/// Question: Authentication ViewModel

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/supabase_config.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Signs in the user with email and password using Supabase Auth
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await SupabaseConfig.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id, email);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registers a new user and creates their database profile
  Future<bool> signUp(
    String email,
    String password,
    String fullName,
    String studentNumber,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Create the user in Supabase Authentication
      final response = await SupabaseConfig.client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // 2. Immediately create their profile in the database
        await SupabaseConfig.client.from('profiles').insert({
          'id': response.user!.id,
          'full_name': fullName.trim(),
          'student_number': studentNumber.trim(),
          'role': 'student', // New registrations default to student
        });

        // 3. Load the profile into the app state
        await _loadUserProfile(response.user!.id, email);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Catch database errors (like trying to register an existing student number)
      _errorMessage =
          'Registration error: This student number or email may already be registered.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Loads user profile from the profiles table to determine role
  Future<void> _loadUserProfile(String userId, String email) async {
    try {
      final data = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = UserModel.fromMap({
        ...data,
        'email': email,
      });
    } catch (e) {
      // Default to student role if profile not found
      _currentUser = UserModel(
        id: userId,
        email: email,
        role: 'student',
      );
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await SupabaseConfig.client.auth.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Checks if there is already a valid session on app launch
  Future<void> checkExistingSession() async {
    final session = SupabaseConfig.client.auth.currentSession;
    if (session != null) {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        await _loadUserProfile(user.id, user.email ?? '');
        notifyListeners();
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

