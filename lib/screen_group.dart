import 'package:flutter/material.dart';
import 'data.dart';
import 'screen_group_info.dart';
import 'screen_schedule.dart';
import 'screen_actions.dart';
import 'screen_list_users.dart';

class ScreenGroup extends StatefulWidget {
  final UserGroup userGroup;

  const ScreenGroup({super.key, required this.userGroup});

  @override
  State<ScreenGroup> createState() => _ScreenGroupState();
}

class _ScreenGroupState extends State<ScreenGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group ${widget.userGroup.name}"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(true), // Devuelve true para refrescar
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildMenuButton("Info", Icons.description, Colors.blueGrey, () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ScreenGroupInfo(userGroup: widget.userGroup),
              )).then((_) => setState(() {}));
            }),
            _buildMenuButton("Schedule", Icons.calendar_today, Colors.blueGrey, () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ScreenSchedule(userGroup: widget.userGroup),
              )).then((_) => setState(() {}));
            }),
            _buildMenuButton("Actions", Icons.settings_applications, Colors.blueGrey, () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ScreenActions(userGroup: widget.userGroup),
              )).then((_) => setState(() {}));
            }),
            _buildMenuButton("Places", Icons.place, Colors.blueGrey, () {
              // Placeholder: Slide 3 dice "not for the moment"
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Places editing not implemented yet"))
              );
            }),
            _buildMenuButton("Users", Icons.group, Colors.blueGrey, () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ScreenListUsers(userGroup: widget.userGroup),
              )).then((_) => setState(() {}));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}