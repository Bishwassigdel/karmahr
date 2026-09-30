package com.example.my_first_flutter_app

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth requires a FragmentActivity (not a plain FlutterActivity) on
// Android — the biometric prompt it shows is itself a DialogFragment.
class MainActivity : FlutterFragmentActivity()
