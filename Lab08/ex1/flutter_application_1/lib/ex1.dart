// ignore_for_file: prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.deepPurple),
    home: UserPreferencesScreen(),
  ));
}

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  _UserPreferencesScreenState createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  String _language = 'English';
  String _colorTheme = 'Light';
  bool _notification = false;
  String _displayName = 'User';
  String _selectedVideoQuality = '720p HD at 30 fps'; // Default video quality
  var videoQualities = [
    '720p HD at 30 fps',
    '1080p HD at 30 fps',
    '1080p HD at 60 fps',
    '4K at 30 fps',
    '4K at 60 fps'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load saved preferences
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
      _colorTheme = prefs.getString('colorTheme') ?? 'Light';
      _notification = prefs.getBool('notification') ?? false;
      _displayName = prefs.getString('displayName') ?? 'User';
      _selectedVideoQuality = prefs.getString('videoQuality') ??
          '720p HD at 30 fps'; // Load video quality
    });
  }

  // Save data whenever a setting is changed
  Future<void> _savePreference(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  void _onLanguageChanged(String? value) {
    setState(() {
      _language = value ?? '';
      _savePreference('language', _language);
    });
  }

  void _onColorThemeChanged(String? value) {
    setState(() {
      _colorTheme = value ?? '';
      _savePreference('colorTheme', _colorTheme);
    });
  }

  void _onNotificationChanged(bool value) {
    setState(() {
      _notification = value;
      _savePreference('notification', _notification);
    });
  }

  void _changeDisplayName() {
    TextEditingController nameController =
        TextEditingController(text: _displayName);

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Change Display Name'),
              content: TextFormField(
                controller: nameController,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _displayName = nameController.text;
                      _savePreference('displayName', _displayName);
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                )
              ],
            ));
  }

  void _videoRecodingbottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => ListView.separated(
              padding: EdgeInsets.all(10),
              itemCount: videoQualities.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(videoQualities[index]),
                  onTap: () {
                    setState(() {
                      _selectedVideoQuality = videoQualities[index];
                      _savePreference('videoQuality', _selectedVideoQuality);
                    });
                    Navigator.pop(
                        context); // Close the bottom sheet after selection
                  },
                );
              },
              separatorBuilder: (ctx, index) => Divider(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple, // Set background color to purple
        title: Text(
          'User Preferences',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // Make title bold
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Name',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextFormField(
                onTap: _changeDisplayName,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: _displayName, // Show current display name
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Language',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              DropdownButtonFormField<String>(
                value: _language,
                onChanged: _onLanguageChanged,
                items: <String>['English', 'Spanish', 'French', 'German']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Color Theme',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              DropdownButtonFormField<String>(
                value: _colorTheme,
                onChanged: _onColorThemeChanged,
                items: <String>['Light', 'Dark']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Notification',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _notification,
                onChanged: _onNotificationChanged,
                title: Text('Banners, Sounds, Badges'),
              ),
              SizedBox(height: 20),
              Text(
                'Record Video',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextFormField(
                onTap: _videoRecodingbottomSheet,
                readOnly: true,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  hintText:
                      _selectedVideoQuality, // Show current selected video quality
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
