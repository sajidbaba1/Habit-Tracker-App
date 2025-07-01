import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:animations/animations.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.favorite;
  String _frequency = 'Everyday';
  bool _checklistEnabled = false;
  Map<String, dynamic>? _editingHabit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _editingHabit = args;
      _titleController.text = args['title'] ?? '';
      _descController.text = args['description'] ?? '';
      _selectedColor = Color(args['color'] ?? Colors.blue.value);
      _selectedIcon = IconData(args['icon'] ?? Icons.favorite.codePoint, fontFamily: 'MaterialIcons');
      _frequency = args['frequency'] ?? 'Everyday';
      _checklistEnabled = (args['checklistEnabled'] as int?)?.toInt() == 1; // Convert int to bool
    }
  }

  final List<Color> _colorOptions = [
    Colors.blue, Colors.red, Colors.green, Colors.yellow, Colors.purple,
    Colors.orange, Colors.pink, Colors.teal, Colors.indigo, Colors.brown,
  ];

  final List<IconData> _iconOptions = [
    Icons.favorite, Icons.book, Icons.lightbulb_outline, Icons.cake,
    Icons.run_circle, Icons.music_note, Icons.camera, Icons.star,
    Icons.local_dining, Icons.fitness_center,
  ];

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            availableColors: _colorOptions,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Done', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _openIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick an Icon', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _iconOptions.map((icon) => IconButton(
              icon: Icon(icon, size: 30),
              onPressed: () {
                setState(() => _selectedIcon = icon);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Done', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingHabit != null ? 'Edit Habit' : 'Add New Habit', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.cyan, // Changed to navy blue
        elevation: 10,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Habit Title',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color', style: TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 8.0),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: 1.0,
                      child: SizedBox(
                        width: screenWidth * 0.4,
                        child: ElevatedButton(
                          onPressed: _openColorPicker,
                          child: const Text('Pick Color'),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Icon', style: TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 8.0),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: 1.0,
                      child: SizedBox(
                        width: screenWidth * 0.4,
                        child: ElevatedButton(
                          onPressed: _openIconPicker,
                          child: const Text('Pick Icon'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16.0),
                Icon(_selectedIcon, size: 30, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _frequency,
              items: ['Everyday', 'Specific days', 'Monthly', 'Custom']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (newValue) => setState(() => _frequency = newValue!),
              decoration: InputDecoration(
                labelText: 'Frequency',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('Checklist', style: TextStyle(fontSize: 16, color: Colors.white)),
              value: _checklistEnabled,
              onChanged: (value) => setState(() => _checklistEnabled = value),
              tileColor: Theme.of(context).cardColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            if (_checklistEnabled)
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text('Add checklist items later.', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
              ),
            const SizedBox(height: 20.0),
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: 1.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a habit title')),
                      );
                      return;
                    }
                    final habit = {
                      'title': _titleController.text,
                      'description': _descController.text,
                      'color': _selectedColor.value,
                      'icon': _selectedIcon.codePoint,
                      'frequency': _frequency,
                      'streak': 0,
                      'completion_log': '[]',
                      'checklistEnabled': _checklistEnabled,
                    };
                    try {
                      if (_editingHabit != null) {
                        await habitProvider.editHabit(_editingHabit!['id'] as int, habit);
                      } else {
                        await habitProvider.addHabit(habit);
                      }
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_editingHabit != null ? 'Update Habit' : 'Save Habit', style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}