class SoundModel {
  final int soundId;
  final String title;
  final String url_avatar;
  final String url;
  final String description;
  final List<int> tags;

  SoundModel({
    required this.soundId,
    required this.title,
    required this.url_avatar,
    required this.url,
    required this.description,
    required this.tags,
  });

  factory SoundModel.fromJson(Map<String, dynamic> json, {int? soundId}) {
    return SoundModel(
      soundId: soundId ?? json['soundId'] ?? 0,
      title: json['title'],
      url_avatar: json['url_avatar'],
      url: json['url'],
      description: json['description'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundId': soundId,
      'title': title,
      'url_avatar': url_avatar,
      'url': url,
      'description': description,
      'tags': tags,
    };
  }
} 