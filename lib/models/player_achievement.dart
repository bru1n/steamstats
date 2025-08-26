class PlayerAchievement {
  final String name;
  final bool achieved;
  final DateTime unlockDate;
  final String description;
  final String apiName;

  PlayerAchievement({
    required this.name,
    required this.achieved,
    required this.unlockDate,
    required this.description,
    required this.apiName,
  });

  factory PlayerAchievement.fromJson(Map<String, dynamic> json) {
    late bool achieved;
    switch (json['achieved']) {
      case 1:
        achieved = true;
      case 0:
        achieved = false;
    }
    return PlayerAchievement(
      name: json['name'],
      achieved: achieved,
      unlockDate: DateTime.fromMillisecondsSinceEpoch(json['unlocktime'] * 1000),
      description: json['description'],
      apiName: json['apiname'],
    );
  }
}
