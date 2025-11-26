import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';

/// Repository for location-related operations.
/// Wraps Geolocator functionality and handles permissions.
class LocationRepository {
  /// Get the current device location.
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get a stream of location updates.
  /// Updates are emitted when the device moves at least [distanceFilter] meters.
  Stream<Position> getLocationStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Check if location permissions are granted.
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions.
  /// Returns true if granted, false otherwise.
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Check if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get a human-readable address from coordinates using reverse geocoding.
  Future<String> getAddressFromPosition(LatLng position) async {
    return await ApiService.getAddressFromLatLng(position);
  }

  /// Convert Position to LatLng.
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}
