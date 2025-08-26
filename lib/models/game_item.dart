class GameItem {
  final int appId;
  final String name;
  final int playtimeForever;
  final String imgIconUrl;
  final DateTime lastPlayed;

  GameItem({
    required this.appId,
    required this.name,
    required this.playtimeForever,
    required this.imgIconUrl,
    required this.lastPlayed,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    DateTime lastPlayed;
    if (json['rtime_last_played'] != null) {
      lastPlayed = DateTime.fromMillisecondsSinceEpoch(json['rtime_last_played'] * 1000);
    } else {
      lastPlayed = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return GameItem(
      appId: json['appid'],
      name: json['name'],
      playtimeForever: json['playtime_forever'],
      imgIconUrl: json['img_icon_url'],
      lastPlayed: lastPlayed,
    );
  }
}
