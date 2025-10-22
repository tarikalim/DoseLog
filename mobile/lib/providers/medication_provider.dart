import 'package:flutter/material.dart';
import '../data/models/medication.dart';
import '../data/models/user_medication.dart';
import '../data/models/medication_log.dart';
import '../data/services/medication_service.dart';
import '../core/api_client.dart';
import '../core/notification_service.dart';

class MedicationProvider with ChangeNotifier {
  final MedicationService _medicationService = MedicationService();
  final NotificationService _notificationService = NotificationService();

  List<Medication> _medications = [];
  List<UserMedication> _userMedications = [];
  List<UserMedication> _activeUserMedications = [];
  Map<String, List<MedicationLog>> _medicationLogs = {};
  Map<String, UserMedicationStats> _stats = {};

  bool _isLoading = false;
  String? _errorMessage;

  List<Medication> get medications => _medications;
  List<UserMedication> get userMedications => _userMedications;
  List<UserMedication> get activeUserMedications => _activeUserMedications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get medication logs for a specific user medication
  List<MedicationLog> getMedicationLogs(String userMedicationId) {
    return _medicationLogs[userMedicationId] ?? [];
  }

  // Get stats for a specific user medication
  UserMedicationStats? getStats(String userMedicationId) {
    return _stats[userMedicationId];
  }

  // Load all medications
  Future<void> loadMedications({int limit = 100, int offset = 0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _medications = await _medicationService.getMedications(
        limit: limit,
        offset: offset,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load medications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user medications
  Future<void> loadUserMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userMedications = await _medicationService.getUserMedications();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load your medications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load active user medications
  Future<void> loadActiveUserMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeUserMedications =
          await _medicationService.getActiveUserMedications();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load active medications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create medication
  Future<bool> createMedication(MedicationCreateRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final medication = await _medicationService.createMedication(request);
      _medications.add(medication);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create medication';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create user medication tracking
  Future<bool> createUserMedication(
      UserMedicationCreateRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Request notification permission if this is the first medication
      if (_userMedications.isEmpty) {
        await _notificationService.requestPermissions();
      }

      final userMedication =
          await _medicationService.createUserMedication(request);
      _userMedications.add(userMedication);
      if (userMedication.active) {
        _activeUserMedications.add(userMedication);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to start tracking medication';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load medication logs for a user medication
  Future<void> loadMedicationLogs(String userMedicationId) async {
    try {
      final logs = await _medicationService.getMedicationLogs(userMedicationId);
      _medicationLogs[userMedicationId] = logs;

      // Schedule notifications for pending doses
      final userMed = _activeUserMedications.firstWhere(
        (um) => um.id == userMedicationId,
        orElse: () => _userMedications.firstWhere((um) => um.id == userMedicationId),
      );
      await _notificationService.scheduleMedicationDoses(userMed, logs);

      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  // Mark medication as taken
  Future<bool> markAsTaken(String logId, String userMedicationId) async {
    try {
      await _medicationService.markAsTaken(logId);
      // Reload logs to get updated status
      await loadMedicationLogs(userMedicationId);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to mark as taken';
      notifyListeners();
      return false;
    }
  }

  // Load stats for a user medication
  Future<void> loadStats(String userMedicationId) async {
    try {
      final stats =
          await _medicationService.getUserMedicationStats(userMedicationId);
      _stats[userMedicationId] = stats;

      // If critical level, schedule daily reminders
      if (stats.warningLevel == 'critical') {
        final userMed = _activeUserMedications.firstWhere(
          (um) => um.id == userMedicationId,
          orElse: () => _userMedications.firstWhere((um) => um.id == userMedicationId),
        );
        final medicationName = userMed.medication?.name ?? 'Medication';
        await _notificationService.scheduleCriticalReminders(medicationName);
      } else {
        // Cancel critical reminders if no longer critical
        await _notificationService.cancelCriticalReminders();
      }

      notifyListeners();
    } catch (e) {
      // Silently fail for stats
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data (for logout)
  void clear() {
    _medications = [];
    _userMedications = [];
    _activeUserMedications = [];
    _medicationLogs = {};
    _stats = {};
    _errorMessage = null;
    // Cancel all notifications on logout
    _notificationService.cancelAllNotifications();
    notifyListeners();
  }
}
