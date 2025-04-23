class WeatherModel {
  final LocationModel location;
  final CurrentModel current;

  WeatherModel({required this.location, required this.current});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: LocationModel.fromJson(json['location']),
      current: CurrentModel.fromJson(json['current']),
    );
  }
}

class LocationModel {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String tzId;
  final int localtimeEpoch;
  final String localtime;

  LocationModel({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tzId,
    required this.localtimeEpoch,
    required this.localtime,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      country: json['country'] ?? '',
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
      tzId: json['tz_id'] ?? '',
      localtimeEpoch: (json['localtime_epoch'] as num).toInt(),
      localtime: json['localtime'] ?? '',
    );
  }
}

class CurrentModel {
  final int lastUpdatedEpoch;
  final String lastUpdated;
  final double tempC;
  final double tempF;
  final int isDay;
  final ConditionModel condition;
  final double windMph;
  final double windKph;
  final int windDegree;
  final String windDir;
  final double pressureMb;
  final double pressureIn;
  final double precipMm;
  final double precipIn;
  final int humidity;
  final int cloud;
  final double feelslikeC;
  final double feelslikeF;
  final double visKm;
  final double visMiles;
  final int uv;
  final double gustMph;
  final double gustKph;

  CurrentModel({
    required this.lastUpdatedEpoch,
    required this.lastUpdated,
    required this.tempC,
    required this.tempF,
    required this.isDay,
    required this.condition,
    required this.windMph,
    required this.windKph,
    required this.windDegree,
    required this.windDir,
    required this.pressureMb,
    required this.pressureIn,
    required this.precipMm,
    required this.precipIn,
    required this.humidity,
    required this.cloud,
    required this.feelslikeC,
    required this.feelslikeF,
    required this.visKm,
    required this.visMiles,
    required this.uv,
    required this.gustMph,
    required this.gustKph,
  });

  factory CurrentModel.fromJson(Map<String, dynamic> json) {
    return CurrentModel(
      lastUpdatedEpoch: _parseIntFromDynamic(json['last_updated_epoch']),
      lastUpdated: json['last_updated'] ?? '',
      tempC: _parseDoubleFromDynamic(json['temp_c']),
      tempF: _parseDoubleFromDynamic(json['temp_f']),
      isDay: _parseIntFromDynamic(json['is_day']),
      condition: ConditionModel.fromJson(json['condition']),
      windMph: _parseDoubleFromDynamic(json['wind_mph']),
      windKph: _parseDoubleFromDynamic(json['wind_kph']),
      windDegree: _parseIntFromDynamic(json['wind_degree']),
      windDir: json['wind_dir'] ?? '',
      pressureMb: _parseDoubleFromDynamic(json['pressure_mb']),
      pressureIn: _parseDoubleFromDynamic(json['pressure_in']),
      precipMm: _parseDoubleFromDynamic(json['precip_mm']),
      precipIn: _parseDoubleFromDynamic(json['precip_in']),
      humidity: _parseIntFromDynamic(json['humidity']),
      cloud: _parseIntFromDynamic(json['cloud']),
      feelslikeC: _parseDoubleFromDynamic(json['feelslike_c']),
      feelslikeF: _parseDoubleFromDynamic(json['feelslike_f']),
      visKm: _parseDoubleFromDynamic(json['vis_km']),
      visMiles: _parseDoubleFromDynamic(json['vis_miles']),
      uv: _parseIntFromDynamic(json['uv']),
      gustMph: _parseDoubleFromDynamic(json['gust_mph']),
      gustKph: _parseDoubleFromDynamic(json['gust_kph']),
    );
  }
}

int _parseIntFromDynamic(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDoubleFromDynamic(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class ConditionModel {
  final String text;
  final String icon;
  final int code;

  ConditionModel({required this.text, required this.icon, required this.code});

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      text: json['text'] ?? '',
      icon: json['icon'] ?? '',
      code: (json['code'] as num).toInt(),
    );
  }
}
