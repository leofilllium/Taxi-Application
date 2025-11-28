import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/enums.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/driver.dart';
import '../../data/models/ride.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/services/websocket_service.dart';
import 'client_event.dart';
import 'client_state.dart';

/// Bloc for managing the entire client ride flow.
/// Handles location, WebSocket, map state, and ride lifecycle.
class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final LocationRepository _locationRepository;
  final RideRepository _rideRepository;
  final WebSocketService _wsService;

  StreamSubscription? _locationSubscription;
  StreamSubscription? _wsSubscription;
  Timer? _nearbyDriversTimer;
  Timer? _etaUpdateTimer;
  Timer? _waitTimeTimer;
  Timer? _tripDurationTimer;

  ClientBloc(
    this._locationRepository,
    this._rideRepository,
    this._wsService,
  ) : super(const ClientState()) {
    on<InitializeClient>(_onInitializeClient);
    on<SelectDestination>(_onSelectDestination);
    on<ConfirmPickupLocation>(_onConfirmPickupLocation);
    on<SelectServiceType>(_onSelectServiceType);
    on<SelectRideType>(_onSelectRideType);
    on<RequestRide>(_onRequestRide);
    on<CancelRide>(_onCancelRide);
    on<RideStatusChanged>(_onRideStatusChanged);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<UpdateNearbyDrivers>(_onUpdateNearbyDrivers);
    on<SubmitRating>(_onSubmitRating);
    on<ClearDestination>(_onClearDestination);
    on<FetchCurrentRide>(_onFetchCurrentRide);
  }

  Future<void> _onInitializeClient(
    InitializeClient event,
    Emitter<ClientState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load car icon
      final carIcon = await _loadCarIcon();
      
      // Check location permissions
      bool hasPermission = await _locationRepository.checkPermission();
      if (!hasPermission) {
        hasPermission = await _locationRepository.requestPermission();
      }

      if (!hasPermission) {
        emit(state.copyWith(
          isLoading: false,
          locationPermissionGranted: false,
          error: 'Location permission not granted',
        ));
        return;
      }

      // Get current location
      final position = await _locationRepository.getCurrentLocation();
      final location = _locationRepository.positionToLatLng(position);
      final address = await _locationRepository.getAddressFromPosition(location);

      // Connect WebSocket
      await _wsService.connect();
      _listenToWebSocket();

      // Check for current ride
      final currentRide = await _rideRepository.getCurrentRide();

      // Start location stream
      _startLocationStream();

      // Start fetching nearby drivers
      _startFetchingNearbyDrivers();

      // Update markers
      final markers = await _buildMarkers(
        currentLocation: location,
        carIcon: carIcon,
      );

      emit(state.copyWith(
        currentLocation: location,
        currentAddress: address,
        pickupLocation: location,
        pickupAddress: address,
        currentRide: currentRide,
        isLoading: false,
        locationPermissionGranted: true,
        carIcon: carIcon,
        markers: markers,
        rideFlowState: currentRide != null ? _getRideFlowStateFromRide(currentRide) : RideFlowState.idle,
      ));

      // Start timers if ride is active
      if (currentRide != null) {
        _startRideTimers(currentRide);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<BitmapDescriptor> _loadCarIcon() async {
    final ByteData data = await rootBundle.load('assets/images/car_icon.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 80,
      targetHeight: 80,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List resizedImageData = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(resizedImageData);
  }

  void _listenToWebSocket() {
    _wsSubscription = _wsService.messages.listen((message) {
      final type = message['type'];
      
      if (type == 'ride_update') {
        add(RideStatusChanged(message['ride']));
      } else if (type == 'driver_location') {
        add(UpdateDriverLocation(
          message['driverId'],
          LatLng(message['latitude'], message['longitude']),
          message['bearing'] ?? 0.0,
        ));
      }
    });
  }

  void _startLocationStream() {
    _locationSubscription = _locationRepository.getLocationStream().listen((position) {
      final location = _locationRepository.positionToLatLng(position);
     _locationRepository.getAddressFromPosition(location).then((address) {
        add(UpdateCurrentLocation(location, address));
      });
    });
  }

  void _startFetchingNearbyDrivers() {
    _nearbyDriversTimer?.cancel();
    _nearbyDriversTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // In a real app, you'd fetch from API
      // For now, we'll just keep the existing drivers
      // add(UpdateNearbyDrivers(drivers));
    });
  }

  void _startRideTimers(Ride ride) {
    if (ride.status == 'accepted') {
      _startETATimer();
    } else if (ride.status == 'driver_arrived') {
      _startWaitTimeTimer();
    } else if (ride.status == 'in_progress') {
      _startTripDurationTimer();
    }
  }

  void _startETATimer() {
    _etaUpdateTimer?.cancel();
    _etaUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.driverETA > 0) {
        emit(state.copyWith(driverETA: state.driverETA - 1));
      }
    });
  }

  void _startWaitTimeTimer() {
    _waitTimeTimer?.cancel();
    _waitTimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.freeWaitTimeSeconds > 0) {
        emit(state.copyWith(freeWaitTimeSeconds: state.freeWaitTimeSeconds - 1));
      }
    });
  }

  void _startTripDurationTimer() {
    _tripDurationTimer?.cancel();
    _tripDurationTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      emit(state.copyWith(remainingTripMinutes: state.remainingTripMinutes - 1));
    });
  }

  Future<void> _onSelectDestination(
    SelectDestination event,
    Emitter<ClientState> emit,
  ) async {
    try {
      // Get route and quotes
      final estimateData = await _rideRepository.getRouteEstimate(
        pickup: state.pickupLocation!,
        destination: event.destination,
      );

      final routeInfo = estimateData['route'];
      final quotes = estimateData['quotes'];

      // Build polyline
      final polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: routeInfo.polylinePoints,
          color: AppColors.routeBlue,
          width: 4,
        ),
      };

      // Update markers
      final markers = await _buildMarkers(
        currentLocation: state.currentLocation,
        pickupLocation: state.pickupLocation,
        destination: event.destination,
        carIcon: state.carIcon,
      );

      emit(state.copyWith(
        destination: event.destination,
        destinationAddress: event.destinationAddress,
        routeInfo: routeInfo,
        quotes: quotes,
        polylines: polylines,
        markers: markers,
        rideFlowState: RideFlowState.confirmingDetails,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onConfirmPickupLocation(
    ConfirmPickupLocation event,
    Emitter<ClientState> emit,
  ) async {
    emit(state.copyWith(
      pickupLocation: event.pickupLocation,
      pickupAddress: event.pickupAddress,
    ));
  }

  Future<void> _onSelectServiceType(
    SelectServiceType event,
    Emitter<ClientState> emit,
  ) async {
    final serviceType = event.serviceType == 'ride' ? ServiceType.ride : ServiceType.delivery;
    emit(state.copyWith(serviceType: serviceType));
  }

  Future<void> _onSelectRideType(
    SelectRideType event,
    Emitter<ClientState> emit,
  ) async {
    emit(state.copyWith(
      selectedRideType: event.rideType,
      selectedPrice: event.price,
    ));
  }

  Future<void> _onRequestRide(
    RequestRide event,
    Emitter<ClientState> emit,
  ) async {
    try {
      emit(state.copyWith(rideFlowState: RideFlowState.searching));

      final ride = await _rideRepository.requestService(
        serviceType: state.serviceType == ServiceType.ride ? 'ride' : 'delivery',
        pickup: state.pickupLocation!,
        destination: state.destination!,
        pickupAddress: state.pickupAddress,
        destinationAddress: state.destinationAddress,
        rideType: state.selectedRideType!,
        estimatedPrice: state.selectedPrice!,
        recipientName: event.recipientName,
        recipientPhone: event.recipientPhone,
        packageDetails: event.packageDetails,
        isFragile: event.isFragile,
      );

      emit(state.copyWith(
        currentRide: ride,
        rideFlowState: RideFlowState.searching,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        rideFlowState: RideFlowState.confirmingDetails,
      ));
    }
  }

  Future<void> _onCancelRide(
    CancelRide event,
    Emitter<ClientState> emit,
  ) async {
    try {
      if (state.currentRide != null) {
        await _rideRepository.cancelRide(state.currentRide!.id);
        
        _stopAllTimers();

        emit(state.copyWith(
          currentRide: null,
          rideFlowState: RideFlowState.idle,
          clearDestination: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRideStatusChanged(
    RideStatusChanged event,
    Emitter<ClientState> emit,
  ) async {
    final updatedRide = Ride.fromJson(event.rideData);
    
    // Stop previous timers
    _stopAllTimers();

    // Start appropriate timer based on new status
    _startRideTimers(updatedRide);

    // Update markers if driver info changed
    Set<Marker> markers = state.markers;
    if (updatedRide.assignedDriver != null) {
      markers = await _buildMarkers(
        currentLocation: state.currentLocation,
        pickupLocation: state.pickupLocation,
        destination: state.destination,
        driverLocation: updatedRide.driverLocation,
        carIcon: state.carIcon,
      );
    }

    emit(state.copyWith(
      currentRide: updatedRide,
      rideFlowState: _getRideFlowStateFromRide(updatedRide),
      markers: markers,
    ));
  }

  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<ClientState> emit,
  ) async {
    if (state.currentRide?.assignedDriver?.id == event.driverId) {
      // Update driver bearings map
      final bearings = Map<String, double>.from(state.driverBearings);
      bearings[event.driverId] = event.bearing;

      // Update markers
      final markers = await _buildMarkers(
        currentLocation: state.currentLocation,
        pickupLocation: state.pickupLocation,
        destination: state.destination,
        driverLocation: event.location,
        bearing: event.bearing,
        carIcon: state.carIcon,
      );

      emit(state.copyWith(
        markers: markers,
        driverBearings: bearings,
      ));
    }
  }

  Future<void> _onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<ClientState> emit,
  ) async {
    emit(state.copyWith(
      currentLocation: event.location,
      currentAddress: event.address,
    ));

    // Update pickup if still idle
    if (state.rideFlowState == RideFlowState.idle) {
      emit(state.copyWith(
        pickupLocation: event.location,
        pickupAddress: event.address,
      ));
    }
  }

  Future<void> _onUpdateNearbyDrivers(
    UpdateNearbyDrivers event,
    Emitter<ClientState> emit,
  ) async {
    final markers = await _buildMarkers(
      currentLocation: state.currentLocation,
      pickupLocation: state.pickupLocation,
      destination: state.destination,
      nearbyDrivers: event.drivers,
      carIcon: state.carIcon,
    );

    emit(state.copyWith(
      nearbyDrivers: event.drivers,
      markers: markers,
    ));
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<ClientState> emit,
  ) async {
    try {
      if (state.currentRide != null) {
        await _rideRepository.rateRide(
          state.currentRide!.id,
          event.rating,
          event.comment,
        );

        emit(state.copyWith(
          currentRide: null,
          rideFlowState: RideFlowState.idle,
          clearDestination: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onClearDestination(
    ClearDestination event,
    Emitter<ClientState> emit,
  ) async {
    final markers = await _buildMarkers(
      currentLocation: state.currentLocation,
      carIcon: state.carIcon,
    );

    emit(state.copyWith(
      clearDestination: true,
      rideFlowState: RideFlowState.idle,
      polylines: const {},
      markers: markers,
    ));
  }

  Future<void> _onFetchCurrentRide(
    FetchCurrentRide event,
    Emitter<ClientState> emit,
  ) async {
    try {
      final ride = await _rideRepository.getCurrentRide();
      if (ride != null) {
        emit(state.copyWith(
          currentRide: ride,
          rideFlowState: _getRideFlowStateFromRide(ride),
        ));
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }

  Future<Set<Marker>> _buildMarkers({
    LatLng? currentLocation,
    LatLng? pickupLocation,
    LatLng? destination,
    LatLng? driverLocation,
    double bearing = 0,
    List<Driver>? nearbyDrivers,
    BitmapDescriptor? carIcon,
  }) async {
    final markers = <Marker>{};

    // Current location marker
    if (currentLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    // Pickup marker
    if (pickupLocation != null && pickupLocation != currentLocation) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ));
    }

    // Destination marker
    if (destination != null) {
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ));
    }

    // Driver marker
    if (driverLocation != null && carIcon != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation,
        icon: carIcon,
        rotation: bearing + 90, // Car image offset
        anchor: const Offset(0.5, 0.5),
      ));
    }

    // Nearby drivers
    if (nearbyDrivers != null && carIcon != null) {
      for (final driver in nearbyDrivers) {
        markers.add(Marker(
          markerId: MarkerId('driver_${driver.id}'),
          position: driver.location,
          icon: carIcon,
          rotation: driver.bearing + 90,
          anchor: const Offset(0.5, 0.5),
        ));
      }
    }

    return markers;
  }

  RideFlowState _getRideFlowStateFromRide(Ride ride) {
    switch (ride.status) {
      case 'pending':
        return RideFlowState.searching;
      case 'accepted':
        return RideFlowState.driverArriving;
      case 'driver_arrived':
        return RideFlowState.driverArrived;
      case 'in_progress':
        return RideFlowState.inProgress;
      default:
        return RideFlowState.idle;
    }
  }

  void _stopAllTimers() {
    _etaUpdateTimer?.cancel();
    _waitTimeTimer?.cancel();
    _tripDurationTimer?.cancel();
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _wsSubscription?.cancel();
    _nearbyDriversTimer?.cancel();
    _stopAllTimers();
    return super.close();
  }
}
