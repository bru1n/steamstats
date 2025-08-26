import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steam_api_app/components/info_tile.dart';
import 'package:steam_api_app/components/my_drawer.dart';
import 'package:steam_api_app/components/no_data_scaffold.dart';
import 'package:steam_api_app/components/recent_game_tile.dart';
import 'package:steam_api_app/helper/helper_functions.dart';
import 'package:steam_api_app/models/game_item.dart';
import 'package:steam_api_app/models/player_achievement.dart';
import 'package:steam_api_app/models/player_summary.dart';
import 'package:steam_api_app/models/recent_game.dart';
import 'package:steam_api_app/pages/friend_list_page.dart';
import 'package:steam_api_app/pages/owned_games_page.dart';
import 'package:steam_api_app/pages/player_achievements_page.dart';
import 'package:steam_api_app/services/steam_provider.dart';
import 'package:steam_api_app/services/steam_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PlayerSummaryPage extends StatefulWidget {
  const PlayerSummaryPage({super.key});

  @override
  State<PlayerSummaryPage> createState() => _PlayerSummaryPageState();
}

class _PlayerSummaryPageState extends State<PlayerSummaryPage> {
  final _steamService = SteamService();
  List<PlayerSummary> _playerSummary = [];

  bool _isLoading = true;

  Future<int> _fetchAchievementsCount() async {
    int achievementsCount = 0;
    final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

    try {
      List<GameItem> games = await _steamService.getOwnedGames(steamId!);
      if (!mounted) return 0;

      for (var eachGame in games) {
        List<PlayerAchievement> achievements =
            await _steamService.getPlayerAchievements(steamId, eachGame.appId);
        if (!mounted) return 0;

        for (var eachAchievement in achievements) {
          if (eachAchievement.achieved) {
            achievementsCount += 1;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching achievements count: $e");
    }

    return achievementsCount;
  }

  Future<int> _fetchFriendsCount() async {
    List<String> friends = [];
    final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

    try {
      friends = await _steamService.getFriendList(steamId!);
    } catch (e) {
      if (!mounted) return 0;
      displayMessageToUser(e.toString(), context, duration: 3000);
      debugPrint("Error fetching friends count: $e");
    }
    return friends.length;
  }

  Future<int> _fetchGamesCount() async {
    List<GameItem> games = [];
    final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

    try {
      games = await _steamService.getOwnedGames(steamId!);
    } catch (e) {
      debugPrint("Error fetching games count: $e");
    }
    return games.length;
  }

  Future<List<RecentGame>> _fetchRecentGames() async {
    List<RecentGame> recentGames = [];
    final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

    try {
      recentGames = await _steamService.getRecentlyPlayedGames(steamId!);
    } catch (e) {
      debugPrint("Error fetching recent games: $e");
    }
    return recentGames;
  }

  Future<int> _fetchSteamLevel() async {
    int steamLevel = 0;
    final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

    try {
      steamLevel = await _steamService.getSteamLevel(steamId!);
    } catch (e) {
      debugPrint("Error fetching steam level: $e");
    }

    return steamLevel;
  }

  Color getLevelColor(int level) {
    int modLevel = level % 100;

    if (modLevel >= 0 && modLevel < 10) return Color(0xFF979797);
    if (modLevel >= 10 && modLevel < 20) return Color(0xFFBE2942);
    if (modLevel >= 20 && modLevel < 30) return Color(0xFFD75A43);
    if (modLevel >= 30 && modLevel < 40) return Color(0xFFEFC023);
    if (modLevel >= 40 && modLevel < 50) return Color(0xFF46793C);
    if (modLevel >= 50 && modLevel < 60) return Color(0xFF4B86CE);
    if (modLevel >= 60 && modLevel < 70) return Color(0xFF7250C2);
    if (modLevel >= 70 && modLevel < 80) return Color(0xFFBB50C2);
    if (modLevel >= 80 && modLevel < 90) return Color(0xFF522436);
    if (modLevel >= 90 && modLevel < 100) return Color(0xFF947850);

    return Colors.grey;
  }

  _fetchPlayerSummary() async {
    if (!mounted) return;

    setState(() {
      _playerSummary.clear();
      _isLoading = true;
    });

    try {
      final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

      if (steamId == null) throw 'User not set';

      List<PlayerSummary> playerSummary = await _steamService.getPlayerSummary([steamId]);

      if (playerSummary[0].communityvisibilitystate != 3) throw 'Your profile is private!';

      if (!mounted) return;

      setState(() {
        _playerSummary = playerSummary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      displayMessageToUser(e.toString(), context, duration: 3000);
      debugPrint("Error fetching player summary: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPlayerSummary();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        drawer: const MyDrawer(),
        drawerEdgeDragWidth: 16,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      if (_playerSummary.isEmpty) {
        return NoDataScaffold(
            title: 'Profile',
            refreshFunction: _fetchPlayerSummary,
            description: 'Go to settings and set user ID.');
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _fetchPlayerSummary();
                },
              ),
            ],
          ),
          drawer: const MyDrawer(),
          drawerEdgeDragWidth: 16,
          body: ListView(
            padding: EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      _playerSummary[0].avatarUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 150,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.broken_image,
                            size: 150,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              _playerSummary[0].personaName,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 5),
                            FutureBuilder<int>(
                              future: _fetchSteamLevel(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: getLevelColor(snapshot.data!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${snapshot.data}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Text('');
                                }
                              },
                            )
                          ],
                        ),
                        Row(
                          children: [
                            switch (_playerSummary[0].personaState) {
                              'Online' => Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.green.withValues(alpha: 0.9),
                                ),
                              'Away' => Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.yellow.withValues(alpha: 0.9),
                                ),
                              'Snooze' => Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.yellow.withValues(alpha: 0.9),
                                ),
                              'Busy' => Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.red.withValues(alpha: 0.9),
                                ),
                              _ => Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.grey.withValues(alpha: 0.9),
                                ),
                            },
                            SizedBox(width: 5),
                            Text(_playerSummary[0].personaState),
                          ],
                        ),
                        if (_playerSummary[0].personaState == 'Offline' &&
                            _playerSummary[0].lastLogOffDate != null)
                          Text(
                            'Last online ${timeago.format(_playerSummary[0].lastLogOffDate!)}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendListPage(),
                      ));
                },
                child: InfoTile(
                  title: Text(
                    'Friends',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: FutureBuilder<int>(
                    future: _fetchFriendsCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          '${snapshot.data}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        );
                      }
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnedGamesPage(),
                      ));
                },
                child: InfoTile(
                  title: Text(
                    'Games',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: FutureBuilder<int>(
                    future: _fetchGamesCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          '${snapshot.data}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        );
                      }
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerAchievementsPage(),
                      ));
                },
                child: InfoTile(
                  title: Text(
                    'Achievements',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: FutureBuilder<int>(
                    future: _fetchAchievementsCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          '${snapshot.data}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        );
                      }
                    },
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                    height: 40,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Text(
                      'Recently played games: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
              FutureBuilder<List<RecentGame>>(
                future: _fetchRecentGames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SizedBox();
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final recentGame = snapshot.data![index];

                        return RecentGameTile(
                          name: recentGame.name,
                          playtime2weeks: recentGame.playtime2weeks,
                          playtimeForever: recentGame.playtimeForever,
                          imgIconUrl: recentGame.imgIconUrl,
                          appId: recentGame.appId,
                        );
                      },
                    );
                  }
                },
              )
            ],
          ),
        );
      }
    }
  }
}
