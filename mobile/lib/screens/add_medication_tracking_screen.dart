import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  final _boxesController = TextEditingController(text: '1');
  final _durationController = TextEditingController(text: '30');

  final Map<String, double> _schedules = {};

  @override
  void dispose() {
    _boxesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _toggleSchedule(String timeSlot) {
    setState(() {
      if (_schedules.containsKey(timeSlot)) {
        _schedules.remove(timeSlot);
      } else {
        _schedules[timeSlot] = 1.0;
      }
    });
  }

  Future<void> _showDoseDialog(String timeSlot) async {
    final controller = TextEditingController(
      text: _schedules[timeSlot]?.toString() ?? '1',
    );

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _getTimeSlotColor(timeSlot).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTimeSlotColor(timeSlot),
                      _getTimeSlotColor(timeSlot).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getTimeSlotIcon(timeSlot), color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                _getTimeSlotLabel(timeSlot),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  suffix: const Text('pills', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final dose = double.tryParse(controller.text);
                        if (dose != null && dose > 0) {
                          setState(() {
                            _schedules[timeSlot] = dose;
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _getTimeSlotColor(timeSlot),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    controller.dispose();
  }

  String _getTimeSlotLabel(String timeSlot) {
    switch (timeSlot) {
      case 'morning':
        return 'Morning';
      case 'noon':
        return 'Noon';
      case 'evening':
        return 'Evening';
      case 'night':
        return 'Night';
      default:
        return timeSlot;
    }
  }

  IconData _getTimeSlotIcon(String timeSlot) {
    switch (timeSlot) {
      case 'morning':
        return Icons.wb_sunny;
      case 'noon':
        return Icons.light_mode;
      case 'evening':
        return Icons.wb_twilight;
      case 'night':
        return Icons.bedtime;
      default:
        return Icons.access_time;
    }
  }

  List<Color> _getTimeSlotGradient(String timeSlot) {
    switch (timeSlot) {
      case 'morning':
        return [const Color(0xFFFF9A56), const Color(0xFFFF6B6B)];
      case 'noon':
        return [const Color(0xFFFECA57), const Color(0xFFFF9F43)];
      case 'evening':
        return [const Color(0xFF9C88FF), const Color(0xFF6C5CE7)];
      case 'night':
        return [const Color(0xFF4A69BD), const Color(0xFF3742FA)];
      default:
        return [Colors.blue, Colors.blue[700]!];
    }
  }

  Color _getTimeSlotColor(String timeSlot) {
    return _getTimeSlotGradient(timeSlot)[0];
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Pick at least one time'),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final medProvider =
        Provider.of<MedicationProvider>(context, listen: false);

    final schedules = _schedules.entries
        .map((entry) => MedicationSchedule(
              timeSlot: entry.key,
              doseAmount: entry.value,
            ))
        .toList();

    final request = UserMedicationCreateRequest(
      medicationId: widget.medication.id,
      boxesOwned: int.tryParse(_boxesController.text.trim()) ?? 1,
      schedules: schedules,
      durationDays: int.tryParse(_durationController.text.trim()) ?? 30,
    );

    final success = await medProvider.createUserMedication(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Started tracking!', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: const Color(0xFF27AE60),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else if (mounted && medProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(medProvider.errorMessage!),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Start Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication Card with Gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C5CE7), Color(0xFF4834DF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.medication_rounded, color: Colors.white, size: 32),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.medication.strengthMg}mg • ${widget.medication.form}',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Form Fields in Row
              Row(
                children: [
                  Expanded(
                    child: _buildCompactField(
                      controller: _boxesController,
                      label: 'Boxes',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFF3498DB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCompactField(
                      controller: _durationController,
                      label: 'Days',
                      icon: Icons.event_rounded,
                      color: const Color(0xFF9B59B6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Schedule Header
              const Text(
                'Daily Schedule',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to select time, long press to edit dose',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Time Slots with Gradient Cards
              _buildGradientTimeSlot('morning'),
              const SizedBox(height: 16),
              _buildGradientTimeSlot('noon'),
              const SizedBox(height: 16),
              _buildGradientTimeSlot('evening'),
              const SizedBox(height: 16),
              _buildGradientTimeSlot('night'),
              const SizedBox(height: 32),

              // Submit Button with Gradient
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF27AE60).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: medProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: medProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Start Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              final num = int.tryParse(value.trim());
              if (num == null || num < 1) {
                return 'Min 1';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGradientTimeSlot(String timeSlot) {
    final isSelected = _schedules.containsKey(timeSlot);
    final dose = _schedules[timeSlot];
    final gradient = _getTimeSlotGradient(timeSlot);

    return GestureDetector(
      onTap: () => _toggleSchedule(timeSlot),
      onLongPress: isSelected ? () => _showDoseDialog(timeSlot) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[200]!, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getTimeSlotIcon(timeSlot),
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTimeSlotLabel(timeSlot),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected && dose != null)
                    Text(
                      '${dose % 1 == 0 ? dose.toInt() : dose} ${dose == 1 ? 'pill' : 'pills'}',
                      style: TextStyle(
                        color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      'Not selected',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: gradient[0], size: 20),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
