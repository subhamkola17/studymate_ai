import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();

  String selectedCategory = "Programming";
  String selectedFilter = "All Subjects";

List<String> noteCategories = [];



  List<String> notes = [];
  List<String> filteredNotes = [];
  List<String> noteTimes = [];
  List<bool> pinnedNotes = [];
  final List<Color> noteColors = [
  Colors.blue.shade100,
  Colors.green.shade100,
  Colors.orange.shade100,
  Colors.purple.shade100,
  Colors.yellow.shade100,
];

  void addNote() {
    if (_controller.text.isNotEmpty) {
      setState(() {
       notes.insert(0, _controller.text);
       pinnedNotes.insert(0, false);

      noteTimes.insert(
       0,
       DateFormat('dd MMM yyyy, hh:mm a')
          .format(DateTime.now()),
     );
     noteCategories.insert(0, selectedCategory);

     saveNotes();
    });
      _controller.clear();
    }
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      pinnedNotes.removeAt(index);
      noteTimes.removeAt(index);
      noteCategories.removeAt(index);
      saveNotes();
    });
  }
  Future<void> saveNotes() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('notes', notes);
  await prefs.setStringList('noteTimes', noteTimes);
  await prefs.setStringList(
  'noteCategories',
  noteCategories,
);
  await prefs.setStringList(
  'pinnedNotes',
  pinnedNotes.map((e) => e.toString()).toList(),
);
}

Future<void> loadNotes() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
  notes = prefs.getStringList('notes') ?? [];

  noteTimes = prefs.getStringList('noteTimes') ?? [];
  noteCategories =
    prefs.getStringList('noteCategories') ?? [];
    if (noteCategories.length != notes.length) {
  noteCategories = List.generate(
    notes.length,
    (_) => "Programming",
  );
}

  pinnedNotes =
      (prefs.getStringList('pinnedNotes') ?? [])
          .map((e) => e == 'true')
          .toList();

  searchNotes("");
});
}
  void editNote(int index) {
  _controller.text = notes[index];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Note"),
      content: TextField(
        controller: _controller,
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              notes[index] = _controller.text;
            });
            saveNotes();
            _controller.clear();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
@override
void initState() {
  super.initState();
  loadNotes();
}
void searchNotes(String query) {
  setState(() {
    filteredNotes = [];

    for (int i = 0; i < notes.length; i++) {
      bool matchesSearch =
          notes[i].toLowerCase().contains(query.toLowerCase());

      bool matchesCategory =
          selectedFilter == "All Subjects" ||
          noteCategories[i] == selectedFilter;

      if (matchesSearch && matchesCategory) {
        filteredNotes.add(notes[i]);
      }
    }
  });
}


