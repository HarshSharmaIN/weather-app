import 'package:flutter/material.dart';

class WeatherUtils {
  static String getWeatherIcon(String iconCode) {
    const iconMap = {
      '01d': '☀️', // clear sky day
      '01n': '🌙', // clear sky night
      '02d': '⛅', // few clouds day
      '02n': '☁️', // few clouds night
      '03d': '☁️', // scattered clouds
      '03n': '☁️',
      '04d': '☁️', // broken clouds
      '04n': '☁️',
      '09d': '🌧️', // shower rain
      '09n': '🌧️',
      '10d': '🌦️', // rain day
      '10n': '🌧️', // rain night
      '11d': '⛈️', // thunderstorm
      '11n': '⛈️',
      '13d': '❄️', // snow
      '13n': '❄️',
      '50d': '🌫️', // mist
      '50n': '🌫️',
    };

    return iconMap[iconCode] ?? '☀️';
  }

  static String getWeatherCondition(String description) {
    return description
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static String getWindDirection(double degrees) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  static String getUVIndexDescription(double uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  static Color getUVIndexColor(double uvIndex) {
    if (uvIndex <= 2) return const Color(0xFF4CAF50); // Green
    if (uvIndex <= 5) return const Color(0xFFFFEB3B); // Yellow
    if (uvIndex <= 7) return const Color(0xFFFF9800); // Orange
    if (uvIndex <= 10) return const Color(0xFFFF5722); // Red
    return const Color(0xFF9C27B0); // Purple
  }

  static String formatTemperature(double temperature) {
    return '${temperature.isFinite ? temperature.round() : 0}°';
  }

  static String formatWindSpeed(double speed) {
    return '${speed.isFinite ? speed.toStringAsFixed(1) : '0.0'} m/s';
  }

  static String formatPressure(int pressure) {
    return '$pressure hPa';
  }

  static String formatVisibility(double visibility) {
    return '${visibility.isFinite ? visibility.toStringAsFixed(1) : '0.0'} km';
  }

  static String formatHumidity(int humidity) {
    return '$humidity%';
  }

  static String formatCloudiness(int cloudiness) {
    return '$cloudiness%';
  }

  static String getAirQualityDescription(double uvIndex) {
    if (uvIndex <= 2) return 'Good';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'Unhealthy for Sensitive Groups';
    if (uvIndex <= 10) return 'Unhealthy';
    return 'Very Unhealthy';
  }
}
