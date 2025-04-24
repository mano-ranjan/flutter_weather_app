import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_state.dart';

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

// Determine which weather scene to show based on weather state and condition code
WeatherScene getWeatherSceneFromState(WeatherState state) {
  print('the state is $state');
  if (state is WeatherLoadedState) {
    final conditionCode = state.weather.current.condition.code;
    // final conditionCode = 1066;
    final isDay = state.weather.current.isDay == 1;

    print('the condition code is $conditionCode');

    // Map condition codes to available WeatherScene enum values

    // Clear conditions (1000-1003)
    if (conditionCode >= 1000 && conditionCode <= 1003) {
      return isDay ? WeatherScene.scorchingSun : WeatherScene.sunset;
    }
    // Partly cloudy, cloudy (1004-1009)
    else if (conditionCode >= 1004 && conditionCode <= 1009) {
      return WeatherScene.sunset;
    }
    // Mist, fog, other visibility issues (1030-1039)
    else if (conditionCode >= 1030 && conditionCode <= 1039) {
      return WeatherScene.rainyOvercast;
    }
    // Rain conditions (1063-1069, 1180-1199, 1240-1249)
    else if ((conditionCode >= 1063 && conditionCode <= 1069) ||
        (conditionCode >= 1180 && conditionCode <= 1199) ||
        (conditionCode >= 1240 && conditionCode <= 1249)) {
      return WeatherScene.rainyOvercast;
    }
    // Heavy rain, stormy conditions (1200-1246, 1273-1282)
    else if ((conditionCode >= 1200 && conditionCode <= 1246) ||
        (conditionCode >= 1273 && conditionCode <= 1282)) {
      return WeatherScene.stormy;
    }
    // Snow, sleet, ice (1066, 1069, 1114-1117, 1210-1237, 1250-1264)
    else if (conditionCode == 1066 ||
        conditionCode == 1069 ||
        (conditionCode >= 1114 && conditionCode <= 1117) ||
        (conditionCode >= 1210 && conditionCode <= 1237) ||
        (conditionCode >= 1250 && conditionCode <= 1264)) {
      return WeatherScene.snowfall;
    }
    // Sleet, mixed precipitation (1069, 1249, 1252)
    else if (conditionCode == 1069 ||
        conditionCode == 1249 ||
        conditionCode == 1252) {
      return WeatherScene.showerSleet;
    }
    // Freezing rain/drizzle (1072, 1168, 1171)
    else if (conditionCode == 1072 ||
        conditionCode == 1168 ||
        conditionCode == 1171) {
      return WeatherScene.frosty;
    }
  }

  // Default scene for initial state or unsupported conditions
  return WeatherScene.weatherEvery;
}
