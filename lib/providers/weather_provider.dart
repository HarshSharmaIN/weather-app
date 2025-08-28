import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherStatus _status = WeatherStatus.initial;
  Weather? _currentWeather;
  List<Forecast> _forecast = [];
  String _errorMessage = '';
  List<City> _citySuggestions = [];
  bool _isSearching = false;

  // Getters
  WeatherStatus get status => _status;
  Weather? get currentWeather => _currentWeather;
  List<Forecast> get forecast => _forecast;
  String get errorMessage => _errorMessage;
  List<City> get citySuggestions => _citySuggestions;
  bool get isSearching => _isSearching;

  // Load cached weather data
  void loadCachedWeather(String cityName) {
    final cached = StorageService.getWeather(cityName);
    if (cached != null) {
      _currentWeather = cached;
      _status = WeatherStatus.success;
      notifyListeners();
    }
  }

  // Get weather by coordinates
  Future<void> getWeatherByCoordinates(double lat, double lon) async {
    _setLoading();

    try {
      final weather = await _weatherService.getCurrentWeather(lat, lon);
      final forecastData = await _weatherService.getForecast(lat, lon);

      _currentWeather = weather;
      _forecast = forecastData;
      _status = WeatherStatus.success;
      _errorMessage = '';

      // Cache the weather data
      await StorageService.saveWeather('current_location', weather);
    } catch (e) {
      _setError(e.toString());
    }

    notifyListeners();
  }

  // Get weather by city name
  Future<void> getWeatherByCity(String cityName) async {
    _setLoading();

    try {
      final weather = await _weatherService.getCurrentWeatherByCity(cityName);

      // First search for the city to get coordinates
      final cities = await _weatherService.searchCities(cityName);
      if (cities.isNotEmpty) {
        final city = cities.first;
        final forecastData = await _weatherService.getForecast(
          city.lat,
          city.lon,
        );
        _forecast = forecastData;
      } else {
        _forecast = [];
      }

      _currentWeather = weather;
      _status = WeatherStatus.success;
      _errorMessage = '';

      // Cache the weather data
      await StorageService.saveWeather(cityName.toLowerCase(), weather);
    } catch (e) {
      _setError(e.toString());
    }

    notifyListeners();
  }

  // Search cities
  Future<void> searchCities(String query) async {
    if (query.isEmpty) {
      _citySuggestions = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final cities = await _weatherService.searchCities(query);
      _citySuggestions = cities;
    } catch (e) {
      _citySuggestions = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  // Select city from suggestions - Fixed the bug here
  Future<void> selectCity(City city) async {
    // Clear suggestions immediately
    _citySuggestions = [];
    notifyListeners();

    // Save to recent cities
    await StorageService.saveRecentCity(city);

    // Get weather for selected city using coordinates
    await getWeatherByCoordinates(city.lat, city.lon);
  }

  // Clear suggestions
  void clearSuggestions() {
    _citySuggestions = [];
    _isSearching = false;
    notifyListeners();
  }

  // Refresh weather data
  Future<void> refresh() async {
    if (_currentWeather != null) {
      // Try to refresh using the same city
      await getWeatherByCity(_currentWeather!.cityName);
    }
  }

  // Private methods
  void _setLoading() {
    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _status = WeatherStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
