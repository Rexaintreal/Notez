import 'package:flutter/material.dart';
import 'package:notez/models/note.dart';
import 'package:notez/models/note_database.dart';
import 'package:provider/provider.dart';

class EditNotePage extends StatefulWidget {
  final Note note;
  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _textController = TextEditingController(text: widget.note.text);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    // If the title is empty, fallback to "Untitled"
    final safeTitle = _titleController.text.trim().isEmpty
        ? "Untitled"
        : _titleController.text.trim();

    await context.read<NoteDatabase>().updateNote(
      widget.note.id,
      safeTitle,
      _textController.text,
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }


  String _formatDate(DateTime date) {
    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final chars = _textController.text.length;
    final lines =
        _textController.text.isEmpty ? 0 : _textController.text.split('\n').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Title field ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // ---- Metadata below title (wraps if too long) ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(
              'Last Updated: ${_formatDate(widget.note.updatedAt)}  •  '
              '$chars Characters •  $lines Lines',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
              ),
              softWrap: true,         
              overflow: TextOverflow.visible,
            ),
          ),

          // ---- Note content ----
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
