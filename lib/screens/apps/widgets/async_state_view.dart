import 'package:flutter/cupertino.dart';

// The four states any dummy-data-today, real-API-later screen needs.
// Every Apps module (Attendance, Tasks, ...) uses this same wrapper
// so swapping in a real backend later is a one-line change.
enum LoadState { loading, error, empty, ready }

class AsyncStateView extends StatelessWidget {
  final LoadState state;
  final Widget child; // shown when state == ready
  final String emptyMessage;
  final String errorMessage;
  final VoidCallback? onRetry;

  // Optional content-shaped placeholder (e.g. SkeletonList) shown while
  // loading instead of the bare spinner. Optional so every existing
  // caller keeps working unchanged.
  final Widget? loadingPlaceholder;

  const AsyncStateView({
    super.key,
    required this.state,
    required this.child,
    this.emptyMessage = 'Nothing to show yet.',
    this.errorMessage = 'Something went wrong.',
    this.onRetry,
    this.loadingPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case LoadState.loading:
        if (loadingPlaceholder != null) return loadingPlaceholder!;
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(child: CupertinoActivityIndicator(radius: 14)),
        );
      case LoadState.error:
        return _StatusMessage(
          icon: CupertinoIcons.exclamationmark_triangle,
          message: errorMessage,
          actionLabel: onRetry != null ? 'Retry' : null,
          onAction: onRetry,
        );
      case LoadState.empty:
        return _StatusMessage(icon: CupertinoIcons.tray, message: emptyMessage);
      case LoadState.ready:
        return child;
    }
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 36, color: subtleTextColor),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: subtleTextColor),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
