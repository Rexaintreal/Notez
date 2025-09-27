import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notez/models/note_database.dart';
import 'package:notez/theme/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _exportNotes(BuildContext context) async {
    try {
      final db = context.read<NoteDatabase>();
      await db.fetchNotes();
      final notes = db.currentNotes;

      if (notes.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No notes to export.")),
        );
        return;
      }

      final jsonNotes = notes.map((n) => {
            'id': n.id,
            'title': n.title,
            'text': n.text,
            'createdAt': n.createdAt.toIso8601String(),
            'updatedAt': n.updatedAt.toIso8601String(),
          }).toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonNotes);

      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/NotezExports');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);

      final filePath =
          '${exportDir.path}/notes_export_${DateTime.now().millisecondsSinceEpoch}.json';
      await File(filePath).writeAsString(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exported to: $filePath")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Export failed: $e")),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _settingsTile({
    required BuildContext context,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final inverse = theme.colorScheme.inversePrimary;
    final surface = theme.colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: inverse,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inverse = theme.colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: inverse,
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600, color: inverse),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _settingsTile(
            context: context,
            label: "Dark Mode",
            trailing: CupertinoSwitch(
              value: context.watch<ThemeProvider>().isDarkMode,
              onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),
          _settingsTile(
            context: context,
            label: "Export All Notes",
            trailing: Icon(Icons.download_rounded, color: inverse),
            onTap: () => _exportNotes(context),
          ),
          const SizedBox(height: 16),
          _settingsTile(
            context: context,
            label: "Made by Saurabh Tiwari",
            trailing: Icon(Icons.open_in_new, color: inverse),
            onTap: () => _launchURL(
              "https://saurabhcodesawfully.pythonanywhere.com/",
            ),
          ),
        ],
      ),
    );
  }
}
