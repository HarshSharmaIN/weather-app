import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart' as loc;

class LocationService {
  final loc.Location _location = loc.Location();

  Future<bool> checkAndRequestLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      // This shows Google’s native "Enable Location" modal
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    // Check for permission
    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  // Get current position
  Future<loc.LocationData> getCurrentPosition() async {
    return await _location.getLocation();
  }

  // Get city name from coordinates
  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        return place.locality ?? place.administrativeArea ?? 'Unknown Location';
      }
    } catch (e) {
      print('Error getting city name: $e');
    }
    return 'Unknown Location';
  }
}
