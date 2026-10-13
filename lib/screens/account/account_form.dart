import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';

/// A labelled text box for the account screens (email, password, code).
class AccountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? placeholder;
  final bool enabled;

  const AccountField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.placeholder,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            enabled: enabled,
            autocorrect: false,
            placeholder: placeholder,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// The page every account screen shares: a title, a short explanation, the
/// fields, an error line and one big red button.
class AccountFormPage extends StatelessWidget {
  final String title;
  final String? intro;
  final List<Widget> fields;
  final String? error;
  final bool busy;
  final String actionLabel;
  final VoidCallback onSubmit;

  /// Small extra buttons under the main one (for example "Send a new code").
  final List<Widget> extras;

  const AccountFormPage({
    super.key,
    required this.title,
    this.intro,
    required this.fields,
    this.error,
    required this.busy,
    required this.actionLabel,
    required this.onSubmit,
    this.extras = const [],
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              children: [
                if (intro != null) ...[
                  Text(
                    intro!,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                ...fields,
                if (error != null) ...[
                  Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                CupertinoButton(
                  color: AppColors.karmaRed,
                  borderRadius: BorderRadius.circular(12),
                  // Ignored while waiting, so a double tap can't send twice.
                  onPressed: busy ? null : onSubmit,
                  child: busy
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : Text(
                          actionLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                ),
                ...extras,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small text-only button, for secondary actions.
Widget accountLink(String text, VoidCallback? onTap) => CupertinoButton(
  padding: const EdgeInsets.only(top: 12),
  minimumSize: Size.zero,
  onPressed: onTap,
  child: Text(text, style: const TextStyle(fontSize: 13)),
);

/// Loose email check: something, an @, something with a dot.
bool looksLikeEmail(String text) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text.trim());
