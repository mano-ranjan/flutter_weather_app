import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/service/bloc/location_bloc/location_event.dart';
import 'package:weather_app/service/bloc/location_bloc/location_state.dart';
import 'package:weather_app/service/utils/geo_utility.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<GetUserLocationEvent>(_getUserLocation);
  }

  Future<void> _getUserLocation(
    GetUserLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    try {
      print("Starting location request...");
      Position position = await determinePosition();
      print("Got position: ${position.latitude}, ${position.longitude}");

      // Get city name
      try {
        String city = await getCityFromCoordinates(position);
        print("You're in: $city");
        emit(LocationLoaded(position: position, cityName: city));
      } catch (e) {
        // If getting city fails, still use the coordinates but show generic location
        emit(LocationLoaded(position: position, cityName: "Current Location"));
      }
    } catch (e) {
      print("Location Error: $e");
      emit(LocationError(message: e.toString()));
    }
  }
}
