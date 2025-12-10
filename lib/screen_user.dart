import 'package:flutter/material.dart';
import 'data.dart';

class ScreenUser extends StatefulWidget {
  final UserGroup userGroup;
  final User? user;

  const ScreenUser({super.key, required this.userGroup, this.user});

  @override
  State<ScreenUser> createState() => _ScreenUserState();
}

class _ScreenUserState extends State<ScreenUser> {
  late TextEditingController _nameController;
  late TextEditingController _credentialController;

  bool get isNewUser => widget.user == null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user?.name ?? "new user");
    _credentialController =
        TextEditingController(text: widget.user?.credential ?? "00000");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text;
    final credential = _credentialController.text;

    if (isNewUser) {
      widget.userGroup.users.add(User(name, credential));
    } else {
      widget.user!.name = name;
      widget.user!.credential = credential;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _credentialController,
              decoration: const InputDecoration(
                labelText: "Credential",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}