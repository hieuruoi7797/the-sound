import 'package:flutter/material.dart';
import 'recording_view.dart';

class RecordingWrapper extends StatelessWidget {
  const RecordingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const ColoredBox(
                color: Color(0xFF1A1A1A),
                child: RecordingView(),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 