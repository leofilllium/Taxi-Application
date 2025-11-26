import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../generated/app_localizations.dart';
import '../config/app_colors.dart';

/// Shows a native-style iOS alert dialog.
void showAppDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  showCupertinoDialog(
    context: context,
    builder:
        (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
  );
}

/// Shows a floating snackbar for non-critical information.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? AppColors.error : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Calculate bearing between two lat/lng points.
double calculateBearing(LatLng start, LatLng end) {
  final startLat = start.latitude * (math.pi / 180);
  final startLng = start.longitude * (math.pi / 180);
  final endLat = end.latitude * (math.pi / 180);
  final endLng = end.longitude * (math.pi / 180);

  final deltaLng = endLng - startLng;

  final y = math.sin(deltaLng) * math.cos(endLat);
  final x =
      math.cos(startLat) * math.sin(endLat) -
      math.sin(startLat) * math.cos(endLat) * math.cos(deltaLng);

  final bearing = math.atan2(y, x);

  // Convert to degrees and normalize to 0-360
  return ((bearing * (180 / math.pi)) + 360) % 360;
}

/// Get localized status text for ride status.
String getStatusText(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context)!;
  switch (status) {
    case 'pending':
      return l10n.statusSearching;
    case 'accepted':
      return l10n.statusDriverOnWay;
    case 'driver_arrived':
      return l10n.statusDriverArrived;
    case 'in_progress':
      return l10n.statusInProgress;
    case 'completed':
      return l10n.statusCompleted;
    case 'cancelled':
      return l10n.statusCancelled;
    default:
      return status;
  }
}

/// Get color for ride status.
Color getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'accepted':
      return AppColors.primary;
    case 'driver_arrived':
      return AppColors.accentGreen;
    case 'in_progress':
      return AppColors.primary;
    case 'completed':
      return AppColors.accentGreen;
    case 'cancelled':
      return AppColors.accentRed;
    default:
      return AppColors.textSecondary;
  }
}
