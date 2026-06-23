import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/wallpaper.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = ['All', 'Cyberpunk', 'Landscape', 'Character', 'Fantasy'];

  final List<Wallpaper> wallpapers = [
    Wallpaper(
      id: '1',
      title: 'Neon Cyberpunk Samurai',
      category: 'Cyberpunk',
      imagePath: 'assets/images/anime_cyberpunk.png',
      author: 'Akihiro Studio',
      views: 12400,
      likes: 3820,
    ),
    Wallpaper(
      id: '2',
      title: 'Breathtaking Cloud Valley',
      category: 'Landscape',
      imagePath: 'assets/images/anime_landscape.png',
      author: 'Makoto Art',
      views: 8900,
      likes: 2150,
    ),
    Wallpaper(
      id: '3',
      title: 'Spirit Warrior Kyra',
      category: 'Character',
      imagePath: 'assets/images/anime_character.png',
      author: 'Zenith Design',
      views: 15600,
      likes: 4980,
    ),
  ];

  List<Wallpaper> get filteredWallpapers {
    return wallpapers.where((wp) {
      final matchesCategory = selectedCategory == 'All' || wp.category == selectedCategory;
      final matchesSearch = wp.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          wp.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Stack(
        children: [
          // Background soft glowing gradients
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8906).withValues(alpha: 0.15),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53170).withValues(alpha: 0.15),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium App Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OtakuWalls',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Premium Anime Live Wallpapers',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFF1F1E29),
                            child: Icon(Icons.person_outline, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 55,
                      borderRadius: 16,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 1.5,
                      linearGradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.03),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search anime wallpapers...',
                          hintStyle: GoogleFonts.inter(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),

                // Categories Selector
                SliverToBoxAdapter(
                  child: Container(
                    height: 45,
                    margin: const EdgeInsets.only(top: 25, bottom: 15),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkWell(
                            onTap: () => setState(() => selectedCategory = cat),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFFE53170), Color(0xFFFF8906)],
                                      )
                                    : null,
                                color: isSelected ? null : const Color(0xFF1F1E29),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Wallpaper Grid
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final wp = filteredWallpapers[index];
                        return Hero(
                          tag: wp.id,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(wallpaper: wp),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                image: DecorationImage(
                                  image: AssetImage(wp.imagePath),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Gradient Overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Details on Card
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          wp.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // BUNGKUS DENGAN EXPANDED
    Expanded(
      child: Text(
        'By ${wp.author}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: Colors.white60,
          fontSize: 11,
        ),
      ),
    ),
    const SizedBox(width: 8), // Beri sedikit jarak agar tidak terlalu rapat
    Row(
      children: [
        const Icon(Icons.favorite_rounded, color: Color(0xFFE53170), size: 12),
        const SizedBox(width: 3),
        Text(
          '${(wp.likes / 1000).toStringAsFixed(1)}k',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    )
  ],
)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredWallpapers.length,
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
