import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_list.dart';
import '../widgets/search_bar.dart';
import '../widgets/weather_details.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialWeather();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  Future<void> _loadInitialWeather() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );

    // Show loading animation
    _fadeController.forward();
    _slideController.forward();

    await locationProvider.getCurrentLocation();

    if (locationProvider.status == LocationStatus.success &&
        locationProvider.currentPosition != null) {
      await weatherProvider.getWeatherByCoordinates(
        locationProvider.currentPosition!.latitude!,
        locationProvider.currentPosition!.longitude!,
      );
      _showSuccessSnackBar('Weather updated for your location');
    } else {
      // Fallback to a default city
      await weatherProvider.getWeatherByCity('New Delhi');
      _showInfoSnackBar('Using default location: New Delhi');
    }
  }

  Future<void> _refreshWeather() async {
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );

    try {
      await weatherProvider.refresh();
      _showSuccessSnackBar('Weather data refreshed');
    } catch (e) {
      _showErrorSnackBar('Failed to refresh weather data');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadInitialWeather,
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: const Text(
                'Weather App',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: IconButton(
                  key: ValueKey(themeProvider.isDarkMode),
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  onPressed: () {
                    themeProvider.setThemeMode(
                      themeProvider.isDarkMode
                          ? ThemeMode.light
                          : ThemeMode.dark,
                    );
                    _showInfoSnackBar(
                      'Switched to ${themeProvider.isDarkMode ? 'dark' : 'light'} theme',
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _loadInitialWeather();
              _showInfoSnackBar('Getting your location...');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: WeatherSearchBar(
                      controller: _searchController,
                      onCitySelected: (cityName) {
                        _showInfoSnackBar('Loading weather for $cityName...');
                      },
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: _buildWeatherContent(weatherProvider),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.status == WeatherStatus.success) {
            return AnimatedScale(
              scale: _fadeAnimation.value,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton.extended(
                onPressed: _refreshWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWeatherContent(WeatherProvider weatherProvider) {
    switch (weatherProvider.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return const LoadingWidget();

      case WeatherStatus.error:
        return WeatherErrorWidget(
          message: weatherProvider.errorMessage,
          onRetry: () {
            _loadInitialWeather();
            _showInfoSnackBar('Retrying...');
          },
        );

      case WeatherStatus.success:
        if (weatherProvider.currentWeather == null) {
          return const Center(child: Text('No weather data available'));
        }

        return Column(
          children: [
            Hero(
              tag: 'weather-card',
              child: WeatherCard(weather: weatherProvider.currentWeather!),
            ),
            const SizedBox(height: 16),
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    ),
                  ),
              child: WeatherDetails(weather: weatherProvider.currentWeather!),
            ),
            const SizedBox(height: 16),
            if (weatherProvider.forecast.isNotEmpty)
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                child: ForecastList(forecasts: weatherProvider.forecast),
              ),
            const SizedBox(height: 100), // Space for FAB
          ],
        );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
