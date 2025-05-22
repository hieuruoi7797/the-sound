class SoundModel {
  final String name;
  final double frequency;
  final int duration; // in seconds or ms
  final String url;

  SoundModel({
    required this.name,
    required this.frequency,
    required this.duration,
    required this.url,
  });

  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      name: json['name'],
      frequency: (json['frequency'] as num).toDouble(),
      duration: json['duration'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'frequency': frequency,
      'duration': duration,
      'url': url,
    };
  }
} 