import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

DateTime? selectedDate;

void main() {
  runApp(MyProfileApp());
}

class MyProfileApp extends StatefulWidget {
  const MyProfileApp({super.key});

  @override
  State<MyProfileApp> createState() => _MyProfileAppState();
}

class _MyProfileAppState extends State<MyProfileApp> {
  ThemeMode _themeMode = ThemeMode.light; // Start with light

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      themeMode: _themeMode,

      // 🟡 LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      ),

      // ⚫ DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.tealAccent,
        ),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
      ),

      home: HomeScreen(
        onThemeToggle: toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

// ------------------------- HOME SCREEN (With Bottom Nav) -------------------------
class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final screens = [const ProfileScreen(), const TaskManagerScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        centerTitle: true,
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: (value) {
              widget.onThemeToggle(value);
            },
          ),
        ],
      ),

      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
        ],
      ),
    );
  }
}

// ------------------------- TASK MANAGER SCREEN -------------------------

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  List<Map<String, dynamic>> tasks = [
    {"title": "Do Homework", "done": false},
    {"title": "Learn Flutter", "done": true},
  ];

  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks(); // Load tasks at start
  }

  // Save tasks to shared_preferences
  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('task_list', jsonEncode(tasks));
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('task_list');
    if (saved != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  void addTask(String taskText) {
    if (taskText.isNotEmpty) {
      setState(() {
        tasks.add({
          "title": taskText,
          "done": false,
          "due": selectedDate?.toIso8601String(), // add due date here
        });
        taskController.clear();
        selectedDate = null; // reset after adding
      });
      saveTasks();
    }
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks(); // Save after deleting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Task Manager"),
        backgroundColor: Colors.teal[400],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Task Input Box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter a new task",
                      hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.tealAccent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    addTask(taskController.text.trim());
                  },
                  child: const Text("Add"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // NEW: Date Picker button
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today, color: Colors.tealAccent),
              label: Text(
                selectedDate == null
                    ? "Pick Due Date"
                    : "Due: ${selectedDate!.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(color: Colors.tealAccent),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: clearCompletedTasks,
              icon: Icon(Icons.cleaning_services),
              label: Text("Clear Completed"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
            SizedBox(height: 10),

            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.teal[200],
                    child: ListTile(
                      leading: Checkbox(
                        value: tasks[index]['done'],
                        onChanged: (value) {
                          setState(() {
                            tasks[index]['done'] = value!;
                          });
                          saveTasks();
                        },
                      ),
                      title: GestureDetector(
                        onTap: () {
                          editTask(index);
                        },
                        child: Text(
                          tasks[index]['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: tasks[index]['done']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      subtitle: tasks[index]['due'] != null
                          ? Text(
                              "Due: ${tasks[index]['due'].toString().split('T')[0]}",
                              style: TextStyle(color: Colors.black87),
                            )
                          : null,

                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteTask(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void editTask(int index) {
    TextEditingController editController = TextEditingController(
      text: tasks[index]['title'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          title: Text("Edit Task", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: editController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter updated task",
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.tealAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // cancel
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks[index]['title'] = editController.text;
                });
                saveTasks();
                Navigator.of(context).pop(); // save & close
              },
              child: Text("Save", style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        );
      },
    );
  }

  void clearCompletedTasks() {
    setState(() {
      tasks.removeWhere((task) => task['done'] == true);
    });
    saveTasks();
  }
}

// ------------------------- PROFILE SCREEN -------------------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.teal[400],
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("assets/images/profilepic.png"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Aryan Sharma",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Flutter Developer 🚀",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                InfoCard(title: "Age", value: "21"),
                InfoCard(title: "Country", value: "India"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
