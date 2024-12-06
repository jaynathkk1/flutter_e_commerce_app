import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class FolderExplorer extends StatefulWidget {
  @override
  _FolderExplorerState createState() => _FolderExplorerState();
}

class _FolderExplorerState extends State<FolderExplorer> {
  Directory? _currentDirectory;
  List<Directory> _folders = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  // Request storage permissions
  Future<void> _requestPermission() async {
    // Request storage permissions
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      _loadDirectory();
    } else if (status.isDenied) {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Permission to access storage denied"),
      ));
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied (e.g. user checked "Don't ask again")
      openAppSettings();  // Open the app settings to enable permission manually
    }
  }

  // Load the initial directory (app's document directory)
  Future<void> _loadDirectory() async {
    setState(() {
      _loading = true;
    });

    // Get the app's document directory
    Directory directory = await getApplicationDocumentsDirectory();
    _loadFolders(directory);

    setState(() {
      _loading = false;
    });
  }

  // Load all folders within a directory
  Future<void> _loadFolders(Directory directory) async {
    List<FileSystemEntity> files = directory.listSync();

    setState(() {
      _currentDirectory = directory;
      _folders = files
          .where((entity) => entity is Directory)
          .map((entity) => entity as Directory)
          .toList();
    });
  }

  // Open a folder to show its contents
  void _openFolder(Directory folder) {
    _loadFolders(folder);
  }

  // Build a list item for each folder
  Widget _buildFolderItem(Directory folder) {
    return ListTile(
      title: Text(folder.uri.pathSegments.last),
      subtitle: Text("Folder"),
      onTap: () {
        _openFolder(folder);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folder Explorer'),
        leading: _currentDirectory != null
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to the parent folder
            Directory? parent = _currentDirectory?.parent;
            if (parent != null) {
              _openFolder(parent);
            }
          },
        )
            : null,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          return _buildFolderItem(_folders[index]);
        },
      ),
    );
  }
}
