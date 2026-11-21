import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:heroicons/heroicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/url_launcher_service.dart';
import 'menu_tooltip.dart';
import 'nested_menu.dart';
import 'menu_items.dart';
import 'app_bar_dialogs.dart';

class DesktopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAutoGenerating;
  final int countdownSeconds;

  const DesktopAppBar({
    super.key,
    this.isAutoGenerating = false,
    this.countdownSeconds = 3,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40);

  void _launchUrl(BuildContext context, String url) async {
    final service = UrlLauncherService();
    try {
      await service.launchCustomUrl(url);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF101016),
        border: Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 1. File Dropdown (Hidden entirely when running on Web platforms)
          if (AppBarDialogs.showFileOption) ...[
            MenuTooltip(
              menuContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  NestedMenuHeader(
                    text: 'App',
                    icon: HeroIcons.squares2x2,
                    nestChildren: [
                      NestedMenuOption(
                        text: 'Check for Updates',
                        icon: HeroIcons.arrowPath,
                        onTap: () => AppBarDialogs.showUpdateDialog(context),
                      ),
                      NestedMenuOption(
                        text: 'Create GitHub Issue',
                        icon: HeroIcons.bugAnt,
                        onTap: () => _launchUrl(context, 'https://github.com/kutlwano-drew/linux_gui_project/issues/new'),
                      ),
                      NestedMenuOption(
                        text: AppConstants.versionNumber,
                        icon: HeroIcons.tag,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 8),
                  MenuActionItem(
                    text: 'Create Desktop Entry',
                    icon: HeroIcons.computerDesktop,
                    onTap: () => AppBarDialogs.showDesktopEntryDialog(context),
                  ),
                  const Divider(color: Colors.white10, height: 8),
                  MenuActionItem(
                    text: 'Uninstall',
                    icon: HeroIcons.trash,
                    onTap: () => AppBarDialogs.showUninstallSequence(context),
                    textColor: Colors.orangeAccent,
                  ),
                  const Divider(color: Colors.white10, height: 8),
                  MenuActionItem(
                    text: 'Exit',
                    icon: HeroIcons.power,
                    onTap: () => AppBarDialogs.showExitSequence(context),
                    textColor: Colors.redAccent,
                  ),
                ],
              ),
              child: _buildBarButton('File'),
            ),
            const SizedBox(width: 4),
          ],

          // 2. The Linux GUI Project Dropdown
          MenuTooltip(
            menuContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuSocialItem(
                  text: 'View Website',
                  icon: FontAwesomeIcons.globe,
                  iconColor: Colors.blueAccent,
                  onTap: () => _launchUrl(context, 'https://lgui.dark-essence.com/'),
                ),
                MenuSocialItem(
                  text: 'View on YouTube',
                  icon: FontAwesomeIcons.youtube,
                  iconColor: const Color(0xFFFF0000),
                  onTap: () => _launchUrl(context, 'https://www.youtube.com/@linuxguiproject'),
                ),
                MenuSocialItem(
                  text: 'View on GitHub',
                  icon: FontAwesomeIcons.github,
                  iconColor: Colors.white,
                  onTap: () => _launchUrl(context, 'https://github.com/kutlwano-drew/linux_gui_project'),
                ),
              ],
            ),
            child: _buildBarButton('The Linux GUI Project'),
          ),
          const SizedBox(width: 4),

          // 3. Developer Dropdown
          MenuTooltip(
            menuContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuActionItem(
                  text: 'View Bio',
                  icon: HeroIcons.identification,
                  onTap: () => AppBarDialogs.showBioDialog(context),
                ),
                MenuSocialItem(
                  text: 'Support',
                  icon: FontAwesomeIcons.mugHot,
                  iconColor: const Color(0xFFFF5E5B),
                  onTap: () => _launchUrl(context, 'https://ko-fi.com/kutlwanodrew'),
                ),
              ],
            ),
            child: _buildBarButton('Developer'),
          ),

          const Spacer(),

          // 4. Center State Text / Ticking Countdown Window
          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 200),
          //   child: isAutoGenerating
          //       ? Row(
          //           key: const ValueKey('countdown'),
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             GlowText(
          //               'next word in : ',
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 12,
          //                 fontFamily: 'monospace',
          //               ),
          //               glowColor: Colors.white24,
          //               blurRadius: 6,
          //             ),
          //             GlowText(
          //               '$countdownSeconds',
          //               style: const TextStyle(
          //                 color: Colors.redAccent,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.bold,
          //                 fontFamily: 'monospace',
          //               ),
          //               glowColor: Colors.redAccent,
          //               blurRadius: 8,
          //             ),
          //             const GlowText(
          //               ' seconds',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 12,
          //                 fontFamily: 'monospace',
          //               ),
          //               glowColor: Colors.white24,
          //               blurRadius: 6,
          //             ),
          //           ],
          //         )
          //       : const Text(
          //           AppConstants.appDisplayName,
          //           key: ValueKey('branding'),
          //           style: TextStyle(
          //             color: Colors.white24,
          //             fontSize: 11,
          //             fontFamily: 'monospace',
          //             letterSpacing: 1.2,
          //           ),
          //         ),
          // ),

          // const Spacer(),

          // // 5. User Avatar/Indicator
          // const CircleAvatar(
          //   radius: 11,
          //   backgroundColor: Colors.white12,
          //   child: HeroIcon(HeroIcons.user, size: 12, color: Colors.white70),
          // ),
        ],
      ),
    );
  }

  Widget _buildBarButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}