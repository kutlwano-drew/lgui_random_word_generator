import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';

class CountdownOverlay extends StatefulWidget {
  final int count;
  final VoidCallback onFinished;

  const CountdownOverlay({
    super.key,
    required this.count,
    required this.onFinished,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late int _currentCount;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.count;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _scaleAnimation = Tween<double>(begin: 3.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _tickCountdown();
  }

  void _tickCountdown() {
    if (_currentCount > 0) {
      _controller.forward(from: 0.0).then((_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _currentCount--;
            });
            _tickCountdown();
          }
        });
      });
    } else {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentCount <= 0) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_currentCount',
                      style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 130,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.deepPurple,
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'STARTING AUTOMATIC CYCLE...'.tr(),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}