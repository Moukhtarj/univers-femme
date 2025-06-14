import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final Location _location = Location();
  LocationData? _currentLocation;
  final Distance _distance = Distance();

  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Location service is disabled');
          return null;
        }
      }

      // Check location permission
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus == PermissionStatus.denied) {
          print('Location permission denied');
          return null;
        }
      }

      if (permissionStatus == PermissionStatus.deniedForever) {
        print('Location permission permanently denied');
        return null;
      }

      // Get location with timeout
      _currentLocation = await _location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          print('Location request timed out');
          return Future.value(null);
        },
      );

      if (_currentLocation == null) {
        print('Failed to get location');
        return null;
      }

      // Validate location data
      if (_currentLocation!.latitude == null || _currentLocation!.longitude == null) {
        print('Invalid location data received');
        return null;
      }

      return _currentLocation;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    try {
      final point1 = LatLng(lat1, lon1);
      final point2 = LatLng(lat2, lon2);
      return _distance.as(LengthUnit.Meter, point1, point2);
    } catch (e) {
      print('Error calculating distance: $e');
      return 0;
    }
  }

  String formatDistance(double distanceInMeters) {
    try {
      if (distanceInMeters < 0) {
        return 'Distance unavailable';
      }
      
      if (distanceInMeters < 1000) {
        return '${distanceInMeters.toStringAsFixed(0)}m';
      } else {
        double distanceInKm = distanceInMeters / 1000;
        return '${distanceInKm.toStringAsFixed(1)}km';
      }
    } catch (e) {
      print('Error formatting distance: $e');
      return 'Distance unavailable';
    }
  }
} 