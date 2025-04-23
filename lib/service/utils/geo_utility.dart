import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  try {
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Location services are disabled. Please enable GPS in your device settings.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
          'Location permissions are denied. Please allow access in app settings.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied. Please enable in app settings.',
      );
    }

    // Get current position without any timeout
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low, // Keep this for better performance
    );
  } catch (e) {
    return Future.error('Error getting location: $e');
  }
}

Future<String> getCityFromCoordinates(Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    ); // No timeout - will wait indefinitely

    if (placemarks.isNotEmpty) {
      final locality = placemarks[0].locality;
      final subLocality = placemarks[0].subLocality;
      final administrativeArea = placemarks[0].administrativeArea;

      // Try to get the most specific location name available
      if (locality != null && locality.isNotEmpty) {
        return locality;
      } else if (subLocality != null && subLocality.isNotEmpty) {
        return subLocality;
      } else if (administrativeArea != null && administrativeArea.isNotEmpty) {
        return administrativeArea;
      } else {
        return 'Unknown location nothing';
      }
    } else {
      return 'Unknown location empty';
    }
  } catch (e) {
    // Handle other errors
    return 'Unknown location Error';
  }
}
