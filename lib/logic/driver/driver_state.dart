import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/ride.dart';
import '../../data/models/route_step.dart';

/// State for the driver screen.
class DriverState extends Equatable {
  final bool isOnline;
  final LatLng? currentLocation;
  final Ride? currentRide;
  final List<Ride> pendingRequests;
  final List<RouteStep>? routeSteps;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool isLoading;
  final bool locationPermissionGranted;
  final String? error;

  const DriverState({
    this.isOnline = false,
    this.currentLocation,
    this.currentRide,
    this.pendingRequests = const [],
    this.routeSteps,
    this.markers = const {},
    this.polylines = const {},
    this.isLoading = true,
    this.locationPermissionGranted = false,
    this.error,
  });

  DriverState copyWith({
    bool? isOnline,
    LatLng? currentLocation,
    Ride? currentRide,
    List<Ride>? pendingRequests,
    List<RouteStep>? routeSteps,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    bool? isLoading,
    bool? locationPermissionGranted,
    String? error,
    bool clearCurrentRide = false,
    bool clearError = false,
  }) {
    return DriverState(
      isOnline: isOnline ?? this.isOnline,
      currentLocation: currentLocation ?? this.currentLocation,
      currentRide: clearCurrentRide ? null : (currentRide ?? this.currentRide),
      pendingRequests: pendingRequests ?? this.pendingRequests,
      routeSteps: routeSteps ?? this.routeSteps,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      isLoading: isLoading ?? this.isLoading,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        currentLocation,
        currentRide,
        pendingRequests,
        routeSteps,
        markers,
        polylines,
        isLoading,
        locationPermissionGranted,
        error,
      ];
}
