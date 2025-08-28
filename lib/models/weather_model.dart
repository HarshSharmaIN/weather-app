import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;

  final String country;

  final double temperature;

  final double feelsLike;

  final String description;

  final String icon;

  final int humidity;

  final double windSpeed;

  final int pressure;

  final double visibility;

  final double uvIndex;

  final DateTime dateTime;

  final DateTime sunrise;

  final DateTime sunset;

  final double windDirection;

  final int cloudiness;

  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.dateTime,
    required this.sunrise,
    required this.sunset,
    required this.windDirection,
    required this.cloudiness,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      country: json['sys']['country'],
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['main']['pressure'] as num).toInt(),
      visibility: ((json['visibility'] as num?) ?? 10000).toDouble() / 1000,
      uvIndex: 0.0, // UV index needs separate API call
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        json['sys']['sunrise'] * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      windDirection: (json['wind']?['deg'] as num?)?.toDouble() ?? 0.0,
      cloudiness: (json['clouds']?['all'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    cityName,
    country,
    temperature,
    feelsLike,
    description,
    icon,
    humidity,
    windSpeed,
    windDirection,
    pressure,
    visibility,
    uvIndex,
    cloudiness,
    dateTime,
    sunrise,
    sunset,
  ];
}

class Forecast extends Equatable {
  final DateTime date;

  final double maxTemp;

  final double minTemp;

  final String description;

  final String icon;

  final int humidity;

  final double windSpeed;

  final double windDirection;

  final int cloudiness;

  const Forecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudiness,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['wind']?['deg'] as num?)?.toDouble() ?? 0.0,
      cloudiness: (json['clouds']?['all'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    date,
    maxTemp,
    minTemp,
    description,
    icon,
    humidity,
    windSpeed,
    windDirection,
    cloudiness,
  ];
}

class City extends Equatable {
  final String name;

  final String country;

  final String state;

  final double lat;

  final double lon;

  const City({
    required this.name,
    required this.country,
    required this.state,
    required this.lat,
    required this.lon,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      country: json['country'],
      state: json['state'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  String get displayName {
    if (state.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }

  @override
  List<Object?> get props => [name, country, state, lat, lon];
}
