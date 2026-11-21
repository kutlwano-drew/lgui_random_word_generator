import 'package:flutter/material.dart';

class MenuTooltip extends StatefulWidget {
  final Widget child;
  final Widget menuContent;

  const MenuTooltip({
    super.key,
    required this.child,
    required this.menuContent,
  });

  @override
  State<MenuTooltip> createState() => _MenuTooltipState();
}

class _MenuTooltipState extends State<MenuTooltip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 220,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 36),
          child: MouseRegion(
            onEnter: (_) => _setHover(true),
            onExit: (_) => _setHover(false),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: widget.menuContent,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _setHover(bool hovered) {
    setState(() {
      _isHovered = hovered;
    });
    if (_isHovered) {
      _showOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_isHovered) {
          _hideOverlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
        child: widget.child,
      ),
    );
  }
}