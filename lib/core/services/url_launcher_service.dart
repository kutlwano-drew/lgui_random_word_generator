// lib/core/services/url_launcher_service.dart

import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';

class UrlLauncherService {
  static const String kofiUrl = 'https://ko-fi.com';

  /// Launches the default Ko-fi support page.
  Future<void> launchKofi() async {
    await launchCustomUrl(kofiUrl);
  }

  /// Safely opens any target URL in an external browser system.
  Future<void> launchCustomUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        final success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!success) {
          throw UrlLauncherException(
            message: 'Unable to start external web viewer. Please copy the URL and visit your browser.'.tr(),
            originalError: 'launchUrl returned false',
          );
        }
      } else {
        throw UrlLauncherException(
          message: 'Your system does not support opening external web addresses.'.tr(),
          originalError: 'canLaunchUrl returned false',
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.log(e, stackTrace);
      if (e is UrlLauncherException) {
        rethrow;
      }
      throw UrlLauncherException(
        message: 'Could not open link. Please verify your device defaults.'.tr(),
        originalError: e,
      );
    }
  }
}