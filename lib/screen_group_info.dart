import 'package:flutter/material.dart';
import 'data.dart';

class ScreenGroupInfo extends StatefulWidget {
  final UserGroup userGroup;

  const ScreenGroupInfo({super.key, required this.userGroup});

  @override
  State<ScreenGroupInfo> createState() => _ScreenGroupInfoState();
}

class _ScreenGroupInfoState extends State<ScreenGroupInfo> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userGroup.name);
    _descController = TextEditingController(text: widget.userGroup.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Info"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Group name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.userGroup.name = _nameController.text;
                widget.userGroup.description = _descController.text;

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved'))
                );
                Navigator.pop(context); // Volver
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}