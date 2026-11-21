import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerInput extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const TimerInput({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<TimerInput> createState() => _TimerInputState();
}

class _TimerInputState extends State<TimerInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange(String text) {
    if (text.isEmpty) return;
    int parsed = int.tryParse(text) ?? widget.initialValue;
    
    // Clamp to reasonable generation boundaries (1s to 60s)
    int clamped = parsed.clamp(1, 60);

    if (clamped != parsed) {
      _controller.text = clamped.toString();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: Colors.white30),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: _handleTextChange,
            ),
          ),
          const Text('s', style: TextStyle(color: Colors.white30, fontSize: 13)),
        ],
      ),
    );
  }
}