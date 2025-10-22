import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/medication_provider.dart';
import '../data/models/user_medication.dart';
import '../core/notification_service.dart';
import 'medications_screen.dart';
import 'medication_logs_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final medProvider =
        Provider.of<MedicationProvider>(context, listen: false);
    await medProvider.loadActiveUserMedications();
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final medProvider =
        Provider.of<MedicationProvider>(context, listen: false);

    await authProvider.logout();
    medProvider.clear();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final medProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DoseLog'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'test_now') {
                final notificationService = NotificationService();
                await notificationService.showImmediateNotification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Immediate notification sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else if (value == 'test_10s') {
                final notificationService = NotificationService();
                await notificationService.testNotification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⏰ Notification in 10 seconds!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test_now',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Test Notification (Now)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_10s',
                child: Row(
                  children: [
                    Icon(Icons.alarm, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Test Notification (10s)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: medProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : medProvider.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          medProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : medProvider.activeUserMedications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.medication_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No active medications',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start tracking your medications',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MedicationsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Medication'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Welcome message
                          Text(
                            'Welcome, ${authProvider.user?.email ?? "User"}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Active medications header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Active Medications',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const MedicationsScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Active medications list
                          ...medProvider.activeUserMedications
                              .map((userMed) => _buildMedicationCard(userMed)),
                        ],
                      ),
      ),
    );
  }

  String _formatDate(String label, String dateStr) {
    try {
      if (dateStr.isEmpty) return '$label: N/A';
      final date = DateTime.parse(dateStr);
      return '$label: ${DateFormat('MMM d, y').format(date)}';
    } catch (e) {
      return '$label: N/A';
    }
  }

  Widget _buildMedicationCard(UserMedication userMed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MedicationLogsScreen(userMedication: userMed),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userMed.medication?.name ?? 'Unknown Medication',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${userMed.medication?.strengthMg ?? 0}mg ${userMed.medication?.form ?? ''} - ${userMed.medication?.mealRelation ?? ''}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (userMed.boxesOwned > 0)
                        Text(
                          'Boxes: ${userMed.boxesOwned}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (userMed.schedules.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Schedule:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: userMed.schedules.map((schedule) {
                  return Chip(
                    label: Text('${schedule.timeSlot}: ${schedule.doseAmount} pill(s)'),
                    backgroundColor: Colors.blue.shade50,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatDate('Started', userMed.startAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.event, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Duration: ${userMed.durationDays} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}
