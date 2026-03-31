import 'package:flutter/material.dart';
import 'package:frontend/api_functions.dart';
import 'package:frontend/create_screen.dart';
import 'package:frontend/model.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String searchQuery = ""; 
  String selectedFilter = "All"; 

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  }

  // void _confirmDelete(BuildContext context, TaskProvider provider, int id) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text("Delete Task?"),
  //       content: const Text("This action cannot be undone."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text("Cancel"),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             provider.deleteTask(id);
  //             Navigator.pop(ctx);
  //           },
  //           child: const Text("Delete", style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTaskCard(Task task, TaskProvider provider) {
    bool isBlocked = false;
    if (task.blockedBy != null) {
      final blockingTask = provider.tasks
          .firstWhere((t) => t.id == task.blockedBy, orElse: () => task);
      if (blockingTask.status != "Done") isBlocked = true;
    }

    return Opacity(
      opacity: isBlocked ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isBlocked ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: _buildStatusIndicator(task.status, isBlocked),
          title: Text(task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration:
                    task.status == "Done" ? TextDecoration.lineThrough : null,
                color: isBlocked ? Colors.grey.shade500 : Colors.black,
              )),
          subtitle: Text(task.description,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: isBlocked
              ? const Icon(Icons.lock_outline, color: Colors.orange)
              : const Icon(Icons.chevron_right),
          onTap: isBlocked
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => TaskCreationScreen(existingTask: task))),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, bool isBlocked) {
    Color color = Colors.blue;
    if (status == "Done") color = Colors.green;
    if (status == "In Progress") color = Colors.orange;
    if (isBlocked) color = Colors.grey;

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus =
          selectedFilter == "All" || task.status == selectedFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("My Tasks",
                style:
                    TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1)),
            actions: [
              if (taskProvider.isLoading)
                const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildModernSearchBar(),
                  const SizedBox(height: 12),
                  _buildStatusFilter(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildTaskCard(filteredTasks[index], taskProvider),
                childCount: filteredTasks.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        label: const Text("Add Task"),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search your tasks...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      onChanged: (v) => setState(() => searchQuery = v),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ["All", "To-Do", "In Progress", "Done"].map((s) {
          final isSelected = selectedFilter == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (v) => setState(() => selectedFilter = s),
              selectedColor: const Color(0xFF6366F1),
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }
}
