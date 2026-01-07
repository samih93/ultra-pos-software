class AppVersionModel {
  final int id;
  final String version;
  final String downloadUrl;
  final int? fileSize;
  final String? releaseNotes;
  final bool isLatest;
  final DateTime createdAt;

  AppVersionModel({
    required this.id,
    required this.version,
    required this.downloadUrl,
    this.fileSize,
    this.releaseNotes,
    required this.isLatest,
    required this.createdAt,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      id: json['id'],
      version: json['version'],
      downloadUrl: json['download_url'],
      fileSize: json['file_size'],
      releaseNotes: json['release_notes'],
      isLatest: json['is_latest'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'download_url': downloadUrl,
      'file_size': fileSize,
      'release_notes': releaseNotes,
      'is_latest': isLatest,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
