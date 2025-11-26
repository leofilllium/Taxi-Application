import 'package:equatable/equatable.dart';

/// Client/Customer model
class Client extends Equatable {
  final String? id;
  final String name;
  final String? phone;

  const Client({
    this.id,
    required this.name,
    this.phone,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'] ?? 'Unknown Client',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, name, phone];
}
