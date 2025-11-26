import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/config/enums.dart';
import '../../data/models/driver.dart';
import '../../data/models/ride.dart';
import '../../data/models/ride_quote.dart';
import '../../data/models/route_info.dart';

/// State for the client screen.
class ClientState extends Equatable {
  final RideFlowState rideFlowState;
  final LatLng? currentLocation;
  final String currentAddress;
  final LatLng? pickupLocation;
  final String pickupAddress;
  final LatLng? destination;
  final String destinationAddress;
  final RouteInfo? routeInfo;
  final List<RideQuote> quotes;
  final List<RideQuote> rideQuotes; // Alias for quotes
  final String? selectedRideType;
  final RideQuote? selectedQuote;
  final double? selectedPrice;
  final Ride? currentRide;
  final List<Driver> nearbyDrivers;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final ServiceType serviceType;
  final ServiceType selectedServiceType; // Alias for serviceType
  final bool hasRated;
  final bool isLoading;
  final bool locationPermissionGranted;
  final String? error;
  final int driverETA;
  final int freeWaitTimeSeconds;
  final int remainingTripMinutes;
  final Map<String, double> driverBearings;
  final BitmapDescriptor? carIcon;

  const ClientState({
    this.rideFlowState = RideFlowState.idle,
    this.currentLocation,
    this.currentAddress = '',
    this.pickupLocation,
    this.pickupAddress = '',
    this.destination,
    this.destinationAddress = '',
    this.routeInfo,
    this.quotes = const [],
    List<RideQuote>? rideQuotes,
    this.selectedRideType,
    this.selectedQuote,
    this.selectedPrice,
    this.currentRide,
    this.nearbyDrivers = const [],
    this.markers = const {},
    this.polylines = const {},
    this.serviceType = ServiceType.ride,
    ServiceType? selectedServiceType,
    this.hasRated =false,
    this.isLoading = true,
    this.locationPermissionGranted = false,
    this.error,
    this.driverETA = 0,
    this.freeWaitTimeSeconds = 120,
    this.remainingTripMinutes = 0,
    this.driverBearings = const {},
    this.carIcon,
  })  : rideQuotes = rideQuotes ?? quotes,
        selectedServiceType = selectedServiceType ?? serviceType;

  ClientState copyWith({
    RideFlowState? rideFlowState,
    LatLng? currentLocation,
    String? currentAddress,
    LatLng? pickupLocation,
    String? pickupAddress,
    LatLng? destination,
    String? destinationAddress,
    RouteInfo? routeInfo,
    List<RideQuote>? quotes,
    String? selectedRideType,
    double? selectedPrice,
    Ride? currentRide,
    List<Driver>? nearbyDrivers,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    ServiceType? serviceType,
    bool? isLoading,
    bool? locationPermissionGranted,
    String? error,
    int? driverETA,
    int? freeWaitTimeSeconds,
    int? remainingTripMinutes,
    Map<String, double>? driverBearings,
    BitmapDescriptor? carIcon,
    bool clearDestination = false,
    bool clearError = false,
  }) {
    return ClientState(
      rideFlowState: rideFlowState ?? this.rideFlowState,
      currentLocation: currentLocation ?? this.currentLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destination: clearDestination ? null : (destination ?? this.destination),
      destinationAddress: clearDestination ? '' : (destinationAddress ?? this.destinationAddress),
      routeInfo: routeInfo ?? this.routeInfo,
      quotes: quotes ?? this.quotes,
      selectedRideType: selectedRideType ?? this.selectedRideType,
      selectedPrice: selectedPrice ?? this.selectedPrice,
      currentRide: currentRide ?? this.currentRide,
      nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      serviceType: serviceType ?? this.serviceType,
      isLoading: isLoading ?? this.isLoading,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      error: clearError ? null : (error ?? this.error),
      driverETA: driverETA ?? this.driverETA,
      freeWaitTimeSeconds: freeWaitTimeSeconds ?? this.freeWaitTimeSeconds,
      remainingTripMinutes: remainingTripMinutes ?? this.remainingTripMinutes,
      driverBearings: driverBearings ?? this.driverBearings,
      carIcon: carIcon ?? this.carIcon,
    );
  }

  @override
  List<Object?> get props => [
        rideFlowState,
        currentLocation,
        currentAddress,
        pickupLocation,
        pickupAddress,
        destination,
        destinationAddress,
        routeInfo,
        quotes,
        selectedRideType,
        selectedPrice,
        currentRide,
        nearbyDrivers,
        markers,
        polylines,
        serviceType,
        isLoading,
        locationPermissionGranted,
        error,
        driverETA,
        freeWaitTimeSeconds,
        remainingTripMinutes,
        driverBearings,
        carIcon,
      ];
}
