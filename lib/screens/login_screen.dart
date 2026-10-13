import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/auth_repository.dart';
import '../state/auth_state.dart';
import '../state/session.dart';
import 'account/activate_account_screen.dart';
import 'account/forgot_password_screen.dart';
import 'portal_home.dart';
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

  // DEMO ONLY: which portal to open. Goes away once the backend returns
  // the real role on login.
  UserRole _demoRole = UserRole.employee;

  // Real login: true while we wait for the server, and what to tell the
  // person if it didn't work.
  bool _busy = false;
  String? _error;

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
  // SIGN IN
  // ============================================================
  //
  // Demo (no backend): sign in with the picked role.
  // Real: check the email and password with the server, then open the
  // portal for the role in the person's profile.
  Future<void> _signIn() async {
    final repo = context.read<AuthRepository>();
    final auth = context.read<AuthState>();
    final l10n = context.l10n;

    if (!repo.usesBackend) {
      auth.signIn(_demoRole);
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => portalHomeFor(_demoRole)),
      );
      return;
    }

    final email = _staffIdController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.loginErrEmpty);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await repo.signIn(email, password);
      if (!mounted) return;
      auth.signInAs(user);
      startSession(context);
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => portalHomeFor(user.role)),
      );
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = failure.reason == AuthFailureReason.wrongCredentials
            ? l10n.loginErrWrong
            : failure.reason.accountLabel(l10n);
      });
    }
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
              child: Text(context.l10n.ok),
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
    TextInputType? keyboardType,
  }) {
    return CupertinoTextField(
      // Connect the field with its controller
      controller: controller,

      keyboardType: keyboardType,
      autocorrect: false,

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
    final l10n = context.l10n;
    // Real login (email) or the demo (Staff ID + role picker).
    final real = context.read<AuthRepository>().usesBackend;

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
                l10n.loginTitle,
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
              Text(
                l10n.loginSubtitle,
                style: const TextStyle(
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
                real ? l10n.emailLabel : l10n.staffIdLabel,
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
                placeholder: real ? l10n.emailHint : l10n.staffIdHint,
                icon: real ? CupertinoIcons.mail : CupertinoIcons.person,
                keyboardType: real ? TextInputType.emailAddress : null,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PASSWORD LABEL
              // ==================================================
              Text(
                l10n.passwordLabel,
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
                placeholder: l10n.passwordHint,
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
                    semanticLabel: _obscurePassword
                        ? l10n.a11yShowPassword
                        : l10n.a11yHidePassword,

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
                    if (!real) {
                      _showMessage(l10n.forgotPasswordUnavailable);
                      return;
                    }
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },

                  child: Text(
                    l10n.forgotPassword,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC62828),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (!real) ...[
                // ==================================================
                // DEMO ROLE PICKER
                // ==================================================
                Text(
                  l10n.demoRoleLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<UserRole>(
                    groupValue: _demoRole,
                    onValueChanged: (role) {
                      if (role != null) setState(() => _demoRole = role);
                    },
                    children: {
                      for (final role in demoLoginRoles)
                        role: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            role.label(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    },
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.demoRoleNote,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 24),
              ],

              // Why a real sign-in failed.
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.destructiveRed,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 14),
              ],

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

                  // Ignored while waiting, so a double tap can't sign in twice.
                  onPressed: _busy ? null : _signIn,

                  child: _busy
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : Text(
                          l10n.signIn,

                          style: const TextStyle(
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

              if (real)
                Center(
                  child: CupertinoButton(
                    padding: const EdgeInsets.only(top: 14),
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const ActivateAccountScreen(),
                      ),
                    ),
                    child: Text(
                      l10n.activateLink,
                      style: const TextStyle(fontSize: 13),
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

                  // Divider text — Flexible so it can wrap instead of
                  // pushing the divider lines off a narrow screen.
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.ssoDivider,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                          decoration: TextDecoration.none,
                        ),
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
                    _showMessage(l10n.ssoUnavailable);
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
                      Flexible(
                        child: Text(
                          l10n.continueWithSso,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            decoration: TextDecoration.none,
                          ),
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
