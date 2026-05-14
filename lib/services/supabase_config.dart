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
/// Question: Supabase Service - Backend Configuration
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mhzbkqstxmzzfukhujnm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oemJrcXN0eG16emZ1a2h1am5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5OTgwNzIsImV4cCI6MjA5MzU3NDA3Mn0.zvEDdZGoPP-ThwHAWIUrL_u6sT6YIfKwng3Iex5OE44';

  static SupabaseClient get client => Supabase.instance.client;
}