import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'game_webview_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Playground',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -50,
            right: -50,
            child: Icon(Icons.star, size: 150, color: Colors.orange.withOpacity(0.05)),
          ),
          Positioned(
            bottom: 50,
            left: -30,
            child: Icon(Icons.circle, size: 100, color: Colors.blue.withOpacity(0.05)),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20), // Reduced from 30
                FadeInDown(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Text(
                          'Fun & Learning Time! 🎮',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pick a game and start the fun',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _GameCardLarge(
                          title: 'Math Man',
                          subtitle: 'Solve math equations Pac-Man style',
                          icon: Icons.calculate_rounded,
                          color: Colors.purple,
                          url: 'https://www.abcya.com/games/math_man',
                          delay: 900,
                        ),
                      ]
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Reduced from 40
                Expanded(
                  child: Padding( // Removed Center to let it start from top
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start, // Align to top
                        children: [
                          _GameCardLarge(
                            title: 'Fuzz Bugs Hop',
                            subtitle: 'Fun jumping & matching game',
                            icon: Icons.sports_esports_rounded,
                            color: Colors.green,
                            url: 'https://www.abcya.com/games/fuzz_bugs_factory_hop',
                            delay: 300,
                          ),
                          const SizedBox(height: 16),
                          _GameCardLarge(
                            title: 'Shapes Geometry',
                            subtitle: 'Explore shapes & geometry',
                            icon: Icons.category_rounded,
                            color: Colors.orange,
                            url: 'https://www.abcya.com/games/mobile/shapes_geometry_game',
                            delay: 700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCardLarge extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String url;
  final int delay;

  const _GameCardLarge({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.url,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameWebViewScreen(
                url: url,
                title: title,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.1), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
