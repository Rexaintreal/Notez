import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

class WhiteboardPage extends StatefulWidget {
  const WhiteboardPage({super.key});

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage> {
  final List<_Stroke> _strokes = [];
  final GlobalKey _paintKey = GlobalKey();

  Color _currentColor = Colors.red;
  double _strokeWidth = 4.0;   // brush width
  double _eraserWidth = 20.0;  // eraser width
  bool _eraserMode = false;
  bool _hasSaved = false;      

  void _clear() => setState(() {
        _strokes.clear();
        _hasSaved = false;
      });

  Future<void> _saveImage() async {
    try {
      if (await Permission.storage.isDenied ||
          await Permission.storage.isRestricted) {
        await Permission.storage.request();
      }

      final boundary =
          _paintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      if (!mounted) return;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final picturesDir = Directory('/storage/emulated/0/Pictures/Whiteboard');
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      final file = File(
        '${picturesDir.path}/whiteboard_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      setState(() => _hasSaved = true); 

      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.surface,
          content: Text(
            'Saved to: ${file.path}',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
        ),
      );
    }
  }

  void _pickHexColor() async {
    final controller = TextEditingController();
    final result = await showDialog<Color>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'Hex Color',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "#RRGGBB or #AARRGGBB",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.inversePrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                try {
                  final input = controller.text.trim();
                  final hex = input.startsWith('#') ? input.substring(1) : input;
                  final color = Color(
                    int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16),
                  );
                  Navigator.pop(context, color);
                } catch (_) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                "OK",
                style: TextStyle(color: theme.colorScheme.inversePrimary),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _currentColor = result;
        _eraserMode = false;
        _hasSaved = false;
      });
    }
  }

  Offset _localPosition(BuildContext context, Offset global) {
    final box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
  }

  void _startStroke(Offset pos, Color backgroundColor) {
    setState(() {
      _strokes.add(_Stroke(
        [pos],
        _eraserMode ? backgroundColor : _currentColor,
        _eraserMode ? _eraserWidth : _strokeWidth,
      ));
      _hasSaved = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_strokes.isNotEmpty && !_hasSaved) {
          final theme = Theme.of(context);
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                "Discard Whiteboard?",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              content: Text(
                "You have unsaved drawings. If you exit now, they will be lost.",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: theme.colorScheme.inversePrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Exit",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text("Whiteboard"),
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _saveImage),
            IconButton(icon: const Icon(Icons.delete_forever), onPressed: _clear),
          ],
        ),
        body: GestureDetector(
          onPanStart: (details) =>
              _startStroke(_localPosition(context, details.localPosition), backgroundColor),
          onPanUpdate: (details) {
            final localPos = _localPosition(context, details.localPosition);
            setState(() => _strokes.last.points.add(localPos));
          },
          child: RepaintBoundary(
            key: _paintKey,
            child: CustomPaint(
              painter: _WhiteboardPainter(_strokes),
              size: Size.infinite,
            ),
          ),
        ),
        bottomNavigationBar: _buildToolbar(context, backgroundColor),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, Color backgroundColor) {
    final theme = Theme.of(context);
    final currentWidth = _eraserMode ? _eraserWidth : _strokeWidth;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 30),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              icon: Icon(_eraserMode ? Icons.brush : Icons.cleaning_services),
              tooltip: _eraserMode ? 'Switch to Pen' : 'Eraser',
              onPressed: () => setState(() => _eraserMode = !_eraserMode),
            ),
            for (final color in [Colors.red, Colors.blue, Colors.green])
              _colorButton(color, backgroundColor),
            IconButton(
              tooltip: 'Custom Hex Color',
              icon: const Icon(Icons.palette),
              onPressed: _pickHexColor,
            ),
            SizedBox(
              width: 160,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _eraserMode ? "Eraser Size" : "Brush Size",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.inversePrimary,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: theme.colorScheme.inversePrimary,
                      inactiveTrackColor:
                          // ignore: deprecated_member_use
                          theme.colorScheme.inversePrimary.withOpacity(0.3),
                      thumbColor: theme.colorScheme.inversePrimary,
                      overlayColor:
                          // ignore: deprecated_member_use
                          theme.colorScheme.inversePrimary.withOpacity(0.2),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 8 + (currentWidth / 2),
                      ),
                    ),
                    child: Slider(
                      value: currentWidth,
                      min: 1,
                      max: 40,
                      divisions: 39,
                      onChanged: (v) => setState(() {
                        if (_eraserMode) {
                          _eraserWidth = v;
                        } else {
                          _strokeWidth = v;
                        }
                        _hasSaved = false;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color, Color backgroundColor) {
    // ignore: deprecated_member_use
    final isSelected = color.value == _currentColor.value && !_eraserMode;
    return GestureDetector(
      onTap: () => setState(() {
        _eraserMode = false;
        _currentColor = color;
        _hasSaved = false;
      }),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  _Stroke(this.points, this.color, this.width);
}

class _WhiteboardPainter extends CustomPainter {
  final List<_Stroke> strokes;
  _WhiteboardPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(_WhiteboardPainter oldDelegate) => true;
}
