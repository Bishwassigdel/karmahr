import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../domain/password_rules.dart';
import '../../l10n/l10n.dart';
import '../../state/auth_repository.dart';
import '../../state/auth_state.dart';
import '../../state/session.dart';
import '../portal_home.dart';
import 'account_form.dart';

/// First visit of an employee HR has invited: choose a password, get a code
/// by email, enter it, and land in their portal.
class ActivateAccountScreen extends StatefulWidget {
  const ActivateAccountScreen({super.key});

  @override
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();

  /// false = asking for email and password; true = waiting for the code.
  var _codeSent = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l10n = context.l10n;
    if (!looksLikeEmail(_email.text)) {
      setState(() => _error = l10n.authErrEmail);
      return;
    }
    final problem = passwordProblem(_password.text, _confirm.text);
    if (problem != null) {
      setState(() => _error = problem.label(l10n));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthRepository>().startSignUp(
        _email.text,
        _password.text,
      );
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

  Future<void> _activate() async {
    final l10n = context.l10n;
    final repo = context.read<AuthRepository>();
    final auth = context.read<AuthState>();
    if (_code.text.trim().isEmpty) {
      setState(() => _error = l10n.authErrCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await repo.finishSignUp(_email.text, _code.text);
      if (!mounted) return;
      auth.signInAs(user);
      startSession(context);
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (_) => portalHomeFor(user.role)),
        (_) => false,
      );
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
        title: l10n.activateTitle,
        intro: l10n.activateIntro,
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
    return AccountFormPage(
      title: l10n.activateTitle,
      intro: l10n.codeSentTo(_email.text.trim()),
      busy: _busy,
      error: _error,
      actionLabel: l10n.activateAction,
      onSubmit: _activate,
      fields: [
        AccountField(
          label: l10n.codeLabel,
          controller: _code,
          keyboardType: TextInputType.number,
        ),
      ],
      extras: [accountLink(l10n.resendCode, _busy ? null : _sendCode)],
    );
  }
}
