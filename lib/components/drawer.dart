import 'package:flutter/material.dart';
import 'package:notez/components/drawer_tile.dart';
import 'package:notez/pages/settings_page.dart';
import 'package:notez/pages/whiteboard_page.dart'; 
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_note,
                  size: 42,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(width: 10),
                Text(
                  "Notez",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Notes tile
          DrawerTile(
            title: "Notes",
            leading: const Icon(Icons.home),
            onTap: () => Navigator.pop(context),
          ),

          // Whiteboard tile 
          DrawerTile(
            title: "Whiteboard",
            leading: const Icon(Icons.brush),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WhiteboardPage()),
              );
            },
          ),

          // Settings tile
          DrawerTile(
            title: "Settings",
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
