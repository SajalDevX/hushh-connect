import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCredentials {
  static String APIKEY = dotenv.env['API_KEY_ENV'] ?? '';
  static String APIURL = dotenv.env['API_URL_ENV'] ?? '';
  static SupabaseClient supabaseClient = SupabaseClient(APIURL, APIKEY);
}
