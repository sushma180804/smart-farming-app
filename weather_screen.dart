// lib/screens/weather_screen.dart (VERIFY YOUR FILE MATCHES THIS)

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_farming_app/services/weather_api_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherApiService _weatherService = WeatherApiService();
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;
  String? _errorMessage;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    FocusScope.of(context).unfocus();
    if (_cityController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _weatherData = null;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.fetchWeather(_cityController.text.trim());
      if (mounted) {
        setState(() => _weatherData = data);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().toLowerCase().contains('city not found')) {
            _errorMessage = 'city_not_found'.tr();
          } else {
            _errorMessage = 'error_fetching_weather'.tr();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... The entire build method you provided is correct ...
    return Scaffold(
      appBar: AppBar(
        title: Text('weather'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'search_city_hint'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _fetchWeather(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchWeather,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _errorMessage != null
                        ? Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center)
                        : _weatherData != null
                            ? WeatherInfoCard(weatherData: _weatherData!)
                            : Text('Enter a city to see the weather forecast.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WeatherInfoCard widget remains the same...
class WeatherInfoCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const WeatherInfoCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final main = weatherData['main'];
    final weather = weatherData['weather'][0];
    final wind = weatherData['wind'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(weatherData['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('${main['temp']}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w200)),
            Text('${weather['main']} (${weather['description']})', style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(Icons.thermostat, 'temperature'.tr(), '${main['feels_like']}°C'),
                _buildInfoColumn(Icons.water_drop, 'humidity'.tr(), '${main['humidity']}%'),
                _buildInfoColumn(Icons.air, 'wind_speed'.tr(), '${wind['speed']} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade600),
        const SizedBox(height: 4),
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}