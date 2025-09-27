import 'package:flutter/material.dart';
import 'package:notez/components/note_settings.dart';
import 'package:popover/popover.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;
  final void Function()? onTap;
  final void Function()? onDeletePressed;

  const NoteTile({
    super.key,
    required this.title,
    required this.content,
    required this.createdAt,
    this.onTap,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText =
        content.isEmpty ? 'Write something…' : 'Created: ${_formatDate(createdAt)}';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitleText,
          style: TextStyle(
            // ignore: deprecated_member_use
            color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showPopover(
              width: 100,
              height: 50, 
              backgroundColor: Theme.of(context).colorScheme.surface,
              context: context,
              bodyBuilder: (context) => NoteSettings(
                onDeleteTap: onDeletePressed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
           "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
