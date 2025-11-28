import 'package:image_picker/image_picker.dart';
import '../models/ride.dart';
import '../services/api_service.dart';

/// Repository for user profile operations.
class UserRepository {
  /// Get the current user's profile data.
  Future<Map<String, dynamic>> getProfile() async {
    final data = await ApiService.getProfile();
    return data;
  }

  /// Update user profile with new field values and optional profile image.
  /// Returns updated profile data on success.
  Future<Map<String, dynamic>> updateProfile(
    Map<String, String> fields,
    XFile? image,
  ) async {
    final data = await ApiService.putMultipart('/profile', fields, image);
    return data['profile'];
  }

  /// Delete the user's account permanently.
  Future<void> deleteAccount() async {
    await ApiService.deleteAccount();
  }

  /// Get the user's ride history.
  Future<List<Ride>> getRideHistory() async {
    final data = await ApiService.get('/rides/history');
    final ridesJson = data['rides'] as List;
    return ridesJson.map((json) => Ride.fromJson(json)).toList();
  }
}
