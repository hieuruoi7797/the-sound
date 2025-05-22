class SoundModel {
  final String audioName;
  final String imageUrl;
  final String audioDirectUrl;
  final String googleDriveUrl;
  final String description;

  SoundModel({
    required this.audioName,
    required this.imageUrl,
    required this.audioDirectUrl,
    required this.googleDriveUrl,
    required this.description,
  });

  factory SoundModel.fromJson(Map<String, dynamic> json) {
    return SoundModel(
      audioName: json['audioName'],
      imageUrl: json['imageUrl'],
      audioDirectUrl: json['audioDirectUrl'],
      googleDriveUrl: json['googleDriveUrl'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioName': audioName,
      'imageUrl': imageUrl,
      'audioDirectUrl': audioDirectUrl,
      'googleDriveUrl': googleDriveUrl,
      'description': description,
    };
  }
} 