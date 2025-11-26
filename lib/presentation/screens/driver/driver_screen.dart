import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../generated/app_localizations.dart';
import '../../../logic/driver/driver_bloc.dart';
import '../../../logic/driver/driver_event.dart';
import '../../../logic/driver/driver_state.dart';

/// Driver screen with map, online status, and ride management
class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Initialize driver
    context.read<DriverBloc>().add(const InitializeDriver());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleOnlineStatus(bool isOnline) {
    context.read<DriverBloc>().add(ToggleOnlineStatus(isOnline));
  }

  void _acceptRide(String rideId) {
    context.read<DriverBloc>().add(AcceptRide(rideId));
  }

  void _rejectRide(String rideId) {
    context.read<DriverBloc>().add(RejectRide(rideId));
  }

  void _notifyArrival(String rideId) {
    context.read<DriverBloc>().add(DriverArrived(rideId));
  }

  void _startRide(String rideId) {
    context.read<DriverBloc>().add(StartRide(rideId));
  }

  void _completeRide(String rideId) {
    context.read<DriverBloc>().add(CompleteRide(rideId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<DriverBloc, DriverState>(
      listener: (context, state) {
        // Show error if any
        if (state.error != null) {
          showAppSnackBar(context, state.error!, isError: true);
        }

        // Center map on current location when it changes
        if (state.currentLocation != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(state.currentLocation!),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<DriverBloc, DriverState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!state.locationPermissionGranted) {
              return _buildLocationPermissionError(l10n);
            }

            return Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: state.currentLocation ?? const LatLng(34.5553, 69.2075),
                    zoom: 15.0,
                  ),
                  markers: state.markers,
                  polylines: state.polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),

                // Top bar with online toggle
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopBar(context, state, l10n),
                ),

                // Pending ride requests
                if (state.pendingRequests.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildRideRequestCard(
                      context,
                      state.pendingRequests.first,
                      l10n,
                    ),
                  ),

                // Active ride panel
                if (state.currentRide != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildActiveRidePanel(
                      context,
                      state.currentRide!,
                      l10n,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, DriverState state, AppLocalizations l10n) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppStyles.cardShadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isOnline ? l10n.youAreOnline : l10n.youAreOffline,
                  style: AppStyles.headline,
                ),
                Text(
                  state.isOnline
                      ? l10n.receivingRideRequests
                      : l10n.notReceivingRequests,
                  style: AppStyles.footnote,
                ),
              ],
            ),
            CupertinoSwitch(
              value: state.isOnline,
              onChanged: _toggleOnlineStatus,
              activeColor: AppColors.accentGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideRequestCard(
    BuildContext context,
    ride,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppStyles.elevatedShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.newRideRequest,
            style: AppStyles.title3,
          ),
          const SizedBox(height: 16),
          _buildAddressRow(
            CupertinoIcons.location_fill,
            AppColors.pickupGreen,
            l10n.pickup,
            ride.pickupAddress,
          ),
          const SizedBox(height: 12),
          _buildAddressRow(
            CupertinoIcons.location_solid,
            AppColors.destinationRed,
            l10n.destination,
            ride.destinationAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectRide(ride.id),
                  style: OutlinedButton.styleFrom(
                    padding
: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                  child: Text(l10n.decline),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptRide(ride.id),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.accentGreen,
                  ),
                  child: Text(l10n.accept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRidePanel(
    BuildContext context,
    ride,
    AppLocalizations l10n,
  ) {
    final status = ride.status;
    String primaryAction = '';
    VoidCallback? primaryCallback;

    if (status == 'accepted') {
      primaryAction = l10n.arriveAtPickup;
      primaryCallback = () => _notifyArrival(ride.id);
    } else if (status == 'driver_arrived') {
      primaryAction = l10n.startRide;
      primaryCallback = () => _startRide(ride.id);
    } else if (status == 'in_progress') {
      primaryAction = l10n.completeRide;
      primaryCallback = () => _completeRide(ride.id);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppStyles.elevatedShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getStatusText(context, status),
                style: AppStyles.title3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getStatusText(context, status),
                  style: AppStyles.footnote.copyWith(
                    color: getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAddressRow(
            CupertinoIcons.location_fill,
            AppColors.pickupGreen,
            l10n.pickup,
            ride.pickupAddress,
          ),
          const SizedBox(height: 12),
          _buildAddressRow(
            CupertinoIcons.location_solid,
            AppColors.destinationRed,
            l10n.destination,
            ride.destinationAddress,
          ),
          if (primaryAction.isNotEmpty && primaryCallback != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: primaryCallback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(primaryAction),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressRow(
    IconData icon,
    Color color,
    String label,
    String address,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppStyles.caption1),
              Text(
                address,
                style: AppStyles.callout,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPermissionError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.location_slash,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.locationPermissionRequired,
              style: AppStyles.title2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pleaseEnableLocationAccess,
              style: AppStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
