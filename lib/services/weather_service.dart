import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'http://api.openweathermap.org/data/2.5';
  static const String _geoUrl = 'http://api.openweathermap.org/geo/1.0';
  static const String _uvUrl = 'http://api.openweathermap.org/data/2.5/uvi';
  static const String _apiKey = 'ca30f4d8594a22d902afc37df2877eec';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Get current weather by coordinates
  Future<Weather> getCurrentWeather(double lat, double lon) async {
    try {
      final weatherResponse = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (weatherResponse.statusCode == 200) {
        // Get UV index separately
        double uvIndex = 0.0;
        try {
          final uvResponse = await _dio.get(
            _uvUrl,
            queryParameters: {'lat': lat, 'lon': lon, 'appid': _apiKey},
          );
          if (uvResponse.statusCode == 200) {
            uvIndex = (uvResponse.data['value'] as num?)?.toDouble() ?? 0.0;
          }
        } catch (e) {
          // UV index is optional, continue without it
          print('Failed to fetch UV index: $e');
        }

        final weatherData = weatherResponse.data;
        weatherData['uv_index'] = uvIndex;
        return Weather.fromJson(weatherData);
      } else {
        throw Exception('Failed to load weather data');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get current weather by city name
  Future<Weather> getCurrentWeatherByCity(String cityName) async {
    try {
      final weatherResponse = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {'q': cityName, 'appid': _apiKey, 'units': 'metric'},
      );

      if (weatherResponse.statusCode == 200) {
        final weatherData = weatherResponse.data;
        final lat = (weatherData['coord']['lat'] as num).toDouble();
        final lon = (weatherData['coord']['lon'] as num).toDouble();

        // Get UV index using coordinates
        double uvIndex = 0.0;
        try {
          final uvResponse = await _dio.get(
            _uvUrl,
            queryParameters: {'lat': lat, 'lon': lon, 'appid': _apiKey},
          );
          if (uvResponse.statusCode == 200) {
            uvIndex = (uvResponse.data['value'] as num?)?.toDouble() ?? 0.0;
          }
        } catch (e) {
          print('Failed to fetch UV index: $e');
        }

        weatherData['uv_index'] = uvIndex;
        return Weather.fromJson(weatherData);
      } else {
        throw Exception('City not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('City not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get 5-day forecast
  Future<List<Forecast>> getForecast(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> forecastList = response.data['list'];

        // Group by date and get daily forecasts
        Map<String, List<Forecast>> groupedByDate = {};

        for (var item in forecastList) {
          final forecast = Forecast.fromJson(item);
          final dateKey =
              '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';

          groupedByDate.putIfAbsent(dateKey, () => []);
          groupedByDate[dateKey]!.add(forecast);
        }

        // Get one forecast per day (using midday forecast if available)
        List<Forecast> dailyForecasts = [];

        groupedByDate.forEach((date, forecasts) {
          // Try to get midday forecast (around 12:00)
          Forecast? middayForecast;
          for (var forecast in forecasts) {
            if (forecast.date.hour >= 11 && forecast.date.hour <= 13) {
              middayForecast = forecast;
              break;
            }
          }

          // If no midday forecast, use first available
          dailyForecasts.add(middayForecast ?? forecasts.first);
        });

        return dailyForecasts.take(5).toList();
      } else {
        throw Exception('Failed to load forecast data');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  // Search cities
  Future<List<City>> searchCities(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await _dio.get(
        '$_geoUrl/direct',
        queryParameters: {'q': query, 'limit': 5, 'appid': _apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> cityList = response.data;
        return cityList.map((json) => City.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search cities');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error searching cities: $e');
    }
  }
}
