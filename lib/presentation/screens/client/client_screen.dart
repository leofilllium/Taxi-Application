import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_styles.dart';
import '../../../core/config/enums.dart';
import '../../../core/utils/helpers.dart';
import '../../../generated/app_localizations.dart';
import '../../../logic/client/client_bloc.dart';
import '../../../logic/client/client_event.dart';
import '../../../logic/client/client_state.dart';

/// Main client screen with Google Maps and ride management
class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Initialize client
    context.read<ClientBloc>().add(const InitializeClient());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ClientBloc, ClientState>(
      listener: (context, state) {
        // Handle state changes that need UI feedback
        if (state.error != null) {
          showAppSnackBar(context, state.error!, isError: true);
        }

        // Center map on current location changes
        if (state.currentLocation != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(state.currentLocation!),
          );
        }

        // Show ride accepted dialog
        if (state.currentRide != null &&
            state.currentRide!.status == 'accepted' &&
            state.rideFlowState == RideFlowState.driverAssigned) {
          _showRideAcceptedDialog(context, state, l10n);
        }

        // Show rating sheet when ride completes
        if (state.currentRide != null &&
            state.currentRide!.status == 'completed' &&
            !state.hasRated) {
          _showRatingSheet(context, state, l10n);
        }
      },
      child: Scaffold(
        body: BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!state.locationPermissionGranted) {
              return _buildLocationPermissionError(l10n);
            }

            return Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: state.currentLocation ??
                        const LatLng(34.5553, 69.2075), // Kabul
                    zoom: 15.0,
                  ),
                  markers: state.markers,
                  polylines: state.polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (_) {
                    // Dismiss any open sheets on map tap
                  },
                ),

                // Top address bar
                if (state.rideFlowState == RideFlowState.idle)
                  _buildTopAddressBar(context, state, l10n),

                // Current location button
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (state.currentLocation != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(state.currentLocation!),
                        );
                      }
                    },
                    child: const Icon(
                      CupertinoIcons.location_fill,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // Bottom sheet based on ride flow state
                _buildBottomSheet(context, state, l10n),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopAddressBar(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
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
          children: [
            const Icon(
              CupertinoIcons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // TODO: Open destination search
                  context.read<ClientBloc>().add(const OpenDestinationSearch());
                },
                child: Text(
                  l10n.whereToGo,
                  style: AppStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
    switch (state.rideFlowState) {
      case RideFlowState.idle:
        return const SizedBox.shrink();

      case RideFlowState.confirmingDetails:
        return _buildRideConfirmationSheet(context, state, l10n);

      case RideFlowState.searching:
        return _buildSearchingSheet(context, state, l10n);

      case RideFlowState.driverAssigned:
      case RideFlowState.driverArriving:
      case RideFlowState.driverArrived:
      case RideFlowState.inProgress:
        return _buildActiveRideSheet(context, state, l10n);

    }
  }

  Widget _buildRideConfirmationSheet(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Destination
                    Text(
                      state.destinationAddress.isNotEmpty
                          ? state.destinationAddress
                          : l10n.destination,
                      style: AppStyles.title2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.routeInfo?.distance.toStringAsFixed(1) ?? '0'} km · ${state.routeInfo?.duration ?? '0 min'}',
                      style: AppStyles.footnote.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Service type selector (ride/delivery)
                    _buildServiceTypeSelector(context, state, l10n),
                    const SizedBox(height: 24),

                    // Ride quotes
                    if (state.rideQuotes.isNotEmpty) ...[
                      Text(l10n.selectRideType, style: AppStyles.headline),
                      const SizedBox(height: 12),
                      ...state.rideQuotes.map((quote) {
                        final isSelected =
                            state.selectedQuote?.rideType == quote.rideType;
                        return _buildQuoteCard(
                          context,
                          quote,
                          isSelected,
                          () {
                            context
                                .read<ClientBloc>()
                                .add(SelectQuote(quote));
                          },
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 24),

                    // Request button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.selectedQuote != null
                            ? () {
                                context
                                    .read<ClientBloc>()
                                    .add(const ConfirmRideRequest());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          l10n.requestRide(state.selectedQuote?.rideName ?? ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceTypeSelector(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceTypeButton(
            context,
            CupertinoIcons.car_detailed,
            l10n.ride,
            ServiceType.ride,
            state.selectedServiceType == ServiceType.ride,
            () {
              context
                  .read<ClientBloc>()
                  .add(const SelectServiceType(ServiceType.ride));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildServiceTypeButton(
            context,
            CupertinoIcons.cube_box,
            l10n.delivery,
            ServiceType.delivery,
            state.selectedServiceType == ServiceType.delivery,
            () {
              context
                  .read<ClientBloc>()
                  .add(const SelectServiceType(ServiceType.delivery));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeButton(
    BuildContext context,
    IconData icon,
    String label,
    ServiceType type,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withOpacity(0.1)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppStyles.callout.copyWith(
                color:
                    isSelected ? AppColors.accentBlue : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    quote,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withOpacity(0.1)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              quote.icon,
              size: 32,
              color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.rideName,
                    style: AppStyles.callout.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    quote.description,
                    style: AppStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${quote.price.toStringAsFixed(0)}؋',
              style: AppStyles.title3.copyWith(
                color: isSelected ? AppColors.accentBlue : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingSheet(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppStyles.elevatedShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 20),
          const SizedBox(height: 16),
          Text(
            l10n.searchingForDrivers,
            style: AppStyles.title3,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pleaseWait,
            style: AppStyles.footnote.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<ClientBloc>().add(const CancelRideRequest());
              },
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRideSheet(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
    final ride = state.currentRide!;
    String statusText = getStatusText(context, ride.status);
    String subtitle = '';

    if (ride.status == 'accepted') {
      subtitle = '${state.driverETA} ${l10n.minAway}';
    } else if (ride.status == 'driver_arrived') {
      subtitle = l10n.driverHasArrived;
    } else if (ride.status == 'in_progress') {
      subtitle = '${state.remainingTripMinutes} ${l10n.minRemaining}';
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusText, style: AppStyles.title3),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppStyles.footnote.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getStatusColor(ride.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: AppStyles.caption1.copyWith(
                    color: getStatusColor(ride.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Driver info
          if (ride.assignedDriver != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: ride.assignedDriver!.profileImageUrl != null
                      ? NetworkImage(ride.assignedDriver!.profileImageUrl!)
                      : const AssetImage('assets/images/logo.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.assignedDriver!.name,
                        style: AppStyles.callout.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${ride.assignedDriver!.vehicle['color']} ${ride.assignedDriver!.vehicle['model']}',
                        style: AppStyles.caption1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Call button
                IconButton(
                  onPressed: () {
                    // TODO: Call driver
                  },
                  icon: const Icon(
                    CupertinoIcons.phone_fill,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
          ],

          // Addresses
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

          // Cancel button (only if not in progress)
          if (ride.status != 'in_progress') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _confirmCancelRide(context, l10n);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: Text(l10n.cancelRide),
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

  void _showRideAcceptedDialog(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.rideAccepted),
        content: Text(l10n.driverIsOnTheWay),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.okay),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showRatingSheet(
    BuildContext context,
    ClientState state,
    AppLocalizations l10n,
  ) {
    // TODO: Implement rating bottom sheet
    // For now, just mark as rated
    context.read<ClientBloc>().add(const MarkAsRated());
  }

  void _confirmCancelRide(BuildContext context, AppLocalizations l10n) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.cancelRide),
        content: Text(l10n.areYouSureYouWantToCancelThisRide),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.no),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.yesCancel),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ClientBloc>().add(const CancelRideRequest());
            },
          ),
        ],
      ),
    );
  }
}
