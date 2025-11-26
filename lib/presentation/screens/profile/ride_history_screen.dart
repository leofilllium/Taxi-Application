import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../generated/app_localizations.dart';
import '../../../logic/ride_history/ride_history_cubit.dart';
import '../../../logic/ride_history/ride_history_state.dart';

/// Ride history screen showing past rides
class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyFormat = NumberFormat.currency(
      locale: locale.toString(),
      symbol: '؋',
      decimalDigits: 0,
    );

    return BlocProvider(
      create: (context) => RideHistoryCubit(context.read())..loadHistory(),
      child: BlocListener<RideHistoryCubit, RideHistoryState>(
        listener: (context, state) {
          if (state is RideHistoryError) {
            showAppSnackBar(context, state.message, isError: true);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundSecondary,
          appBar: AppBar(
            title: Text(l10n.rideHistory),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: BlocBuilder<RideHistoryCubit, RideHistoryState>(
            builder: (context, state) {
              // Loading state
              if (state is RideHistoryLoading) {
                return const Center(
                  child: CupertinoActivityIndicator(radius: 18),
                );
              }

              // Error state
              if (state is RideHistoryError) {
                return _buildErrorState(context, state.message, l10n);
              }

              // Loaded state
              if (state is RideHistoryLoaded || state is RideHistoryRefreshing) {
                final rides = state is RideHistoryLoaded
                    ? state.rides
                    : (state as RideHistoryRefreshing).rides;

                if (rides.isEmpty) {
                  return _buildEmptyState(l10n);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<RideHistoryCubit>().refresh();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: rides.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return _buildRideCard(
                        context,
                        ride,
                        currencyFormat,
                        locale,
                        l10n,
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRideCard(
    BuildContext context,
    ride,
    NumberFormat currencyFormat,
    Locale locale,
    AppLocalizations l10n,
  ) {
    final isCompleted = ride.status == 'completed';
    final isCancelled = ride.status == 'cancelled';
    final statusColor = getStatusColor(ride.status);
    final icon = isCompleted
        ? CupertinoIcons.check_mark_circled
        : (isCancelled
            ? CupertinoIcons.xmark_circle
            : CupertinoIcons.info_circle);
    final price = currencyFormat.format(
      ride.finalPrice ?? ride.estimatedPrice ?? 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        leading: Icon(icon, color: statusColor, size: 28),
        title: Text(
          ride.destinationAddress,
          style: AppStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          l10n.from(ride.pickupAddress),
          style: AppStyles.caption1.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMd(locale.toString())
                  .add_jm()
                  .format(ride.createdAt.toLocal()),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.time,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(l10n.noPastRides, style: AppStyles.title2),
          const SizedBox(height: 8),
          Text(
            l10n.pastRidesMessage,
            style: AppStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              error,
              style: AppStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<RideHistoryCubit>().retry();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
