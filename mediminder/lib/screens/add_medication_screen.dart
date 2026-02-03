import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/medication_model.dart';
import '../providers/medication_provider.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _supplyController = TextEditingController();

  String _dosageUnit = 'mg';
  String _frequencyType = 'daily';
  final List<TimeOfDay> _scheduleTimes = [const TimeOfDay(hour: 8, minute: 0)];
  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;

  final List<Color> _colors = [
    const Color(0xFF1a237e),
    const Color(0xFF27AE60),
    const Color(0xFFEB5757),
    const Color(0xFFF2994A),
    const Color(0xFF9B51E0),
    const Color(0xFFE91E63),
  ];

  final List<IconData> _icons = [
    Icons.medication,
    Icons.medical_services,
    Icons.healing,
    Icons.favorite,
    Icons.local_pharmacy,
    Icons.vaccines,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _supplyController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduleTimes[index],
    );
    if (picked != null) {
      setState(() {
        _scheduleTimes[index] = picked;
      });
    }
  }

  void _addTimeSlot() {
    setState(() {
      _scheduleTimes.add(const TimeOfDay(hour: 12, minute: 0));
    });
  }

  void _removeTimeSlot(int index) {
    if (_scheduleTimes.length > 1) {
      setState(() {
        _scheduleTimes.removeAt(index);
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MedicationProvider>(context, listen: false);

      final medication = MedicationModel(
        medId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'local_user',
        name: _nameController.text.trim(),
        dosage: double.tryParse(_dosageController.text) ?? 0,
        dosageUnit: _dosageUnit,
        frequencyType: _frequencyType,
        scheduleTimes: _scheduleTimes
            .map((t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
            .toList(),
        iconId: _selectedIconIndex,
        color: _colors[_selectedColorIndex].value,
        currentSupply: int.tryParse(_supplyController.text) ?? 0,
        createdAt: DateTime.now(),
      );

      provider.addMedication(medication);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medication.name} added successfully!'),
          backgroundColor: _colors[_selectedColorIndex],
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        actions: [
          TextButton(
            onPressed: _saveMedication,
            child: const Text('SAVE',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Medication Name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        hintText: 'e.g., Aspirin, Vitamin D',
                        prefixIcon: Icon(Icons.medication),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter medication name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _dosageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dosage',
                              hintText: 'e.g., 500',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _dosageUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: ['mg', 'ml', 'tablets', 'capsules', 'drops']
                                .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _dosageUnit = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Schedule Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _frequencyType,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        prefixIcon: Icon(Icons.repeat),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(
                            value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(
                            value: 'as_needed', child: Text('As Needed')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _frequencyType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Reminder Times',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        TextButton.icon(
                          onPressed: _addTimeSlot,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._scheduleTimes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final time = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            _formatTimeOfDay(time),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          trailing: _scheduleTimes.length > 1
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _removeTimeSlot(index),
                                )
                              : null,
                          onTap: () => _selectTime(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Supply Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supply Tracking',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _supplyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Current Supply Count',
                        hintText: 'e.g., 30',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Appearance Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Color'),
                    const SizedBox(height: 8),
                    Row(
                      children: _colors.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColorIndex = entry.key),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: _selectedColorIndex == entry.key
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: _selectedColorIndex == entry.key
                                  ? [
                                      BoxShadow(
                                          color: entry.value, blurRadius: 8)
                                    ]
                                  : null,
                            ),
                            child: _selectedColorIndex == entry.key
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Icon'),
                    const SizedBox(height: 8),
                    Row(
                      children: _icons.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedIconIndex = entry.key),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedIconIndex == entry.key
                                  ? _colors[_selectedColorIndex]
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              entry.value,
                              color: _selectedIconIndex == entry.key
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveMedication,
              style: ElevatedButton.styleFrom(
                backgroundColor: _colors[_selectedColorIndex],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Medication',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
