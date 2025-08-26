import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steam_api_app/components/info_tile.dart';
import 'package:steam_api_app/components/my_drawer.dart';
import 'package:steam_api_app/components/my_textfield.dart';
import 'package:steam_api_app/components/no_data_scaffold.dart';
import 'package:steam_api_app/models/global_achievement.dart';
import 'package:steam_api_app/models/player_achievement.dart';
import 'package:steam_api_app/models/player_achievement_with_global.dart';
import 'package:steam_api_app/services/steam_provider.dart';
import 'package:steam_api_app/services/steam_service.dart';
import 'package:intl/intl.dart';

class GameAchievementsPage extends StatefulWidget {
  final int appId;
  final String name;

  const GameAchievementsPage({
    super.key,
    required this.appId,
    required this.name,
  });

  @override
  State<GameAchievementsPage> createState() => _GameAchievementsPageState();
}

class _GameAchievementsPageState extends State<GameAchievementsPage> {
  final _steamService = SteamService();
  List<PlayerAchievementWithGlobal> _playerAchievementWithGlobal = [];
  List<PlayerAchievementWithGlobal> _achievementsFiltered = [];
  final TextEditingController _searchController = TextEditingController();
  String _lastSortCriteria = 'Achieved';
  bool _isAscending = true;
  bool _isLoading = true;

  _fetchAchievements() async {
    if (!mounted) return;

    setState(() {
      _playerAchievementWithGlobal.clear();
      _isLoading = true;
    });

    try {
      final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

      List<PlayerAchievement> achievements =
          await _steamService.getPlayerAchievements(steamId!, widget.appId);

      achievements.sort((a, b) => (b.achieved ? 1 : 0).compareTo(a.achieved ? 1 : 0));

      if (!mounted) return;

      List<GlobalAchievement> globalAchievements =
          await _steamService.getGlobalAchievementPercentages(widget.appId);

      if (!mounted) return;

      List<PlayerAchievementWithGlobal> playerAchievementWithGlobal = [];

      for (var eachAchievement in achievements) {
        for (var eachGlobal in globalAchievements) {
          if (eachAchievement.apiName == eachGlobal.name) {
            playerAchievementWithGlobal.add(
              PlayerAchievementWithGlobal(
                achievement: eachAchievement,
                percent: eachGlobal.percent,
              ),
            );
            break;
          }
        }
      }

      setState(() {
        _playerAchievementWithGlobal = playerAchievementWithGlobal;
        _achievementsFiltered = playerAchievementWithGlobal;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching achievemnts: $e');
    }
  }

  void _sortItems(String criteria) {
    setState(() {
      if (criteria == 'Percent') {
        if (_isAscending) {
          _achievementsFiltered
              .sort((a, b) => double.parse(a.percent).compareTo(double.parse(b.percent)));
        } else {
          _achievementsFiltered
              .sort((a, b) => double.parse(b.percent).compareTo(double.parse(a.percent)));
        }
        _lastSortCriteria = 'Percent';
      } else if (criteria == 'Date') {
        if (_isAscending) {
          _achievementsFiltered
              .sort((a, b) => a.achievement.unlockDate.compareTo(b.achievement.unlockDate));
        } else {
          _achievementsFiltered
              .sort((a, b) => b.achievement.unlockDate.compareTo(a.achievement.unlockDate));
        }
        _lastSortCriteria = 'Date';
      } else if (criteria == 'Achieved') {
        if (_isAscending) {
          _achievementsFiltered.sort(
              (a, b) => (a.achievement.achieved ? 1 : 0).compareTo(b.achievement.achieved ? 1 : 0));
        } else {
          _achievementsFiltered.sort(
              (a, b) => (b.achievement.achieved ? 1 : 0).compareTo(a.achievement.achieved ? 1 : 0));
        }
        _lastSortCriteria = 'Achieved';
      }
    });
  }

  void _filterList(String query) {
    setState(() {
      _achievementsFiltered = _playerAchievementWithGlobal
          .where((item) => item.achievement.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
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
      if (_playerAchievementWithGlobal.isEmpty) {
        return NoDataScaffold(
          title: '${widget.name} Achievements',
          refreshFunction: _fetchAchievements,
          description: 'This game has no achievements',
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              '${widget.name} Achievements',
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
                  _fetchAchievements();
                },
              ),
            ],
          ),
          drawer: const MyDrawer(),
          drawerEdgeDragWidth: 16,
          body: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(16),
            itemCount: _achievementsFiltered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: MyTextfield(
                    controller: _searchController,
                    onChanged: _filterList,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                          onPressed: () {
                            setState(() {
                              _isAscending = !_isAscending;
                              _sortItems(_lastSortCriteria);
                            });
                          },
                          tooltip: _isAscending ? 'Sort Ascending' : 'Sort Descending',
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.only(right: 10),
                          color: Theme.of(context).colorScheme.surface,
                          menuPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          icon: Icon(Icons.sort),
                          onSelected: (value) {
                            if (value == 'ToggleOrder') {
                              setState(() {
                                _isAscending = !_isAscending;
                                _sortItems(_lastSortCriteria);
                              });
                            } else {
                              _lastSortCriteria = value;
                              _sortItems(value);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text(
                                'Sort by:',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            PopupMenuDivider(height: 2),
                            PopupMenuItem(
                              child: Text('Global percentage'),
                              onTap: () {
                                _sortItems('Percent');
                              },
                            ),
                            PopupMenuItem(
                              child: Text('Completion date'),
                              onTap: () {
                                _sortItems('Date');
                              },
                            ),
                            PopupMenuItem(
                              child: Text('Achieved'),
                              onTap: () {
                                _sortItems('Achieved');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              final achievement = _achievementsFiltered[index - 1];

              return InfoTile(
                color: achievement.achievement.achieved
                    ? Colors.green.withValues(alpha: 0.9)
                    : Theme.of(context).colorScheme.surfaceContainer,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        achievement.achievement.name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    achievement.achievement.achieved
                        ? const Icon(Icons.check)
                        : const Icon(Icons.close),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    achievement.achievement.description == ''
                        ? const SizedBox()
                        : Column(
                            children: [
                              const SizedBox(height: 5),
                              Text(achievement.achievement.description),
                            ],
                          ),
                    achievement.achievement.achieved
                        ? Column(
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                  'Completed ${DateFormat('dd MMMM yyyy').format(achievement.achievement.unlockDate)}'),
                            ],
                          )
                        : const SizedBox(),
                    SizedBox(height: 5),
                    Text('${achievement.percent}%'),
                  ],
                ),
              );
            },
          ),
        );
      }
    }
  }
}
