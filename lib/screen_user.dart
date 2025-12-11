import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'data.dart';

class ScreenUser extends StatefulWidget {
  final UserGroup userGroup;
  final User? user;

  const ScreenUser({super.key, required this.userGroup, this.user});

  @override
  State<ScreenUser> createState() => _ScreenUserState();
}

class _ScreenUserState extends State<ScreenUser> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _credentialController;

  String? _currentImagePath;
  bool _isLocalFile = false;

  bool get isNewUser => widget.user == null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? "");
    _credentialController = TextEditingController(text: widget.user?.credential ?? "");

    // Inicializar imagen al arrancar
    _updateImageFromData(_nameController.text);

    // Escoltar canvis en el nom per canviar la foto en temps real
    _nameController.addListener(() {
      _updateImageFromData(_nameController.text);
    });
  }

  // Funcio per buscar la imatge segons el nom
  void _updateImageFromData(String name) {
    String nameKey = name.toLowerCase();

    // Si el nom existeix al mapa, agafem la seva foto. Si no, mantenim la que hi hagi o posem la de 'new user'
    if (Data.images.containsKey(nameKey)) {
      String path = Data.images[nameKey]!;
      setState(() {
        _currentImagePath = path;
        // Si comença per faces/, és un asset. Si no, és un fitxer local (guardat abans)
        _isLocalFile = !path.startsWith('faces/');
      });
    } else if (isNewUser && _currentImagePath == null) {
      // Només si és nou i encara no tenim imatge, posem la per defecte
      setState(() {
        _currentImagePath = Data.images['new user'];
        _isLocalFile = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: 'Select User Avatar',
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _currentImagePath = result.files.single.path!;
        _isLocalFile = true;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final credential = _credentialController.text;

      // guardem la imatge associada al nom (per si es torna a obrir)
      if (_currentImagePath != null) {
        Data.images[name.toLowerCase()] = _currentImagePath!;
      }

      if (isNewUser) {
        widget.userGroup.users.add(User(name, credential));
      } else {
        widget.user!.name = name;
        widget.user!.credential = credential;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_currentImagePath != null) {
      if (_isLocalFile) {
        imageProvider = FileImage(File(_currentImagePath!));
      } else {
        imageProvider = AssetImage(_currentImagePath!);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(50),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Name required';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _credentialController,
                decoration: const InputDecoration(
                  labelText: "Credential",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Credential required';
                  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                    return 'Credential must be exactly 5 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}