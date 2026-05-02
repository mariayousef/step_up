import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyNote {
  String text;
  bool isPinned;
  MyNote(this.text, {this.isPinned = false});
  
  Map<String, dynamic> toJson() => {'text': text, 'isPinned': isPinned};
  factory MyNote.fromJson(Map<String, dynamic> json) => MyNote(json['text'], isPinned: json['isPinned']);
}

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<MyNote> _notes = [];
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('doctor_notes');
    if (notesJson != null) {
      final List<dynamic> decodedList = jsonDecode(notesJson);
      setState(() {
        _notes = decodedList.map((item) => MyNote.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await prefs.setString('doctor_notes', encodedList);
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Private Note'),
          content: TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Type your note here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_noteController.text.isNotEmpty) {
                  setState(() {
                    _notes.insert(0, MyNote(_noteController.text));
                  });
                  _saveNotes();
                  _sortNotes();
                  _noteController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  void _togglePin(int index) {
    setState(() {
      _notes[index].isPinned = !_notes[index].isPinned;
      _sortNotes();
    });
    _saveNotes();
  }

  void _sortNotes() {
    // Pinned notes bubble to top
    _notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0; // maintain relative order
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_document, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No notes yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add a new private note.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: note.isPinned ? 3 : 1, // ظل أكبر عند التثبيت
                  color: note.isPinned ? Colors.teal.shade50 : Colors.white, // لون مميز للمثبت
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined, 
                        color: note.isPinned ? const Color(0xFF00796B) : Colors.grey
                      ),
                      onPressed: () => _togglePin(index),
                    ),
                    title: Text(note.text),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteNote(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: const Color(0xFF00796B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
