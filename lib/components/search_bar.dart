import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoteSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String placeholder;

  const NoteSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.placeholder = "Search by title",
  });

  @override
  State<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends State<NoteSearchBar> {
  void _controllerListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerListener);
  }

  @override
  void didUpdateWidget(covariant NoteSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_controllerListener);
      widget.controller.addListener(_controllerListener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inverse = theme.colorScheme.inversePrimary;
    final fillColor = theme.colorScheme.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: isDark ? fillColor.withOpacity(0.18) : fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ignore: deprecated_member_use
          Icon(Icons.search, color: inverse.withOpacity(0.95)),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              controller: widget.controller,
              placeholder: widget.placeholder,
              placeholderStyle: TextStyle(
                // ignore: deprecated_member_use
                color: inverse.withOpacity(0.65),
                fontSize: 15,
              ),
              style: TextStyle(color: inverse, fontSize: 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: null,
              onChanged: (v) => widget.onChanged(v),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onChanged('');
                if (widget.onClear != null) widget.onClear!();
              },
              // ignore: deprecated_member_use
              child: Icon(Icons.clear, color: inverse.withOpacity(0.8)),
            ),
        ],
      ),
    );
  }
}
