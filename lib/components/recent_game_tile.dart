import 'package:flutter/material.dart';
import 'package:steam_api_app/pages/game_achievements_page.dart';
import 'package:steam_api_app/pages/news_for_app_page.dart';

class RecentGameTile extends StatefulWidget {
  final String name;
  final int playtime2weeks;
  final int playtimeForever;
  final String imgIconUrl;
  final int appId;

  const RecentGameTile({
    super.key,
    required this.name,
    required this.playtime2weeks,
    required this.playtimeForever,
    required this.imgIconUrl,
    required this.appId,
  });

  @override
  State<RecentGameTile> createState() => _RecentGameTileState();
}

class _RecentGameTileState extends State<RecentGameTile> {
  bool _isExpanded = false;

  String formatPlaytime(int playtime) {
    final hours = playtime ~/ 60;
    final minutes = playtime % 60;
    return '$hours h $minutes m';
  }

  @override
  Widget build(BuildContext context) {
    String imgUrl =
        'https://images.weserv.nl/?url=https://media.steampowered.com/steamcommunity/public/images/apps/${widget.appId}/${widget.imgIconUrl}.jpg';

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
              title: Text(widget.name),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
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
                  widget.playtime2weeks != 0
                      ? Text('Last 2 weeks: ${formatPlaytime(widget.playtime2weeks)}')
                      : SizedBox(),
                  widget.playtimeForever != 0
                      ? Text('Total playtime: ${formatPlaytime(widget.playtimeForever)}')
                      : SizedBox(),
                ],
              ),
              trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              child: ConstrainedBox(
                constraints: _isExpanded ? BoxConstraints() : BoxConstraints(maxHeight: 0),
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
                              builder: (context) =>
                                  NewsForAppPage(appId: widget.appId, name: widget.name),
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
                              builder: (context) =>
                                  GameAchievementsPage(appId: widget.appId, name: widget.name),
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
