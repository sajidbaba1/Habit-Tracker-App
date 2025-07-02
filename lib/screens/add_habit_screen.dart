import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddHabitScreen extends StatefulWidget {
  final Map<String, dynamic>? habit;
  final int? habitId;

  const AddHabitScreen({super.key, this.habit, this.habitId});

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _category;
  late int _icon;
  late int _color;
  late bool _checklistEnabled;

  @override
  void initState() {
    super.initState();
    _title = widget.habit?['title'] ?? '';
    _category = widget.habit?['category'] ?? 'Other';
    _icon = widget.habit?['icon'] ?? Icons.favorite.codePoint;
    _color = widget.habit?['color'] ?? Colors.blue.value;
    _checklistEnabled = (widget.habit?['checklist_enabled'] ?? 0) == 1;
  }

  void _autoDetectCategory(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('gym') || lowerTitle.contains('exercise')) _category = 'Health';
    else if (lowerTitle.contains('study') || lowerTitle.contains('learn')) _category = 'Education';
    else if (lowerTitle.contains('read') || lowerTitle.contains('book')) _category = 'Reading';
    else _category = 'Other';
    setState(() {});
  }

  void _selectIcon() async {
    final selectedIcon = await showDialog<int>(
      context: context,
      builder: (context) => IconPickerDialog(),
    );
    if (selectedIcon != null) setState(() => _icon = selectedIcon);
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Color(_color),
            onColorChanged: (color) => setState(() => _color = color.value),
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      if (widget.habitId == null) {
        await habitProvider.addHabit(
          title: _title,
          category: _category,
          icon: _icon,
          color: _color,
          checklistEnabled: _checklistEnabled,
        );
      } else {
        await habitProvider.updateHabit(
          widget.habitId!,
          title: _title,
          category: _category,
          icon: _icon,
          color: _color,
          checklistEnabled: _checklistEnabled,
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitId == null ? 'Add Habit' : 'Edit Habit').animate().fadeIn().slideY(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary).animate().fadeIn(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Habit Title'),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  onChanged: _autoDetectCategory,
                  onSaved: (value) => _title = value!,
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Health', 'Education', 'Reading', 'Other']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Select Icon'),
                  trailing: Icon(IconData(_icon, fontFamily: 'MaterialIcons')),
                  onTap: _selectIcon,
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Pick Color'),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    color: Color(_color),
                  ),
                  onTap: _pickColor,
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Checklist Enabled'),
                  value: _checklistEnabled,
                  onChanged: (value) => setState(() => _checklistEnabled = value),
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Save Habit'),
                ).animate().fadeIn().scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select Icon'),
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          children: [
            for (var icon in [Icons.favorite, Icons.run_circle, Icons.book, Icons.local_dining])
              IconButton(icon: Icon(icon), onPressed: () => Navigator.pop(context, icon.codePoint)),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}