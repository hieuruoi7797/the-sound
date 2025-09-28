import 'package:flutter/material.dart';

class ScanNoteCard extends StatelessWidget {
  const ScanNoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: const Color(0xff1f1e2880),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Scan your space to get AI-recommended sounds and feedback.',
                  textAlign:   TextAlign.center,
                  style: TextStyle(
                    color: Color(0xffAAA7BC),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

