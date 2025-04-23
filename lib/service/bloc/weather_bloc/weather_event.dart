import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class SearchCityEvent extends WeatherEvent {
  final String city;
  const SearchCityEvent({required this.city});

  @override
  List<Object> get props => [city];
}

class FetchWeatherByCoordinatesEvent extends WeatherEvent {
  final double latitude;
  final double longitude;

  const FetchWeatherByCoordinatesEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class FetchWeatherEvent extends WeatherEvent {}

class RefreshWeatherTimerEvent extends WeatherEvent {}
