import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'AddNoteScreen.dart';
import 'NoteListItemWidget.dart';
import 'NoteGridItemWidget.dart';
import 'NoteDialogs.dart';
import 'database_helper.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Map<String, dynamic>> notes = [];
  bool isListView = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await DatabaseHelper().fetchNotes();
    setState(() {
      notes = data;
    });
  }

  void _toggleView() {
    setState(() {
      isListView = !isListView;
    });
  }

  void _navigateToAddNoteScreen({Map<String, String?>? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(note: note),
      ),
    );

    if (result != null) {
      setState(() {
        if (note != null) {
          // Update existing note
          note['title'] = result['title'];
          note['content'] = result['content'];
        } else {
          // Add new note
          notes.add(result);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                note != null ? 'Note updated' : 'A new note has been created')),
      );
      print('AddNoteScreen returned: $result');
    }
  }

  void _deleteNoteAtIndex(int index) {
    final deletedNote = notes[index];
    setState(() {
      notes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              notes.insert(index, deletedNote);
            });
          },
        ),
      ),
    );
  }

  void _setPassword(int index, String password) {
    setState(() {
      notes[index]['password'] = password;
    });
  }

  void _removePassword(int index) {
    setState(() {
      notes[index]['password'] = null;
    });
  }

  void _changePassword(int index, String oldPassword, String newPassword) {
    if (notes[index]['password'] == oldPassword) {
      setState(() {
        notes[index]['password'] = newPassword;
      });
    } else {
      // Show error message
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Slidable(
              key: ValueKey(index),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      if (notes[index]['password'] != null) {
                        showDeletePasswordDialog(context, (password) {
                          if (notes[index]['password'] == password) {
                            _deleteNoteAtIndex(index);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Incorrect password')),
                            );
                          }
                        });
                      } else {
                        showDeleteConfirmationDialog(
                            context, () => _deleteNoteAtIndex(index));
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  if (notes[index]['password'] == null)
                    SlidableAction(
                      onPressed: (context) {
                        showSetPasswordDialog(context,
                            (password) => _setPassword(index, password));
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.lock,
                      label: 'Set Password',
                    )
                  else ...[
                    SlidableAction(
                      onPressed: (context) {
                        showChangePasswordDialog(context,
                            (oldPassword, newPassword) {
                          if (notes[index]['password'] == oldPassword) {
                            _changePassword(index, oldPassword, newPassword);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Incorrect old password')),
                            );
                          }
                        });
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.lock,
                      label: 'Change Password',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        showEnterPasswordDialog(context, (password) {
                          if (notes[index]['password'] == password) {
                            _removePassword(index);
                          } else {
                            // Show error message
                          }
                        });
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.lock_open,
                      label: 'Remove Password',
                    ),
                  ],
                ],
              ),
              child: NoteListItemWidget(
                note: notes[index]
                    .map((key, value) => MapEntry(key, value?.toString())),
                onTap: (note) {
                  if (note['password'] != null) {
                    showEnterPasswordDialog(context, (password) {
                      if (note['password'] == password) {
                        _navigateToAddNoteScreen(note: note);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incorrect password')),
                        );
                      }
                    });
                  } else {
                    _navigateToAddNoteScreen(note: note);
                  }
                },
              ),
            ),
            const Divider(), // Add divider after each note
          ],
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3 / 4,
      children: notes.map((note) {
        Color noteColor = Color(int.parse(note['color'] ?? '0xFFFFFF00'));
        return GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete'),
                      onTap: () {
                        Navigator.pop(context);
                        showDeleteConfirmationDialog(context,
                            () => _deleteNoteAtIndex(notes.indexOf(note)));
                      },
                    ),
                    if (note['password'] == null)
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Set Password'),
                        onTap: () {
                          Navigator.pop(context);
                          showSetPasswordDialog(
                            context,
                            (password) =>
                                _setPassword(notes.indexOf(note), password),
                          );
                        },
                      ),
                    if (note['password'] != null)
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        onTap: () {
                          Navigator.pop(context);
                          showChangePasswordDialog(context,
                              (oldPassword, newPassword) {
                            if (note['password'] == oldPassword) {
                              _changePassword(notes.indexOf(note), oldPassword,
                                  newPassword);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Incorrect old password')),
                              );
                            }
                          });
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.lock_open),
                      title: const Text('Remove Password'),
                      onTap: () {
                        Navigator.pop(context);
                        showEnterPasswordDialog(context, (password) {
                          if (note['password'] == password) {
                            _removePassword(notes.indexOf(note));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Incorrect password')),
                            );
                          }
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: NoteGridItemWidget(
            note: note.map((key, value) => MapEntry(key, value?.toString())),
            color: noteColor,
            onTap: (note) {
              print('Note tapped: $note');
              if (note['password'] != null) {
                showEnterPasswordDialog(context, (password) {
                  print('Password entered: $password');
                  if (note['password'] == password) {
                    print('Correct password entered!');
                    _navigateToAddNoteScreen(note: note);
                  } else {
                    // Handle incorrect password scenario
                  }
                });
              } else {
                _navigateToAddNoteScreen(note: note);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(isListView ? Icons.grid_view : Icons.list,
                color: Colors.white),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isListView ? _buildListView() : _buildGridView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddNoteScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
