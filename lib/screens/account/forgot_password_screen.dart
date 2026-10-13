import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../domain/password_rules.dart';
import '../../l10n/l10n.dart';
import '../../state/auth_repository.dart';
import '../apps/widgets/ui_kit.dart';
import 'account_form.dart';

/// "Forgot password": ask for an email, get a 6-digit code, enter it with a
/// new password, then go back to the login screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  var _codeSent = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l10n = context.l10n;
    if (!looksLikeEmail(_email.text)) {
      setState(() => _error = l10n.authErrEmail);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthRepository>().sendPasswordReset(_email.text);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _codeSent = true;
      });
    } on AuthFailure catch (f) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = f.reason.accountLabel(l10n);
      });
    }
  }

  Future<void> _reset() async {
    final l10n = context.l10n;
    if (_code.text.trim().isEmpty) {
      setState(() => _error = l10n.authErrCode);
      return;
    }
    final problem = passwordProblem(_password.text, _confirm.text);
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
      await repo.resetPassword(_email.text, _code.text, _password.text);
      if (!mounted) return;
      setState(() => _busy = false);
      await showMessage(
        context,
        title: l10n.passwordResetTitle,
        message: l10n.passwordResetBody,
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
    if (!_codeSent) {
      return AccountFormPage(
        title: l10n.forgotTitle,
        intro: l10n.forgotIntro,
        busy: _busy,
        error: _error,
        actionLabel: l10n.activateSendCode,
        onSubmit: _sendCode,
        fields: [
          AccountField(
            label: l10n.emailLabel,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            placeholder: l10n.emailHint,
          ),
        ],
      );
    }
    return AccountFormPage(
      title: l10n.forgotTitle,
      intro: l10n.codeSentTo(_email.text.trim()),
      busy: _busy,
      error: _error,
      actionLabel: l10n.forgotAction,
      onSubmit: _reset,
      fields: [
        AccountField(
          label: l10n.codeLabel,
          controller: _code,
          keyboardType: TextInputType.number,
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
      extras: [accountLink(l10n.resendCode, _busy ? null : _sendCode)],
    );
  }
}
