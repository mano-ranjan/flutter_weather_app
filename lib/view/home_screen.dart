import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/service/bloc/location_bloc/location_bloc.dart';
import 'package:weather_app/service/bloc/location_bloc/location_event.dart';
import 'package:weather_app/service/bloc/location_bloc/location_state.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_bloc.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_event.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_state.dart';
import 'package:weather_animation/weather_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch the location event
    context.read<LocationBloc>().add(GetUserLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, locationState) {
          if (locationState is LocationLoaded) {
            // When location is loaded, fetch weather data
            context.read<WeatherBloc>().add(
              FetchWeatherByCoordinatesEvent(
                latitude: locationState.position.latitude,
                longitude: locationState.position.longitude,
              ),
            );
          } else if (locationState is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please check location permissions and internet connection',
                ),
              ),
            );
          }
        },
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, weatherState) {
            // Determine which weather scene to show based on weather condition
            WeatherScene weatherScene = _getWeatherSceneFromState(weatherState);

            return Stack(
              children: [
                // Weather animation background
                WrapperScene.weather(
                  scene: weatherScene,
                  sizeCanvas: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                ),

                // Location and weather data display
                BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, locationState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (locationState is LocationLoading ||
                              weatherState is WeatherLoadingState)
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          const SizedBox(height: 16),

                          // Location name
                          Text(
                            _getCityText(locationState, weatherState),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),

                          // Coordinates display
                          if (locationState is LocationLoaded)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Lat: ${locationState.position.latitude.toStringAsFixed(4)}, Long: ${locationState.position.longitude.toStringAsFixed(4)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 8,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Weather data display when loaded
                          if (weatherState is WeatherLoadedState) ...[
                            _buildWeatherInfo(weatherState),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Build weather information display
  Widget _buildWeatherInfo(WeatherLoadedState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Weather condition icon
              Image.network(
                'https:${state.weather.current.condition.icon}',
                width: 64,
                height: 64,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 64,
                    ),
              ),
              const SizedBox(width: 16),
              // Temperature display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.weather.current.tempC.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    state.weather.current.condition.text,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Additional weather details
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWeatherDetail(
                'Feels Like',
                '${state.weather.current.feelslikeC.toStringAsFixed(1)}°C',
                Icons.thermostat,
              ),
              const SizedBox(width: 16),
              _buildWeatherDetail(
                'Humidity',
                '${state.weather.current.humidity}%',
                Icons.water_drop,
              ),
              const SizedBox(width: 16),
              _buildWeatherDetail(
                'Wind',
                '${state.weather.current.windKph} km/h',
                Icons.air,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for weather details
  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  // Determine which weather scene to show based on weather state and condition code
  WeatherScene _getWeatherSceneFromState(WeatherState state) {
    print('the state is $state');
    if (state is WeatherLoadedState) {
      final conditionCode = state.weather.current.condition.code;
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
    return WeatherScene.frosty;
  }

  // Get appropriate location text based on state
  String _getCityText(LocationState locationState, WeatherState weatherState) {
    // If weather is loaded, use the location from the weather data
    if (weatherState is WeatherLoadedState) {
      return weatherState.weather.location.name;
    }

    // Otherwise use location state
    if (locationState is LocationInitial) {
      return "Locating...";
    } else if (locationState is LocationLoading) {
      return "Locating...";
    } else if (locationState is LocationLoaded) {
      return locationState.cityName;
    } else if (locationState is LocationError) {
      return "Unable to get location";
    } else {
      return "Unknown state";
    }
  }
}
