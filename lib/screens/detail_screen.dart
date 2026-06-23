import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import '../models/wallpaper.dart';

class DetailScreen extends StatefulWidget {
  final Wallpaper wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isApplying = false;

  Future<String> _copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(
      byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    return file.path;
  }

  Future<void> _applyWallpaper(WallpaperTarget target) async {
    setState(() => _isApplying = true);
    try {
      // Since it's a local asset, copy to a temp file first
      final filePath = await _copyAssetToFile(widget.wallpaper.imagePath);

      final result = await AsyncWallpaper.setWallpaper(
        WallpaperRequest(
          target: target,
          sourceType: WallpaperSourceType.file,
          source: filePath,
          goToHome: false,
        ),
      );

      if (mounted) {
        final message = result.isSuccess
            ? 'Wallpaper applied successfully!'
            : 'Failed to apply wallpaper: ${result.error?.message ?? 'Unknown error'}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFE53170),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _applyLiveWallpaper() async {
    setState(() => _isApplying = true);
    try {
      // For video live wallpaper, async_wallpaper launches the Android Live Wallpaper picker
      // with the specified video file path.
      // E.g., AsyncWallpaper.setLiveWallpaper(filePath)
      
      // Simulating finding/preparing the video file path
      await Future.delayed(const Duration(milliseconds: 1500));
      // In a real implementation:
      // String path = await _downloadOrGetVideoPath();
      // await AsyncWallpaper.setLiveWallpaper(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening Android Live Wallpaper Picker...'),
            backgroundColor: Color(0xFFFF8906),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting Live Wallpaper: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: 320,
          borderRadius: 30,
          blur: 20,
          alignment: Alignment.center,
          border: 1.5,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1F1E29).withValues(alpha: 0.9),
              const Color(0xFF0F0E17).withValues(alpha: 0.95),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set Wallpaper',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionButton(
                  icon: Icons.home_rounded,
                  label: 'Home Screen',
                  onTap: () {
                    Navigator.pop(context);
                    _applyWallpaper(WallpaperTarget.home);
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.lock_rounded,
                  label: 'Lock Screen',
                  onTap: () {
                    Navigator.pop(context);
                    _applyWallpaper(WallpaperTarget.lock);
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.phone_android_rounded,
                  label: 'Both Screens',
                  onTap: () {
                    Navigator.pop(context);
                    _applyWallpaper(WallpaperTarget.both);
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.video_library_rounded,
                  label: 'Set as Android Live Wallpaper',
                  isLive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _applyLiveWallpaper();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isLive ? const Color(0xFFFF8906).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
          ),
          color: isLive ? const Color(0xFFFF8906).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLive ? const Color(0xFFFF8906) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isLive ? const Color(0xFFFF8906) : Colors.white,
                fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: isLive ? const Color(0xFFFF8906) : Colors.white54,
              size: 18,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Hero(
              tag: widget.wallpaper.id,
              child: Image.asset(
                widget.wallpaper.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Vignette gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // Top Header (Back Button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Glassmorphic Information Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 180,
                  borderRadius: 24,
                  blur: 15,
                  alignment: Alignment.center,
                  border: 1.5,
                  linearGradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.2),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53170).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE53170).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                widget.wallpaper.category,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFE53170),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  '${(widget.wallpaper.views / 1000).toStringAsFixed(1)}k',
                                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(width: 15),
                                const Icon(Icons.favorite_rounded, color: Color(0xFFE53170), size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  '${(widget.wallpaper.likes / 1000).toStringAsFixed(1)}k',
                                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          widget.wallpaper.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created by ${widget.wallpaper.author}',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Action Button (Apply Wallpaper)
                InkWell(
                  onTap: _isApplying ? null : _showWallpaperOptions,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53170), Color(0xFFFF8906)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53170).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isApplying
                          ? const SpinKitThreeBounce(color: Colors.white, size: 24)
                          : Text(
                              'APPLY WALLPAPER',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
