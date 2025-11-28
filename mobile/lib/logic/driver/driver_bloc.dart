import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/ride.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/websocket_service.dart';
import 'driver_event.dart';
import 'driver_state.dart';

/// Bloc for managing driver functionality.
/// Handles online status, location updates, ride requests, and navigation.
class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final LocationRepository _locationRepository;
  final RideRepository _rideRepository;
  final WebSocketService _wsService;

  StreamSubscription? _locationSubscription;
  StreamSubscription? _wsSubscription;

  DriverBloc(
    this._locationRepository,
    this._rideRepository,
    this._wsService,
  ) : super(const DriverState()) {
    on<InitializeDriver>(_onInitializeDriver);
    on<ToggleOnlineStatus>(_onToggleOnlineStatus);
    on<NewRideRequest>(_onNewRideRequest);
    on<AcceptRide>(_onAcceptRide);
    on<RejectRide>(_onRejectRide);
    on<DriverArrived>(_onDriverArrived);
    on<StartRide>(_onStartRide);
    on<CompleteRide>(_onCompleteRide);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
    on<DriverRideStatusChanged>(_onDriverRideStatusChanged);
    on<FetchDriverCurrentRide>(_onFetchDriverCurrentRide);
  }

  Future<void> _onInitializeDriver(
    InitializeDriver event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
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

      // Connect WebSocket
      await _wsService.connect();
      _listenToWebSocket();

      // Check for current ride
      final currentRide = await _rideRepository.getCurrentRide();

      // Start location stream
      _startLocationStream();

      emit(state.copyWith(
        currentLocation: location,
        currentRide: currentRide,
        isLoading: false,
        locationPermissionGranted: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _listenToWebSocket() {
    _wsSubscription = _wsService.messages.listen((message) {
      final type = message['type'];
      
      if (type == 'new_ride_request') {
        final ride = Ride.fromJson(message['ride']);
        add(NewRideRequest(ride));
      } else if (type == 'ride_update') {
        add(DriverRideStatusChanged(message['ride']));
      }
    });
  }

  void _startLocationStream() {
    _locationSubscription = _locationRepository.getLocationStream().listen((position) {
      final location = _locationRepository.positionToLatLng(position);
      // Calculate bearing if needed
      add(UpdateDriverLocation(location, 0)); // TODO: Calculate bearing
    });
  }

  Future<void> _onToggleOnlineStatus(
    ToggleOnlineStatus event,
    Emitter<DriverState> emit,
  ) async {
    try {
      // Send to backend
      await ApiService.post('/driver/online-status', {
        'isOnline': event.isOnline,
      });

      // Update WebSocket service
      _wsService.setDriverOnlineStatus(event.isOnline);

      emit(state.copyWith(isOnline: event.isOnline));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onNewRideRequest(
    NewRideRequest event,
    Emitter<DriverState> emit,
  ) async {
    final requests = List<Ride>.from(state.pendingRequests)..add(event.ride);
    emit(state.copyWith(pendingRequests: requests));
  }

  Future<void> _onAcceptRide(
    AcceptRide event,
    Emitter<DriverState> emit,
  ) async {
    try {
      await ApiService.post('/rides/${event.rideId}/accept', {});
      
      // Remove from pending
      final requests = state.pendingRequests
          .where((r) => r.id != event.rideId)
          .toList();

      // Fetch updated ride details
      final ride = await _rideRepository.getCurrentRide();

      emit(state.copyWith(
        pendingRequests: requests,
        currentRide: ride,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRejectRide(
    RejectRide event,
    Emitter<DriverState> emit,
  ) async {
    try {
      await ApiService.post('/rides/${event.rideId}/reject', {});
      
      final requests = state.pendingRequests
          .where((r) => r.id != event.rideId)
          .toList();

      emit(state.copyWith(pendingRequests: requests));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDriverArrived(
    DriverArrived event,
    Emitter<DriverState> emit,
  ) async {
    try {
      await ApiService.post('/rides/${event.rideId}/arrived', {});
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onStartRide(
    StartRide event,
    Emitter<DriverState> emit,
  ) async {
    try {
      await ApiService.post('/rides/${event.rideId}/start', {});
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCompleteRide(
    CompleteRide event,
    Emitter<DriverState> emit,
  ) async {
    try {
      await ApiService.post('/rides/${event.rideId}/complete', {});
      emit(state.copyWith(clearCurrentRide: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(currentLocation: event.location));
    
    // Send to WebSocket if online
    if (state.isOnline) {
      _wsService.sendMessage({
        'type': 'location_update',
        'latitude': event.location.latitude,
        'longitude': event.location.longitude,
        'bearing': event.bearing,
      });
    }
  }

  Future<void> _onDriverRideStatusChanged(
    DriverRideStatusChanged event,
    Emitter<DriverState> emit,
  ) async {
    final updatedRide = Ride.fromJson(event.rideData);
    emit(state.copyWith(currentRide: updatedRide));
  }

  Future<void> _onFetchDriverCurrentRide(
    FetchDriverCurrentRide event,
    Emitter<DriverState> emit,
  ) async {
    try {
      final ride = await _rideRepository.getCurrentRide();
      if (ride != null) {
        emit(state.copyWith(currentRide: ride));
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _wsSubscription?.cancel();
    _wsService.setDriverOnlineStatus(false);
    return super.close();
  }
}
