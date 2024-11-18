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
    _initializeNotes();
  }

  Future<void> _initializeNotes() async {
    // Check if the database is empty
    final data = await DatabaseHelper().fetchNotes();
    if (data.isEmpty) {
      // Insert initial notes
      await _insertInitialNotes();
    }
    _loadNotes();
  }

  Future<void> _insertInitialNotes() async {
    var initialNotes = [
      {
        'title': 'Việt Nam khởi đầu tốt nhất lịch sử dự U20 châu Á',
        'content':
            'Lần đầu trong lịch sử 64 năm của giải U20 châu Á, Việt Nam thắng cả hai trận đầu tiên, trước Australia và Qatar.'
      },
      {
        'title': 'Truyền thông Indonesia khen U20 Việt Nam phi thường',
        'content':
            'Nhiều báo, đài Indonesia ngạc nhiên khi Việt Nam toàn thắng hai trận đầu ở bảng đấu khó tại vòng chung kết U20 châu Á 2023'
      },
      {
        'title':
            'Nguyễn Thanh Nhàn tỏa sáng, dẫn dắt U20 Việt Nam đến chiến thắng',
        'content':
            'Tiền đạo Nguyễn Thanh Nhàn đang là cái tên nổi bật nhất trong đội hình U20 Việt Nam. Với khả năng ghi bàn ấn tượng và lối chơi thông minh, Thanh Nhàn đã đóng góp rất lớn vào thành công của đội nhà. Cú đúp vào lưới U20 Australia đã khẳng định tài năng của cầu thủ trẻ này.'
      },
      {
        'title':
            'Tinh thần đồng đội tuyệt vời giúp U20 Việt Nam vượt qua mọi thử thách',
        'content':
            'Một trong những yếu tố quan trọng giúp U20 Việt Nam đạt được thành công là tinh thần đồng đội cao. Các cầu thủ luôn sát cánh bên nhau, hỗ trợ lẫn nhau trong mọi tình huống. Điều này đã tạo nên một tập thể đoàn kết, vững mạnh và khó bị đánh bại.'
      },
      {
        'title': 'U20 Việt Nam tạo nên lịch sử mới tại U20 châu Á',
        'content':
            'Thành tích của U20 Việt Nam tại giải đấu năm nay là một cột mốc quan trọng trong lịch sử bóng đá trẻ Việt Nam. So với các kỳ U20 châu Á trước, U20 Việt Nam đã có sự tiến bộ vượt bậc về cả chuyên môn và tinh thần. Đây là một tín hiệu rất đáng mừng cho bóng đá nước nhà.'
      },
      {
        'title':
            'U20 Việt Nam: Hứa hẹn một tương lai tươi sáng cho bóng đá Việt Nam',
        'content':
            'Với những gì đã thể hiện, U20 Việt Nam đã chứng minh rằng bóng đá Việt Nam đang sở hữu một lứa cầu thủ tài năng. Thành công của U20 Việt Nam sẽ là động lực lớn để các cầu thủ trẻ khác cố gắng hơn nữa, hướng tới mục tiêu chinh phục những đỉnh cao mới.'
      },
    ];

    for (var note in initialNotes) {
      await DatabaseHelper().insertNote(note);
    }
  }

  Future<void> _loadNotes() async {
    final data = await DatabaseHelper().fetchNotes();
    setState(() {
      notes = List.from(
          data); // Create a new list to avoid modifying the original data
    });
  }

  void _toggleView() {
    setState(() {
      isListView = !isListView;
    });
  }

  Future<void> _navigateToAddNoteScreen({Map<String, dynamic>? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(note: note),
      ),
    );

    if (result != null) {
      if (note != null) {
        // Update existing note
        await DatabaseHelper().updateNote(note['id'], result);
        setState(() {
          notes[notes.indexWhere((element) => element['id'] == note['id'])] =
              result;
        });
      } else {
        // Add new note
        final id = await DatabaseHelper().insertNote(result);
        setState(() {
          notes.add({'id': id, ...result});
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                note != null ? 'Note updated' : 'A new note has been created')),
      );
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
