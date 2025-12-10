import 'dart:io'; // per poder llegir fitxers
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

  // variables x la imatge
  String? _currentImagePath;
  bool _isLocalFile = false; // x saber si es un asset o un fitxer del disc

  bool get isNewUser => widget.user == null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? "");
    _credentialController = TextEditingController(text: widget.user?.credential ?? "");

    String nameKey = isNewUser ? "new user" : widget.user!.name.toLowerCase();
    _currentImagePath = Data.images[nameKey] ?? Data.images['new user'];

    if (_currentImagePath != null && !_currentImagePath!.startsWith('faces/')) {
      _isLocalFile = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  // obra el selector de fitxers
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
        // si es local usem FileImage
        imageProvider = FileImage(File(_currentImagePath!));
      } else {
        // si es un asset (de la carpeta faces/), usem AssetImage
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
              // Embolcallem amb InkWell per fer-ho clicable
              InkWell(
                onTap: _pickImage, // Cridem la funció en fer clic
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
                    // Afegim una icona de càmera petita per indicar que es pot canviar
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

              // Validació Nom
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

              // Validació Credencial
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