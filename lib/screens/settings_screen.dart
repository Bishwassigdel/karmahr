import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Human-readable label + description for each mode, so the row-building
  // code below doesn't repeat itself three times.
  String _title(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  String _subtitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return "Match this iPhone's Light/Dark setting";
      case AppThemeMode.light:
        return 'Always use Light appearance';
      case AppThemeMode.dark:
        return 'Always use Dark appearance';
    }
  }

  IconData _icon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return CupertinoIcons.device_phone_portrait;
      case AppThemeMode.light:
        return CupertinoIcons.sun_max_fill;
      case AppThemeMode.dark:
        return CupertinoIcons.moon_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this screen's checkmarks whenever the
    // selected mode changes — same pattern used for AttendanceState.
    final themeState = context.watch<ThemeState>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('APPEARANCE'),
              footer: const Text(
                'Choose how KarmaHR looks. "System Default" switches '
                'automatically with your phone — pick Light or Dark to '
                'keep it fixed no matter what your phone is set to.',
              ),
              children: AppThemeMode.values.map((mode) {
                final isSelected = themeState.mode == mode;
                return CupertinoListTile(
                  leading: Icon(_icon(mode)),
                  title: Text(_title(mode)),
                  subtitle: Text(_subtitle(mode)),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.activeGreen,
                        )
                      : null,
                  onTap: () => context.read<ThemeState>().setMode(mode),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
