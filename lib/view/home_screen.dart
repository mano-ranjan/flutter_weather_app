import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:weather_app/service/bloc/location_bloc/location_bloc.dart';
import 'package:weather_app/service/bloc/location_bloc/location_event.dart';
import 'package:weather_app/service/bloc/location_bloc/location_state.dart';
import 'package:weather_app/service/bloc/search_bloc/search_bloc.dart';
import 'package:weather_app/service/bloc/search_bloc/search_state.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_bloc.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_event.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_state.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:weather_app/service/utils/geo_utility.dart';
import 'package:weather_app/service/bloc/search_bloc/search_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FloatingSearchBarController _searchController =
      FloatingSearchBarController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(GetUserLocationEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, locationState) {
          if (locationState is LocationLoaded) {
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
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, weatherState) {
            if (weatherState is WeatherLoadingState) {
              setState(() {
                _isRefreshing = true;
              });
            } else {
              setState(() {
                _isRefreshing = false;
              });
            }
          },
          builder: (context, weatherState) {
            WeatherScene weatherScene = getWeatherSceneFromState(weatherState);

            return Stack(
              children: [
                // Weather animation background
                AnimatedSwitcher(
                  duration: const Duration(seconds: 2),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey<WeatherScene>(weatherScene),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: WrapperScene.weather(
                      scene: weatherScene,
                      sizeCanvas: Size(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height,
                      ),
                    ),
                  ),
                ),

                // Search bar
                FloatingSearchBar(
                  controller: _searchController,
                  hint: 'Search city...',
                  scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
                  transitionDuration: const Duration(milliseconds: 800),
                  transitionCurve: Curves.easeInOut,
                  physics: const BouncingScrollPhysics(),
                  axisAlignment: 0.0,
                  openAxisAlignment: 0.0,
                  width: 600,
                  debounceDelay: const Duration(milliseconds: 500),
                  onQueryChanged: (query) {
                    // Call API when user finishes typing
                  },
                  onSubmitted: (query) {
                    // Call the searchCity event when user submits query
                    if (query.trim().isNotEmpty) {
                      context.read<WeatherBloc>().add(
                        SearchCityEvent(city: query.trim()),
                      );
                      _searchController.close();
                    }
                  },
                  transition: CircularFloatingSearchBarTransition(),
                  actions: [
                    FloatingSearchBarAction(
                      showIfOpened: false,
                      child: CircularButton(
                        icon: const Icon(Icons.place),
                        onPressed: () {
                          // Trigger getting current location again
                          context.read<LocationBloc>().add(
                            GetUserLocationEvent(),
                          );
                        },
                      ),
                    ),
                    FloatingSearchBarAction.searchToClear(showIfClosed: false),
                  ],
                  builder: (context, transition) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Material(
                        color: Colors.white,
                        elevation: 4,
                        child: BlocBuilder<SearchBloc, SearchState>(
                          builder: (context, historyState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Current search
                                if (_searchController.query.isNotEmpty)
                                  ListTile(
                                    leading: const Icon(Icons.search),
                                    title: Text(_searchController.query),
                                    onTap: () {
                                      context.read<WeatherBloc>().add(
                                        SearchCityEvent(
                                          city: _searchController.query,
                                        ),
                                      );
                                      context.read<SearchBloc>().add(
                                        AddSearchQueryEvent(
                                          _searchController.query,
                                        ),
                                      );
                                      _searchController.close();
                                    },
                                  ),

                                // Search history
                                ...historyState.searchHistory.map(
                                  (query) => ListTile(
                                    leading: const Icon(Icons.history),
                                    title: Text(query),
                                    onTap: () {
                                      _searchController.query = query;
                                      context.read<WeatherBloc>().add(
                                        SearchCityEvent(city: query),
                                      );
                                      _searchController.close();
                                    },
                                  ),
                                ),

                                // Clear history button if there's any history
                                if (historyState.searchHistory.isNotEmpty)
                                  ListTile(
                                    leading: const Icon(Icons.clear_all),
                                    title: const Text('Clear History'),
                                    onTap: () {
                                      context.read<SearchBloc>().add(
                                        ClearSearchHistoryEvent(),
                                      );
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.only(
                    top: 80,
                  ), // Add space for search bar
                  child: BlocBuilder<LocationBloc, LocationState>(
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

                            // Show coordinates only if not a search result
                            if (locationState is LocationLoaded &&
                                !(weatherState is WeatherLoadedState &&
                                    weatherState.isFromSearch))
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
                ),

                // Optional refresh indicator
                if (_isRefreshing)
                  Positioned(
                    top: 100, // Position below search bar
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
          // Add last updated info
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Last updated: ${state.weather.current.lastUpdated}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
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
