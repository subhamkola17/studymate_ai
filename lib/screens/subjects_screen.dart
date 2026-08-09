import 'package:flutter/material.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> subjects = [
    {
      "name": "Mathematics",
      "icon": Icons.calculate,
      "favorite": false,
    },
    {
      "name": "Physics",
      "icon": Icons.science,
      "favorite": false,
    },
    {
      "name": "Chemistry",
      "icon": Icons.biotech,
      "favorite": false,
    },
    {
      "name": "Computer Science",
      "icon": Icons.computer,
      "favorite": false,
    },
  ];

  List<Map<String, dynamic>> filteredSubjects = [];

  final List<Color> subjectColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.yellow.shade100,
  ];

  @override
  void initState() {
    super.initState();
    filteredSubjects = List.from(subjects);
  }

  void searchSubject(String query) {
    setState(() {
      filteredSubjects = subjects
          .where(
            (subject) => subject["name"]
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void addSubject() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Subject"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Subject Name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  subjects.add({
                    "name": controller.text,
                    "icon": Icons.book,
                    "favorite": false,
                  });

                  filteredSubjects =
                      List.from(subjects);
                });

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void editSubject(int index) {
    final controller = TextEditingController(
      text: filteredSubjects[index]["name"],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Subject"),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                filteredSubjects[index]["name"] =
                    controller.text;
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteSubject(int index) {
    setState(() {
      subjects.remove(filteredSubjects[index]);
      filteredSubjects =
          List.from(subjects);
    });
  }

  void toggleFavorite(int index) {
    setState(() {
      filteredSubjects[index]["favorite"] =
          !filteredSubjects[index]["favorite"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subjects"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addSubject,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: searchSubject,
              decoration: InputDecoration(
                hintText: "Search Subject",
                prefixIcon:
                    const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          Text(
            "Total Subjects: ${subjects.length}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount:
                  filteredSubjects.length,
              itemBuilder:
                  (context, index) {
                return Card(
                  color: subjectColors[
                      index %
                          subjectColors.length],
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  elevation: 6,
                  child: ListTile(
                    leading: CircleAvatar(
  backgroundColor: Colors.indigo,
  child: Icon(
    filteredSubjects[index]["icon"],
    color: Colors.white,
  ),
),
                   title: Text(
  filteredSubjects[index]["name"],
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontSize: 18,
  ),
),

                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            filteredSubjects[
                                        index]
                                    [
                                    "favorite"]
                                ? Icons.star
                                : Icons
                                    .star_border,
                            color:
                                Colors.orange,
                          ),
                          onPressed: () =>
                              toggleFavorite(
                                  index),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () =>
                              editSubject(
                                  index),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              deleteSubject(
                                  index),
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