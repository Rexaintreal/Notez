import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:notez/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {

  static late Isar isar;

  // I N I T I A L I Z E - D A T A B A S E 
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema],
      directory: dir.path
    );
  }

  // list of notes
  final List<Note> currentNotes = [];

  // CREATE
  Future<void> addNote(String titleFromUser, String textFromUser) async {
    final now = DateTime.now();
    final safeTitle = titleFromUser.trim().isEmpty ? "Untitled" : titleFromUser.trim();



    final newNote = Note()
      ..title = safeTitle
      ..text = textFromUser
      ..createdAt = now
      ..updatedAt = now;

    await isar.writeTxn(() => isar.notes.put(newNote));
    fetchNotes();
  }


  // R E A D - notes from db
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  // U P D A T E - a note in db
  Future<void> updateNote(int id, String newTitle, String newText) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      // Always fallback to "Untitled" if empty
      existingNote.title = newTitle.trim().isEmpty ? "Untitled" : newTitle.trim();
      existingNote.text = newText;
      existingNote.updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }


  // D E L E T E - a not from the db
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }

}