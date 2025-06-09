import 'package:mytune/features/recording/models/frequency_model.dart';

class FrequenciesDataModel {
  final Map<String, FrequencyModel> frequencies;

  FrequenciesDataModel({
    required this.frequencies,
  });

  factory FrequenciesDataModel.fromJson(Map<String, dynamic> json) {
    final Map<String, FrequencyModel> frequenciesMap = {};
    json['frequencies'].forEach((key, value) {
      frequenciesMap[key] = FrequencyModel.fromJson(Map<String, dynamic>.from(value));
    });
    return FrequenciesDataModel(
      frequencies: frequenciesMap,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> frequenciesMap = {};
    frequencies.forEach((key, value) {
      frequenciesMap[key] = value.toJson();
    });
    return {
      'frequencies': frequenciesMap,
    };
  }
} 