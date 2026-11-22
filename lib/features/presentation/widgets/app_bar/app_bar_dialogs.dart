import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/services/desktop_entry_service.dart';
import '../../../../core/services/uninstaller_service.dart';

class AppBarDialogs {
  // Hide File menu on web.
  static bool get showFileOption => !kIsWeb;

  // Updates Dialog
  static void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101016),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const HeroIcon(
                      HeroIcons.arrowPath,
                      size: 20,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Checking for updates...'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const LinearProgressIndicator(
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancel'.tr(),
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Timer(const Duration(seconds: 3), () {
      if (!context.mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        _showUpToDateDialog(context);
      }
    });
  }

  static void _showUpToDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        title: Text(
          'System Update'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Your inator is fully up to date!'.tr(),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Perfect'.tr(),
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop Entry Creation Dialog
  static void showDesktopEntryDialog(BuildContext context) {
    if (kIsWeb || !Platform.isLinux) {
      _showShortcutStatusDialog(context, false);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(width: 20),
            Text(
              'Registering desktop launcher...'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    DesktopEntryService().createDesktopEntry().then((success) {
      if (context.mounted) {
        Navigator.pop(context);
        _showShortcutStatusDialog(context, success);
      }
    });
  }

  static void _showShortcutStatusDialog(BuildContext context, bool success) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        title: Text(
          success ? 'Launcher Registered'.tr() : 'Registration Failed'.tr(),
          style: TextStyle(
            color: success ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        content: Text(
          success
              ? 'The launcher was successfully registered to your system app launcher database.'
                    .tr()
              : 'The system failed to register the launcher shortcut. Ensure necessary platform compatibility or write permissions are met.'
                    .tr(),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'OK'.tr(),
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  // Uninstaller Sequence
  static void showUninstallSequence(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101016),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
          title: Row(
            children: [
              const HeroIcon(
                HeroIcons.trash,
                color: Colors.orangeAccent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Uninstall Application'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to uninstall random word generator.'.tr() +
                '\n\n' +
                'This will remove desktop launchers, local user data, and system configurations.'
                    .tr(),
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel'.tr(),
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                _executeUninstallation(context);
              },
              child: Text(
                'Uninstall'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _executeUninstallation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.orangeAccent),
            const SizedBox(width: 20),
            Text(
              'Removing system components...'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    UninstallerService().uninstallApp().then((success) {
      if (context.mounted) {
        Navigator.pop(context);
        _showUninstallStatusDialog(context, success);
      }
    });
  }

  static void _showUninstallStatusDialog(BuildContext context, bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: success ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        title: Text(
          success ? 'Uninstall Complete'.tr() : 'Uninstall Incomplete'.tr(),
          style: TextStyle(
            color: success ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        content: Text(
          success
              ? 'Application shortcuts and local data have been removed. The application will now close.'
                    .tr()
              : 'Some components could not be automatically purged. You may need elevated permissions.'
                    .tr(),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: success ? Colors.greenAccent : Colors.redAccent,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);

              if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: Text(
              'Close App'.tr(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Exit Dialog
  static void showExitSequence(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101016),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
          title: Row(
            children: [
              const HeroIcon(
                HeroIcons.exclamationTriangle,
                color: Colors.redAccent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Exit Application'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to terminate this generation session?'.tr(),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel'.tr(),
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                _startShutdownCountdown(context);
              },
              child: Text(
                'Yes, Exit'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _startShutdownCountdown(BuildContext context) {
    int countdown = 3;
    Timer? shutdownTimer;

    void executePlatformExit() {
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            shutdownTimer ??= Timer.periodic(const Duration(seconds: 1), (
              timer,
            ) {
              if (countdown > 1) {
                setState(() => countdown--);
              } else {
                timer.cancel();
                executePlatformExit();
              }
            });

            return AlertDialog(
              backgroundColor: const Color(0xFF0D0D12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Shutting down app in:'.tr() +
                        '\n' +
                        '{count} seconds'.tr(
                          namedArgs: {'count': '$countdown'},
                        ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          shutdownTimer?.cancel();
                          executePlatformExit();
                        },
                        child: Text(
                          'Close Now'.tr(),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          shutdownTimer?.cancel();
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'Stay in App'.tr(),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Developer Profile Bio Dialog
  static void showBioDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101016),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white12),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white10,
                        child: HeroIcon(
                          HeroIcons.user,
                          size: 40,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Text(
                    'Name: Kutlwano P. Maruatona'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Alias: Drew'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bio:'.tr(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Systems enthusiast and desktop developer working on building robust UI tools for power-users.'
                        .tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Believer in highly modular codebases, keyboard-driven navigation models, and clean visual layouts that don't get in the developer's way."
                        .tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Passionate about cognitive architectures, evolutionary theories, and building things that last.'
                        .tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Close'.tr(),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
