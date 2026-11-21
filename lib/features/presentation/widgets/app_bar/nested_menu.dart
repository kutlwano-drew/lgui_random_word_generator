// lib/presentation/widgets/app_bar/nested_menu.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class NestedMenuHeader extends StatefulWidget {
  final String text;
  final HeroIcons icon;
  final List<Widget> nestChildren;

  const NestedMenuHeader({
    super.key,
    required this.text,
    required this.icon,
    required this.nestChildren,
  });

  @override
  State<NestedMenuHeader> createState() => _NestedMenuHeaderState();
}

class _NestedMenuHeaderState extends State<NestedMenuHeader> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  Timer? _debounceTimer; // Keeps track of hover timeouts to prevent async layout crashes

  void _showSubmenu() {
    if (!mounted || _overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 220, 
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(4, -6),
            child: MouseRegion(
              onEnter: (_) => _setHover(true),
              onExit: (_) => _setHover(false),
              child: Material(
                elevation: 8,
                color: const Color(0xFF101016),
                borderRadius: BorderRadius.circular(8),
                shadowColor: Colors.white10, // Safe: Shadow color only
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.nestChildren,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSubmenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _setHover(bool value) {
    _debounceTimer?.cancel(); // Instantly kill pending state changes
    
    if (!mounted) return;
    setState(() {
      _isHovering = value;
    });

    if (_isHovering) {
      _showSubmenu();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        if (!_isHovering) {
          _hideSubmenu();
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Kill active timers before context drops
    _hideSubmenu(); // Remove child overlay safely
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
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
                color: Colors.white70,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const HeroIcon(HeroIcons.chevronRight, size: 12, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

class NestedMenuOption extends StatefulWidget {
  final String text;
  final HeroIcons icon;
  final VoidCallback onTap;

  const NestedMenuOption({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  State<NestedMenuOption> createState() => _NestedMenuOptionState();
}

class _NestedMenuOptionState extends State<NestedMenuOption> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
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
                color: Colors.white60,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}