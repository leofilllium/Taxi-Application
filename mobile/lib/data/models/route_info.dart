import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper function to decode Google polyline
List<LatLng> _decodePoly(String encoded) {
  String prepared = encoded.replaceAll(r'\\', r'\');
  List<LatLng> points = <LatLng>[];
  int index = 0, len = prepared.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      if (index >= prepared.length) break;
      b = prepared.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat_unsigned = result >> 1;
    int dlat = (result & 1) == 1 ? -dlat_unsigned - 1 : dlat_unsigned;
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      if (index >= prepared.length) break;
      b = prepared.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng_unsigned = result >> 1;
    int dlng = (result & 1) == 1 ? -dlng_unsigned - 1 : dlng_unsigned;
    lng += dlng;
    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}

/// Route information with polyline, distance, and duration
class RouteInfo extends Equatable {
  final List<LatLng> polylinePoints;
  final double distance;
  final int duration;

  const RouteInfo({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    final List<LatLng> decodedPoints = _decodePoly(json['polyline'] ?? '');
    return RouteInfo(
      polylinePoints: decodedPoints,
      distance: (json['distance'] ?? 0.0).toDouble(),
      duration: (json['duration'] ?? 0).toInt(),
    );
  }

  @override
  List<Object?> get props => [polylinePoints, distance, duration];
}
