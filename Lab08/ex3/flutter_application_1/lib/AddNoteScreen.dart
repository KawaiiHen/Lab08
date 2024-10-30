import 'package:flutter/material.dart';

class AddNoteScreen extends StatefulWidget {
  final Map<String, String?>? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'] ?? '';
      _contentController.text = widget.note!['content'] ?? '';
    }

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isEdited = _titleController.text != (widget.note?['title'] ?? '') ||
          _contentController.text != (widget.note?['content'] ?? '');
    });
  }

  Future<bool> _onWillPop() async {
    if (_isEdited) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Save Changes'),
            content: const Text(
                'Note is modified, do you want to continue editing?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Stay on the screen
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Allow exit
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
      return shouldLeave ?? false; // Return false if dialog is dismissed
    }
    return true; // Allow exit if not edited
  }

  // void _saveNote() {
  //   if (_isEdited) {
  //     Navigator.pop(context, {
  //       'title': _titleController.text,
  //       'content': _contentController.text,
  //     });
  //   }
  // }
  void _saveNote() {
    if (_isEdited) {
      Navigator.pop(context, {
        'title': _titleController.text,
        'content': _contentController.text,
        'password': null, // or add logic for password if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop, // Intercepts the back button press
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null ? 'Create New Note' : 'Edit a Note',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.purple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter the title',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                // Make the content text field expand to fill remaining space
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null, // Allows the text field to grow vertically
                  expands: true, // Allows the field to fill the available space
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Enter the content',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  widget.note == null ? 'Save Note' : 'Save all changes',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
