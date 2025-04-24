import 'package:equatable/equatable.dart';
import 'package:weather_app/model/weather_model.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitialState extends WeatherState {}

class WeatherLoadingState extends WeatherState {}

class WeatherLoadedState extends WeatherState {
  final WeatherModel weather;
  final bool isFromSearch;

  const WeatherLoadedState(this.weather, {this.isFromSearch = false});

  @override
  List<Object?> get props => [weather, isFromSearch];
}

class WeatherErrorState extends WeatherState {
  final String message;

  const WeatherErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
