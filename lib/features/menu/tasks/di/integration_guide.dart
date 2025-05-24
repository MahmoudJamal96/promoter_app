// How to integrate Tasks feature in the app

// Add this import at the top of the injection_container.dart or similar file
import 'package:promoter_app/features/menu/tasks/di/setup_tasks.dart';

// Then call this function during initialization
void init() {
  // ... other initialization code

  // Initialize tasks feature
  setupTasksDependencies();

  // ... more initialization code
}

/*
If you want to add the tasks feature to a specific menu or screen,
you can add it like this to your route configuration or navigation:

final routes = {
  '/tasks': (context) => const TasksScreen(),
  // ... other routes
};

Or add it to your drawer/menu:

ListTile(
  leading: const Icon(Icons.task),
  title: const Text('مهامي'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TasksScreen()),
    );
  },
),
*/
