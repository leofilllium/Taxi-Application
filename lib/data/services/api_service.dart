import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/constants.dart';
import '../models/ride.dart';
import '../models/ride_quote.dart';
import '../models/route_info.dart';

/// Custom Exception for API-related errors.
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

/// API Service for all HTTP requests.
class ApiService {
  static const String baseUrl = API_BASE_URL;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Handles HTTP responses, parsing errors and successes.
  static dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      // Some DELETE or PUT endpoints return 204 No Content
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      } else {
        throw ApiException('Server returned status ${response.statusCode} with no body.');
      }
    }

    final responseBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw ApiException(
        responseBody['error'] ?? 'An unknown server error occurred.',
      );
    }
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      final uri = Uri.parse('$API_BASE_URL$endpoint');
      final response = await http
          .post(uri, headers: await _getHeaders(), body: json.encode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$API_BASE_URL$endpoint');
      final response = await http
          .get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final uri = Uri.parse('$API_BASE_URL$endpoint');
      final response = await http
          .put(uri, headers: await _getHeaders(), body: json.encode(body))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getAddressFromLatLng(LatLng latLng) async {
    final data = await get(
      '/reverse-geocode?lat=${latLng.latitude}&lng=${latLng.longitude}',
    );
    return data['address'];
  }

  static Future<Map<String, dynamic>> getRouteAndPriceEstimate({
    required LatLng pickup,
    required LatLng destination,
  }) async {
    final endpoint =
        '/rides/estimate?from=${pickup.latitude},${pickup.longitude}&to=${destination.latitude},${destination.longitude}';
    final data = await get(endpoint);
    final routeInfo = RouteInfo.fromJson(data['route']);
    final quotes =
        (data['quotes'] as List)
            .map((quoteData) => RideQuote.fromJson(quoteData))
            .toList();
    return {'route': routeInfo, 'quotes': quotes};
  }

  static Future<Ride> requestService({
    required String serviceType,
    required LatLng pickup,
    required LatLng destination,
    required String pickupAddress,
    required String destinationAddress,
    required String rideType,
    required double estimatedPrice,
    String? recipientName,
    String? recipientPhone,
    String? packageDetails,
    bool? isFragile,
  }) async {
    final body = {
      'serviceType': serviceType,
      'pickupLatitude': pickup.latitude,
      'pickupLongitude': pickup.longitude,
      'destinationLatitude': destination.latitude,
      'destinationLongitude': destination.longitude,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'rideType': rideType,
      'estimatedPrice': estimatedPrice,
    };
    if (serviceType == 'delivery') {
      body.addAll({
        'recipientName': recipientName!,
        'recipientPhone': recipientPhone!,
        'packageDetails': packageDetails!,
        'isFragile': isFragile!,
      });
    }
    final data = await post('/service/request', body);
    return Ride.fromJson(data['ride']);
  }

  static Future<void> cancelRide(String rideId) async {
    await put('/rides/$rideId/cancel', {});
  }

  static Future<Ride?> getCurrentRide() async {
    final data = await get('/rides/current');
    return data['ride'] != null ? Ride.fromJson(data['ride']) : null;
  }

  static Future<void> rateRide(
    String rideId,
    int rating,
    String? comment,
  ) async {
    try {
      final body = {'rating': rating, 'comment': comment ?? ""};

      final response = await post('/rides/$rideId/rate', body);
      if (response['message'] == null) {
        throw ApiException(
          "Unexpected server response while submitting your rating.",
        );
      }
    } on ApiException catch (e) {
      throw ApiException("Rating failed: ${e.message}");
    } catch (e, stack) {
      print("rateRide error: $e");
      print(stack);
      if (e is ApiException) rethrow;
      throw ApiException(
        "Unexpected client error while submitting your rating.",
      );
    }
  }

  static Future<dynamic> putMultipart(String endpoint, Map<String, String> fields, XFile? file) async {
    try {
      final uri = Uri.parse('$API_BASE_URL$endpoint');
      var request = http.MultipartRequest('PUT', uri);
      request.headers.addAll(await _getHeaders());
      request.fields.addAll(fields);

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedBody = json.decode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decodedBody;
      } else {
        throw ApiException(decodedBody['error'] ?? 'An unknown server error occurred.');
      }
    } on SocketException {
      throw ApiException('Network error. Please check your internet connection.');
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final data = await get('/profile');
    return data['profile'];
  }

  static Future<void> deleteAccount() async {
    try {
      final uri = Uri.parse('$API_BASE_URL/profile');
      final response = await http.delete(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
      _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your internet connection.');
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }
}
