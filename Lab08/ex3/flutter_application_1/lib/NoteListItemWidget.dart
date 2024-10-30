import 'package:flutter/material.dart';

class NoteListItemWidget extends StatelessWidget {
  final Map<String, String?> note;
  final Function(Map<String, String?>) onTap;

  const NoteListItemWidget({required this.note, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //      onTap: () => _navigateToAddNoteScreen(note: note),
      onTap: () => onTap(note),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Row(
            children: [
              const Icon(Icons.note, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'] ?? '',
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note['content'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (note['password'] != null)
                const Icon(Icons.lock, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
