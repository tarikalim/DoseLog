import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../models/medication.dart';
import '../models/user_medication.dart';
import '../models/medication_log.dart';

class MedicationService {
  final ApiClient _apiClient = ApiClient();

  // Get all medications
  Future<List<Medication>> getMedications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConstants.medicationsEndpoint,
        queryParams: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      if (response is List) {
        return response.map((json) => Medication.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to load medications: ${e.toString()}');
    }
  }

  // Get medication by ID
  Future<Medication> getMedicationById(String id) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.medicationsEndpoint}/$id',
      );
      return Medication.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to load medication: ${e.toString()}');
    }
  }

  // Create medication
  Future<Medication> createMedication(MedicationCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        AppConstants.medicationsEndpoint,
        body: request.toJson(),
      );
      return Medication.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to create medication: ${e.toString()}');
    }
  }

  // Update medication (if needed in the future)
  // Future<Medication> updateMedication(...) async { ... }

  // Get user medications
  Future<List<UserMedication>> getUserMedications() async {
    try {
      final response = await _apiClient.get(
        AppConstants.userMedicationsEndpoint,
      );

      if (response is List) {
        return response.map((json) => UserMedication.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to load user medications: ${e.toString()}');
    }
  }

  // Get active user medications
  Future<List<UserMedication>> getActiveUserMedications() async {
    try {
      final response = await _apiClient.get(
        AppConstants.activeUserMedicationsEndpoint,
      );

      if (response is List) {
        final userMeds = response.map((json) => UserMedication.fromJson(json)).toList();

        // Fetch medication details for each user medication
        for (int i = 0; i < userMeds.length; i++) {
          try {
            final medication = await getMedicationById(userMeds[i].medicationId);
            userMeds[i] = UserMedication(
              id: userMeds[i].id,
              userId: userMeds[i].userId,
              medicationId: userMeds[i].medicationId,
              boxesOwned: userMeds[i].boxesOwned,
              schedules: userMeds[i].schedules,
              durationDays: userMeds[i].durationDays,
              startAt: userMeds[i].startAt,
              active: userMeds[i].active,
              createdAt: userMeds[i].createdAt,
              medication: medication,
            );
          } catch (e) {
            // Continue if medication fetch fails
          }
        }

        return userMeds;
      }
      return [];
    } catch (e) {
      throw ApiException(
          'Failed to load active user medications: ${e.toString()}');
    }
  }

  // Create user medication tracking
  Future<UserMedication> createUserMedication(
    UserMedicationCreateRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        AppConstants.userMedicationsEndpoint,
        body: request.toJson(),
      );
      return UserMedication.fromJson(response);
    } catch (e) {
      throw ApiException(
          'Failed to create medication tracking: ${e.toString()}');
    }
  }

  // Update user medication (if needed in the future)
  // Future<UserMedication> updateUserMedication(...) async { ... }

  // Get medication logs for a user medication
  Future<List<MedicationLog>> getMedicationLogs(String userMedicationId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.medicationLogsEndpoint}/user-medication/$userMedicationId',
      );

      if (response is List) {
        return response.map((json) => MedicationLog.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to load medication logs: ${e.toString()}');
    }
  }

  // Mark medication log as taken
  Future<void> markAsTaken(String logId) async {
    try {
      await _apiClient.put(
        '${AppConstants.medicationLogsEndpoint}/$logId/mark-taken',
      );
    } catch (e) {
      throw ApiException('Failed to mark as taken: ${e.toString()}');
    }
  }

  // Get user medication stats
  Future<UserMedicationStats> getUserMedicationStats(
      String userMedicationId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.userMedicationsEndpoint}/$userMedicationId/stats',
      );
      return UserMedicationStats.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to load stats: ${e.toString()}');
    }
  }
}
