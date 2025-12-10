import 'dart:io'; // NECESSARI per poder llegir fitxers del disc dur
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // NECESSARI pel selector
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

  // NOVES VARIABLES D'ESTAT PER A LA IMATGE
  String? _currentImagePath;
  bool _isLocalFile = false; // Per saber si és un asset o un fitxer del PC

  bool get isNewUser => widget.user == null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? "");
    _credentialController = TextEditingController(text: widget.user?.credential ?? "");

    // Inicialitzem la imatge actual
    String nameKey = isNewUser ? "new user" : widget.user!.name.toLowerCase();
    _currentImagePath = Data.images[nameKey] ?? Data.images['new user'];

    // Comprovem si la imatge inicial és local (no comença per 'faces/')
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

  // NOVA FUNCIÓ: Obre el selector de fitxers
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Només permetem imatges
      dialogTitle: 'Select User Avatar',
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        // Guardem la ruta absoluta del fitxer seleccionat al PC
        _currentImagePath = result.files.single.path!;
        _isLocalFile = true; // Ara sabem que és un fitxer local
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final credential = _credentialController.text;

      // GUARDEM LA NOVA IMATGE AL MAPA GLOBAL
      // Utilitzem el nom en minúscules com a clau
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
    // Determinim quin tipus d'imatge mostrar
    ImageProvider? imageProvider;
    if (_currentImagePath != null) {
      if (_isLocalFile) {
        // Si és local (del PC), usem FileImage
        imageProvider = FileImage(File(_currentImagePath!));
      } else {
        // Si és un asset (de la carpeta faces/), usem AssetImage
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