import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/api_service/weather_api_service.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_event.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApiService _weatherApiService = WeatherApiService();

  WeatherBloc() : super(WeatherInitialState()) {
    on<SearchCityEvent>(_searchCity);
    on<FetchWeatherEvent>(_fetchWeather);
    on<FetchWeatherByCoordinatesEvent>(_fetchWeatherByCoordinates);
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
      emit(WeatherLoadedState(weather));
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
      final WeatherModel weather = await _weatherApiService
          .getWeatherByCoordinates(event.latitude, event.longitude);
      emit(WeatherLoadedState(weather));
    } catch (e) {
      emit(WeatherErrorState(e.toString()));
    }
  }
}
