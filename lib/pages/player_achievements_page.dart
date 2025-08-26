import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steam_api_app/components/game_with_achievements_tile.dart';
import 'package:steam_api_app/components/my_drawer.dart';
import 'package:steam_api_app/components/my_textfield.dart';
import 'package:steam_api_app/components/no_data_scaffold.dart';
import 'package:steam_api_app/models/game_item.dart';
import 'package:steam_api_app/models/game_with_achievements.dart';
import 'package:steam_api_app/models/player_achievement.dart';
import 'package:steam_api_app/services/steam_provider.dart';
import 'package:steam_api_app/services/steam_service.dart';

class PlayerAchievementsPage extends StatefulWidget {
  const PlayerAchievementsPage({super.key});

  @override
  State<PlayerAchievementsPage> createState() => _PlayerAchievementsPageState();
}

class _PlayerAchievementsPageState extends State<PlayerAchievementsPage> {
  final _steamService = SteamService();
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<GameWithAchievements> _gamesWithAchievements = [];
  List<GameWithAchievements> _gamesWithAchievementsFiltered = [];

  void _fetchGamesWithAchievements() async {
    if (!mounted) return;

    setState(() {
      _gamesWithAchievements.clear();
      _isLoading = true;
    });

    try {
      final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

      List<GameItem> games = await _steamService.getOwnedGames(steamId!);
      List<GameWithAchievements> gamesWithAchievements = [];
      int totalAchievemets = 0;
      int completedAchievements = 0;

      if (!mounted) return;

      for (var eachGame in games) {
        List<PlayerAchievement> achievements =
            await _steamService.getPlayerAchievements(steamId, eachGame.appId);
        for (var eachAchievement in achievements) {
          totalAchievemets += 1;
          if (eachAchievement.achieved) {
            completedAchievements += 1;
          }
        }
        gamesWithAchievements.add(
          GameWithAchievements(
            appId: eachGame.appId,
            name: eachGame.name,
            imgIconUrl: eachGame.imgIconUrl,
            totalAchievemets: totalAchievemets,
            completedAchievements: completedAchievements,
          ),
        );

        gamesWithAchievements.sort((a, b) => b.percent.compareTo(a.percent));

        if (!mounted) return;

        setState(() {
          totalAchievemets = 0;
          completedAchievements = 0;
          _gamesWithAchievements = gamesWithAchievements;
          _gamesWithAchievementsFiltered = gamesWithAchievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching games with achievemnts: $e");
    }
  }

  void _filterList(String query) {
    setState(() {
      _gamesWithAchievementsFiltered = _gamesWithAchievements
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchGamesWithAchievements();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      if (_gamesWithAchievements.isEmpty) {
        return NoDataScaffold(
          title: 'Achievements',
          refreshFunction: _fetchGamesWithAchievements,
          description: 'Choose another user.',
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _fetchGamesWithAchievements();
                },
              )
            ],
          ),
          drawer: MyDrawer(),
          drawerEdgeDragWidth: 16,
          body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _gamesWithAchievementsFiltered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: MyTextfield(
                    controller: _searchController,
                    onChanged: _filterList,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                  ),
                );
              }

              final game = _gamesWithAchievementsFiltered[index - 1];
              return GameWithAchievementsTile(
                appId: game.appId,
                name: game.name,
                imgIconUrl: game.imgIconUrl,
                totalAchievemets: game.totalAchievemets,
                completedAchievements: game.completedAchievements,
                percent: game.percent,
              );
            },
          ),
        );
      }
    }
  }
}
