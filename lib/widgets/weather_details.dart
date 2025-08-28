import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class WeatherDetails extends StatelessWidget {
  final Weather weather;

  const WeatherDetails({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather Details',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.thermostat,
                      title: 'Feels Like',
                      value: WeatherUtils.formatTemperature(weather.feelsLike),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.compress,
                      title: 'Pressure',
                      value: WeatherUtils.formatPressure(weather.pressure),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.compress,
                      title: 'Pressure',
                      value: WeatherUtils.formatPressure(weather.pressure),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.water_drop_outlined,
                      title: 'Humidity',
                      value: WeatherUtils.formatHumidity(weather.humidity),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.air,
                      title: 'Wind',
                      value:
                          '${WeatherUtils.formatWindSpeed(weather.windSpeed)} ${WeatherUtils.getWindDirection(weather.windDirection)}',
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.cloud,
                      title: 'Cloudiness',
                      value: '${weather.cloudiness}%',
                      valueColor: WeatherUtils.getUVIndexColor(weather.uvIndex),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
