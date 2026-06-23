class Wallpaper {
  final String id;
  final String title;
  final String category;
  final String imagePath; // Local asset path
  final String? networkUrl; // Network fallback
  final String? videoPath; // For live video wallpaper
  final String author;
  final int views;
  final int likes;

  Wallpaper({
    required this.id,
    required this.title,
    required this.category,
    required this.imagePath,
    this.networkUrl,
    this.videoPath,
    required this.author,
    required this.views,
    required this.likes,
  });
}
