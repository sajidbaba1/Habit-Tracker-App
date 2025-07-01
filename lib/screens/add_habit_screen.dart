import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  final Map<String, dynamic>? habit;
  final int? habitId;

  const AddHabitScreen({super.key, this.habit, this.habitId});

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = 'Health';
  IconData _icon = Icons.favorite;
  Color _color = Colors.blue;
  bool _checklistEnabled = false;
  final List<String> _categories = ['Health', 'Productivity', 'Leisure', 'Learning'];
  final List<IconData> _icons = [
    Icons.favorite,
    Icons.directions_run,
    Icons.book,
    Icons.work,
    Icons.sports,
    Icons.music_note,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _title = widget.habit!['title'] as String? ?? '';
      _category = widget.habit!['category'] as String? ?? 'Health';
      _icon = IconData(widget.habit!['icon'] as int? ?? Icons.favorite.codePoint, fontFamily: 'MaterialIcons');
      _color = Color(widget.habit!['color'] as int? ?? Colors.blue.value);
      _checklistEnabled = widget.habit!['checklistEnabled'] == 1;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      HapticFeedback.vibrate();
      if (widget.habitId == null) {
        habitProvider.addHabit(
          title: _title,
          category: _category,
          icon: _icon.codePoint,
          color: _color.value,
          checklistEnabled: _checklistEnabled,
        );
      } else {
        habitProvider.updateHabit(
          widget.habitId!,
          title: _title,
          category: _category,
          icon: _icon.codePoint,
          color: _color.value,
          checklistEnabled: _checklistEnabled,
        );
      }
      Navigator.pop(context);
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _color,
            onColorChanged: (color) => setState(() => _color = color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitId == null ? 'Add Habit' : 'Edit Habit'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Habit Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IconData>(
                value: _icon,
                decoration: const InputDecoration(
                  labelText: 'Icon',
                  border: OutlineInputBorder(),
                ),
                items: _icons
                    .map((icon) => DropdownMenuItem(
                  value: icon,
                  child: Icon(icon),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _icon = value!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Color'),
                trailing: CircleAvatar(backgroundColor: _color),
                onTap: _pickColor,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Checklist'),
                value: _checklistEnabled,
                onChanged: (value) => setState(() => _checklistEnabled = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(widget.habitId == null ? 'Add Habit' : 'Update Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}