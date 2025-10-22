import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';
import '../data/models/medication.dart';
import '../data/models/user_medication.dart';

class AddMedicationTrackingScreen extends StatefulWidget {
  final Medication medication;

  const AddMedicationTrackingScreen({
    super.key,
    required this.medication,
  });

  @override
  State<AddMedicationTrackingScreen> createState() =>
      _AddMedicationTrackingScreenState();
}

class _AddMedicationTrackingScreenState
    extends State<AddMedicationTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<TimeOfDay> _scheduleTimes = [];

  @override
  void dispose() {
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _addScheduleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _scheduleTimes.add(picked);
        _scheduleTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  void _removeScheduleTime(int index) {
    setState(() {
      _scheduleTimes.removeAt(index);
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_scheduleTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one schedule time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final medProvider =
        Provider.of<MedicationProvider>(context, listen: false);

    // Convert time slots to schedule format
    final schedules = _scheduleTimes.map((time) {
      String timeSlot = 'morning';
      if (time.hour >= 12 && time.hour < 17) {
        timeSlot = 'afternoon';
      } else if (time.hour >= 17 && time.hour < 21) {
        timeSlot = 'evening';
      } else if (time.hour >= 21 || time.hour < 6) {
        timeSlot = 'night';
      }

      return MedicationSchedule(
        timeSlot: timeSlot,
        doseAmount: int.tryParse(_dosageController.text.trim()) ?? 1,
      );
    }).toList();

    final request = UserMedicationCreateRequest(
      medicationId: widget.medication.id,
      boxesOwned: 1,
      schedules: schedules,
      durationDays: _endDate != null
          ? _endDate!.difference(_startDate).inDays
          : int.tryParse(_frequencyController.text.trim()) ?? 30,
    );

    final success = await medProvider.createUserMedication(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medication tracking started'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop(); // Go back to home
    } else if (mounted && medProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(medProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Tracking'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medication info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.medication,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.medication.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.medication.strengthMg}mg ${widget.medication.form}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 500mg, 1 tablet',
                  prefixIcon: Icon(Icons.local_pharmacy),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Frequency
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  hintText: 'e.g., Daily, Twice daily, As needed',
                  prefixIcon: Icon(Icons.repeat),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter frequency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: _selectStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('MMMM d, y').format(_startDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date (Optional)
              InkWell(
                onTap: _selectEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date (Optional)',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate != null
                            ? DateFormat('MMMM d, y').format(_endDate!)
                            : 'No end date',
                        style: TextStyle(
                          color: _endDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (_endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Schedule Times
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Schedule Times',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addScheduleTime,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_scheduleTimes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No schedule times added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _scheduleTimes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final time = entry.value;
                    return Chip(
                      label: Text(time.format(context)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeScheduleTime(index),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: medProvider.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: medProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Start Tracking',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
