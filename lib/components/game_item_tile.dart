import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:steam_api_app/pages/game_achievements_page.dart';
import 'package:steam_api_app/pages/news_for_app_page.dart';

class GameItemTile extends StatelessWidget {
  final int appId;
  final String name;
  final int playtimeForever;
  final String imgIconUrl;
  final DateTime lastPlayed;
  final bool isExpanded;
  final VoidCallback onTileTapped;

  const GameItemTile({
    super.key,
    required this.appId,
    required this.name,
    required this.playtimeForever,
    required this.imgIconUrl,
    required this.lastPlayed,
    required this.isExpanded,
    required this.onTileTapped,
  });

  String formatPlaytime(int playtime) {
    final hours = playtime ~/ 60;
    final minutes = playtime % 60;
    return '$hours h $minutes m';
  }

  @override
  Widget build(BuildContext context) {
    String imgUrl =
        'https://images.weserv.nl/?url=https://media.steampowered.com/steamcommunity/public/images/apps/$appId/$imgIconUrl.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(name),
              onTap: onTileTapped,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(5),
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  lastPlayed != DateTime.fromMillisecondsSinceEpoch(0)
                      ? Text('Total playtime: ${formatPlaytime(playtimeForever)}')
                      : SizedBox(),
                  lastPlayed != DateTime.fromMillisecondsSinceEpoch(0)
                      ? Text('Last played: ${DateFormat('dd MMMM yyyy').format(lastPlayed)}')
                      : Text('No recorded activity'),
                ],
              ),
              trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              child: ConstrainedBox(
                constraints: isExpanded ? BoxConstraints() : BoxConstraints(maxHeight: 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsForAppPage(appId: appId, name: name),
                            ),
                          );
                        },
                        child: Text(
                          'News',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameAchievementsPage(appId: appId, name: name),
                            ),
                          );
                        },
                        child: Text(
                          'Achievements',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
