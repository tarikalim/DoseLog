import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';
import '../data/models/user_medication.dart';
import '../data/models/medication_log.dart';

class MedicationLogsScreen extends StatefulWidget {
  final UserMedication userMedication;

  const MedicationLogsScreen({
    super.key,
    required this.userMedication,
  });

  @override
  State<MedicationLogsScreen> createState() => _MedicationLogsScreenState();
}

class _MedicationLogsScreenState extends State<MedicationLogsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final medProvider =
        Provider.of<MedicationProvider>(context, listen: false);
    await medProvider.loadMedicationLogs(widget.userMedication.id);
    await medProvider.loadStats(widget.userMedication.id);
  }

  Future<void> _markAsTaken(String logId) async {
    final medProvider =
        Provider.of<MedicationProvider>(context, listen: false);
    final success =
        await medProvider.markAsTaken(logId, widget.userMedication.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as taken'),
          backgroundColor: Colors.green,
        ),
      );
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
    final logs = medProvider.getMedicationLogs(widget.userMedication.id);
    final stats = medProvider.getStats(widget.userMedication.id);

    // Group logs by date
    final Map<String, List<MedicationLog>> groupedLogs = {};
    for (final log in logs) {
      final date = log.timestamp.split('T')[0];
      if (!groupedLogs.containsKey(date)) {
        groupedLogs[date] = [];
      }
      groupedLogs[date]!.add(log);
    }

    final sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => a.compareTo(b)); // Oldest first

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Logs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: logs.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No logs yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Medication Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                      widget.userMedication.medication?.name ??
                                          'Unknown',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${widget.userMedication.medication?.strengthMg ?? 0}mg ${widget.userMedication.medication?.form ?? ''} - ${widget.userMedication.durationDays} days',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (stats != null) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text(
                              'Pill Statistics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Remaining',
                                  '${stats.remainingPills}/${stats.totalPills}',
                                  _getWarningColor(stats.warningLevel),
                                ),
                                _buildStatItem(
                                  'Daily Use',
                                  '${stats.dailyConsumption}',
                                  Colors.blue,
                                ),
                                _buildStatItem(
                                  'Days Left',
                                  '${stats.estimatedDaysRemaining}',
                                  Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Planned Duration: ${stats.plannedDurationDays} days',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Days Elapsed: ${stats.daysElapsed}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Planned Days Remaining: ${stats.plannedDaysRemaining}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getWarningColor(stats.warningLevel).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getWarningColor(stats.warningLevel),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    stats.warningLevel.toUpperCase(),
                                    style: TextStyle(
                                      color: _getWarningColor(stats.warningLevel),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logs grouped by date
                  ...sortedDates.map((date) {
                    final dateLogs = groupedLogs[date]!;
                    final dateTime = DateTime.parse(date);
                    final isToday = DateFormat('yyyy-MM-dd')
                            .format(DateTime.now()) ==
                        date;
                    final isTomorrow = DateFormat('yyyy-MM-dd').format(
                            DateTime.now().add(const Duration(days: 1))) ==
                        date;

                    String dateLabel;
                    if (isToday) {
                      dateLabel = 'Today';
                    } else if (isTomorrow) {
                      dateLabel = 'Tomorrow';
                    } else {
                      dateLabel = DateFormat('EEEE, MMMM d').format(dateTime);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...dateLogs.map((log) => _buildLogCard(log)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
              ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getWarningColor(String warningLevel) {
    switch (warningLevel) {
      case 'critical':
        return Colors.red;
      case 'low':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _buildLogCard(MedicationLog log) {
    final logDate = DateTime.parse(log.timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDay = DateTime(logDate.year, logDate.month, logDate.day);

    final isOverdue = !log.isTaken && logDate.isBefore(now);
    final isFutureDate = logDay.isAfter(today); // Yarın veya daha sonra
    final canTake = !log.isTaken && !isFutureDate; // Bugün veya geçmiş

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (log.isTaken) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Taken';
    } else if (isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'Missed';
    } else if (isFutureDate) {
      statusColor = Colors.blue;
      statusIcon = Icons.schedule;
      statusText = 'Scheduled';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.schedule;
      statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.timeSlot.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${log.plannedDose} pill(s) - $statusText',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (canTake)
              ElevatedButton(
                onPressed: () => _markAsTaken(log.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Take'),
              )
            else if (isFutureDate)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: const Text(
                  'Future',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
