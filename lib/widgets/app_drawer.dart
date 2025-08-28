import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../services/storage_service.dart';
import '../models/weather_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildRecentCitiesSection(context),
                const Divider(),
                _buildSettingsSection(context),
                const Divider(),
                _buildAboutSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      width: 350,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.wb_sunny, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Weather App',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stay updated with weather',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCitiesSection(BuildContext context) {
    final recentCities = StorageService.getRecentCities();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Recent Cities',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (recentCities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'No recent cities',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...recentCities.map((city) => _buildCityTile(context, city)),
        if (recentCities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () async {
                await StorageService.clearRecentCities();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recent cities cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
            ),
          ),
      ],
    );
  }

  Widget _buildCityTile(BuildContext context, City city) {
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: Text(city.name),
      subtitle: Text(city.displayName),
      onTap: () {
        Navigator.of(context).pop();
        Provider.of<WeatherProvider>(
          context,
          listen: false,
        ).getWeatherByCoordinates(city.lat, city.lon);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loading weather for ${city.name}...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Settings',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark/light theme'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          onTap: () {
            Navigator.of(context).pop();
            _showHelpDialog(context);
          },
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to use the Weather App:'),
            SizedBox(height: 8),
            Text('• Search for cities using the search bar'),
            Text('• Tap on suggestions to select a city'),
            Text('• Pull down to refresh weather data'),
            Text('• Use the location button to get current location weather'),
            Text('• Access recent cities from the drawer'),
            SizedBox(height: 16),
            Text('Need more help? Contact at harshsharmaasl80@gmail.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
