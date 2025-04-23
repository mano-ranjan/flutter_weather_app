import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_event.dart';
import 'package:weather_app/service/bloc/weather_bloc/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitialState()) {
    on<SearchCityEvent>(searchCity);
    on<FetchWeatherEvent>(fetchWeather);
    on<FetchWeatherByCoordinatesEvent>(fetchWeatherByCoordinates);
  }

  searchCity(SearchCityEvent event, Emitter<WeatherState> emit) {
    print('Searching city: ${event.city}');
    // Implement API call with city name
  }

  fetchWeather(FetchWeatherEvent event, Emitter<WeatherState> emit) {
    print('Fetching weather with default parameters');
  }

  fetchWeatherByCoordinates(
    FetchWeatherByCoordinatesEvent event,
    Emitter<WeatherState> emit,
  ) {
    print(
      'Fetching weather for coordinates: ${event.latitude}, ${event.longitude}',
    );
    // Implement API call with coordinates
    // For now we'll just emit a success state
    emit(WeatherCitySuccessState());
  }
}
