import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Driver model with location and vehicle information
class Driver extends Equatable {
  final String id;
  final String name;
  final LatLng location;
  final String? phone;
  final double? rating;
  final Map<String, dynamic> vehicle;
  final String? profileImageUrl;
  final bool isAvailable;
  final double bearing;

  const Driver({
    required this.id,
    required this.name,
    required this.location,
    required this.vehicle,
    this.phone,
    this.rating,
    this.profileImageUrl,
    required this.isAvailable,
    this.bearing = 0.0,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> vehicleData;
    if (json.containsKey('vehicle') && json['vehicle'] is Map) {
      vehicleData = json['vehicle'];
    } else {
      vehicleData = {
        'model': json['model'],
        'licensePlate': json['licensePlate'],
        'color': json['color'],
        'year': json['year'],
        'type': json['vehicleType'],
      };
    }
    return Driver(
      id: json['id'],
      name: json['name'],
      location: LatLng(
        json['latitude']?.toDouble() ?? 0.0,
        json['longitude']?.toDouble() ?? 0.0,
      ),
      phone: json['phone'],
      rating: json['rating']?.toDouble(),
      vehicle: vehicleData,
      profileImageUrl: json['profileImageUrl'],
      isAvailable: json['isAvailable'] ?? false,
      bearing: (json['bearing'] as num? ?? 0.0).toDouble(),
    );
  }

  Driver copyWith({
    String? id,
    String? name,
    LatLng? location,
    String? phone,
    double? rating,
    Map<String, dynamic>? vehicle,
    String? profileImageUrl,
    bool? isAvailable,
    double? bearing,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      vehicle: vehicle ?? this.vehicle,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      bearing: bearing ?? this.bearing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        phone,
        rating,
        vehicle,
        profileImageUrl,
        isAvailable,
        bearing,
      ];
}
