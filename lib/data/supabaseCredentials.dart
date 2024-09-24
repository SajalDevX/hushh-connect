import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCredentials {
  static const String APIKEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2eWNpaXRyZ2NxaGZod3BvcWxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ1MzMzODgsImV4cCI6MjA0MDEwOTM4OH0.gEHU_6lk71VcnWYq1Z5DWl5sWh-1VnI-E1fQ1Eo5eVE';
  static const String APIURL = 'https://gvyciitrgcqhfhwpoqld.supabase.co';
  static SupabaseClient supabaseClient = SupabaseClient(APIURL, APIKEY);
}
