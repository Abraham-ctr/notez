import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import 'package:notez/providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.filteredTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notez'),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleTheme,
                activeColor: Colors.white,
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final padding = isWide ? 80.0 : 12.0;
          final cardMaxWidth = 700.0;

          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.error != null) {
            return Center(
              child: Text(
                taskProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              children: [
                // 🔍 Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      fillColor:
                          isDark ? AppColors.cardDark : AppColors.cardLight,
                      filled: true,
                    ),
                    onChanged: taskProvider.setSearchQuery,
                  ),
                ),

                // 🔁 Filter dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Text(
                        'Filter:',
                        style: TextStyle(
                          color:
                              isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<TaskFilter>(
                        value: taskProvider.filter,
                        dropdownColor:
                            isDark ? AppColors.cardDark : AppColors.cardLight,
                        items: const [
                          DropdownMenuItem(
                            value: TaskFilter.all,
                            child: Text('All'),
                          ),
                          DropdownMenuItem(
                            value: TaskFilter.completed,
                            child: Text('Completed'),
                          ),
                          DropdownMenuItem(
                            value: TaskFilter.pending,
                            child: Text('Pending'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            taskProvider.setFilter(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // 📝 Task list
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text('No tasks yet'))
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];

                            return Center(
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: cardMaxWidth),
                                child: Card(
                                  color: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 25),
                                          child: Checkbox(
                                            value: task.isDone,
                                            activeColor: AppColors.primary,
                                            onChanged: (_) => taskProvider
                                                .toggleTaskStatus(task),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 11),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 20,
                                                    color: isDark
                                                        ? AppColors.textLight
                                                        : AppColors.textDark,
                                                    decoration: task.isDone
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                  'Created: ${DateFormat.yMMMd().add_jm().format(task.timestamp.toDate())}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  size: 20,
                                                  color: isDark
                                                      ? AppColors.textLight
                                                      : AppColors.textDark),
                                              onPressed: () =>
                                                  _showEditTaskDialog(
                                                      context, task),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  size: 20,
                                                  color: isDark
                                                      ? AppColors.textLight
                                                      : AppColors.textDark),
                                              onPressed: () => taskProvider
                                                  .deleteTask(task.id),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        title: const Text('Add Task'),
        content: TextField(
          controller: taskController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = taskController.text.trim();
              if (title.isNotEmpty) {
                Provider.of<TaskProvider>(context, listen: false)
                    .addTask(title);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Update task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != task.title) {
                Provider.of<TaskProvider>(context, listen: false)
                    .updateTaskTitle(task.id, newTitle);
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
