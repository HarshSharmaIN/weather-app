import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import 'package:intl/intl.dart';

class WeatherCard extends StatefulWidget {
  final Weather weather;

  const WeatherCard({super.key, required this.weather});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotateController);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: _getWeatherGradient(widget.weather.icon),
            boxShadow: [
              BoxShadow(
                color: _getWeatherGradient(
                  widget.weather.icon,
                ).colors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                _buildLocationHeader(),
                const SizedBox(height: 24),
                _buildWeatherIcon(),
                const SizedBox(height: 16),
                _buildTemperature(),
                const SizedBox(height: 8),
                _buildDescription(),
                const SizedBox(height: 8),
                _buildFeelsLike(),
                const SizedBox(height: 24),
                _buildWeatherMetrics(),
                const SizedBox(height: 20),
                _buildSunriseSunset(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 22,
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '${widget.weather.cityName}, ${widget.weather.country}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherIcon() {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value * 0.1, // Subtle rotation
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              WeatherUtils.getWeatherIcon(widget.weather.icon),
              style: const TextStyle(fontSize: 80),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemperature() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0, end: widget.weather.temperature),
      builder: (context, value, child) {
        return Text(
          '${value.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w200,
            height: 1,
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        WeatherUtils.getWeatherCondition(widget.weather.description),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFeelsLike() {
    return Text(
      'Feels like ${WeatherUtils.formatTemperature(widget.weather.feelsLike)}',
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildWeatherMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWeatherDetail(
            icon: Icons.visibility,
            label: 'Visibility',
            value: WeatherUtils.formatVisibility(widget.weather.visibility),
          ),
          _buildDivider(),
          _buildWeatherDetail(
            icon: Icons.water_drop,
            label: 'Humidity',
            value: WeatherUtils.formatHumidity(widget.weather.humidity),
          ),
          _buildDivider(),
          _buildWeatherDetail(
            icon: Icons.air,
            label: 'Wind',
            value:
                '${WeatherUtils.formatWindSpeed(widget.weather.windSpeed)} ${WeatherUtils.getWindDirection(widget.weather.windDirection)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSunriseSunset() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange.shade200, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sunrise',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(widget.weather.sunrise),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.nightlight, color: Colors.indigo.shade200, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sunset',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(widget.weather.sunset),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient(String iconCode) {
    if (iconCode.contains('01')) {
      // Clear sky
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
      );
    } else if (iconCode.contains('02') || iconCode.contains('03')) {
      // Few/scattered clouds
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF78909C), Color(0xFF546E7A)],
      );
    } else if (iconCode.contains('04')) {
      // Broken clouds
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF607D8B), Color(0xFF455A64)],
      );
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      // Rain
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
      );
    } else if (iconCode.contains('11')) {
      // Thunderstorm
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF424242), Color(0xFF212121)],
      );
    } else if (iconCode.contains('13')) {
      // Snow
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF90A4AE), Color(0xFF78909C)],
      );
    } else if (iconCode.contains('50')) {
      // Mist
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
      );
    }

    // Default gradient
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }
}
