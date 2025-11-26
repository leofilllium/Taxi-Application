import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'client.dart';
import 'driver.dart';
import 'route_step.dart';

/// Comprehensive Ride model with all ride information
class Ride extends Equatable {
  final String id;
  final String status;
  final String pickupAddress;
  final String destinationAddress;
  final double? estimatedPrice;
  final double? finalPrice;
  final DateTime createdAt;
  final String? clientId;
  final String? driverId;
  final Driver? assignedDriver;
  final Client? client;
  final LatLng? driverLocation;
  final String? rideType;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final double? distance;
  final int? eta;
  final List<RouteStep>? routeSteps;
  final String serviceType;
  final String? recipientName;
  final String? recipientPhone;
  final String? packageDetails;
  final bool? isFragile;

  const Ride({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.destinationAddress,
    this.estimatedPrice,
    this.finalPrice,
    required this.createdAt,
    this.clientId,
    this.driverId,
    this.assignedDriver,
    this.client,
    this.driverLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.distance,
    this.eta,
    this.routeSteps,
    this.rideType,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.serviceType = 'ride',
    this.recipientName,
    this.recipientPhone,
    this.packageDetails,
    this.isFragile,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    Driver? driver;
    LatLng? driverLoc;
    if (json['driver'] != null && json['driver'] is Map) {
      driver = Driver.fromJson(json['driver']);
      if (json['driver']['latitude'] != null &&
          json['driver']['longitude'] != null) {
        driverLoc = LatLng(
          json['driver']['latitude'].toDouble(),
          json['driver']['longitude'].toDouble(),
        );
      }
    }
    List<RouteStep>? routeSteps;
    if (json['routeSteps'] != null && json['routeSteps'] is List) {
      routeSteps =
          (json['routeSteps'] as List)
              .map((step) => RouteStep.fromJson(step))
              .toList();
    }
    return Ride(
      id: json['id'] ?? 'unknown_ride_${DateTime.now().millisecondsSinceEpoch}',
      status: json['status'] ?? 'pending',
      pickupAddress: json['pickupAddress'] ?? 'Unknown Pickup Location',
      destinationAddress: json['destinationAddress'] ?? 'Unknown Destination',
      estimatedPrice: json['estimatedPrice']?.toDouble(),
      finalPrice: json['finalPrice']?.toDouble(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      clientId: json['clientId'],
      driverId: json['driverId'],
      assignedDriver: driver,
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      driverLocation: driverLoc,
      pickupLatitude: json['pickupLatitude']?.toDouble() ?? 0.0,
      pickupLongitude: json['pickupLongitude']?.toDouble() ?? 0.0,
      destinationLatitude: json['destinationLatitude']?.toDouble() ?? 0.0,
      destinationLongitude: json['destinationLongitude']?.toDouble() ?? 0.0,
      distance: json['distance']?.toDouble(),
      eta: json['eta'] is num ? (json['eta'] as num).toInt() : null,
      routeSteps: routeSteps,
      rideType: json['rideType'],
      acceptedAt:
          json['acceptedAt'] != null
              ? DateTime.parse(json['acceptedAt'])
              : null,
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      serviceType: json['serviceType'] ?? 'ride',
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      packageDetails: json['packageDetails'],
      isFragile: json['isFragile'],
    );
  }

  Ride copyWith({
    String? id,
    String? status,
    String? pickupAddress,
    String? destinationAddress,
    double? estimatedPrice,
    double? finalPrice,
    DateTime? createdAt,
    String? clientId,
    String? driverId,
    Driver? assignedDriver,
    Client? client,
    LatLng? driverLocation,
    String? rideType,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    double? distance,
    int? eta,
    List<RouteStep>? routeSteps,
    String? serviceType,
    String? recipientName,
    String? recipientPhone,
    String? packageDetails,
    bool? isFragile,
  }) {
    return Ride(
      id: id ?? this.id,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId ?? this.clientId,
      driverId: driverId ?? this.driverId,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      client: client ?? this.client,
      driverLocation: driverLocation ?? this.driverLocation,
      rideType: rideType ?? this.rideType,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      routeSteps: routeSteps ?? this.routeSteps,
      serviceType: serviceType ?? this.serviceType,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      packageDetails: packageDetails ?? this.packageDetails,
      isFragile: isFragile ?? this.isFragile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        pickupAddress,
        destinationAddress,
        estimatedPrice,
        finalPrice,
        createdAt,
        clientId,
        driverId,
        assignedDriver,
        client,
        driverLocation,
        rideType,
        acceptedAt,
        startedAt,
        completedAt,
        pickupLatitude,
        pickupLongitude,
        destinationLatitude,
        destinationLongitude,
        distance,
        eta,
        routeSteps,
        serviceType,
        recipientName,
        recipientPhone,
        packageDetails,
        isFragile,
      ];
}
