import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String get weatherApiKey {
    return dotenv.env['WEATHER_API_KEY'] ?? '';
  }
}
