/**
 * Student Numbers: [TO BE FILLED BY GROUP MEMBERS]
 * Student Names  : [TO BE FILLED BY GROUP MEMBERS]
 * Question: Supabase Service - Backend Configuration
 */

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mhzbkqstxmzzfukhujnm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oemJrcXN0eG16emZ1a2h1am5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5OTgwNzIsImV4cCI6MjA5MzU3NDA3Mn0.zvEDdZGoPP-ThwHAWIUrL_u6sT6YIfKwng3Iex5OE44';

  static SupabaseClient get client => Supabase.instance.client;
}