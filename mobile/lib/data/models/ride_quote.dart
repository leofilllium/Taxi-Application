import 'package:flutter/cupertino.dart';
import 'package:equatable/equatable.dart';

/// Ride quote/pricing option
class RideQuote extends Equatable {
  final String rideType;
  final String rideName;
  final double price;
  final IconData icon;

  const RideQuote({
    required this.rideType,
    required this.rideName,
    required this.price,
    required this.icon,
  });

  factory RideQuote.fromJson(Map<String, dynamic> json) {
    IconData iconData;
    switch (json['rideType']) {
      case 'Tuk-tuk':
        iconData = CupertinoIcons.car;
        break;
      case 'Comfort':
        iconData = CupertinoIcons.car;
        break;
      case 'Comfort X':
        iconData = CupertinoIcons.star_fill;
        break;
      case 'Premium':
        iconData = CupertinoIcons.person_3_fill;
        break;
      case 'Motorbike':
        iconData = CupertinoIcons.cube_box_fill;
        break;
      default:
        iconData = CupertinoIcons.car_detailed;
    }
    return RideQuote(
      rideType: json['rideType'],
      rideName: json['rideName'],
      price: (json['price'] ?? 0.0).toDouble(),
      icon: iconData,
    );
  }

  @override
  List<Object?> get props => [rideType, rideName, price, icon];
}
