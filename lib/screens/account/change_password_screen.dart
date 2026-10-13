import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../domain/password_rules.dart';
import '../../l10n/l10n.dart';
import '../../state/auth_repository.dart';
import '../apps/widgets/ui_kit.dart';
import 'account_form.dart';

/// Settings > Change password. Asks for the current password first.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_current.text.isEmpty) {
      setState(() => _error = l10n.authErrCurrent);
      return;
    }
    final problem = passwordProblem(
      _password.text,
      _confirm.text,
      old: _current.text,
    );
    if (problem != null) {
      setState(() => _error = problem.label(l10n));
      return;
    }
    final repo = context.read<AuthRepository>();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await repo.changePassword(_current.text, _password.text);
      if (!mounted) return;
      setState(() => _busy = false);
      await showMessage(
        context,
        title: l10n.changePasswordTitle,
        message: l10n.changePasswordDone,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on AuthFailure catch (f) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = f.reason.accountLabel(l10n);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AccountFormPage(
      title: l10n.changePasswordTitle,
      busy: _busy,
      error: _error,
      actionLabel: l10n.changePasswordAction,
      onSubmit: _save,
      fields: [
        AccountField(
          label: l10n.currentPasswordLabel,
          controller: _current,
          obscure: true,
        ),
        AccountField(
          label: l10n.newPasswordLabel,
          controller: _password,
          obscure: true,
          placeholder: l10n.passwordHelp,
        ),
        AccountField(
          label: l10n.confirmPasswordLabel,
          controller: _confirm,
          obscure: true,
        ),
      ],
    );
  }
}
