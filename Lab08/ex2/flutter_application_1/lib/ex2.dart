// ignore_for_file: prefer_const_constructors, unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.deepPurple),
    home: FileManagerApp(),
  ));
}

class FileManagerApp extends StatefulWidget {
  const FileManagerApp({super.key});

  @override
  _FileManagerAppState createState() => _FileManagerAppState();
}

class _FileManagerAppState extends State<FileManagerApp> {
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _fileContentController = TextEditingController();
  List<FileSystemEntity> _files = [];
  Directory? _directory;

  @override
  void initState() {
    super.initState();
    _getDirectory();
  }

  // Get the app's document directory
  Future<void> _getDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _directory = directory;
    });
    _listFiles();
  }

  // List files in the directory
  void _listFiles() {
    if (_directory != null) {
      setState(() {
        _files = _directory!.listSync();
      });
    }
  }

  // Save or update file content
  Future<void> _saveFile() async {
    final fileName = _fileNameController.text.trim();
    final fileContent = _fileContentController.text;

    if (fileName.isEmpty) {
      _showSnackBar('Please enter a file name');
      return;
    }

    final file = File('${_directory!.path}/$fileName.txt');
    await file.writeAsString(fileContent);

    _clearFields();
    _listFiles();
    _showSnackBar('File saved successfully!');
  }

  // Read file content
  Future<void> _readFile() async {
    final fileName = _fileNameController.text.trim();
    final filePath = '${_directory!.path}/$fileName.txt';
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _fileContentController.text = content;
      });
    } else {
      _showSnackBar('File does not exist');
    }
  }

  // Delete file
  Future<void> _deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      _listFiles();
      _showSnackBar('File deleted successfully!');
    }
  }

  // View file content
  void _viewFileContent(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _fileNameController.text = file.uri.pathSegments.last.replaceAll('.txt', '');
        _fileContentController.text = content;
      });
    } else {
      _showSnackBar('File does not exist');
    }
  }

  // Clear input fields and refocus
  void _clearFields() {
    _fileNameController.clear();
    _fileContentController.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Show a snack bar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Manager'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 24),
            TextFormField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: 'File Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _fileContentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveFile,
                    style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
                    child: Text('Save or Update'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _readFile,
                    style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
                    child: Text('Read file'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (ctx, idx) {
                  final file = _files[idx];
                  return Column(
                    children: [
                      ListTile(
                        onTap: () => _viewFileContent(file.path),
                        title: Text(file.uri.pathSegments.last),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteFile(file.path),
                        ),
                      ),
                      Divider(height: 1),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
