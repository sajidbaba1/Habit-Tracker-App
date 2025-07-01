import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key, this.habitId});

  final int? habitId;

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.favorite;
  String _frequency = 'Everyday';
  bool _checklistEnabled = false;

  final List<IconData> _iconOptions = [
    Icons.favorite, Icons.book, Icons.lightbulb, Icons.cake,
    Icons.run_circle, Icons.music_note, Icons.camera, Icons.star,
    Icons.local_dining, Icons.fitness_center, Icons.spa, Icons.local_drink,
    Icons.local_florist, Icons.local_library, Icons.local_movies, Icons.local_phone,
    Icons.local_pizza, Icons.local_play, Icons.local_post_office, Icons.local_taxi,
    Icons.lock, Icons.mail, Icons.map, Icons.menu_book, Icons.mic, Icons.movie,
    Icons.palette, Icons.pets, Icons.phone, Icons.photo, Icons.play_arrow,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final habit = habitProvider.habits.firstWhere(
            (h) => h['id'] == widget.habitId,
        orElse: () => {},
      );
      if (habit.isNotEmpty) {
        _titleController.text = habit['title'] as String? ?? '';
        _descController.text = habit['description'] as String? ?? '';
        _selectedColor = Color(habit['color'] as int? ?? Colors.blue.toARGB32());
        _selectedIcon = IconData(habit['icon'] as int? ?? Icons.favorite.codePoint, fontFamily: 'MaterialIcons');
        _frequency = habit['frequency'] as String? ?? 'Everyday';
        _checklistEnabled = habit['checklistEnabled'] as bool? ?? false;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a Color', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: Text('Done', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
        title: Text('Pick an Icon', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _iconOptions.map((icon) => IconButton(
              icon: Icon(icon, size: 30, color: Theme.of(context).colorScheme.onSurface),
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
    final navigationService = GetIt.I<NavigationService>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habitId == null ? 'Add New Habit' : 'Edit Habit',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
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
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                          child: Text('Pick Color', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
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
                          child: Text('Pick Icon', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  CircleAvatar(backgroundColor: _selectedColor, radius: 20),
                  const SizedBox(width: 16.0),
                  Icon(_selectedIcon, size: 30, color: Theme.of(context).colorScheme.onSurface),
                ],
              ),
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
                tileColor: Theme.of(context).cardColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              if (_checklistEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Add checklist items later.', style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final habit = {
                        'title': _titleController.text,
                        'description': _descController.text,
                        'color': _selectedColor.toARGB32(),
                        'icon': _selectedIcon.codePoint,
                        'frequency': _frequency,
                        'streak': widget.habitId != null ? (habitProvider.habits.firstWhere((h) => h['id'] == widget.habitId, orElse: () => {})['streak'] ?? 0) : 0,
                        'completion_log': widget.habitId != null ? (habitProvider.habits.firstWhere((h) => h['id'] == widget.habitId, orElse: () => {})['completion_log'] ?? '[]') : '[]',
                        'checklistEnabled': _checklistEnabled,
                      };
                      final navigator = Navigator.of(context);
                      try {
                        if (widget.habitId != null) {
                          await habitProvider.editHabit(widget.habitId!, habit);
                        } else {
                          await habitProvider.addHabit(habit);
                        }
                        navigationService.goBack();
                      } catch (e) {
                        navigator.popUntil((route) => route.isFirst);
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
                  child: Text(
                    widget.habitId == null ? 'Save Habit' : 'Update Habit',
                    style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}