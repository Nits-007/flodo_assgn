import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';
import 'api_functions.dart';

class TaskCreationScreen extends StatefulWidget {
  final Task? existingTask; 
  const TaskCreationScreen({Key? key, this.existingTask}) : super(key: key);

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = "To-Do";
  int? _blockedByTaskId;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _descController.text = widget.existingTask!.description;
      _selectedDate = widget.existingTask!.dueDate;
      _selectedStatus = widget.existingTask!.status;
      _blockedByTaskId = widget.existingTask!.blockedBy;
    } else {
      _loadDrafts();
    }
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titleController.text = prefs.getString('draft_title') ?? '';
      _descController.text = prefs.getString('draft_desc') ?? '';
    });
  }

  Future<void> _saveDrafts() async {
    if (widget.existingTask != null) return; 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', _titleController.text);
    await prefs.setString('draft_desc', _descController.text);
  }

  void _submit() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final taskData = Task(
      id: widget.existingTask?.id,
      title: _titleController.text,
      description: _descController.text,
      dueDate: _selectedDate,
      status: _selectedStatus,
      blockedBy: _blockedByTaskId,
    );

    if (widget.existingTask == null) {
      await provider.addTask(taskData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
    } else {
      await provider.updateTask(widget.existingTask!.id!, taskData);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final isSyncing = Provider.of<TaskProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.existingTask == null ? "Create Task" : "Task Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
              onChanged: (_) => _saveDrafts(),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
              onChanged: (_) => _saveDrafts(),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text("Due Date: ${_selectedDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: ["To-Do", "In Progress", "Done"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedStatus = val!),
              decoration: const InputDecoration(labelText: "Status"),
            ),
            DropdownButtonFormField<int?>(
              value: _blockedByTaskId,
              hint: const Text("Blocked By (Optional)"),
              items: tasks.where((t) => t.id != widget.existingTask?.id).map((t) => 
                DropdownMenuItem(value: t.id, child: Text(t.title))).toList(),
              onChanged: (val) => setState(() => _blockedByTaskId = val),
            ),
            const SizedBox(height: 40),
            isSyncing 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _submit, child: const Text("Save Task")),
          ],
        ),
      ),
    );
  }
}