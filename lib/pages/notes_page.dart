import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notez/components/drawer.dart';
import 'package:notez/components/note_tile.dart';
import 'package:notez/components/search_bar.dart';
import 'package:notez/models/note.dart';
import 'package:notez/models/note_database.dart';
import 'package:notez/pages/edit_note_page.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final titleController = TextEditingController();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NoteDatabase>().fetchNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void createNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("New Note"),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Title",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // If empty, set to "Untitled"
              final title = titleController.text.trim().isEmpty
                  ? "Untitled"
                  : titleController.text.trim();

              context.read<NoteDatabase>().addNote(
                title,
                "", // start with empty content
              );

              titleController.clear();
              Navigator.pop(context);
            },
            child: Text(
              "Create",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }



  void deleteNote(int id) => context.read<NoteDatabase>().deleteNote(id);

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteDatabase>().currentNotes;
    final List<Note> filtered = _searchQuery.isEmpty
        ? notes
        : notes.where((n) => n.title.toLowerCase().contains(_searchQuery)).toList();

    final inverse = Theme.of(context).colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: const MyDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: inverse,
        title: Text(
          "Notez",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: inverse,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.inversePrimary),
      ),
      body: Column(
        children: [
          NoteSearchBar(
            controller: _searchController,
            onChanged: (v) {
              setState(() => _searchQuery = v.trim().toLowerCase());
            },
            onClear: () {
              setState(() => _searchQuery = "");
            },
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty ? "No notes yet" : "No titles match your search",
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: inverse.withOpacity(0.65),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return NoteTile(
                        title: note.title,
                        content: note.text,
                        createdAt: note.createdAt,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
                        ),
                        onDeletePressed: () => deleteNote(note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
