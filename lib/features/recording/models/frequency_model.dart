class FrequencyModel {
  final List<int> range;
  final List<String> feedback;

  FrequencyModel({
    required this.range,
    required this.feedback,
  });

  factory FrequencyModel.fromJson(Map<String, dynamic> json) {
    return FrequencyModel(
      range: List<int>.from(json['range']),
      feedback: List<String>.from(json['feedback']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'feedback': feedback,
    };
  }
} 