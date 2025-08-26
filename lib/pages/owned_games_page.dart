import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steam_api_app/components/game_item_tile.dart';
import 'package:steam_api_app/components/my_drawer.dart';
import 'package:steam_api_app/components/my_textfield.dart';
import 'package:steam_api_app/components/no_data_scaffold.dart';
import 'package:steam_api_app/models/game_item.dart';
import 'package:steam_api_app/services/steam_provider.dart';
import 'package:steam_api_app/services/steam_service.dart';

class OwnedGamesPage extends StatefulWidget {
  const OwnedGamesPage({super.key});

  @override
  State<OwnedGamesPage> createState() => _OwnedGamesPageState();
}

class _OwnedGamesPageState extends State<OwnedGamesPage> {
  final _steamService = SteamService();
  List<GameItem> _games = [];
  List<GameItem> _gamesFiltered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _lastSortCriteria = 'Time';
  bool _isAscending = true;
  int? _expandedTileIndex;

  _fetchGames() async {
    if (!mounted) return;
    setState(() {
      _games.clear();
      _isLoading = true;
    });

    try {
      final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

      List<GameItem> games = await _steamService.getOwnedGames(steamId!);

      games.sort((a, b) => b.playtimeForever.compareTo(a.playtimeForever));

      if (!mounted) return;

      setState(() {
        _games = games;
        _gamesFiltered = _games;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching games: $e");
    }
  }

  void _sortItems(String criteria) {
    setState(() {
      if (criteria == 'Date') {
        if (_isAscending) {
          _gamesFiltered.sort((a, b) => b.lastPlayed.compareTo(a.lastPlayed));
        } else {
          _gamesFiltered.sort((a, b) => a.lastPlayed.compareTo(b.lastPlayed));
        }
        _lastSortCriteria = 'Date';
      } else if (criteria == 'Time') {
        if (_isAscending) {
          _gamesFiltered.sort((a, b) => b.playtimeForever.compareTo(a.playtimeForever));
        } else {
          _gamesFiltered.sort((a, b) => a.playtimeForever.compareTo(b.playtimeForever));
        }
        _lastSortCriteria = 'Time';
      }
    });
  }

  void _filterList(String query) {
    setState(() {
      _gamesFiltered =
          _games.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchGames();
      }
    });
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
      if (_games.isEmpty) {
        return NoDataScaffold(
            title: 'Owned Games',
            refreshFunction: _fetchGames,
            description: 'Choose another user.');
      } else {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text(
                'Owned Games',
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
                    _fetchGames();
                  },
                ),
              ],
            ),
            drawer: MyDrawer(),
            drawerEdgeDragWidth: 16,
            body: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.all(16),
              itemCount: _gamesFiltered.length + 1,
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
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text(
                                  'Sort by:',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              PopupMenuDivider(height: 2),
                              PopupMenuItem(
                                child: Text('Date'),
                                onTap: () {
                                  _sortItems('Date');
                                },
                              ),
                              PopupMenuItem(
                                child: Text('Hours'),
                                onTap: () {
                                  _sortItems('Time');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final game = _gamesFiltered[index - 1];
                return GameItemTile(
                  appId: game.appId,
                  name: game.name,
                  playtimeForever: game.playtimeForever,
                  imgIconUrl: game.imgIconUrl,
                  lastPlayed: game.lastPlayed,
                  isExpanded: _expandedTileIndex == index - 1,
                  onTileTapped: () {
                    setState(() {
                      if (_expandedTileIndex == index - 1) {
                        _expandedTileIndex = null;
                      } else {
                        _expandedTileIndex = index - 1;
                      }
                    });
                  },
                );
              },
            ));
      }
    }
  }
}
