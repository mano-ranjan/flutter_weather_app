import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/api_service/weather_api_service.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_event.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApiService _weatherApiService = WeatherApiService();
  Timer? _refreshTimer;

  // Keep track of last coordinates to refresh
  double? _lastLatitude;
  double? _lastLongitude;

  WeatherBloc() : super(WeatherInitialState()) {
    on<SearchCityEvent>(_searchCity);
    on<FetchWeatherEvent>(_fetchWeather);
    on<FetchWeatherByCoordinatesEvent>(_fetchWeatherByCoordinates);
    on<RefreshWeatherTimerEvent>(_refreshWeather);

    // Start the timer when the bloc is created
    _startRefreshTimer();
  }

  // Start a timer to refresh weather data every hour
  void _startRefreshTimer() {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    // Create a new timer that fires every hour (3600 seconds)
    _refreshTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => add(RefreshWeatherTimerEvent()),
    );
  }

  @override
  Future<void> close() {
    // Cancel the timer when the bloc is closed
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> _searchCity(
    SearchCityEvent event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoadingState());
    try {
      final WeatherModel weather = await _weatherApiService.getWeatherByCity(
        event.city,
      );
      emit(WeatherLoadedState(weather, isFromSearch: true));
    } catch (e) {
      emit(WeatherErrorState(e.toString()));
    }
  }

  Future<void> _fetchWeather(
    FetchWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    // You could implement a default location fetch here
    emit(WeatherLoadingState());
    try {
      // Using a default city as an example
      final WeatherModel weather = await _weatherApiService.getWeatherByCity(
        'London',
      );
      emit(WeatherLoadedState(weather));
    } catch (e) {
      emit(WeatherErrorState(e.toString()));
    }
  }

  Future<void> _fetchWeatherByCoordinates(
    FetchWeatherByCoordinatesEvent event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoadingState());
    try {
      // Store the coordinates for later refresh
      _lastLatitude = event.latitude;
      _lastLongitude = event.longitude;

      final WeatherModel weather = await _weatherApiService
          .getWeatherByCoordinates(event.latitude, event.longitude);
      emit(WeatherLoadedState(weather));
    } catch (e) {
      emit(WeatherErrorState(e.toString()));
    }
  }

  // Handle the refresh timer event
  Future<void> _refreshWeather(
    RefreshWeatherTimerEvent event,
    Emitter<WeatherState> emit,
  ) async {
    // Only refresh if we have coordinates to use
    if (_lastLatitude != null && _lastLongitude != null) {
      try {
        // Don't emit loading state during background refresh to avoid UI flicker
        final currentState = state;

        final WeatherModel weather = await _weatherApiService
            .getWeatherByCoordinates(_lastLatitude!, _lastLongitude!);

        // Only update if we're still in a loaded state
        if (currentState is WeatherLoadedState) {
          emit(WeatherLoadedState(weather));
        }
      } catch (e) {
        // If refresh fails, only emit error if we're not already in a loaded state
        // This prevents showing errors for background refresh failures when the UI already has data
        if (state is! WeatherLoadedState) {
          emit(WeatherErrorState(e.toString()));
        }
      }
    }
  }
}
