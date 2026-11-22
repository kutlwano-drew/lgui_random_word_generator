// lib/presentation/widgets/app_bar/menu_items.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:heroicons/heroicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuActionItem extends StatefulWidget {
  final String text;
  final HeroIcons icon;
  final VoidCallback onTap;
  final Color textColor;

  const MenuActionItem({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  State<MenuActionItem> createState() => _MenuActionItemState();
}

class _MenuActionItemState extends State<MenuActionItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovering ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            children: [
              HeroIcon(
                widget.icon, 
                size: 16, 
                color: widget.textColor.withOpacity(0.7),
              ),
              const SizedBox(width: 10),
              Text(
                widget.text.tr(), 
                style: TextStyle(
                  color: widget.textColor, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuSocialItem extends StatefulWidget {
  final String text;
  final FaIconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const MenuSocialItem({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<MenuSocialItem> createState() => _MenuSocialItemState();
}

class _MenuSocialItemState extends State<MenuSocialItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovering ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            children: [
              FaIcon(
                widget.icon, 
                size: 15, 
                color: widget.iconColor,
              ),
              const SizedBox(width: 10),
              Text(
                widget.text.tr(), 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}