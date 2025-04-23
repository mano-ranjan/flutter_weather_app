import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_bloc.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_event.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_state.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:weather_app/service/utils/geo_utility.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentCity = "Locating...";
  bool isLoading = true;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    // No longer call FetchWeatherEvent here - wait for position first
    getUserLocation();
  }

  void getUserLocation() async {
    try {
      print("Starting location request...");
      Position position = await determinePosition();
      print("Got position: ${position.latitude}, ${position.longitude}");

      // Store the position for later use
      currentPosition = position;

      // Get city name for display purposes only
      try {
        String city = await getCityFromCoordinates(position);
        print("You're in: $city");
        if (mounted) {
          setState(() {
            currentCity = city;
            isLoading = false;
          });
        }
      } catch (e) {
        // If getting city fails, still use the coordinates but show generic location
        if (mounted) {
          setState(() {
            currentCity = "Current Location";
            isLoading = false;
          });
        }
      }

      // Now that we have coordinates, fetch weather data
      if (mounted) {
        context.read<WeatherBloc>().add(
          FetchWeatherByCoordinatesEvent(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      }
    } catch (e) {
      print("Location Error: $e");
      if (mounted) {
        setState(() {
          currentCity = "Unable to get location";
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please check location permissions and internet connection',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          return Stack(
            children: [
              WrapperScene.weather(
                scene: WeatherScene.sunset,
                sizeCanvas: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
              ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      currentCity,
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
                    if (currentPosition != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Lat: ${currentPosition!.latitude.toStringAsFixed(4)}, Long: ${currentPosition!.longitude.toStringAsFixed(4)}",
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
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
