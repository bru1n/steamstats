class PlayerSummary {
  final String steamId;
  final String personaName;
  final String avatarUrl;
  final DateTime? lastLogOffDate;
  final String personaState;
  final int communityvisibilitystate;

  PlayerSummary({
    required this.steamId,
    required this.personaName,
    required this.avatarUrl,
    this.lastLogOffDate,
    required this.personaState,
    required this.communityvisibilitystate,
  });

  factory PlayerSummary.fromJson(Map<String, dynamic> json) {
    var personaState = '';
    switch (json['personastate']) {
      case 0:
        personaState = 'Offline';
      case 1:
        personaState = 'Online';
      case 2:
        personaState = 'Busy';
      case 3:
        personaState = 'Away';
      case 4:
        personaState = 'Snooze';
      case 5:
        personaState = 'looking to trade';
      case 6:
        personaState = 'looking to play';
    }

    DateTime? lastLogOffDate;
    if (json['lastlogoff'] != null) {
      lastLogOffDate = DateTime.fromMillisecondsSinceEpoch(json['lastlogoff'] * 1000);
    }

    String proxyAvatarUrl(String originalUrl) {
      final Uri originalUri = Uri.parse(originalUrl);
      return 'https://images.weserv.nl/?url=${originalUri.host}${originalUri.path}';
    }

    return PlayerSummary(
      steamId: json['steamid'],
      personaName: json['personaname'],
      avatarUrl: proxyAvatarUrl(json['avatarfull']),
      lastLogOffDate: lastLogOffDate,
      personaState: personaState,
      communityvisibilitystate: json['communityvisibilitystate'],
    );
  }
}
