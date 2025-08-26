import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steam_api_app/components/friend_tile.dart';
import 'package:steam_api_app/components/my_drawer.dart';
import 'package:steam_api_app/components/my_textfield.dart';
import 'package:steam_api_app/components/no_data_scaffold.dart';
import 'package:steam_api_app/helper/helper_functions.dart';
import 'package:steam_api_app/models/player_summary.dart';
import 'package:steam_api_app/services/steam_provider.dart';
import 'package:steam_api_app/services/steam_service.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final _steamService = SteamService();
  List<String> _friends = [];
  List<PlayerSummary> _friendsSummary = [];
  List<PlayerSummary> _friendsSummaryFiltered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  _fetchFriends() async {
    if (!mounted) return;
    setState(() {
      _friends.clear();
      _isLoading = true;
    });
    try {
      final steamId = Provider.of<SteamProvider>(context, listen: false).steamId;

      List<String> friends = await _steamService.getFriendList(steamId!);
      List<PlayerSummary> friendsSummary = await _steamService.getPlayerSummary(friends);

      friendsSummary.sort((a, b) => a.personaName.compareTo(b.personaName));

      friendsSummary.sort((a, b) {
        const stateOrder = {
          'Online': 0,
          'Away': 1,
          'Snooze': 2,
          'Busy': 3,
          'Offline': 4,
        };
        return (stateOrder[a.personaState] ?? 5).compareTo(stateOrder[b.personaState] ?? 5);
      });
      if (!mounted) return;

      setState(() {
        _friendsSummary = friendsSummary;
        _friendsSummaryFiltered = _friendsSummary;
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      displayMessageToUser(e.toString(), context, duration: 3000);
      debugPrint("Error fetching friends: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterList(String query) {
    setState(() {
      _friendsSummaryFiltered = _friendsSummary
          .where((item) => item.personaName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchFriends();
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
      if (_friends.isEmpty) {
        return NoDataScaffold(
          title: 'Friend List',
          refreshFunction: _fetchFriends,
          description: 'Choose another user.',
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text(
              'Friend List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _fetchFriends();
                },
              ),
            ],
          ),
          drawer: const MyDrawer(),
          drawerEdgeDragWidth: 16,
          body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _friendsSummaryFiltered.length + 1,
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

              final friend = _friendsSummaryFiltered[index - 1];
              return FriendTile(
                personaName: friend.personaName,
                avatarUrl: friend.avatarUrl,
                personaState: friend.personaState,
                lastLogOffDate: friend.lastLogOffDate,
                color: switch (friend.personaState) {
                  'Online' => Colors.green.withValues(alpha: 0.9),
                  'Away' => Colors.yellow.withValues(alpha: 0.9),
                  'Snooze' => Colors.yellow.withValues(alpha: 0.9),
                  'Busy' => Colors.red.withValues(alpha: 0.9),
                  _ => Colors.grey.withValues(alpha: 0.9),
                },
                steamId: friend.steamId,
              );
            },
          ),
        );
      }
    }
  }
}
