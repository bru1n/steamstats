class GlobalAchievement {
  final String name;
  final String percent;

  GlobalAchievement({
    required this.name,
    required this.percent,
  });

  factory GlobalAchievement.fromJson(Map<String, dynamic> json) {
    return GlobalAchievement(
      name: json['name'],
      percent: json['percent'],
    );
  }
}
