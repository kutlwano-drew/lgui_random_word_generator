import 'dart:io';

class UninstallerService {
  /// Entry point to execute uninstallation across desktop platforms
  Future<bool> uninstallApp() async {
    try {
      if (Platform.isLinux) {
        return await _uninstallLinux();
      } else if (Platform.isWindows) {
        return await _uninstallWindows();
      } else if (Platform.isMacOS) {
        return await _uninstallMacOS();
      }
      return false;
    } catch (e) {
      stderr.write("Failed to perform uninstallation: $e\n");
      return false;
    }
  }

Future<bool> _uninstallLinux() async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) return false;

    // Detect if running as installed DEB package or local desktop entry
    final possiblePkgs = ['lgui-random-word-generator', 'lgui_random_word_generator'];
    String? installedPkg;

    for (final pkg in possiblePkgs) {
      final check = await Process.run('dpkg', ['-s', pkg]);
      if (check.exitCode == 0) {
        installedPkg = pkg;
        break;
      }
    }

    // Script to clean local files and run system purge after the process exits
    final scriptContent = '''#!/bin/bash
sleep 1
# Remove local user desktop entries and config
rm -f "$homeDir/.local/share/applications/lgui_random_word_generator.desktop"
rm -f "$homeDir/.local/share/applications/lgui-random-word-generator.desktop"
rm -rf "$homeDir/.config/lgui_random_word_generator"
rm -rf "$homeDir/.local/share/lgui_random_word_generator"

# System package purge if installed via DEB
if [ -n "$installedPkg" ]; then
  pkexec apt-get purge -y $installedPkg
fi

# Refresh desktop database
update-desktop-database "$homeDir/.local/share/applications" 2>/dev/null || true
''';

    try {
      final scriptFile = File('/tmp/lgui_uninstall.sh');
      await scriptFile.writeAsString(scriptContent);
      await Process.run('chmod', ['+x', scriptFile.path]);

      // Launch the script as a detached background process
      await Process.start('/bin/bash', [scriptFile.path], mode: ProcessStartMode.detached);
      return true;
    } catch (e) {
      stderr.write("Uninstall script launch failed: $e\n");
      return false;
    }
  }

  
  Future<bool> _uninstallWindows() async {
    final appData = Platform.environment['APPDATA'];
    final localAppData = Platform.environment['LOCALAPPDATA'];
    const displayName = "random word generator";

    // 1. Remove Start Menu Shortcut
    if (appData != null) {
      final shortcut = File("$appData\\Microsoft\\Windows\\Start Menu\\Programs\\$displayName.lnk");
      if (await shortcut.exists()) {
        await shortcut.delete();
      }
    }

    // 2. Remove Windows Local AppData
    if (localAppData != null) {
      final appDataDir = Directory("$localAppData\\lgui_random_word_generator");
      if (await appDataDir.exists()) {
        await appDataDir.delete(recursive: true);
      }
    }

    return true;
  }

  Future<bool> _uninstallMacOS() async {
    final homeDir = Platform.environment['HOME'];
    const displayName = "random word generator";

    if (homeDir != null) {
      // 1. Remove ~/Applications shortcut / app bundle
      final targetApp = File('$homeDir/Applications/$displayName.app');
      if (await targetApp.exists()) {
        await targetApp.delete(recursive: true);
      }

      // 2. Remove Application Support cached data
      final appSupport = Directory('$homeDir/Library/Application Support/lgui_random_word_generator');
      if (await appSupport.exists()) {
        await appSupport.delete(recursive: true);
      }
    }

    return true;
  }
}