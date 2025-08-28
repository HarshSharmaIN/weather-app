import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class WeatherSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onCitySelected;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    this.onCitySelected,
  });

  @override
  State<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends State<WeatherSearchBar>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  late AnimationController _suggestionController;
  late Animation<double> _suggestionAnimation;

  @override
  void initState() {
    super.initState();

    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _suggestionAnimation = CurvedAnimation(
      parent: _suggestionController,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });

      if (_showSuggestions) {
        _suggestionController.forward();
      } else {
        _suggestionController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Column(
          children: [
            Hero(
              tag: 'search-bar',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for a city...',
                    prefixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: weatherProvider.isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Icon(Icons.search),
                    ),
                    suffixIcon: widget.controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              widget.controller.clear();
                              weatherProvider.clearSuggestions();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.isNotEmpty) {
                      weatherProvider.searchCities(value);
                    } else {
                      weatherProvider.clearSuggestions();
                    }
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _selectCity(value, weatherProvider);
                    }
                  },
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _suggestionAnimation,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _suggestionAnimation,
                  child: _showSuggestions
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildSuggestionsList(weatherProvider),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestionsList(WeatherProvider weatherProvider) {
    if (weatherProvider.isSearching) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Searching cities...'),
            ],
          ),
        ),
      );
    }

    if (weatherProvider.citySuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: weatherProvider.citySuggestions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final city = weatherProvider.citySuggestions[index];
            return _buildSuggestionTile(city, weatherProvider, index);
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(
    City city,
    WeatherProvider weatherProvider,
    int index,
  ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100 + (index * 50)),
      curve: Curves.easeOutCubic,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          city.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          city.displayName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          widget.controller.text = city.name;
          _selectCity(city.name, weatherProvider, city: city);
        },
      ),
    );
  }

  void _selectCity(
    String cityName,
    WeatherProvider weatherProvider, {
    City? city,
  }) {
    _focusNode.unfocus();
    weatherProvider.clearSuggestions();

    if (city != null) {
      // Use coordinates for more accurate weather data
      weatherProvider.selectCity(city);
    } else {
      // Fallback to city name search
      weatherProvider.getWeatherByCity(cityName);
    }

    widget.onCitySelected?.call(cityName);

    // Show loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Loading weather for $cityName...'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _suggestionController.dispose();
    super.dispose();
  }
}
