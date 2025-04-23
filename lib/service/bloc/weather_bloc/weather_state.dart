import 'package:equatable/equatable.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitialState extends WeatherState {}

class WeatherCityLoadingState extends WeatherState {}

class WeatherCitySuccessState extends WeatherState {}

class WeatherCityFailureState extends WeatherState {}
