import 'dart:io';
import '../constants/app_constants.dart';

class DesktopEntryService {
  /// Entry point to install shortcut launchers natively across platforms
  Future<bool> createDesktopEntry() async {
    try {
      final String executablePath = Platform.resolvedExecutable;

      if (Platform.isLinux) {
        return await _createLinuxDesktopEntry(executablePath);
      } else if (Platform.isWindows) {
        return await _createWindowsShortcut(executablePath);
      } else if (Platform.isMacOS) {
        return await _createMacOSShortcut(executablePath);
      }
      return false;
    } catch (e) {
      stderr.write("Failed to create shortcut: $e\n");
      return false;
    }
  }

  Future<bool> _createLinuxDesktopEntry(String execPath) async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) return false;

    final targetDir = Directory('$homeDir/.local/share/applications');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    const displayName = "random word generator";
    final desktopFile = File('${targetDir.path}/lgui_random_word_generator.desktop');
    
    // Locates logo.png inside Flutter's Linux release asset bundle directory
    final iconPath = _detectLocalIconPath(execPath) ?? "system-run";

    final contents = '''[Desktop Entry]
Type=Application
Version=1.0
Name=$displayName
Comment=A professional, doofenshmirtz-tier random word generator
Exec="$execPath"
Icon=$iconPath
Terminal=false
Categories=Development;Utility;
StartupWMClass=${AppConstants.appName}
''';

    await desktopFile.writeAsString(contents);
    
    // Mark launcher executable
    final result = await Process.run('chmod', ['+x', desktopFile.path]);
    return result.exitCode == 0;
  }

  Future<bool> _createWindowsShortcut(String execPath) async {
    final appData = Platform.environment['APPDATA'];
    if (appData == null) return false;

    const displayName = "random word generator";
    final shortcutPath = "$appData\\Microsoft\\Windows\\Start Menu\\Programs\\$displayName.lnk";
    
    // PowerShell script binds the target executable and pulls icon 0 embedded by flutter_launcher_icons
    final powershellCmd = 
        '\$s=(New-Object -ComObject WScript.Shell).CreateShortcut("$shortcutPath");'
        '\$s.TargetPath="$execPath";'
        '\$s.IconLocation="$execPath,0";'
        '\$s.Save()';

    final result = await Process.run('powershell', ['-Command', powershellCmd]);
    return result.exitCode == 0;
  }

  Future<bool> _createMacOSShortcut(String execPath) async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) return false;

    final applicationsDir = Directory('$homeDir/Applications');
    if (!await applicationsDir.exists()) {
      await applicationsDir.create(recursive: true);
    }

    const displayName = "random word generator";

    // Extract the .app bundle root path (e.g., /Path/To/App.app) from resolvedExecutable
    String appBundlePath = execPath;
    if (execPath.contains('.app/Contents/MacOS')) {
      appBundlePath = execPath.substring(0, execPath.indexOf('.app') + 4);
    }

    final targetPath = "${applicationsDir.path}/$displayName.app";

    // Clean up existing symlink if present to prevent linking conflicts
    final targetLink = Link(targetPath);
    if (await targetLink.exists()) {
      await targetLink.delete();
    }

    final result = await Process.run('ln', ['-s', appBundlePath, targetPath]);
    return result.exitCode == 0;
  }

  String? _detectLocalIconPath(String execPath) {
    final execDir = File(execPath).parent.path;

    // Flutter Linux release bundle path
    final releaseAsset = File('$execDir/data/flutter_assets/assets/images/logo.png');
    if (releaseAsset.existsSync()) {
      return releaseAsset.path;
    }

    // Fallback for local debugging/testing environments
    final devAsset = File('$execDir/assets/images/logo.png');
    if (devAsset.existsSync()) {
      return devAsset.path;
    }

    return null;
  }
}