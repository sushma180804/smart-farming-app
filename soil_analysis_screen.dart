// lib/screens/soil_analysis_screen.dart (REPLACE ENTIRE FILE)

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_farming_app/data/soil_data.dart';

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({super.key});

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  // To store the currently selected soil type from the dropdown
  SoilInfo? _selectedSoil;
  // To store the recommendations to be displayed
  List<String> _recommendations = [];

  void _getRecommendations() {
    if (_selectedSoil != null) {
      setState(() {
        _recommendations = _selectedSoil!.recommendedCrops;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('soil_analysis'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown for selecting soil type
            DropdownButtonFormField<SoilInfo>(
              decoration: InputDecoration(
                labelText: 'select_soil_type'.tr(),
                border: const OutlineInputBorder(),
              ),
              value: _selectedSoil,
              items: soilData.map((soil) {
                return DropdownMenuItem<SoilInfo>(
                  value: soil,
                  // Display the translated name of the soil
                  child: Text(soil.nameKey.tr()),
                );
              }).toList(),
              onChanged: (SoilInfo? newValue) {
                setState(() {
                  _selectedSoil = newValue;
                  // Clear previous recommendations when a new soil is selected
                  _recommendations = [];
                });
              },
            ),
            const SizedBox(height: 24),
            // Button to trigger the recommendation
            ElevatedButton(
              onPressed: _getRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('get_recommendations'.tr()),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Display the results
            Expanded(
              child: _recommendations.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'recommended_crops'.tr()} "${_selectedSoil!.nameKey.tr()}"',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: const Icon(Icons.eco, color: Colors.green),
                                  title: Text(_recommendations[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('Select a soil type and get recommendations.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}