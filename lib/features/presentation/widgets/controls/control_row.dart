import 'package:flutter/material.dart';
import '../../../../core/services/sound_service.dart';
import '../dialogs/sound_settings_dialog.dart';
import 'timer_input.dart';

class ControlRow extends StatelessWidget {
  final VoidCallback onGenerate;
  final bool isAutoGenerating;
  final VoidCallback onToggleAutoGenerate;
  final int timerDuration;
  final ValueChanged<int> onTimerChanged;

  const ControlRow({
    super.key,
    required this.onGenerate,
    required this.isAutoGenerating,
    required this.onToggleAutoGenerate,
    required this.timerDuration,
    required this.onTimerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Manual Generator Button
        ElevatedButton.icon(
          onPressed: isAutoGenerating ? null : onGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            disabledBackgroundColor: Colors.deepPurpleAccent.withOpacity(0.3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.flash_on, size: 16),
          label: const Text('Generate', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),

        // 2. Timer Loop Controls
        TimerInput(
          initialValue: timerDuration,
          onChanged: onTimerChanged,
        ),
        const SizedBox(width: 8),

        IconButton.filled(
          onPressed: onToggleAutoGenerate,
          style: IconButton.styleFrom(
            backgroundColor: isAutoGenerating ? Colors.green : Colors.white12,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: Icon(isAutoGenerating ? Icons.pause_rounded : Icons.play_arrow_rounded),
        ),
        const SizedBox(width: 12),

  //       // 3. Custom Action Slot Placeholder
  //       GestureDetector(
  // onTap: () {
  //   SoundService.instance.playButtonClick();
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.black.withOpacity(0.4), // Subtle dimming under the blur layer
  //     builder: (context) => const SoundSettingsDialog(),
  //   );
  // },
  //         child: Container(
  //           height: 44,
  //           padding: const EdgeInsets.symmetric(horizontal: 14),
  //           decoration: BoxDecoration(
  //             color: Colors.white.withOpacity(0.04),
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: Colors.white10),
  //           ),
  //           alignment: Alignment.center,
  //           child: const Row(
  //             children: [
  //               Icon(Icons.tune_rounded, size: 16, color: Colors.white),
  //               SizedBox(width: 6),
  //               Text('Modifier', style: TextStyle(color: Colors.white, fontSize: 13)),
  //             ],
  //           ),
  //         ),
  //       ),
      ],
    );
  }
}