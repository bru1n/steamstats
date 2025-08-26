class GameWithAchievements {
  final int appId;
  final String name;
  final String imgIconUrl;
  final int totalAchievemets;
  final int completedAchievements;

  GameWithAchievements({
    required this.appId,
    required this.name,
    required this.imgIconUrl,
    required this.totalAchievemets,
    required this.completedAchievements,
  });

  bool get isCompleted => totalAchievemets == completedAchievements && totalAchievemets != 0;

  double get percent => totalAchievemets != 0 ? completedAchievements / totalAchievemets : 0;
}
