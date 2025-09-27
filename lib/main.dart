import 'package:flutter/material.dart';
import 'package:notez/models/note_database.dart';
import 'package:notez/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/notes_page.dart';

void main() async {
  // initialize note isar database
  WidgetsFlutterBinding.ensureInitialized();
  await NoteDatabase.initialize();

  runApp(MultiProvider(
    providers: [
      // note database provider
      ChangeNotifierProvider(create: (_) => NoteDatabase()),

      // theme provider
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getTheme(),
          home: const NotesPage(),
        );
      },
    );
  }
}