import 'package:flutter/material.dart';
import 'data.dart';
import 'screen_user.dart';

class ScreenListUsers extends StatefulWidget {
  final UserGroup userGroup;

  const ScreenListUsers({super.key, required this.userGroup});

  @override
  State<ScreenListUsers> createState() => _ScreenListUsersState();
}

class _ScreenListUsersState extends State<ScreenListUsers> {
  late UserGroup userGroup;

  @override
  void initState() {
    super.initState();
    userGroup = widget.userGroup;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute<void>(
              builder: (context) =>
                  ScreenUser(userGroup: userGroup, user: null),
            ),
          )
              .then((_) => setState(() {}));
        },
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Users ${userGroup.name}"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: userGroup.users.length,
        itemBuilder: (BuildContext context, int index) =>
            _buildRow(userGroup.users[index], index),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }

  Widget _buildRow(User user, int index) {
    return ListTile(
      title: Text(user.name),
      trailing: Text(user.credential),
      onTap: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute<void>(
            builder: (context) =>
                ScreenUser(userGroup: userGroup, user: user),
          ),
        )
            .then((_) => setState(() {}));
      },
    );
  }
}
