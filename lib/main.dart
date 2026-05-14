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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/supabase_config.dart';
import 'utils/app_theme.dart';
import 'utils/route_manager.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const StudentAssistantApp());
}

class StudentAssistantApp extends StatelessWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inject ViewModels so they are available throughout the app
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        
        // Setup central routing
        initialRoute: RouteManager.login,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}