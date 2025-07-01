import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';

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
  final _formKey = GlobalKey<FormState>(); // Add form key for validation

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {})); // Update state on text change
    _descController.addListener(() => setState(() {})); // Update state on text change
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && mounted) {
      _editingHabit = args;
      _titleController.text = args['title'] ?? '';
      _descController.text = args['description'] ?? '';
      _selectedColor = Color(args['color'] ?? Colors.blue.value);
      _selectedIcon = IconData(args['icon'] ?? Icons.favorite.codePoint);
      _frequency = args['frequency'] ?? 'Everyday';
      _checklistEnabled = args['checklistEnabled'] ?? false;
      setState(() {}); // Force UI update with initial values
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  final List<Color> _colorOptions = [
    Colors.blue, Colors.red, Colors.green, Colors.yellow, Colors.purple,
    Colors.orange, Colors.pink, Colors.teal, Colors.indigo, Colors.brown,
    Colors.cyan, Colors.amber, Colors.lime, Colors.deepPurple, Colors.deepOrange,
    Colors.lightGreen, Colors.blueGrey, Colors.black, Colors.white70, Colors.grey,
  ];

  final List<IconData> _iconOptions = [
    Icons.favorite, Icons.book, Icons.lightbulb_outline, Icons.cake,
    Icons.run_circle, Icons.music_note, Icons.camera, Icons.star,
    Icons.local_dining, Icons.fitness_center, Icons.spa, Icons.local_drink,
    Icons.local_florist, Icons.local_library, Icons.local_movies, Icons.local_phone,
    Icons.local_pizza, Icons.local_play, Icons.local_post_office, Icons.local_taxi,
    Icons.lock, Icons.mail, Icons.map, Icons.menu_book, Icons.mic, Icons.movie,
    Icons.palette, Icons.pets, Icons.phone, Icons.photo, Icons.play_arrow,
  ];

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Done', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () {
              setState(() {}); // Ensure state is updated
              Navigator.pop(context);
            },
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingHabit?.isNotEmpty ?? false ? 'Edit Habit' : 'Add New Habit', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Habit Title',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a habit title' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        width: screenWidth * 0.4,
                        child: ElevatedButton(
                          onPressed: _openColorPicker,
                          child: const Text('Pick Color'),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Icon', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        width: screenWidth * 0.4,
                        child: ElevatedButton(
                          onPressed: _openIconPicker,
                          child: const Text('Pick Icon'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              CircleAvatar(backgroundColor: _selectedColor, radius: 20),
              Icon(_selectedIcon, size: 30, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _frequency,
                items: ['Everyday', 'Specific days', 'Monthly', 'Custom']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))))
                    .toList(),
                onChanged: (newValue) => setState(() => _frequency = newValue!),
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: Text('Checklist', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                value: _checklistEnabled,
                onChanged: (value) => setState(() => _checklistEnabled = value),
                tileColor: Theme.of(context).cardColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              if (_checklistEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Add checklist items later.', style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final habit = {
                        'title': _titleController.text,
                        'description': _descController.text,
                        'color': _selectedColor.value,
                        'icon': _selectedIcon.codePoint,
                        'frequency': _frequency,
                        'streak': _editingHabit?['streak'] ?? 0,
                        'completion_log': _editingHabit?['completion_log'] ?? '[]',
                      };
                      try {
                        if (_editingHabit?.isNotEmpty ?? false) {
                          await habitProvider.editHabit(_editingHabit!['id'] as int, habit);
                        } else {
                          await habitProvider.addHabit(habit);
                        }
                        Navigator.pop(context, habit);
                        if (_editingHabit?.isNotEmpty ?? false) {
                          habitProvider.loadHabits(); // Refresh UI after edit
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save habit: $e', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_editingHabit?.isNotEmpty ?? false ? 'Update Habit' : 'Save Habit', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}