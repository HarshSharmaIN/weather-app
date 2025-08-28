import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/weather_model.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    await Hive.initFlutter();
    _prefs = await SharedPreferences.getInstance();
  }

  // Weather storage
  static Future<void> saveWeather(String key, Weather weather) async {
    final weatherJson = {
      'cityName': weather.cityName,
      'country': weather.country,
      'temperature': weather.temperature,
      'feelsLike': weather.feelsLike,
      'description': weather.description,
      'icon': weather.icon,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'windDirection': weather.windDirection,
      'pressure': weather.pressure,
      'visibility': weather.visibility,
      'uvIndex': weather.uvIndex,
      'cloudiness': weather.cloudiness,
      'dateTime': weather.dateTime.millisecondsSinceEpoch,
      'sunrise': weather.sunrise.millisecondsSinceEpoch,
      'sunset': weather.sunset.millisecondsSinceEpoch,
    };
    await _prefs.setString('weather_$key', json.encode(weatherJson));
  }

  static Weather? getWeather(String key) {
    final weatherString = _prefs.getString('weather_$key');
    if (weatherString == null) return null;

    try {
      final weatherJson = json.decode(weatherString);
      return Weather(
        cityName: weatherJson['cityName'],
        country: weatherJson['country'],
        temperature: (weatherJson['temperature'] as num).toDouble(),
        feelsLike: (weatherJson['feelsLike'] as num).toDouble(),
        description: weatherJson['description'],
        icon: weatherJson['icon'],
        humidity: (weatherJson['humidity'] as num).toInt(),
        windSpeed: (weatherJson['windSpeed'] as num).toDouble(),
        windDirection:
            (weatherJson['windDirection'] as num?)?.toDouble() ?? 0.0,
        pressure: (weatherJson['pressure'] as num).toInt(),
        visibility: (weatherJson['visibility'] as num).toDouble(),
        uvIndex: (weatherJson['uvIndex'] as num).toDouble(),
        cloudiness: (weatherJson['cloudiness'] as num?)?.toInt() ?? 0,
        dateTime: DateTime.fromMillisecondsSinceEpoch(weatherJson['dateTime']),
        sunrise: DateTime.fromMillisecondsSinceEpoch(weatherJson['sunrise']),
        sunset: DateTime.fromMillisecondsSinceEpoch(weatherJson['sunset']),
      );
    } catch (e) {
      return null;
    }
  }

  // Settings storage
  static Future<void> saveSetting(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else {
      await _prefs.setString(key, value.toString());
    }
  }

  static T? getSetting<T>(String key) {
    final value = _prefs.get(key);
    return value as T?;
  }

  // Recent cities storage
  static Future<void> saveRecentCity(City city) async {
    final cities = getRecentCities();

    // Remove if already exists
    cities.removeWhere((c) => c.name == city.name);

    // Add to beginning
    cities.insert(0, city);

    // Keep only last 5 cities
    if (cities.length > 5) {
      cities.removeRange(5, cities.length);
    }

    final citiesJson = cities
        .map(
          (city) => {
            'name': city.name,
            'country': city.country,
            'state': city.state,
            'lat': city.lat,
            'lon': city.lon,
          },
        )
        .toList();

    await _prefs.setString('recent_cities', json.encode(citiesJson));
  }

  static List<City> getRecentCities() {
    final citiesString = _prefs.getString('recent_cities');
    if (citiesString == null) return [];

    try {
      final citiesJson = json.decode(citiesString) as List;
      return citiesJson
          .map(
            (cityJson) => City(
              name: cityJson['name'],
              country: cityJson['country'],
              state: cityJson['state'] ?? '',
              lat: (cityJson['lat'] as num).toDouble(),
              lon: (cityJson['lon'] as num).toDouble(),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearRecentCities() async {
    await _prefs.remove('recent_cities');
  }
}
