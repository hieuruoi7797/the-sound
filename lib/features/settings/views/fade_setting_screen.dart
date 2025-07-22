import 'package:flutter/material.dart';

class FadeSettingScreen extends StatelessWidget {
  final String title;
  final int selectedSeconds;
  final List<int> options;
  final void Function(int) onSelected;

  const FadeSettingScreen({
    super.key,
    required this.title,
    required this.selectedSeconds,
    required this.options,
    required this.onSelected,
  });

  String _formatOption(int seconds) {
    if (seconds == 0) return '0 second';
    if (seconds < 60) return '$seconds second';
    if (seconds % 60 == 0) return '${seconds ~/ 60} minute';
    return '${seconds ~/ 60} minute ${seconds % 60} second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141318),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141318),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: const Color(0xFF232129),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final seconds = options[index];
              return ListTile(
                title: Text(
                  _formatOption(seconds),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: selectedSeconds == seconds
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
                onTap: () {
                  onSelected(seconds);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
} 