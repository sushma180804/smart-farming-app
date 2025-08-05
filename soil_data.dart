// lib/data/soil_data.dart (NEW FILE)

// A simple class to represent a soil type and its recommended crops.
class SoilInfo {
  final String nameKey; // This will be the key for translation, e.g., "soil_type_alluvial"
  final List<String> recommendedCrops;

  SoilInfo({required this.nameKey, required this.recommendedCrops});
}

// Our pre-defined list of soil data. This acts as our mini-database for now.
final List<SoilInfo> soilData = [
  SoilInfo(
    nameKey: 'soil_type_alluvial',
    recommendedCrops: ['Rice', 'Wheat', 'Sugarcane', 'Maize', 'Cotton', 'Jute'],
  ),
  SoilInfo(
    nameKey: 'soil_type_black',
    recommendedCrops: ['Cotton', 'Sugarcane', 'Jowar', 'Tobacco', 'Wheat', 'Oilseeds'],
  ),
  SoilInfo(
    nameKey: 'soil_type_red',
    recommendedCrops: ['Wheat', 'Rice', 'Millets', 'Pulses', 'Groundnut', 'Potato'],
  ),
  SoilInfo(
    nameKey: 'soil_type_laterite',
    recommendedCrops: ['Tea', 'Coffee', 'Rubber', 'Cashew', 'Coconut'],
  ),
  SoilInfo(
    nameKey: 'soil_type_desert',
    recommendedCrops: ['Millets (Bajra)', 'Pulses', 'Guar', 'Fodder crops'],
  ),
];