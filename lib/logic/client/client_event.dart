import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/config/enums.dart';
import '../../data/models/driver.dart';
import '../../data/models/ride_quote.dart';

/// Base class for all client events.
abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the client (location, WebSocket, current ride check).
class InitializeClient extends ClientEvent {
  const InitializeClient();
}

/// Open destination search
class OpenDestinationSearch extends ClientEvent {
  const OpenDestinationSearch();
}

/// User selected a destination.
class SelectDestination extends ClientEvent {
  final LatLng destination;
  final String destinationAddress;

  const SelectDestination(this.destination, this.destinationAddress);

  @override
  List<Object?> get props => [destination, destinationAddress];
}

/// User confirmed pickup location (different from current location).
class ConfirmPickupLocation extends ClientEvent {
  final LatLng pickupLocation;
  final String pickupAddress;

  const ConfirmPickupLocation(this.pickupLocation, this.pickupAddress);

  @override
  List<Object?> get props => [pickupLocation, pickupAddress];
}

/// User changed service type (ride/delivery).
class SelectServiceType extends ClientEvent {
  final ServiceType serviceType;

  const SelectServiceType(this.serviceType);

  @override
  List<Object?> get props => [serviceType];
}

/// User selected a ride quote.
class SelectQuote extends ClientEvent {
  final RideQuote quote;

  const SelectQuote(this.quote);

  @override
  List<Object?> get props => [quote];
}

/// User selected a ride type/quote.
class SelectRideType extends ClientEvent {
  final String rideType;
  final double price;

  const SelectRideType(this.rideType, this.price);

  @override
  List<Object?> get props => [rideType, price];
}

/// Confirm ride request
class ConfirmRideRequest extends ClientEvent {
  const ConfirmRideRequest();
}

/// User requested a ride.
class RequestRide extends ClientEvent {
  final String? recipientName;
  final String? recipientPhone;
  final String? packageDetails;
  final bool? isFragile;

  const RequestRide({
    this.recipientName,
    this.recipientPhone,
    this.packageDetails,
    this.isFragile,
  });

  @override
  List<Object?> get props => [recipientName, recipientPhone, packageDetails, isFragile];
}

/// Cancel ride request
class CancelRideRequest extends ClientEvent {
  const CancelRideRequest();
}

/// User cancelled the current ride.
class CancelRide extends ClientEvent {
  const CancelRide();
}

/// Mark ride as rated
class MarkAsRated extends ClientEvent {
  const MarkAsRated();
}

/// Received ride status update via WebSocket.
class RideStatusChanged extends ClientEvent {
  final Map<String, dynamic> rideData;

  const RideStatusChanged(this.rideData);

  @override
  List<Object?> get props => [rideData];
}

/// Received driver location update via WebSocket.
class UpdateDriverLocation extends ClientEvent {
  final String driverId;
  final LatLng location;
  final double bearing;

  const UpdateDriverLocation(this.driverId, this.location, this.bearing);

  @override
  List<Object?> get props => [driverId, location, bearing];
}

/// Update user's current location.
class UpdateCurrentLocation extends ClientEvent {
  final LatLng location;
  final String address;

  const UpdateCurrentLocation(this.location, this.address);

  @override
  List<Object?> get props => [location, address];
}

/// Update nearby drivers list.
class UpdateNearbyDrivers extends ClientEvent {
  final List<Driver> drivers;

  const UpdateNearbyDrivers(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

/// User submitted rating for completed ride.
class SubmitRating extends ClientEvent {
  final int rating;
  final String? comment;

  const SubmitRating(this.rating, this.comment);

  @override
  List<Object?> get props => [rating, comment];
}

/// Clear destination and return to idle.
class ClearDestination extends ClientEvent {
  const ClearDestination();
}

/// Fetch current ride on init.
class FetchCurrentRide extends ClientEvent {
  const FetchCurrentRide();
}
