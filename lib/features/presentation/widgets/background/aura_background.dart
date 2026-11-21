import 'package:flutter/material.dart';
import 'package:aura_icon/aura_icon.dart'; 
// Import the flutter_glow package
import 'package:flutter_glow/flutter_glow.dart'; 

class AuraBackground extends StatelessWidget {
  final Widget child;

  const AuraBackground({
    super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Explicit width and height controls using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final auraWidth = screenSize.width * 0.8;
    final auraHeight = screenSize.height * 0.8;

    return Stack(
      children: [
        // Base dark theme background canvas
        Container(
          color: const Color(0xFF0D0D12),
        ),

        // Center-positioned AuraIcon wrapped in a GlowContainer for the specific neon glow
        Positioned.fill(
          child: Center(
            child: SizedBox(
              width: auraWidth,
              height: auraHeight,
              child: GlowContainer(
                color: Colors.black.withOpacity(0.1), // Keeps the container body transparent
                //glowColor: const Color(0xFFEC4899), // Casts the pink neon glow outwards
                blurRadius: 40, // Adjusts how far the glow spreads
                spreadRadius: 4,
                borderRadius: BorderRadius.circular(120), // Blends the glow shape
                child: AuraIcon(
                  size: auraWidth, 
                  radius: 120, 
                  shape: AuraShape.square,
                  colors: const [
                    Color(0xFF6366F1), // Indigo aura

Color(0xFFA855F7), // Purple aura

Color(0xFF2563EB), // Deep blue base 
                  ],
                ),
              ),
            ),
          ),
        ),

        // Main layout content on top of the aura glow
        SafeArea(
          child: child,
        ),
      ],
    );
  }
}