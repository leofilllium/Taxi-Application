import 'package:equatable/equatable.dart';
import '../../data/models/ride.dart';

/// Base class for ride history states.
abstract class RideHistoryState extends Equatable {
  const RideHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before history is loaded.
class RideHistoryInitial extends RideHistoryState {
  const RideHistoryInitial();
}

/// Loading ride history.
class RideHistoryLoading extends RideHistoryState {
  const RideHistoryLoading();
}

/// Ride history successfully loaded.
class RideHistoryLoaded extends RideHistoryState {
  final List<Ride> rides;

  const RideHistoryLoaded(this.rides);

  @override
  List<Object?> get props => [rides];
}

/// Error loading ride history.
class RideHistoryError extends RideHistoryState {
  final String message;

  const RideHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Refreshing ride history.
class RideHistoryRefreshing extends RideHistoryState {
  final List<Ride> rides; // Keep showing current data while refreshing

  const RideHistoryRefreshing(this.rides);

  @override
  List<Object?> get props => [rides];
}
