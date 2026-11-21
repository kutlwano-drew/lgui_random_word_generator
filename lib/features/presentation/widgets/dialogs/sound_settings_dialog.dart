// lib/presentation/widgets/dialogs/sound_settings_dialog.dart

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/services/sound_service.dart'; // Adjust path based on your project structure

class SoundSettingsDialog extends StatefulWidget {
  const SoundSettingsDialog({super.key});

  @override
  State<SoundSettingsDialog> createState() => _SoundSettingsDialogState();
}

class _SoundSettingsDialogState extends State<SoundSettingsDialog> {
  final SoundService _sound = SoundService.instance;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), // Glass baseline
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and top-right close circle button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sounds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Sounds On / Off custom toggle configuration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _sound.soundsOn ? 'Sounds on' : 'Sounds off',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _sound.soundsOn = !_sound.soundsOn;
                      });
                      _sound.playButtonClick();
                    },
                    child: Container(
                      width: 46,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white, // Explicit white track
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 120),
                        alignment: _sound.soundsOn ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _sound.soundsOn ? Colors.greenAccent : Colors.red, // Target indicator colors
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Volume Level Controller Layout
              const Text(
                'Volume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white12,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: _sound.volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _sound.setVolume(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}