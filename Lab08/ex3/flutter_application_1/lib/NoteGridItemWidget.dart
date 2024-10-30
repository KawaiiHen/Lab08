import 'package:flutter/material.dart';

class NoteGridItemWidget extends StatelessWidget {
  final Map<String, String?> note;
  final Function(Map<String, String?>) onTap;
  final Color color;

  const NoteGridItemWidget({
    required this.note,
    required this.onTap,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(note),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        color: color, // Use the color parameter
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note['title'] ?? '',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(note['content'] ?? ''),
              if (note['password'] != null)
                const Icon(Icons.lock, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
