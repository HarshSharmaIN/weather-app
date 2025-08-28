import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import '../services/location_service.dart';

enum LocationStatus { initial, loading, success, denied, error }

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  LocationStatus _status = LocationStatus.initial;
  loc.LocationData? _currentPosition;
  String _currentCity = '';
  String _errorMessage = '';

  // Getters
  LocationStatus get status => _status;
  loc.LocationData? get currentPosition => _currentPosition;
  String get currentCity => _currentCity;
  String get errorMessage => _errorMessage;

  // Get current location
  Future<void> getCurrentLocation() async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      final hasPermission = await _locationService.checkAndRequestLocation();
      if (!hasPermission) {
        _status = LocationStatus.denied;
        _errorMessage = 'Location permission denied or service disabled';
        notifyListeners();
        return;
      }

      final position = await _locationService.getCurrentPosition();
      final cityName = await _locationService.getCityNameFromCoordinates(
        position.latitude!,
        position.longitude!,
      );

      _currentPosition = position;
      _currentCity = cityName;
      _status = LocationStatus.success;
      _errorMessage = '';
    } catch (e) {
      _status = LocationStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Just check location permission + service
  Future<bool> hasLocationPermission() async {
    return await _locationService.checkAndRequestLocation();
  }
}
