// Core enums used in client flow
/// Ride flow states for client journey
enum RideFlowState {
  idle,
  confirmingDetails,
  searching,
  driverAssigned,
  driverArriving,
  driverArrived,
  inProgress,
}

/// Service types available
enum ServiceType { ride, delivery }
