import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Style dynamique selon la couleur principale
    final bool isWhite = color == Colors.white || color.value == 0xFFFFFFFF;
    final Color bgColor = isWhite ? Colors.white : color.withOpacity(0.12);
    final Color shadowColor =
        isWhite ? Colors.black26 : color.withOpacity(0.35);

    return Card(
      elevation: 8,
      shadowColor: shadowColor,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isWhite ? 0.12 : 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz_rounded,
                      color: color.withOpacity(0.5)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Plus d’options à venir !')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          delay: Duration(milliseconds: 400 + (title.hashCode % 4) * 100),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        );
  }
}
