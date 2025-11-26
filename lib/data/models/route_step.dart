import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Turn-by-turn navigation step
class RouteStep extends Equatable {
  final String instructions;
  final double distance;
  final double duration;
  final LatLng location;

  const RouteStep({
    required this.instructions,
    required this.distance,
    required this.duration,
    required this.location,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instructions: json['instructions'] ?? 'No instruction',
      distance: json['distance']?.toDouble() ?? 0,
      duration: json['duration']?.toDouble() ?? 0,
      location: LatLng(
        json['latitude']?.toDouble() ?? 0,
        json['longitude']?.toDouble() ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [instructions, distance, duration, location];
}
