import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ride.dart';
import '../models/ride_quote.dart';
import '../models/route_info.dart';
import '../services/api_service.dart';

/// Repository for ride-related operations.
/// Manages ride lifecycle and caches current ride state.
class RideRepository {
  Ride? _currentRide;

  /// Get route information and price estimates for a ride.
  /// Returns a map with 'route' and 'quotes' keys.
  Future<Map<String, dynamic>> getRouteEstimate({
    required LatLng pickup,
    required LatLng destination,
  }) async {
    final data = await ApiService.getRouteAndPriceEstimate(
      pickup: pickup,
      destination: destination,
    );
    return {
      'route': data['route'] as RouteInfo,
      'quotes': data['quotes'] as List<RideQuote>,
    };
  }

  /// Request a new service (ride or delivery).
  Future<Ride> requestService({
    required String serviceType,
    required LatLng pickup,
    required LatLng destination,
    required String pickupAddress,
    required String destinationAddress,
    required String rideType,
    required double estimatedPrice,
    String? recipientName,
    String? recipientPhone,
    String? packageDetails,
    bool? isFragile,
  }) async {
    final ride = await ApiService.requestService(
      serviceType: serviceType,
      pickup: pickup,
      destination: destination,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      rideType: rideType,
      estimatedPrice: estimatedPrice,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      packageDetails: packageDetails,
      isFragile: isFragile,
    );
    _currentRide = ride;
    return ride;
  }

  /// Cancel an active ride.
  Future<void> cancelRide(String rideId) async {
    await ApiService.cancelRide(rideId);
    if (_currentRide?.id == rideId) {
      _currentRide = null;
    }
  }

  /// Get the current active ride for the user.
  Future<Ride?> getCurrentRide() async {
    _currentRide = await ApiService.getCurrentRide();
    return _currentRide;
  }

  /// Rate a completed ride.
  Future<void> rateRide(
    String rideId,
    int rating,
    String? comment,
  ) async {
    await ApiService.rateRide(rideId, rating, comment);
  }

  /// Get the cached current ride without making an API call.
  Ride? getCachedCurrentRide() => _currentRide;

  /// Update the cached current ride.
  void updateCachedRide(Ride ride) {
    _currentRide = ride;
  }

  /// Clear the cached current ride.
  void clearCachedRide() {
    _currentRide = null;
  }
}
