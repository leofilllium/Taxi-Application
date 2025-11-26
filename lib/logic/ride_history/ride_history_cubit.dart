import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'ride_history_state.dart';

/// Cubit for managing ride history.
class RideHistoryCubit extends Cubit<RideHistoryState> {
  final UserRepository _userRepository;

  RideHistoryCubit(this._userRepository) : super(const RideHistoryInitial());

  /// Load the user's ride history.
  Future<void> loadHistory() async {
    emit(const RideHistoryLoading());
    try {
      final rides = await _userRepository.getRideHistory();
      emit(RideHistoryLoaded(rides));
    } catch (e) {
      emit(RideHistoryError(e.toString()));
    }
  }

  /// Refresh the ride history (shows current data while refreshing).
  Future<void> refresh() async {
    if (state is RideHistoryLoaded) {
      final currentRides = (state as RideHistoryLoaded).rides;
      emit(RideHistoryRefreshing(currentRides));
      try {
        final rides = await _userRepository.getRideHistory();
        emit(RideHistoryLoaded(rides));
      } catch (e) {
        emit(RideHistoryError(e.toString()));
      }
    } else {
      await loadHistory();
    }
  }

  /// Retry loading after an error.
  Future<void> retry() async {
    await loadHistory();
  }
}
