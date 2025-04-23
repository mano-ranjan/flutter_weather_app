import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/utils/config_service.dart';

class WeatherApiService {
  final String baseUrl = 'https://api.weatherapi.com/v1';
  final String _apiKey = ConfigService.weatherApiKey;

  Future<WeatherModel> getWeatherByCity(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/current.json?q=$city&key=$_apiKey'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }

  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$baseUrl/current.json?q=$lat,$lon&key=$_apiKey'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }
}
