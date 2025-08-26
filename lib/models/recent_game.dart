class RecentGame {
  final String name;
  final int playtime2weeks;
  final int playtimeForever;
  final String imgIconUrl;
  final int appId;

  RecentGame({
    required this.name,
    required this.playtime2weeks,
    required this.playtimeForever,
    required this.imgIconUrl,
    required this.appId,
  });

  factory RecentGame.fromJson(Map<String, dynamic> json) {
    return RecentGame(
      name: json['name'],
      playtime2weeks: json['playtime_2weeks'],
      playtimeForever: json['playtime_forever'],
      imgIconUrl: json['img_icon_url'],
      appId: json['appid'],
    );
  }
}
