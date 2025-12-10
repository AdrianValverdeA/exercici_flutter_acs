import 'package:flutter/material.dart';
import 'data.dart' as app_data;

class ScreenActions extends StatefulWidget {
  final app_data.UserGroup userGroup;

  const ScreenActions({super.key, required this.userGroup});

  @override
  State<ScreenActions> createState() => _ScreenActionsState();
}

class _ScreenActionsState extends State<ScreenActions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actions"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          // CORRECTE: Iterem sobre 'AppActions.all' (totes les opcions possibles)
          // NO iteris sobre 'widget.userGroup.actions'
          ...app_data.ActionsApp.all.map((actionName) {
            // Comprovem si el grup té aquesta acció per marcar el checkbox
            final isEnabled = widget.userGroup.actions.contains(actionName);

            return CheckboxListTile(
              title: Text(actionName),
              subtitle: _getActionDescription(actionName),
              value: isEnabled, // True si està a la llista, False si no
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    // Si marquem, afegim a la llista del grup
                    widget.userGroup.actions.add(actionName);
                  } else {
                    // Si desmarquem, traiem de la llista del grup
                    widget.userGroup.actions.remove(actionName);
                  }
                });
              },
            );
          }).toList(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          )
        ],
      ),
    );
  }

  // (Mètode _getActionDescription igual que abans...)
  Widget? _getActionDescription(String action) {
    switch (action) {
      case "open": return const Text("Opens an unlocked door");
      case "close": return const Text("Closes an open door");
      case "lock": return const Text("Locks a door");
      case "unlock": return const Text("Unlocks a locked door");
      case "unlock_shortly": return const Text("Unlocks for 10 seconds");
      default: return null;
    }
  }
}