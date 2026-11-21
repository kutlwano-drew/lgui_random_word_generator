import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb platform checks
import 'package:flutter/services.dart';   // For cross-platform SystemNavigator close hooks
import 'package:heroicons/heroicons.dart';

import '../../../../core/services/desktop_entry_service.dart';
import '../../../../core/services/uninstaller_service.dart';

class AppBarDialogs {
  
  // Getter to determine if the File menu/option should be rendered (hidden on web)
  static bool get showFileOption => !kIsWeb;

  // Updates Dialog
  static void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101016),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    HeroIcon(HeroIcons.arrowPath, size: 20, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Text(
                      'Checking for updates...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    Timer(const Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close checking loading popup
        _showUpToDateDialog(context);
      }
    });
  }

  static void _showUpToDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        title: const Text('System Update', style: TextStyle(color: Colors.white)),
        content: const Text('Your inator is fully up to date!', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Perfect', style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }

  // Desktop Entry (Shortcut) Creation Dialog
  static void showDesktopEntryDialog(BuildContext context) {
    // Short circuit safely if on Web or non-Linux platforms
    if (kIsWeb || !Platform.isLinux) {
      _showShortcutStatusDialog(context, false);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        content: const Row(
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(width: 20),
            Text('Registering desktop launcher...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    DesktopEntryService().createDesktopEntry().then((success) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading Dialog
        _showShortcutStatusDialog(context, success);
      }
    });
  }

  static void _showShortcutStatusDialog(BuildContext context, bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        title: Text(
          success ? 'Launcher Registered' : 'Registration Failed',
          style: TextStyle(color: success ? Colors.greenAccent : Colors.redAccent),
        ),
        content: Text(
          success 
              ? 'The launcher was successfully registered to your system app launcher database.' 
              : 'The system failed to register the launcher shortcut. Ensure necessary platform compatibility or write permissions are met.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }

  // Uninstaller Sequence Dialogs
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
          title: const Row(
            children: [
              HeroIcon(HeroIcons.trash, color: Colors.orangeAccent, size: 22),
              SizedBox(width: 10),
              Text('Uninstall Application', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Are you sure you want to uninstall random word generator?\n\n'
            'This will remove desktop launchers, local user data, and system configurations.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () {
                Navigator.pop(dialogCtx);
                _executeUninstallation(context);
              },
              child: const Text('Uninstall', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101016),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        content: const Row(
          children: [
            CircularProgressIndicator(color: Colors.orangeAccent),
            SizedBox(width: 20),
            Text('Removing system components...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    UninstallerService().uninstallApp().then((success) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss progress dialog
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
          side: BorderSide(color: success ? Colors.greenAccent : Colors.redAccent),
        ),
        title: Text(
          success ? 'Uninstall Complete' : 'Uninstall Incomplete',
          style: TextStyle(color: success ? Colors.greenAccent : Colors.redAccent),
        ),
        content: Text(
          success
              ? 'Application shortcuts and local data have been removed. The application will now close.'
              : 'Some components could not be automatically purged. You may need elevated permissions.',
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
            child: const Text('Close App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Exit dialog
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
          title: const Row(
            children: [
              HeroIcon(HeroIcons.exclamationTriangle, color: Colors.redAccent, size: 22),
              SizedBox(width: 10),
              Text('Exit Application', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Are you sure you want to terminate this generation session?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(dialogCtx); // Dismiss confirmation dialog
                _startShutdownCountdown(context);
              },
              child: const Text('Yes, Exit', style: TextStyle(color: Colors.white)),
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            shutdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
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
                  const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent)),
                  const SizedBox(height: 24),
                  Text(
                    'Shutting down app in:\n$countdown seconds',
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
                        child: const Text('Close Now', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () {
                          shutdownTimer?.cancel();
                          Navigator.pop(context); 
                        },
                        child: const Text('Stay in App', style: TextStyle(color: Colors.white54)),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Developer Profile bio scrollable Dialog
  static void showBioDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white10,
                        child: HeroIcon(HeroIcons.user, size: 40, color: Colors.white70),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  const Text(
                    'Name: Kutlwano P. Maruatona',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Alias: Drew',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bio:',
                    style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Systems enthusiast and desktop developer working on building robust UI tools for power-users.\n\n'
                    'Believer in highly modular codebases, keyboard-driven navigation models, and clean visual layouts that don\'t get in the developer\'s way.\n\n'
                    'Passionate about cognitive architectures, evolutionary theories, and building things that last.',
                    style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.white70)),
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