Future<void> exportPdf(int index) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "StudyMate AI Note",
              style: pw.TextStyle(fontSize: 24),
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              notes[index],
              style: pw.TextStyle(fontSize: 18),
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              noteTimes[index],
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: Column(
        children: [

           Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: const InputDecoration(
          labelText: "Category",
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: "Mathematics",
            child: Text("📘 Mathematics"),
          ),
          DropdownMenuItem(
            value: "Physics",
            child: Text("📗 Physics"),
          ),
          DropdownMenuItem(
            value: "Chemistry",
            child: Text("📕 Chemistry"),
          ),
          DropdownMenuItem(
            value: "Programming",
            child: Text("💻 Programming"),
          ),
          DropdownMenuItem(
            value: "Data Structures",
            child: Text("🗂️ Data Structures"),
          ),
          DropdownMenuItem(
            value: "Algorithms",
            child: Text("⚡ Algorithms"),
          ),
          DropdownMenuItem(
            value: "Database",
            child: Text("🗄️ Database"),
          ),
          DropdownMenuItem(
            value: "Operating System",
            child: Text("🖥️ Operating System"),
          ),
          DropdownMenuItem(
            value: "Computer Networks",
            child: Text("🌐 Computer Networks"),
          ),
          DropdownMenuItem(
            value: "Electronics",
            child: Text("🔌 Electronics"),
          ),
          DropdownMenuItem(
            value: "AI & ML",
            child: Text("🤖 AI & ML"),
          ),
          DropdownMenuItem(
            value: "Web Development",
            child: Text("🌍 Web Development"),
          ),
          DropdownMenuItem(
            value: "Cyber Security",
            child: Text("🔒 Cyber Security"),
          ),
          DropdownMenuItem(
            value: "Other",
            child: Text("📚 Other"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
          });
        },
      ),
    ),

    const SizedBox(height: 10),

    Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
  ),
  child: DropdownButtonFormField<String>(
    value: selectedFilter,
    decoration: const InputDecoration(
      labelText: "Filter Notes",
      border: OutlineInputBorder(),
    ),
    items: const [
      DropdownMenuItem(
        value: "All Subjects",
        child: Text("📚 All Subjects"),
      ),
      DropdownMenuItem(
        value: "Mathematics",
        child: Text("📘 Mathematics"),
      ),
      DropdownMenuItem(
        value: "Physics",
        child: Text("📗 Physics"),
      ),
      DropdownMenuItem(
        value: "Chemistry",
        child: Text("📕 Chemistry"),
      ),
      DropdownMenuItem(
        value: "Programming",
        child: Text("💻 Programming"),
      ),
      DropdownMenuItem(
        value: "Data Structures",
        child: Text("🗂️ Data Structures"),
      ),
      DropdownMenuItem(
        value: "Algorithms",
        child: Text("⚡ Algorithms"),
      ),
      DropdownMenuItem(
        value: "Database",
        child: Text("🗄️ Database"),
      ),
      DropdownMenuItem(
        value: "Operating System",
        child: Text("🖥️ Operating System"),
      ),
      DropdownMenuItem(
        value: "Computer Networks",
        child: Text("🌐 Computer Networks"),
      ),
      DropdownMenuItem(
        value: "Electronics",
        child: Text("🔌 Electronics"),
      ),
      DropdownMenuItem(
        value: "AI & ML",
        child: Text("🤖 AI & ML"),
      ),
      DropdownMenuItem(
        value: "Web Development",
        child: Text("🌍 Web Development"),
      ),
      DropdownMenuItem(
        value: "Cyber Security",
        child: Text("🔒 Cyber Security"),
      ),
    ],
    onChanged: (value) {
      setState(() {
        selectedFilter = value!;
      });

      searchNotes('');
    },
  ),
),

const SizedBox(height: 10),


  Padding(
    padding: const EdgeInsets.all(10),
    child: TextField(
      onChanged: searchNotes,
      decoration: InputDecoration(
        hintText: "Search Notes",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  ),

  const SizedBox(height: 10),

  Text(
    "Total Notes: ${notes.length}",
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),
     
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter Note",
                    ),
                  ),
                ),
                IconButton(
  onPressed: addNote,
  icon: const Icon(Icons.add),
),
              ],
            ),
          ),
         Expanded(
  child: filteredNotes.isEmpty
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 70,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              Text(
                "No notes found",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Try another keyword"),
            ],
          ),
        )
      : ListView.builder(
          itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                return Card(
  color: noteColors[index % noteColors.length],
  elevation: 4,
  margin: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: ListTile(
    leading: const CircleAvatar(
      child: Icon(Icons.note),
    ),
   title: Text(
  filteredNotes[index],
  style: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  ),
),
    subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
   Text(
  noteCategories[index],
  style: const TextStyle(
    color: Colors.black54,
    fontWeight: FontWeight.w600,
  ),
),
    Text(
      noteTimes[index],
      style: const TextStyle(
       fontSize: 13,
fontWeight: FontWeight.w500,
color: Colors.black87,
      ),
    ),
  ],
),
    trailing: Row(
  mainAxisSize: MainAxisSize.min,
 children: [

  IconButton(
    icon: Icon(
      pinnedNotes[index]
          ? Icons.push_pin
          : Icons.push_pin_outlined,
      color: Colors.orange,
    ),
    onPressed: () {
  setState(() {
    pinnedNotes[index] = !pinnedNotes[index];

    if (pinnedNotes[index]) {
      final note = notes.removeAt(index);
      final time = noteTimes.removeAt(index);
      final pin = pinnedNotes.removeAt(index);

      notes.insert(0, note);
      noteTimes.insert(0, time);
      pinnedNotes.insert(0, pin);
    }
  });

  saveNotes();
},
  ),

  IconButton(
    icon: const Icon(
      Icons.edit,
      color: Colors.blue,
    ),
      onPressed: () => editNote(index),
    ),

    IconButton(
  icon: const Icon(
    Icons.picture_as_pdf,
    color: Colors.deepOrange,
  ),
  onPressed: () => exportPdf(index),
),

    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () => deleteNote(index),
    ),
  ],
),
  ),
);
              },
            ),
          ),
        ],
      ),
    );
  }
}