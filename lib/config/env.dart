// Settings that differ per machine and must never be committed. They come
// from a local `.env` file passed at build time:
//
//   flutter run --dart-define-from-file=.env
//
// Copy `.env.example` to `.env` and fill it in. Without it these are empty
// and the app runs on its built-in demo data, as before (tests and CI rely
// on that).

class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// The publishable key (starts with `sb_publishable_`). Safe in the app:
  /// Row Level Security in the database decides what each user may read.
  /// Never put the secret key here.
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
