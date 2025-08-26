import 'package:flutter/material.dart';
import 'package:steam_api_app/pages/game_achievements_page.dart';

class GameWithAchievementsTile extends StatelessWidget {
  final int appId;
  final String name;
  final String imgIconUrl;
  final int totalAchievemets;
  final int completedAchievements;
  final double percent;

  const GameWithAchievementsTile({
    super.key,
    required this.appId,
    required this.name,
    required this.imgIconUrl,
    required this.totalAchievemets,
    required this.completedAchievements,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    String imgUrl =
        'https://images.weserv.nl/?url=https://media.steampowered.com/steamcommunity/public/images/apps/$appId/$imgIconUrl.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameAchievementsPage(appId: appId, name: name),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.9),
                Colors.green.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surfaceContainer,
                Theme.of(context).colorScheme.surfaceContainer,
              ],
              stops: [0, percent, percent, 1],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(name),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                height: 30,
                width: 30,
                child: Image.network(
                  imgUrl,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Icon(
                      Icons.videogame_asset,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    );
                  },
                ),
              ),
            ),
            subtitle: Text('$completedAchievements / $totalAchievemets'),
            trailing: completedAchievements == totalAchievemets && totalAchievemets != 0
                ? Icon(Icons.emoji_events, color: Colors.amber.withValues(alpha: 0.9))
                : Icon(Icons.emoji_events),
          ),
        ),
      ),
    );
  }
}
