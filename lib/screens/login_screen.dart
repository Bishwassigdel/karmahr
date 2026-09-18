import 'package:flutter/cupertino.dart';

import 'main_nav_screen.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  // Controller for Staff ID input
  final _staffIdController = TextEditingController();

  // Controller for Password input
  final _passwordController = TextEditingController();

  // This controls whether the password is hidden or visible
  bool _obscurePassword = true;

  // ============================================================
  // DISPOSE
  // ============================================================

  // Dispose controllers when the screen is removed.
  // This helps prevent memory leaks.
  @override
  void dispose() {
    _staffIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================
  //
  // Used by features that aren't built yet (Forgot Password, SSO) —
  // there's no backend/auth in this app yet, so these can't do
  // anything real, but a dialog is a more honest placeholder than a
  // button that silently does nothing.
  void _showMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD TEXT FIELD
  // ============================================================

  // Reusable function for creating input fields.
  //
  // Instead of writing the same CupertinoTextField code
  // multiple times, we can use this function.
  Widget _buildField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return CupertinoTextField(
      // Connect the field with its controller
      controller: controller,

      // Placeholder text inside the field
      placeholder: placeholder,

      // Hide text when this is true
      obscureText: obscureText,

      // Space inside the input field
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      // Icon displayed on the left
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, size: 19, color: CupertinoColors.systemGrey),
      ),

      // Optional widget on the right.
      // We use this for the password eye icon.
      suffix: suffix,

      // Input field background and border radius.
      // .resolveFrom(context) is needed here — State's own `context`
      // getter works fine outside build() too — otherwise this stays
      // stuck on its light-mode color even in Dark Mode.
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),

      // Text style inside the input field
      style: const TextStyle(fontSize: 15, decoration: TextDecoration.none),
    );
  }

  // ============================================================
  // MAIN BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // KarmaHR primary red color
    const karmaRed = AppColors.karmaRed;

    // CupertinoDynamicColor must be resolved against the current context
    // before use in plain widgets — otherwise it silently always renders
    // its light-mode value, even in Dark Mode.
    final background = AppColors.background.resolveFrom(context);
    final textPrimary = AppColors.textPrimary.resolveFrom(context);

    return CupertinoPageScaffold(
      backgroundColor: background,

      child: SafeArea(
        child: SingleChildScrollView(
          // Screen horizontal and vertical spacing
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // LOGO
              // ==================================================

              Container(
                width: 56,
                height: 56,

                decoration: BoxDecoration(
                  // Light red background
                  color: karmaRed.withValues(alpha: 0.08),

                  // Rounded corners
                  borderRadius: BorderRadius.circular(16),
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),

                  child: Image.asset(
                    'assets/images/logo.jpg',

                    // Make image fill the container
                    fit: BoxFit.cover,

                    // Fallback if image has any issue
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        CupertinoIcons.person_3_fill,
                        color: karmaRed,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // PAGE TITLE
              // ==================================================
              Text(
                'Sign in to KarmaHR',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // SUBTITLE
              // ==================================================
              const Text(
                'Enter your staff credentials to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 34),

              // ==================================================
              // STAFF ID LABEL
              // ==================================================
              Text(
                'Staff ID',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // STAFF ID FIELD
              // ==================================================
              _buildField(
                controller: _staffIdController,
                placeholder: 'e.g. MB-24071',
                icon: CupertinoIcons.person,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PASSWORD LABEL
              // ==================================================
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // PASSWORD FIELD
              // ==================================================
              _buildField(
                controller: _passwordController,
                placeholder: 'Enter your password',
                icon: CupertinoIcons.lock,

                // Hide/show password
                obscureText: _obscurePassword,

                // Eye icon on the right side
                suffix: CupertinoButton(
                  padding: const EdgeInsets.only(right: 12),

                  minimumSize: Size.zero,

                  onPressed: () {
                    // Change password visibility
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },

                  child: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash,

                    size: 19,

                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // FORGOT PASSWORD
              // ==================================================
              Align(
                alignment: Alignment.centerRight,

                child: CupertinoButton(
                  padding: EdgeInsets.zero,

                  minimumSize: Size.zero,

                  onPressed: () {
                    _showMessage('Forgot password isn\'t available yet.');
                  },

                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC62828),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // SIGN IN BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,

                child: CupertinoButton(
                  // Red background
                  color: karmaRed,

                  // Rounded corners
                  borderRadius: BorderRadius.circular(12),

                  onPressed: () {
                    // =================================================
                    // TEMPORARY LOGIN
                    // =================================================
                    //
                    // Currently this directly opens MainNavScreen.
                    //
                    // Later, this is where you will:
                    // 1. Validate Staff ID
                    // 2. Validate password
                    // 3. Call your backend
                    // 4. Check authentication
                    // 5. Save login session
                    //
                    // =================================================

                    Navigator.pushReplacement(
                      context,

                      CupertinoPageRoute(
                        builder: (context) => const MainNavScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    'Sign In',

                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,

                      // White text on red button
                      color: CupertinoColors.white,

                      // Remove unwanted underline
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // SSO DIVIDER
              // ==================================================
              Row(
                children: [
                  // Left line
                  Expanded(
                    child: Container(
                      height: 1,
                      color: CupertinoColors.systemGrey5.resolveFrom(context),
                    ),
                  ),

                  // Divider text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with SSO',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),

                  // Right line
                  Expanded(
                    child: Container(
                      height: 1,
                      color: CupertinoColors.systemGrey5.resolveFrom(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CONTINUE WITH SSO BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,

                child: CupertinoButton(
                  // Light grey button
                  color: CupertinoColors.systemGrey6.resolveFrom(context),

                  borderRadius: BorderRadius.circular(12),

                  // Later this can connect to Company SSO, SAML, OpenID
                  // Connect, or an Enterprise Identity Provider — none
                  // of that exists yet, so this just says so for now.
                  onPressed: () {
                    _showMessage('SSO sign-in isn\'t available yet.');
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      // SSO icon
                      Icon(
                        CupertinoIcons.person_2,
                        size: 18,
                        color: textPrimary,
                      ),

                      const SizedBox(width: 8),

                      // SSO button text
                      Text(
                        'Continue with SSO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
