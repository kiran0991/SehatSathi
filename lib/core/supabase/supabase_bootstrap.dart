import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrapConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

Future<void> initializeSupabase() async {
  if (!SupabaseBootstrapConfig.isConfigured) {
    return;
  }

  await Supabase.initialize(
    url: SupabaseBootstrapConfig.url,
    publishableKey: SupabaseBootstrapConfig.anonKey,
  );
}
