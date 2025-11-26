import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/ride.dart';

/// Base class for all driver events.
abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the driver (location, WebSocket, current ride check).
class InitializeDriver extends DriverEvent {
  const InitializeDriver();
}

/// Driver toggle online/offline status.
class ToggleOnlineStatus extends DriverEvent {
  final bool isOnline;

  const ToggleOnlineStatus(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

/// Driver received a new ride request.
class NewRideRequest extends DriverEvent {
  final Ride ride;

  const NewRideRequest(this.ride);

  @override
  List<Object?> get props => [ride];
}

/// Driver accepted a ride request.
class AcceptRide extends DriverEvent {
  final String rideId;

  const AcceptRide(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

/// Driver rejected a ride request.
class RejectRide extends DriverEvent {
  final String rideId;

  const RejectRide(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

/// Driver arrived at pickup location.
class DriverArrived extends DriverEvent {
  final String rideId;

  const DriverArrived(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

/// Driver started the ride.
class StartRide extends DriverEvent {
  final String rideId;

  const StartRide(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

/// Driver completed the ride.
class CompleteRide extends DriverEvent {
  final String rideId;

  const CompleteRide(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

/// Update driver's current location.
class UpdateDriverLocation extends DriverEvent {
  final LatLng location;
  final double bearing;

  const UpdateDriverLocation(this.location, this.bearing);

  @override
  List<Object?> get props => [location, bearing];
}

/// Received ride status update via WebSocket.
class DriverRideStatusChanged extends DriverEvent {
  final Map<String, dynamic> rideData;

  const DriverRideStatusChanged(this.rideData);

  @override
  List<Object?> get props => [rideData];
}

/// Fetch current ride on init.
class FetchDriverCurrentRide extends DriverEvent {
  const FetchDriverCurrentRide();
}
