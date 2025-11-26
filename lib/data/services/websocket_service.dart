import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/config/constants.dart';

/// WebSocket service for real-time communication.
class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();
  Timer? _locationUpdateTimer;
  bool _isDriverOnline = false;

  Stream<Map<String, dynamic>> get messages => _controller.stream;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(WS_URL));
      _channel!.sink.add(json.encode({'type': 'auth', 'token': token}));
      _channel!.stream.listen(
        (message) {
          try {
            final decoded = json.decode(message);
            _controller.add(decoded);
          } catch (e) {
            debugPrint("Failed to decode WebSocket message: $e");
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          Future.delayed(const Duration(seconds: 5), connect);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          Future.delayed(const Duration(seconds: 5), connect);
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      Future.delayed(const Duration(seconds: 5), connect);
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel?.sink != null && _channel?.closeCode == null) {
      _channel!.sink.add(json.encode(message));
    } else {
      debugPrint("WebSocket not connected. Message not sent: $message");
    }
  }

  void startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (_isDriverOnline) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          double bearing = 0;
          sendMessage({
            'type': 'location_update',
            'latitude': position.latitude,
            'longitude': position.longitude,
            'bearing': bearing
          });
        } catch (e) {
          debugPrint("Error getting location for WS update: $e");
        }
      }
    });
  }

  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  void setDriverOnlineStatus(bool isOnline) {
    _isDriverOnline = isOnline;
    if (isOnline) {
      startLocationUpdates();
    } else {
      stopLocationUpdates();
    }
  }

  void disconnect() {
    stopLocationUpdates();
    _channel?.sink.close();
    if (!_controller.isClosed) _controller.close();
  }
}
